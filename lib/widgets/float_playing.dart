import 'dart:io';
import 'package:flutter/material.dart';
import '../global.dart';
import '../metadata.dart';
import 'link.dart' as link;

class FloatPlaying extends StatefulWidget {
  const FloatPlaying({super.key});

  @override
  State<FloatPlaying> createState() => _FloatPlayingState();
}

class _FloatPlayingState extends State<FloatPlaying> {
  static final GlobalKey pictureKey = GlobalKey();
  String? path;
  Metadata? metadata;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _fresh();
  }

  Future<void> _fresh() async {
    dynamic playlist = Global.player.audioSource;
    path = playlist.children[Global.player.currentIndex].tag.id;
    metadata = Metadata('');
    if (path != metadata!.path) {
      metadata = Metadata(path!);
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
  }

  @override
  Widget build(BuildContext context) {
    return link.Link(
      route: '/player',
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 50,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                SizedBox(
                  key: pictureKey,
                  width: 50,
                  height: 50,
                  child:
                      metadata?.picture != null
                          ? Image.memory(metadata!.picture!)
                          : (metadata?.pictureCache != null
                              ? Image.file(File(metadata!.pictureCache!))
                              : Icon(Icons.music_note)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    metadata?.title ?? path?.split('/').last ?? 'Unknown Title',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Global.player.playing ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    // if (Global.player.playing) {
                    //   Global.player.pause();
                    // } else {
                    //   Global.player.play();
                    // }
                    (Global.player.playing
                            ? Global.player.pause()
                            : Global.player.play())
                        .then((value) {
                          setState(() {});
                          _fresh();
                        });
                  },
                ),

                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    Global.player.seekToNext().then((value) {
                      setState(() {});
                      _fresh();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
