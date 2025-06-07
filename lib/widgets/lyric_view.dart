// 歌词视图组件
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';
import '../global.dart';
import '../lyric.dart';
import '../settings.dart';

/// 歌词显示主组件
class LyricView extends StatefulWidget {
  final String path; // 音频文件路径
  final double paddingTop; // 顶部内边距
  final double paddingBottom; // 底部内边距

  const LyricView({
    super.key,
    required this.path,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
  });

  @override
  State<LyricView> createState() => _LyricViewState();
}

/// 歌词视图状态管理
class _LyricViewState extends State<LyricView> {
  String text = '';
  Metadata? metadata; // 元数据解析器
  Lyrics? lyrics; // 歌词数据
  final GlobalKey singleChildScrollViewKey = GlobalKey(); // 滚动视图Key
  final GlobalKey columnKey = GlobalKey(); // 列布局Key
  final GlobalKey activeKey = GlobalKey(); // 当前激活歌词Key
  final ScrollController _scrollController = ScrollController(); // 滚动控制器
  int index = -1; // 当前歌词索引

  @override
  void initState() {
    super.initState();
    _init(); // 初始化数据
    _fresh(); // 启动刷新循环
  }

  @override
  void didUpdateWidget(LyricView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      // 路径变化时重新初始化
      lyrics = null;
      if (mounted) setState(() {});
      _init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose(); // 释放滚动控制器
  }

  /// 初始化歌词数据
  Future<void> _init() async {
    metadata = Metadata(widget.path);
    metadata!.getLyric().then((value) {
      setState(() {});
      if (value == null) return;
      lyrics = Lyrics(value);
      lyrics!.parse().then((value) {
        setState(() {});
      });
    });
  }

