import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
