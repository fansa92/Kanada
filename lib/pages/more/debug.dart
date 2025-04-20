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
      body: LinkList(links: [
        [Icons.link, 'Link Debug Page', '/more/debug/link'],
        [Icons.music_note, 'Player Debug Page', '/more/debug/player'],
      ]),
    );
  }
}