import 'package:flutter/material.dart';
import '../../../../Netease.dart';

class NetEaseUrlDebug extends StatefulWidget {
  const NetEaseUrlDebug({super.key});

  @override
  State<NetEaseUrlDebug> createState() => _NetEaseUrlDebugState();
}

class _NetEaseUrlDebugState extends State<NetEaseUrlDebug> {
  final _controller = TextEditingController();
  String? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NetEase Url Debug')),
      body: ListView(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: '输入歌曲id'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = int.tryParse(_controller.text);
              if (id == null) {
                return;
              }
              data = await NetEase.getUrl(id);
              setState(() {});
            },
            child: const Text('获取歌曲详情'),
          ),
          Text('data: $data'),
        ],
      ),
    );
  }
}
