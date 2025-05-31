import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/global.dart';
import 'package:kanada/metadata.dart';

import '../lyric_sender.dart';

class MusicInfo extends StatefulWidget {
  final String path;

  const MusicInfo({super.key, required this.path});

  @override
  State<MusicInfo> createState() => _MusicInfoState();
}

class _MusicInfoState extends State<MusicInfo> {
  late Metadata metadata;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    metadata = Metadata(widget.path);
    await metadata.getMetadata();
    setState(() {});
    await metadata.getPicture();
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
        await Future.wait([data.getMetadata(), data.getPicture()]);
        return AudioSource.file(
          path,
          tag: MediaItem(
            id: path,
            album: data.album,
            title: data.title ?? path.split('/').last,
            artist: data.artist,
            duration: data.duration ?? const Duration(seconds: 180),
            artUri: Uri.parse('file://${data.picturePath}'),
          ),
        );
      }),
    );

    // 查找索引的优化（避免重复遍历）
    final idx = playlistPaths.indexOf(widget.path);

    Global.player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: idx >= 0 ? idx : null,
    );
    // Global.player.setAudioSources(
    //   sources,
    //   initialIndex: idx >= 0? idx : null,
    // );
    Global.init = true;
    Global.player.seek(Duration.zero);
    Global.player.play();
    if (!Global.lyricSenderInit) {
      // print('sendLyrics');
      // sendLyrics();
      Global.player.positionStream.listen((position) {
        sendLyrics();
      });
      Global.lyricSenderInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: play,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child:
                  metadata.picture != null
                      ? Image.memory(metadata.picture!, fit: BoxFit.cover)
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
                ),
                Text(
                  metadata.artist ?? 'Unknown Artist',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
