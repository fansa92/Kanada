import 'package:flutter/material.dart';
import '../../../metadata.dart';

class PlayFileDebug extends StatefulWidget {
  final String path;
  const PlayFileDebug({super.key, required this.path});
  @override
  State<PlayFileDebug> createState() => _PlayFileDebugState();
}
class _PlayFileDebugState extends State<PlayFileDebug> {
  late Metadata metadata;

  @override
  void initState() {
    super.initState();
    metadata = Metadata(widget.path);
    metadata.getMetadata().then((value) {
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
          Text('Picture: ${metadata.picture?.length} bytes'),
          metadata.picture!=null?Image.memory(metadata.picture!):Container(),
          Text('Lyric: ${metadata.lyric}'),
          Text('Metadata: ${metadata.metadata}')
        ],
      ),
    );
  }
}