import 'package:flutter/material.dart';
import 'package:kanada/widgets/link_list.dart';

class NetEaseDebug extends StatefulWidget{
  const NetEaseDebug({super.key});

  @override
  State<NetEaseDebug> createState() => _NetEaseDebugState();
}
class _NetEaseDebugState extends State<NetEaseDebug>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NetEase Debug'),
      ),
      body: LinkList(links: [
        [Icons.music_note, 'NetEase Search Debug Page', '/more/debug/netease/search'],
        [Icons.music_note, 'NetEase Detail Debug Page', '/more/debug/netease/detail'],
        [Icons.music_note, 'NetEase Url Debug Page', '/more/debug/netease/url'],
      ]),
    );
  }
}