import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/widgets/lyric_complicated_view.dart';
import 'package:kanada/widgets/lyric_view.dart';

import '../global.dart';
import '../metadata.dart';
import '../settings.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  String? path;
  Metadata? metadata;
  double _duration = 1;
  double _position = 0;
  double _progress = 0;

  // StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<SequenceState?>? _sequenceSub;
  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();
    _init();
    metadata = Global.metadataCache;
    // _currentIndexSub = Global.player.currentIndexStream.listen((index) {
    //   if (index != null) {
    //     print(path);
    //     _init();
    //   }
    // });
    _sequenceSub = Global.player.sequenceStateStream.listen((state) {
      _init();
    });
    // 初始化位置监听
    _positionSub = Global.player.positionStream.listen((position) {
      _duration = Global.player.duration?.inMilliseconds.toDouble() ?? 1.0;
      _position = Global.player.position.inMilliseconds.toDouble();
      _progress = _duration > 0 ? _position / _duration : 0.0;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // _currentIndexSub?.cancel();
    _sequenceSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final newPath = Global.player.current;

    // 路径未变化时跳过
    if (newPath == metadata?.path) return;

    // 更新元数据
    path = newPath;
    metadata = Metadata(path!);
    await metadata!.getMetadata();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 100 + MediaQuery.of(context).padding.top,
            left: 12,
            right: 12,
          ),
          child:
              metadata?.path != null
                  ? (Settings.lyricComplicatedAnimation
                      ? LyricComplicatedView(path: metadata!.path)
                      : LyricView(
                        path: metadata!.path,
                        paddingTop: MediaQuery.of(context).size.height * 0.5,
                        paddingBottom: MediaQuery.of(context).size.height,
                        // paddingTop: 100 + MediaQuery.of(context).padding.top,
                        // paddingBottom: MediaQuery.of(context).size.height,
                        // padding: EdgeInsets.only(
                        //   top: 100 + MediaQuery.of(context).padding.top,
                        // ),
                      ))
                  : Container(),
        ),
        SizedBox(
          height: 100 + MediaQuery.of(context).padding.top,
          width: double.infinity,
          child: ClipRect(
            // child: BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Card(
                          elevation: 0,
                          child: Hero(
                            tag: 'player-image',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              key: ValueKey('player-image'),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child:
                                    metadata?.cover != null
                                        ? Image.memory(metadata!.cover!)
                                        : (metadata?.coverCache != null
                                            ? Image.file(
                                              File(metadata!.coverCache!),
                                            )
                                            : Icon(Icons.music_note)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              metadata?.title ??
                                  path?.split('/').last ??
                                  'Unknown Title',
                              style: Global.playerTheme.textTheme.titleLarge
                                  ?.copyWith(
                                    color: Global
                                        .playerTheme
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: .8),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              metadata?.artist ?? 'Unknown Artist',
                              style: Global.playerTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Global
                                        .playerTheme
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: .6),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (Settings.lyricShowProgressBar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.bottom * .3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Global.playerTheme.colorScheme.primary.withValues(
                      alpha: .6,
                    ),
                    Colors.transparent,
                  ],
                  stops: [_progress, _progress],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
