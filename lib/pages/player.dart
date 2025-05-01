import 'dart:io';

import 'package:flutter/material.dart';
import '../../global.dart';
import '../metadata.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static final GlobalKey pictureKey = GlobalKey();
  String path = '';
  Metadata? metadata;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!Global.init) {
      path = Global.path;
      setState(() {});
      metadata = Metadata(path);
      await Future.wait([metadata!.getMetadata(), metadata!.getPicture()]);
      setState(() {});
      while (!Global.init) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    dynamic playlist = Global.player.audioSource;
    path = playlist.children[Global.player.currentIndex].tag.id;
    setState(() {});
    if (path != metadata!.path) {
      // 并行执行带缓存的操作
      await Future.wait([metadata!.getMetadata(), metadata!.getPicture()]);
      setState(() {});

      // 并行执行不带缓存的操作
      await Future.wait([
        metadata!.getMetadata(cache: false),
        metadata!.getPicture(cache: false),
      ]);
      setState(() {});
    }
    print(metadata);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            key: pictureKey,
            width: 200,
            height: 200,
            child:
                metadata?.picture != null
                    ? Image.memory(metadata!.picture!)
                    : (metadata?.pictureCache != null
                        ? Image.file(File(metadata!.pictureCache!))
                        : Icon(Icons.music_note)),
          ),
        ],
      ),
    );
  }
}
