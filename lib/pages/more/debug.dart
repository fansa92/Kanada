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
        [Icons.folder_copy, 'File Choose Debug Page', '/more/debug/file_choose']
      ]),
    );
  }
}