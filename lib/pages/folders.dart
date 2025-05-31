import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanada/widgets/link.dart';
import 'package:kanada/widgets/music_info.dart';
import 'package:path/path.dart' as p;

import '../global.dart';
import '../settings.dart';
import 'folder.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  List<FileSystemEntity> files = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    files.clear();
    final dirs = Settings.folders.map((e) => Directory(e)).toList();
    for (var dir in dirs) {
      List<FileSystemEntity> entities = await dir.list().toList();
      files.addAll(
        entities.where((entity) {
          String extension = p.extension(entity.path).toLowerCase();
          return extension == '.mp3' || extension == '.flac';
        }),
      );
    }
    // print(files);
    Global.playlist = files.map((e) => e.path).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Hero(tag: 'search-bar', child: SearchAnchor.bar(
              // isFullScreen: false,
              barHintText: 'Search',
              suggestionsBuilder:
                  (context, controller) => List.generate(
                files.length,
                    (index) => MusicInfoSearch(
                  path: files[index].path,
                  keywords: controller.text,
                ),
              ),
            )),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Settings.folders.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return LinkBuilder(
                    builder: (context) => FolderPage(path: '/ALL/'),
                    child: ListTile(
                      title: Text('All'),
                      subtitle: Text('All Music'),
                    ),
                  );
                }
                return LinkBuilder(
                  builder:
                      (context) =>
                          FolderPage(path: Settings.folders[index - 1]),
                  child: ListTile(
                    title: Text(
                      Settings.folders[index - 1].split(
                        '/',
                      )[Settings.folders[index - 1].split('/').length - 2],
                    ),
                    subtitle: Text(Settings.folders[index - 1]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
