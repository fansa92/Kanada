import 'package:flutter/material.dart';
import 'package:kanada/widgets/music_info.dart';

import '../../../../Netease.dart';

class NetEasePlaylistDebug extends StatefulWidget {
  const NetEasePlaylistDebug({super.key});

  @override
  State<NetEasePlaylistDebug> createState() => _NetEasePlaylistDebugState();
}

class _NetEasePlaylistDebugState extends State<NetEasePlaylistDebug> {
  final _controller = TextEditingController();
  List<int> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NetEase Playlist Debug')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: '输入歌单id'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = int.tryParse(_controller.text);
              if (id == null) {
                return;
              }
              data = await NetEase.getPlaylist(id);
              setState(() {});
            },
            child: const Text('获取歌单详情'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(title: MusicInfo(path: 'netease://${data[index]}'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
