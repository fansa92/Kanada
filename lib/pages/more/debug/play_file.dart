import 'dart:io';

import 'package:flutter/material.dart';
import '../../../lyric.dart';
import '../../../metadata.dart';

class PlayFileDebug extends StatefulWidget {
  final String path;
  const PlayFileDebug({super.key, required this.path});
  @override
  State<PlayFileDebug> createState() => _PlayFileDebugState();
}
class _PlayFileDebugState extends State<PlayFileDebug> {
  late Metadata metadata;
  Lyrics lyrics = Lyrics('');

  @override
  void initState() {
    super.initState();
    metadata = Metadata(widget.path);
    metadata.getMetadata().then((value) {
      setState(() {});
    });
    metadata.getLyric().then((value) {
      setState(() {});
      lyrics=Lyrics(metadata.lyric!);
      lyrics.parse().then((value) {
        setState(() {});
      });
    });
    metadata.getCover().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play File Debug'),
      ),
      body: ListView(
        children: [
          Text('Path: ${widget.path}'),
          Text('Title: ${metadata.title}'),
          Text('Artist: ${metadata.artist}'),
          Text('Album: ${metadata.album}'),
          Text('Duration: ${metadata.duration}'),
          // Text('Picture: ${metadata.cover?.length} bytes'),
          metadata.coverPath!=null?Image.file(File(metadata.coverPath!)):Container(),
          Text('Lyric: ${metadata.lyric}'),
          Text('Metadata: ${metadata.metadata}'),
          Text('Lyrics: ${lyrics.lyrics}')
        ],
      ),
    );
  }
}