import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanada/widgets/music_info.dart';

import '../../../../Netease.dart';

class NetEaseSearchDebug extends StatefulWidget {
  const NetEaseSearchDebug({super.key});

  @override
  State<NetEaseSearchDebug> createState() => _NetEaseSearchDebugState();
}

class _NetEaseSearchDebugState extends State<NetEaseSearchDebug> {
  final _controller = TextEditingController();
  Map? data;

  @override
  void initState() {
    super.initState();
    _controller.text = '25時';
  }

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: '已复制到剪贴板',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

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
                setState(() {});
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
                    return ListTile(
                      title: MusicInfo(path: 'netease://$mid'),
                      onLongPress: ()=>copy('$mid'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
