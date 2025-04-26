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
        itemCount: Settings.folders.length,
        itemBuilder: (context, index) {
          return LinkBuilder(
            builder: (context) => FolderPage(path: Settings.folders[index]),
            child: ListTile(
              title: Text(Settings.folders[index].split('/')[Settings.folders[index].split('/').length - 2]),
              subtitle: Text(Settings.folders[index]),
            ),
          );
        },
      ),
    );
  }
}
