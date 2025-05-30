import 'package:flutter/material.dart';
import 'package:kanada/widgets/link.dart';

import '../settings.dart';
import 'folder.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: ListView.builder(
        itemCount: Settings.folders.length+1,
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
            builder: (context) => FolderPage(path: Settings.folders[index-1]),
            child: ListTile(
              title: Text(Settings.folders[index-1].split('/')[Settings.folders[index-1].split('/').length - 2]),
              subtitle: Text(Settings.folders[index-1]),
            ),
          );
        },
      ),
    );
  }
}
