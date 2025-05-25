import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/lyric_sender.dart';
import 'package:kanada/pages/playing.dart';
import '../global.dart';
import '../metadata.dart';
import '../tool.dart';
import 'link.dart' as link;
import 'package:animations/animations.dart';

import 'lyric_view.dart';

class FloatPlaying extends StatefulWidget {
  const FloatPlaying({super.key});

  @override
  State<FloatPlaying> createState() => _FloatPlayingState();
}

class _FloatPlayingState extends State<FloatPlaying> {
  String? path;
  Metadata? metadata;
  StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<SequenceState?>? _sequenceSub;

  // StreamSubscription<Duration?>? _positionSub;

  @override
  void initState() {
    super.initState();
    _init();
    metadata = Global.metadataCache;

    // 监听 currentIndex 变化
    _currentIndexSub = Global.player.currentIndexStream.listen((index) {
      _fresh();
    });

    // 监听播放列表元数据变化（包括 setAudioSource）
    _sequenceSub = Global.player.sequenceStateStream.listen((state) {
      if (state.currentIndex != null) {
        _fresh(); // 主动刷新
      }
    });

    // 监听播放位置变化
    // _positionSub = Global.player.positionStream.listen((position) {
    //   if (mounted) setState(() {});
    // });

    Timer.periodic(Duration(milliseconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _currentIndexSub?.cancel();
    _sequenceSub?.cancel();
    // _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _fresh();
  }

  Future<void> _fresh() async {
    // 获取新路径
    final newPath = getCurrentUri();

    // 路径未变化时跳过
    if (newPath == metadata?.path) return;

    // 更新元数据
    path = newPath;
    metadata = Metadata(path!);

    // 并行加载元数据（带缓存）
    await Future.wait([metadata!.getMetadata(), metadata!.getPicture()]);
    if (mounted) setState(() {});

    // 并行加载最新数据（无缓存）
    await Future.wait([
      metadata!.getMetadata(cache: false),
      metadata!.getPicture(cache: false),
    ]);
    if (mounted) setState(() {});
    // Global.pictureCache = metadata!.picturePath;
    Global.metadataCache = metadata;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        Global.player.duration != null
            ? Global.player.position.inMilliseconds /
                Global.player.duration!.inMilliseconds
            : 0.0;
    return Hero(
      tag: 'float-player',
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Card(
          elevation: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: OpenContainer(
              transitionDuration: Duration(milliseconds: 300),
              closedBuilder:
                  (context, action) => Container(
                    width: double.infinity,
                    height: 50,
                    color: Global.playerTheme.colorScheme.primaryContainer,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Global.playerTheme.colorScheme.primary
                                      .withValues(alpha: .2),
                                  Colors.transparent,
                                ],
                                stops: [progress, progress],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child:
                                    metadata?.picture != null
                                        ? Image.memory(metadata!.picture!)
                                        : (metadata?.pictureCache != null
                                            ? Image.file(
                                              File(metadata!.pictureCache!),
                                            )
                                            : Icon(Icons.music_note)),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    metadata?.title ??
                                        path?.split('/').last ??
                                        'Unknown Title',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Global
                                              .playerTheme
                                              .colorScheme
                                              .onPrimaryContainer,
                                    ),
                                  ),
                                  if (currentLyric.content != '')
                                    ClipRect(
                                      child: LyricEasyWidget(
                                        ctx: currentLyric.content,
                                        startTime: currentLyric.startTime,
                                        endTime: currentLyric.endTime,
                                        lyric: currentLyric.words,
                                        fontSize: 12,
                                      ),
                                    ),
                                  // Text(
                                  //   currentLyric.content,
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color:
                                  //         Global
                                  //             .playerTheme
                                  //             .colorScheme
                                  //             .onPrimaryContainer,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Global.player.playing
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color:
                                    Global
                                        .playerTheme
                                        .colorScheme
                                        .onPrimaryContainer,
                              ),
                              onPressed: () {
                                (Global.player.playing
                                        ? Global.player.pause()
                                        : Global.player.play())
                                    .then((value) {
                                      setState(() {});
                                      _fresh();
                                    });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next,
                                color:
                                    Global
                                        .playerTheme
                                        .colorScheme
                                        .onPrimaryContainer,
                              ),
                              onPressed: Global.player.seekToNext,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              openBuilder: (context, action) => PlayingPage(),
            ),
          ),
        ),
      ),
    );
  }
}
