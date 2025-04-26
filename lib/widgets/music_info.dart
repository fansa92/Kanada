import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/global.dart';
import 'package:kanada/metadata.dart';
import 'package:kanada/widgets/link.dart';

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
    //       duration: const Duration(seconds: 160),
    //       artUri: Uri.parse(
    //         'file://${metadata.picturePath}',
    //       ),
    //     ),
    //   ),
    // );
    int idx=-1;
    List<AudioSource> sources=[];
    for (var i = 0; i < Global.playlist.length; i++) {
      if (Global.playlist[i] == widget.path) {
        idx=i;
      }
      final data=Metadata(Global.playlist[i]);
      await data.getMetadata();
      await data.getPicture();
      sources.add(AudioSource.file(
        Global.playlist[i],
        tag: MediaItem(
          id: Global.playlist[i],
          album: data.album,
          title: data.title?? Global.playlist[i].split('/').last,
          artist: data.artist,
          duration: data.duration?? const Duration(seconds: 180),
          artUri: Uri.parse(
            'file://${data.picturePath}',
          ),
        )
      ));
    }
    Global.player.setAudioSource(
      ConcatenatingAudioSource(
        children: sources,
      ),
      initialIndex: idx,
    );
    Global.player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Link(route: '/player', onTapBefore: play, child: Row(
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
              Text(metadata.title ?? widget.path.split('/').last),
              Text(
                metadata.artist ?? 'Unknown Artist',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
