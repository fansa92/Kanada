import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';
import '../global.dart';
import '../lyric.dart';

class LyricView extends StatefulWidget {
  // static Color primaryColor = Colors.red;
  // static Color secondaryColor = Colors.blue;
  final String path;
  final double paddingTop;
  final double paddingBottom;

  // final EdgeInsets padding;

  const LyricView({
    super.key,
    required this.path,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
  });

  @override
  State<LyricView> createState() => _LyricViewState();
}

class _LyricViewState extends State<LyricView> {
  String text = '';
  Metadata? metadata;
  Lyrics? lyrics;
  final GlobalKey singleChildScrollViewKey = GlobalKey();
  final GlobalKey columnKey = GlobalKey();
  final GlobalKey activeKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  int index = -1;
  final List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    _init();
    // LyricView.primaryColor = Theme.of(context).colorScheme.primary;
    // LyricView.secondaryColor = Theme.of(context).colorScheme.secondary;
    // 初始化位置监听
    // _positionSub = Global.player.positionStream.listen((position) {
    //   if (mounted) setState(() {});
    // });
    _fresh();
  }

  @override
  void didUpdateWidget(LyricView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      // 路径变化时执行重新初始化
      lyrics = null;
      if (mounted) setState(() {});
      _init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    // _positionSub?.cancel();
    _scrollController.dispose();
  }

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

  Future<void> _fresh() async {
    if (!mounted) return;
    if (lyrics != null) {
      int idx = -1;
      for (int i = 0; i < lyrics!.lyrics.length; i++) {
        final lyric = lyrics!.lyrics[i];
        if (Global.player.position.inMilliseconds <= lyric['endTime']) {
          idx = i;
          break;
        }
      }
      if (idx != index && idx != -1) {
        // print('idx: $idx');
        index = idx;
        if (_scrollController.hasClients && lyrics!.lyrics.isNotEmpty) {
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
            // 将子组件的全局坐标转换为相对于 Column 的坐标
            Offset childPosition = targetRenderBox.globalToLocal(
              Offset.zero,
              ancestor: columnRenderBox,
            );
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
    Future.delayed(Duration(milliseconds: 10), () {
      _fresh();
    });
  }

  Widget buildNestedLyrics(int startIndex, int endIndex) {
    if (startIndex >= lyrics!.lyrics.length) return const SizedBox.shrink();

    final currentLyric = lyrics!.lyrics[startIndex];

    if (startIndex >= endIndex) {
      return Column(
        children: [
          for (int i = startIndex; i < lyrics!.lyrics.length; i++)
            LyricWidget(
              key: startIndex == index ? activeKey : null,
              ctx: lyrics!.lyrics[i]['content'],
              startTime: lyrics!.lyrics[i]['startTime'],
              endTime: lyrics!.lyrics[i]['endTime'],
              lyric: lyrics!.lyrics[i]['lyric'],
            ),
        ],
      );
    }

    return Column(
      children: [
        LyricWidget(
          key: startIndex == index ? activeKey : null,
          ctx: currentLyric['content'],
          startTime: currentLyric['startTime'],
          endTime: currentLyric['endTime'],
          lyric: currentLyric['lyric'],
        ),
        ClipRect(
          child: Stack(
            children: [
              // 递归调用构建下一个歌词
              buildNestedLyrics(startIndex + 1, endIndex),
              // 模糊层覆盖在后续歌词上方
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
    print('lyrics: ${lyrics?.lyrics.length} index: $index');
    widgets.clear();
    for (int i = 0; i < lyrics!.lyrics.length; i++) {
      if (i >= index - 3 && i <= index) {
        widgets.add(
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
      } else if (i > index) {
        // 从 index+1 开始递归构建
        if (i == index + 1) {
          widgets.add(buildNestedLyrics(i, i + 8));
        }
        break; // 后续项由递归处理
      } else {
        // if (i == index || i == index + 1) {
        //   print('-----i: $i index: $index');
        // }
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
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            key: columnKey,
            children: [
              SizedBox(height: widget.paddingTop),
              for (int i = 0; i < widgets.length; i++) widgets[i],
              SizedBox(height: widget.paddingBottom),
            ],
          ),
        );
  }
}

class LyricWidget extends StatelessWidget {
  final String ctx;
  final int startTime;
  final int endTime;
  final List<Map<String, dynamic>> lyric;

  const LyricWidget({
    super.key,
    required this.ctx,
    required this.startTime,
    required this.endTime,
    required this.lyric,
  });

  @override
  Widget build(BuildContext context) {
    // final bool active =
    //     Global.player.position.inMilliseconds >= startTime &&
    //         Global.player.position.inMilliseconds <= endTime;
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Word extends StatelessWidget {
  final String word;
  final int startTime;
  final int endTime;
  final int currentTime;
  static const double padding = 1.0;

  const Word({
    super.key,
    required this.word,
    required this.startTime,
    required this.endTime,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentTime >= startTime && currentTime <= endTime;
    Widget text = Container();

    if (!isActive) {
      text = Text(
        word,
        style: TextStyle(
          color:
              currentTime > startTime
                  ? Global.playerTheme.colorScheme.primary
                  : Global.playerTheme.colorScheme.onSurface.withValues(
                    alpha: .6,
                  ),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
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
        // blendMode: BlendMode.srcATop,
        child: Text(
          word,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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
