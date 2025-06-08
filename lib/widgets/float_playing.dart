import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/background.dart';
import 'package:kanada/pages/playing.dart';
import 'package:palette_generator/palette_generator.dart';
import '../global.dart';
import '../metadata.dart';
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
      if (state?.currentIndex != null) {
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
    final newPath = Global.player.current;
    if (newPath == null) return;

    // 路径未变化时跳过
    if (newPath == metadata?.path) return;

    // 更新元数据
    path = newPath;
    metadata = Metadata(path!);

    // 并行加载元数据（带缓存）
    await Future.wait([metadata!.getMetadata(), metadata!.getCover()]);
    if (mounted) setState(() {});

    // 并行加载最新数据（无缓存）
    await Future.wait([
      metadata!.getMetadata(cache: false),
      metadata!.getCover(cache: false),
    ]);
    if (mounted) setState(() {});
    // Global.pictureCache = metadata!.picturePath;
    Global.metadataCache = metadata;
    if (metadata?.coverPath == null) return;
    final colors =
        Global.colorsCache[metadata!.path] ??
        (await PaletteGenerator.fromImageProvider(
          // MemoryImage(metadata!.cover!),
          FileImage(File(metadata!.coverPath!)),
          maximumColorCount: 10,
        )).colors.take(5).toList();
    Global.colorsCache[metadata!.path] = colors;
    if (mounted) {
      Global.playerTheme = Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors[0],
          brightness: Brightness.dark,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (path == null) return SizedBox.shrink();
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 使用 constraints 获取父容器最大宽度
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 50,
                                width: constraints.maxWidth * progress,
                                color: Global.playerTheme.colorScheme.primary
                                    .withValues(alpha: .2),
                              ),
                            );
                          },
                        ),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child:
                                    metadata?.coverPath != null
                                        ? Image.file(File(metadata!.coverPath!))
                                        : (metadata?.coverCache != null
                                            ? Image.file(
                                              File(metadata!.coverCache!),
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
                              onPressed: Global.player.skipToNext,
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
