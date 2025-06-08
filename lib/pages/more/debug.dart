import 'package:flutter/material.dart';
import 'package:kanada/widgets/link_list.dart';

class DebugPage extends StatefulWidget{
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}
class _DebugPageState extends State<DebugPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: LinkList(links: [
        [Icons.link, 'Link Debug Page', '/more/debug/link'],
        [Icons.music_note, 'Player Debug Page', '/more/debug/player'],
        [Icons.text_fields, 'Toast Debug Page', '/more/debug/toast'],
        [Icons.folder_copy, 'File Choose Debug Page', '/more/debug/file_choose'],
        [Icons.text_fields, 'Lyric Sender Debug Page', '/more/debug/lyric_sender'],
        [Icons.text_fields, 'Lyric Debug Page', '/more/debug/lyric'],
        [Icons.color_lens, 'Pick Color Debug Page', '/more/debug/pick_color'],
        [Icons.color_lens, 'Color Diffusion Debug Page', '/more/debug/color_diffusion'],
        [Icons.text_fields, 'Current Lyric Debug Page', '/more/debug/current_lyric'],
        [Icons.color_lens, 'Color Page', '/more/debug/color'],
        [Icons.music_note, 'NetEase Debug Page', '/more/debug/netease'],
      ]),
    );
  }
}