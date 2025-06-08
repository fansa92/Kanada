import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanada/lyric.dart';

import '../../../../Netease.dart';

class NetEaseDetailDebug extends StatefulWidget {
  const NetEaseDetailDebug({super.key});

  @override
  State<NetEaseDetailDebug> createState() => _NetEaseDetailDebugState();
}

class _NetEaseDetailDebugState extends State<NetEaseDetailDebug> {
  final _controller = TextEditingController();
  MetadataNetEase? metadata;
  Lyrics? lyrics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NetEase Detail Debug')),
      body: ListView(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: '输入歌曲id'),
          ),
          ElevatedButton(
            onPressed: () async {
              // final id = int.tryParse(_controller.text);
              // if (id == null) {
              //   return;
              // }
              // final data = await NetEase.getDetail(id);
              // setState(() {
              //   _json = jsonEncode(data);
              // });
              metadata = MetadataNetEase(_controller.text);
              await metadata!.getMetadata();
              setState(() {});
              await metadata!.getCover();
              setState(() {});
              await metadata!.getLyric();
              setState(() {});
              if(metadata!.lyric == null) {
                return;
              }
              lyrics = Lyrics(metadata!.lyric!);
              lyrics?.parse();
              setState(() {});
            },
            child: const Text('获取歌曲详情'),
          ),
          Text('Title: ${metadata?.title}'),
          Text('Artist: ${metadata?.artist}'),
          Text('Album: ${metadata?.album}'),
          Text('Duration: ${metadata?.duration}'),
          // Text('Picture: ${metadata.cover?.length} bytes'),
          metadata?.coverPath != null
              ? Image.file(File(metadata!.coverPath!))
              : Container(),
          Text('Lyric: ${metadata?.lyric}'),
          Text(lyrics?.lyrics.map((e)=>e['content']).toList().join('\n') ?? ''),
        ],
      ),
    );
  }
}
