import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';
import 'package:kanada/widgets/link.dart';
import 'package:kanada/widgets/music_info.dart';
import '../global.dart';
import '../settings.dart';
import 'folder.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  Playlist playlist = Playlist('/ALL/');
  Map<String, Playlist> folders = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    playlist.getSongs().then((value) {
      Global.playlist = playlist.songs;
      if (mounted) {
        setState(() {});
      }
    });
    for (var i = 0; i < Settings.folders.length; i++) {
      final path = Settings.folders[i];
      folders[path] = Playlist(path);
    }
    setState(() {});
    await Future.wait(folders.values.map((e) => e.init()));
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
            child: Hero(
              tag: 'search-bar',
              child: SearchAnchor.bar(
                // isFullScreen: false,
                barHintText: 'Search',
                barBackgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.secondaryContainer,
                ),
                suggestionsBuilder:
                    (context, controller) => List.generate(
                      playlist.songs.length,
                      (index) => MusicInfoSearch(
                        path: playlist.songs[index],
                        keywords: controller.text,
                      ),
                    ),
              ),
            ),
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
                      folders[Settings.folders[index - 1]]?.name ??
                          Settings.folders[index - 1],
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
