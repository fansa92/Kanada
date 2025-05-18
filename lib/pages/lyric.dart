import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/widgets/lyric_view.dart';

import '../global.dart';
import '../metadata.dart';

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
    // _currentIndexSub = Global.player.currentIndexStream.listen((index) {
    //   if (index != null) {
    //     print(path);
    //     _init();
    //   }
    // });
    _sequenceSub = Global.player.sequenceStateStream.listen((state) {
      if (state != null) {
        _init();
      }
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
    final playlist = Global.player.audioSource;
    final currentIndex = Global.player.currentIndex;

    // 防御性检查：确保播放列表和索引有效
    if (playlist is! ConcatenatingAudioSource ||
        currentIndex == null ||
        currentIndex >= playlist.children.length) {
      return;
    }

    dynamic current = playlist.children[currentIndex];
    // 获取新路径
    final newPath = current.tag.id;

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
          ),
          child:
              metadata?.path != null
                  ? LyricView(
                    path: metadata!.path,
                    paddingTop: 100 + MediaQuery.of(context).padding.top,
                    // paddingBottom: MediaQuery.of(context).size.height,
                    // padding: EdgeInsets.only(
                    //   top: 100 + MediaQuery.of(context).padding.top,
                    // ),
                  )
                  : Container(),
        ),
        SizedBox(
          height: 100 + MediaQuery.of(context).padding.top,
          width: double.infinity,
          child: ClipRect(
            // child: BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              // color: Theme.of(
              //   context,
              // ).colorScheme.surface.withValues(alpha: .8),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Card(
                            elevation: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child:
                                    metadata?.picture != null
                                        ? Image.memory(metadata!.picture!)
                                        : (metadata?.pictureCache != null
                                            ? Image.file(
                                              File(metadata!.pictureCache!),
                                            )
                                            : (Global.pictureCache != null
                                                ? Image.file(
                                                  File(Global.pictureCache!),
                                                )
                                                : Icon(Icons.music_note))),
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
                                style: Global.playerTheme.textTheme.titleLarge?.copyWith(
                                  color: Global.playerTheme.colorScheme.onSurface.withValues(alpha: .8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                metadata?.artist ?? 'Unknown Artist',
                                style: Global.playerTheme.textTheme.bodyMedium?.copyWith(
                                  color: Global.playerTheme.colorScheme.onSurface.withValues(alpha: .6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: Global.playerTheme.colorScheme.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Global.playerTheme.colorScheme.primary,
                              Colors.transparent,
                            ],
                            stops: [_progress-0.005, _progress+0.005],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
