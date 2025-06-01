import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/global.dart';
import 'package:kanada/metadata.dart';

import '../lyric_sender.dart';

class MusicInfo extends StatefulWidget {
  final String path;
  final bool play;
  final ThemeData? theme;
  final bool nextPlay;

  const MusicInfo({
    super.key,
    required this.path,
    this.play = true,
    this.theme,
    this.nextPlay = true,
  });

  @override
  State<MusicInfo> createState() => _MusicInfoState();
}

class _MusicInfoState extends State<MusicInfo> {
  late Metadata metadata;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    metadata = Metadata(widget.path);
    await metadata.getMetadata();
    setState(() {});
    await metadata.getCover();
    setState(() {});
  }

  Future<void> play() async {
    // Global.player.setAudioSource(
    //   AudioSource.file(
    //     widget.path,
    //     tag: MediaItem(
    //       id: widget.path,
    //       album: metadata.album,
    //       title: metadata.title?? widget.path.split('/').last,
    //       artist: metadata.artist,
    //       duration: metadata.duration,
    //       artUri: Uri.parse(
    //         'file://${metadata.picturePath}',
    //       ),
    //     ),
    //   ),
    // );
    Global.init = false;
    Global.path = widget.path;

    // 提前提取路径列表，避免多次访问 Global.playlist
    final playlistPaths = Global.playlist;

    playlistPaths.shuffle();

    // 使用 map+toList 并行化处理
    final sources = await Future.wait(
      playlistPaths.map((path) async {
        final data = Metadata(path);
        await Future.wait([data.getMetadata(), data.getCover()]);
        return AudioSource.file(
          path,
          tag: MediaItem(
            id: path,
            album: data.album,
            title: data.title ?? path.split('/').last,
            artist: data.artist,
            duration: data.duration ?? const Duration(seconds: 180),
            artUri: Uri.parse('file://${data.coverPath}'),
          ),
        );
      }),
    );

    // 查找索引的优化（避免重复遍历）
    final idx = playlistPaths.indexOf(widget.path);

    // Global.player.setAudioSource(
    //   ConcatenatingAudioSource(children: sources),
    //   initialIndex: idx >= 0 ? idx : null,
    // );
    await Global.player.setAudioSources(sources, initialIndex: idx >= 0 ? idx : null);
    Global.init = true;
    if (!Global.lyricSenderInit) {
      // print('sendLyrics');
      // sendLyrics();
      Global.player.positionStream.listen((position) {
        sendLyrics();
      });
      Global.lyricSenderInit = true;
    }
    await Global.player.seek(Duration.zero, index: idx >= 0? idx : null);
    await Global.player.play();
  }

  @override
  Widget build(BuildContext context) {
    theme = widget.theme ?? Theme.of(context);
    return InkWell(
      onTap: widget.play ? play : null,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child:
                  metadata.cover != null
                      ? Image.memory(metadata.cover!, fit: BoxFit.cover)
                      : const Icon(Icons.music_note),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata.title ?? widget.path.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  metadata.artist ?? 'Unknown Artist',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.nextPlay)
            IconButton(
              onPressed: () {
                Global.player.audioSources.insert(
                  (Global.player.currentIndex ?? 0) + 1,
                  AudioSource.file(
                    widget.path,
                    tag: MediaItem(
                      id: widget.path,
                      album: metadata.album,
                      title: metadata.title ?? widget.path.split('/').last,
                      artist: metadata.artist,
                      duration: metadata.duration,
                      artUri: Uri.parse('file://${metadata.coverPath}'),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add_circle, color: theme.colorScheme.onSurface),
            ),
        ],
      ),
    );
  }
}

class MusicInfoSearch extends StatefulWidget {
  final String path;
  final String keywords;

  const MusicInfoSearch({
    super.key,
    required this.path,
    required this.keywords,
  });

  @override
  State<MusicInfoSearch> createState() => _MusicInfoSearchState();
}

class _MusicInfoSearchState extends State<MusicInfoSearch> {
  bool show = false;
  Metadata metadata = Metadata('');

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant MusicInfoSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keywords != oldWidget.keywords) {
      _init();
    }
  }

  Future<void> _init() async {
    if (widget.keywords.isEmpty) {
      show = true;
      setState(() {});
    } else {
      if (metadata.path != widget.path) {
        metadata = Metadata(widget.path);
        await metadata.getMetadata();
      }
      if ((metadata.title != null
              ? metadata.title!.toLowerCase().contains(
                widget.keywords.toLowerCase(),
              )
              : false) ||
          (metadata.artist != null
              ? metadata.artist!.toLowerCase().contains(
                widget.keywords.toLowerCase(),
              )
              : false) ||
          (metadata.album != null
              ? metadata.album!.toLowerCase().contains(
                widget.keywords.toLowerCase(),
              )
              : false)) {
        show = true;
      } else {
        show = false;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? ListTile(
          key: ValueKey(widget.path),
          title: MusicInfo(path: widget.path),
        )
        : Container();
  }
}
