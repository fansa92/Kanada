import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kanada/widgets/music_info.dart';

import '../../../../Netease.dart';

class NetEaseSearchDebug extends StatefulWidget {
  const NetEaseSearchDebug({super.key});

  @override
  State<NetEaseSearchDebug> createState() => _NetEaseSearchDebugState();
}

class _NetEaseSearchDebugState extends State<NetEaseSearchDebug> {
  final _controller = TextEditingController();
  String _json = '';
  Map? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NetEase Search Debug')),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: '输入歌曲名'),
            ),
            ElevatedButton(
              onPressed: () async {
                final keywords = _controller.text;
                if (keywords.isEmpty) {
                  return;
                }
                data = await NetEase.search(keywords);
                if (data == null) {
                  return;
                }
                setState(() {
                  _json = jsonEncode(data);
                });
              },
              child: Text('搜索歌曲'),
            ),
            // Expanded(
            //   child: SingleChildScrollView(
            //     child: Text(_json),
            //   ),
            // )
            if (data != null)
              Expanded(
                child: ListView.builder(
                  itemCount: data!['result']!['songs']!.length,
                  itemBuilder: (context, index) {
                    final mid = data!['result']!['songs']![index]['id'];
                    return ListTile(title: MusicInfo(path: 'netease://$mid'));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
