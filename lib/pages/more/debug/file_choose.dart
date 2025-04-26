import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanada/pages/more/debug/play_file.dart';
import 'package:kanada/widgets/link.dart';

class FileChooseDebug extends StatefulWidget {
  final String? path;

  const FileChooseDebug({super.key, this.path});

  @override
  State<FileChooseDebug> createState() => _FileChooseDebugState();
}

class _FileChooseDebugState extends State<FileChooseDebug> {
  late String path;
  List<String> dirs = [];
  List<String> files = [];

  Future<void> getDirs() async {
    dirs = [];
    files = [];
    // 获取目录下的所有文件和文件夹
    List<FileSystemEntity> entities = await Directory(path).list().toList();
    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        dirs.add(entity.path);
      } else if (entity is File) {
        files.add(entity.path);
      }
    }
    dirs.sort(
      (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    files.sort(
      (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
  }

  @override
  void initState() {
    super.initState();
    path = widget.path ?? '/storage/emulated/0/';
    // print(path);
    _init();
  }

  Future<void> _init() async {
    await getDirs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(path.split('/').last)),
      body: ListView.builder(
        itemCount: dirs.length + files.length + 1,
        itemBuilder: (context, index) {
          if (index == 0 && path != '/storage/emulated/0/') {
            return InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const ListTile(
                leading: Icon(Icons.folder),
                title: Text('..'),
              ),
            );
            // return LinkBuilder(
            //   child: ListTile(
            //     leading: const Icon(Icons.folder),
            //     title: Text('..'),
            //   ),
            //   builder:
            //       (context) => FileChooseDebug(
            //         path: '${path
            //             .split('/')
            //             .sublist(0, path.split('/').length - 1)
            //             .join('/')}/',
            //       ),
            // );
          } else if (index <= dirs.length && index > 0) {
            return LinkBuilder(
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: Text(dirs[index - 1].split('/').last),
              ),
              builder: (context) => FileChooseDebug(path: dirs[index - 1]),
            );
          } else if (index > dirs.length) {
            return LinkBuilder(
              child: ListTile(
                leading: const Icon(Icons.file_copy),
                title: Text(files[index - dirs.length - 1].split('/').last),
              ),
              builder:
                  (context) =>
                      PlayFileDebug(path: files[index - dirs.length - 1]),
            );
          }
          return Container();
        },
      ),
    );
  }
}
