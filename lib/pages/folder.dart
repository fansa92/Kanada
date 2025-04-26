import 'package:flutter/material.dart';
import 'package:kanada/widgets/music_info.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class FolderPage extends StatefulWidget {
  final String path;

  const FolderPage({super.key, required this.path});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<FileSystemEntity> files = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final dir = Directory(widget.path);
    List<FileSystemEntity> entities = await dir.list().toList();

    files =
        entities.where((entity) {
          String extension = p.extension(entity.path).toLowerCase();
          return extension == '.mp3' || extension == '.flac';
        }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split('/')[widget.path.split('/').length - 2]),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return ListTile(title: MusicInfo(path: files[index].path));
        },
      ),
    );
  }
}
