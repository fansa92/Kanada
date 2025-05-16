import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';
import '../global.dart';
import '../lyric.dart';

class LyricView extends StatefulWidget {
  static Color primaryColor = Colors.red;
  static Color secondaryColor = Colors.blue;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    LyricView.primaryColor = Theme.of(context).colorScheme.primary;
    LyricView.secondaryColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .6);
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
                  (-childPosition.dy) -
                      (singleChildRenderBox.size.height - widget.paddingTop) /
                          2 +
                      (targetRenderBox.size.height / 2),
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

  @override
  Widget build(BuildContext context) {
    return lyrics == null
        ? Text('正在加载歌词...')
        : SingleChildScrollView(
          key: singleChildScrollViewKey,
          controller: _scrollController,
          // physics: NeverScrollableScrollPhysics(),
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
                  ? LyricView.primaryColor
                  : LyricView.secondaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      text = ShaderMask(
        shaderCallback:
            (bounds) => LinearGradient(
              colors: [LyricView.primaryColor, LyricView.secondaryColor],
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

// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:kanada/metadata.dart';
// import '../global.dart';
// import '../lyric.dart';
// import 'fraction_clip.dart';
//
// class LyricView extends StatefulWidget {
//   static Color primaryColor = Colors.red;
//   static Color secondaryColor = Colors.blue;
//   final String path;
//   final double paddingTop;
//   final double paddingBottom;
//
//   // final EdgeInsets padding;
//
//   const LyricView({
//     super.key,
//     required this.path,
//     this.paddingTop = 0.0,
//     this.paddingBottom = 0.0,
//   });
//
//   @override
//   State<LyricView> createState() => _LyricViewState();
// }
//
// class _LyricViewState extends State<LyricView> {
//   String text = '';
//   Metadata? metadata;
//   Lyrics? lyrics;
//
//   // StreamSubscription<Duration>? _positionSub;
//   final ScrollController _scrollController = ScrollController();
//
//   // final GlobalKey activeKey = GlobalKey();
//   // final GlobalKey firstKey = GlobalKey();
//   int index = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//     // LyricView.primaryColor = Theme.of(context).colorScheme.primary;
//     // LyricView.secondaryColor = Theme.of(context).colorScheme.secondary;
//     // 初始化位置监听
//     // _positionSub = Global.player.positionStream.listen((position) {
//     //   if (mounted) setState(() {});
//     // });
//     _fresh();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     LyricView.primaryColor = Theme.of(context).colorScheme.primary;
//     LyricView.secondaryColor = Theme.of(
//       context,
//     ).colorScheme.onSurface.withValues(alpha: .6);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     // _positionSub?.cancel();
//     _scrollController.dispose();
//   }
//
//   Future<void> _init() async {
//     metadata = Metadata(widget.path);
//     metadata!.getLyric().then((value) {
//       setState(() {});
//       if (value == null) return;
//       lyrics = Lyrics(value);
//       lyrics!.parse().then((value) {
//         setState(() {});
//       });
//     });
//   }
//
//   Future<void> _fresh() async {
//     if (!mounted) return;
//     if (lyrics != null) {
//       int idx = -1;
//       for (int i = 0; i < lyrics!.lyrics.length; i++) {
//         final lyric = lyrics!.lyrics[i];
//         if (Global.player.position.inMilliseconds <= lyric['endTime']) {
//           idx = i;
//           break;
//         }
//       }
//       if (idx != index && idx != -1) {
//         print('idx: $idx');
//         index = idx;
//         // setState(() {});
//         // if (_scrollController.hasClients && lyrics!.lyrics.isNotEmpty) {
//         //   final lrc = lyrics!.lyrics[index];
//         //   final progress =
//         //       (Global.player.position.inMilliseconds - lrc['startTime']) /
//         //       (lrc['endTime'] - lrc['startTime']);
//         //   final height = firstKey.currentContext!.size!.height;
//         //   _scrollController.jumpTo(height * progress);
//         // }
//         // if (_scrollController.hasClients && lyrics!.lyrics.isNotEmpty) {
//         //   print('${_scrollController.position.maxScrollExtent}');
//         //   _scrollController.animateTo(
//         //     // (_scrollController.position.maxScrollExtent +
//         //     //         MediaQuery.of(context).size.height-200) *
//         //     //     idx /
//         //     //     lyrics!.lyrics.length,
//         //     (_scrollController.position.maxScrollExtent) *
//         //             idx /
//         //             lyrics!.lyrics.length +
//         //         (MediaQuery.of(context).size.height - 200) *
//         //             idx /
//         //             lyrics!.lyrics.length,
//         //     duration: Duration(milliseconds: 300),
//         //     curve: Curves.easeInOut,
//         //   );
//         // }
//       }
//       // if (_scrollController.hasClients && lyrics!.lyrics.isNotEmpty) {
//       //   final lrc = lyrics!.lyrics[index];
//       //   final progress =
//       //       (Global.player.position.inMilliseconds - lrc['startTime']) /
//       //       (lrc['endTime'] - lrc['startTime']);
//       //   final height = firstKey.currentContext!.size!.height;
//       //   _scrollController.jumpTo(height * progress);
//       // }
//     }
//     // final lrc = lyrics!.lyrics[index];
//     // final progress =
//     //     (Global.player.position.inMilliseconds - lrc['startTime']) /
//     //         (lrc['endTime'] - lrc['startTime']);
//     // firstHeight = firstKey.currentContext!=null?firstKey.currentContext!.size!.height*(1-Curves.easeInOut.transform(max(0, min(progress*3-2, 1)))):null;
//     setState(() {});
//     Future.delayed(Duration(milliseconds: 10), () {
//       _fresh();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return lyrics == null
//         ? Text('正在加载歌词...')
//         : ListView.builder(
//       controller: _scrollController,
//       itemCount: lyrics!.lyrics.length + 2 - index + 2,
//       physics: NeverScrollableScrollPhysics(),
//       itemBuilder: (context, i) {
//         // print(lyrics!.lyrics.length);
//         if (i == 0) {
//           return SizedBox(height: widget.paddingTop);
//         }
//         if (i - 1 + index - 2 >= lyrics!.lyrics.length) {
//           return SizedBox(height: widget.paddingBottom);
//         }
//         if (i - 1 + index - 2 < 0) {
//           return Container();
//         }
//         final lyric = lyrics!.lyrics[i - 1 + index - 2];
//         if (i == 1) {
//           final lrc = lyrics!.lyrics[i - 1 + index - 2+2];
//           final progress =
//               (Global.player.position.inMilliseconds - lrc['startTime']) /
//                   (lrc['endTime'] - lrc['startTime']);
//           return SizedBox(
//             child: FractionClip(
//                 top: Curves.easeInOut.transform(max(0, min(progress*3-2, 1))),
//                 child: ListTile(
//                   // key: firstKey,
//                   title: Padding(
//                     padding: const EdgeInsets.only(top: 3),
//                     child: Text(
//                       lyric['content'],
//                       style: TextStyle(
//                         color:
//                         Global.player.position.inMilliseconds >
//                             lyric['startTime']
//                             ? LyricView.primaryColor
//                             : LyricView.secondaryColor,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 )),
//           );
//         }
//         final bool isActive =
//             Global.player.position.inMilliseconds >= lyric['startTime'] &&
//                 Global.player.position.inMilliseconds <= lyric['endTime'];
//         if (isActive) {
//           return ListTile(
//             // key: activeKey,
//             title: Wrap(
//               children: [
//                 for (final word in lyric['lyric'])
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: Word(
//                       word: word['word'],
//                       startTime: word['startTime'],
//                       endTime: word['endTime'],
//                       currentTime: Global.player.position.inMilliseconds,
//                     ),
//                   ),
//               ],
//             ),
//           );
//         }
//         return ListTile(
//           // key: ValueKey(lyric),
//           title: Padding(
//             padding: const EdgeInsets.only(top: 3),
//             child: Text(
//               lyric['content'],
//               style: TextStyle(
//                 color:
//                 Global.player.position.inMilliseconds >
//                     lyric['startTime']
//                     ? LyricView.primaryColor
//                     : LyricView.secondaryColor,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class Word extends StatelessWidget {
//   final String word;
//   final int startTime;
//   final int endTime;
//   final int currentTime;
//
//   const Word({
//     super.key,
//     required this.word,
//     required this.startTime,
//     required this.endTime,
//     required this.currentTime,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isActive = currentTime >= startTime && currentTime <= endTime;
//     Widget text = Container();
//
//     if (!isActive) {
//       text = Text(
//         word,
//         style: TextStyle(
//           color:
//           currentTime > startTime
//               ? LyricView.primaryColor
//               : LyricView.secondaryColor,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//     } else {
//       text = ShaderMask(
//         shaderCallback:
//             (bounds) => LinearGradient(
//           colors: [LyricView.primaryColor, LyricView.secondaryColor],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           stops: [
//             (currentTime - startTime) / (endTime - startTime) - 0.1,
//             (currentTime - startTime) / (endTime - startTime) + 0.1,
//           ],
//         ).createShader(bounds),
//         blendMode: BlendMode.srcATop,
//         child: Text(
//           word,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }
//     return Padding(
//       padding: EdgeInsets.only(
//         top:
//         3 *
//             Curves.easeInOut.transform(
//               1 -
//                   max(
//                     0,
//                     min((currentTime - startTime) / (endTime - startTime), 1),
//                   ),
//             ),
//       ),
//       child: text,
//     );
//   }
// }
