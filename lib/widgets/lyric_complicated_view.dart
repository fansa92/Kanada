import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kanada/settings.dart';
import 'package:kanada/tool.dart';

import '../global.dart';
import '../lyric.dart';
import '../metadata.dart';
import 'lyric_view.dart';

class LyricComplicatedView extends StatefulWidget {
  final String path;
  static BoxConstraints? constraints;

  const LyricComplicatedView({super.key, required this.path});

  @override
  State<LyricComplicatedView> createState() => _LyricComplicatedViewState();
}

class _LyricComplicatedViewState extends State<LyricComplicatedView> {
  // final List<Widget> widgets = [];
  final List<GlobalKey> keys = [];
  Lyrics? lyrics;
  int index = -1;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(LyricComplicatedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      // 路径变化时重新初始化
      lyrics = null;
      if (mounted) setState(() {});
      _init();
    }
  }

  Future<void> _init() async {
    final path = widget.path;
    final metadata = Metadata(path);
    await metadata.getLyric();
    lyrics = Lyrics(metadata.lyric!);
    lyrics?.parse();
    // widgets.clear();
    keys.clear();
    keys.addAll(List.generate(lyrics!.lyrics.length, (index) => GlobalKey()));
    // for (var i = 0; i < lyrics!.lyrics.length; i++) {
    //   keys.add(GlobalKey());
    //   widgets.add(
    //     Builder(
    //       builder:
    //           (context) => ,
    //     ),
    //   );
    // }
    _fresh();
  }

  Future<void> _fresh() async {
    if (!mounted) return;
    // print('fresh()');
    int idx = -1;
    for (int i = 0; i < lyrics!.lyrics.length; i++) {
      final lyric = lyrics!.lyrics[i];
      if (Global.player.position.inMilliseconds >= lyric['startTime']) {
        idx = i;
      }
      if (Global.player.position.inMilliseconds <= lyric['endTime']) {
        idx = i;
        break;
      }
    }
    // if (idx == index) return;
    index = idx;
    // print('index: $index');
    // widgets.clear();
    // final double offset = -index * 20;
    setState(() {});
    Future.delayed(Duration(milliseconds: 10), () {
      _fresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        LyricComplicatedView.constraints = constraints;
        // print('width: ${_constraints!.maxWidth}');
        return ShaderMask(
          // 关键：使用线性渐变作为遮罩
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent, // 渐变开始
                Colors.black, // 底部完全不透明
              ],
              stops: [0.0, 50 / bounds.height], // 调整渐变区域
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn, // 使用目标输入混合模式
          child: Stack(
            children: [
              for (
                int i = (index - 5).clamp(0, lyrics!.lyrics.length - 1);
                i < lyrics!.lyrics.length &&
                    (i - 1) * 60 - (index - 3) * 60 <=
                        LyricComplicatedView.constraints!.maxHeight;
                i++
              )
                Builder(
                  builder: (context) {
                    return AnimatedPositioned(
                      key: keys[i],
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      // top: offsetY,
                      top: calcPaddingTop(i),
                      left: 0,
                      right: 0,
                      child: ClipRect(
                        child: Stack(
                          children: [
                            LyricWidget(
                              ctx: lyrics!.lyrics[i]['content'],
                              startTime: lyrics!.lyrics[i]['startTime'],
                              endTime: lyrics!.lyrics[i]['endTime'],
                              lyric: lyrics!.lyrics[i]['lyric'],
                              blurRadius: Settings.lyricBlur?abs(index - i).toDouble():0,
                            ),
                            if (Settings.lyricGlow)
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                  ),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  double calcPaddingTop(int i) {
    // if (i == 0) return 0;
    if (i == index) return 180;
    int lineCount(i) => calculateLineCount(
      lyrics!.lyrics[i]['content'],
      LyricComplicatedView.constraints!.maxWidth * .8,
      28,
      FontWeight.bold,
    );
    if (i < index) {
      return calcPaddingTop(i + 1) - lineCount(i) * 60;
    } else {
      return calcPaddingTop(i - 1) + lineCount(i - 1) * 60;
    }
    // return i*60 - (index-3)*60;
  }
}