  /// 定时刷新歌词位置
  Future<void> _fresh() async {
    if (!mounted) return;
    if (lyrics != null) {
      // 计算当前播放位置对应的歌词索引
      int idx = -1;
      for (int i = 0; i < lyrics!.lyrics.length; i++) {
        final lyric = lyrics!.lyrics[i];
        if (Global.player.position.inMilliseconds <= lyric['endTime']) {
          idx = i;
          break;
        }
      }

      // 当歌词索引变化时执行滚动
      if (idx != index && idx != -1) {
        index = idx;
        if (_scrollController.hasClients && lyrics!.lyrics.isNotEmpty) {
          // 获取布局信息用于滚动计算
          RenderBox? singleChildRenderBox =
              singleChildScrollViewKey.currentContext?.findRenderObject()
                  as RenderBox?;
          RenderBox? columnRenderBox =
              columnKey.currentContext?.findRenderObject() as RenderBox?;
          RenderBox? targetRenderBox =
              activeKey.currentContext?.findRenderObject() as RenderBox?;

          if (singleChildRenderBox != null &&
              columnRenderBox != null &&
              targetRenderBox != null) {
            // 计算目标歌词的相对位置
            Offset childPosition = targetRenderBox.globalToLocal(
              Offset.zero,
              ancestor: columnRenderBox,
            );
            // 执行平滑滚动
            _scrollController.animateTo(
              min(
                max(
                  _scrollController.position.minScrollExtent,
                  (-childPosition.dy) - (targetRenderBox.size.height * 1),
                ),
                _scrollController.position.maxScrollExtent,
              ),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      }
    }
    setState(() {});
    // 每10ms循环刷新
    Future.delayed(Duration(milliseconds: 10), () {
      _fresh();
    });
  }

  /// 构建嵌套歌词结构（带模糊效果）
  Widget buildNestedLyrics(int startIndex, int endIndex) {
    if (startIndex >= lyrics!.lyrics.length) return const SizedBox.shrink();

    final currentLyric = lyrics!.lyrics[startIndex];

    if (startIndex >= endIndex) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 当前歌词项
        LyricWidget(
          key: startIndex == index ? activeKey : null,
          ctx: currentLyric['content'],
          startTime: currentLyric['startTime'],
          endTime: currentLyric['endTime'],
          lyric: currentLyric['lyric'],
        ),
        // 模糊层包裹后续歌词
        ClipRect(
          child: Stack(
            children: [
              buildNestedLyrics(startIndex + 1, endIndex), // 递归构建
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(color: Colors.transparent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Settings.lyricBlur) {
      return lyrics == null
          ? Text('正在加载歌词...')
          : SingleChildScrollView(
            key: singleChildScrollViewKey,
            controller: _scrollController,
            physics: NeverScrollableScrollPhysics(), // 禁用用户滚动
            child: Column(
              key: columnKey,
              children: [
                SizedBox(height: widget.paddingTop),
                for (int i = 0; i < lyrics!.lyrics.length; i++)
                  LyricWidget(
                    key: i == index ? activeKey : null,
                    ctx: lyrics!.lyrics[i]['content'],
                    startTime: lyrics!.lyrics[i]['startTime'],
                    endTime: lyrics!.lyrics[i]['endTime'],
                    lyric: lyrics!.lyrics[i]['lyric'],
                  ),
                SizedBox(height: widget.paddingBottom),
              ],
            ),
          );
    }
    final List<Widget> widgets = []; // 普通歌词组件列表
    final List<Widget> widgets2 = []; // 模糊歌词组件列表

    // 构建歌词列表
    for (int i = 0; i <= index; i++) {
      if (i >= index - 5 && i <= index) {
        // 最近5句添加模糊效果
        widgets2.add(
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: LyricWidget(
              key: i == index ? activeKey : null,
              ctx: lyrics!.lyrics[i]['content'],
              startTime: lyrics!.lyrics[i]['startTime'],
              endTime: lyrics!.lyrics[i]['endTime'],
              lyric: lyrics!.lyrics[i]['lyric'],
            ),
          ),
        );
      } else {
        // 普通歌词项
        widgets.add(
          LyricWidget(
            key: i == index ? activeKey : null,
            ctx: lyrics!.lyrics[i]['content'],
            startTime: lyrics!.lyrics[i]['startTime'],
            endTime: lyrics!.lyrics[i]['endTime'],
            lyric: lyrics!.lyrics[i]['lyric'],
          ),
        );
      }
    }

    return lyrics == null
        ? Text('正在加载歌词...')
        : SingleChildScrollView(
          key: singleChildScrollViewKey,
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(), // 禁用用户滚动
          child: Column(
            key: columnKey,
            children: [
              SizedBox(height: widget.paddingTop),
              ...widgets, // 展开普通歌词
              ClipRect(child: Column(children: widgets2)), // 模糊歌词区域
              buildNestedLyrics(index + 1, index + 12), // 构建后续歌词
              SizedBox(height: widget.paddingBottom),
            ],
          ),
        );
  }
}

// 单个歌词组件
class LyricWidget extends StatelessWidget {
  final String ctx; // 歌词内容
  final int startTime; // 开始时间
  final int endTime; // 结束时间
  final List<Map<String, dynamic>> lyric; // 分词数据
  final double fontSize; // 字体大小

  const LyricWidget({
    super.key,
    required this.ctx,
    required this.startTime,
    required this.endTime,
    required this.lyric,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Wrap(
          children: [
            for (final word in lyric)
              Padding(
                key: ValueKey(word),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Word(
                  word: word['word'],
                  startTime: word['startTime'],
                  endTime: word['endTime'],
                  currentTime: Global.player.position.inMilliseconds,
                  fontSize: fontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 单个文字组件
class Word extends StatelessWidget {
  final String word; // 文字内容
  final int startTime; // 开始时间
  final int endTime; // 结束时间
  final int currentTime; // 当前时间
  final double fontSize; // 字体大小
  static const double padding = 1.0; // 动态间距

  const Word({
    super.key,
    required this.word,
    required this.startTime,
    required this.endTime,
    required this.currentTime,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentTime >= startTime && currentTime <= endTime;

    Widget text = Container();
    if (!isActive) {
      // 非激活状态样式
      text = Text(
        word,
        style: TextStyle(
          color:
              currentTime > startTime
                  ? Global.playerTheme.colorScheme.primary
                  : Global.playerTheme.colorScheme.onSurface.withValues(
                    alpha: .6,
                  ),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      // 激活状态渐变效果
      text = ShaderMask(
        shaderCallback:
            (bounds) => LinearGradient(
              colors: [
                Global.playerTheme.colorScheme.primary,
                Global.playerTheme.colorScheme.onSurface.withValues(alpha: .6),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (currentTime - startTime) / (endTime - startTime) - 0.1,
                (currentTime - startTime) / (endTime - startTime) + 0.1,
              ],
            ).createShader(bounds),
        child: Text(
          word,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top:
            padding *
            Curves.easeInOut.transform(
              max(
                0,
                min(1 - (currentTime - startTime) / (endTime - startTime), 1),
              ),
            ),
        bottom:
            padding *
            Curves.easeInOut.transform(
              max(0, min((currentTime - startTime) / (endTime - startTime), 1)),
            ),
      ),
      child: text,
    );
  }
}

// 简易歌词组件（备用）
class LyricEasyWidget extends StatelessWidget {
  final String ctx;
  final int startTime;
  final int endTime;
  final List<Map<String, dynamic>> lyric;
  final double fontSize;

  const LyricEasyWidget({
    super.key,
    required this.ctx,
    required this.startTime,
    required this.endTime,
    required this.lyric,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final word in lyric)
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    Global.playerTheme.colorScheme.primary,
                    Global.playerTheme.colorScheme.onSurface.withValues(
                      alpha: .6,
                    ),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    (Global.player.position.inMilliseconds -
                                word['startTime']) /
                            (word['endTime'] - word['startTime']) -
                        0.1,
                    (Global.player.position.inMilliseconds -
                                word['startTime']) /
                            (word['endTime'] - word['startTime']) +
                        0.1,
                  ],
                ).createShader(bounds),
            child: Text(
              word['word'],
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
          ),
      ],
    );
  }
}
