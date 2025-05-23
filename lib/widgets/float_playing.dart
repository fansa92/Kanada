import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../global.dart';
import '../metadata.dart';
import '../pages/player.dart';
import 'link.dart' as link;

class FloatPlaying extends StatefulWidget {
  const FloatPlaying({super.key});

  @override
  State<FloatPlaying> createState() => _FloatPlayingState();
}

class _FloatPlayingState extends State<FloatPlaying> {
  final GlobalKey pictureKey = GlobalKey();
  String? path;
  Metadata? metadata;
  StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<SequenceState?>? _sequenceSub;

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
  }

  @override
  void dispose() {
    _currentIndexSub?.cancel();
    _sequenceSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _fresh();
  }

  Future<void> _fresh() async {
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
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Card(
        elevation: 8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: link.Link(
            route: '/player',
            sourceKey: pictureKey,
            targetKey: PlayerPage.pictureKey,
            child: Container(
              width: double.infinity,
              height: 50,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Hero(
                    tag: 'player-image',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        key: pictureKey,
                        width: 50,
                        height: 50,
                        child:
                            metadata?.picture != null
                                ? Image.memory(metadata!.picture!)
                                : (metadata?.pictureCache != null
                                    ? Image.file(File(metadata!.pictureCache!))
                                    : Icon(Icons.music_note)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      metadata?.title ??
                          path?.split('/').last ??
                          'Unknown Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Global.player.playing ? Icons.pause : Icons.play_arrow,
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
                    icon: Icon(Icons.skip_next),
                    onPressed: Global.player.seekToNext,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
