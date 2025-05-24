import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/lyric_sender.dart';

import '../../../global.dart';

class CurrentLyricDebug extends StatefulWidget {
  const CurrentLyricDebug({super.key});

  @override
  State<CurrentLyricDebug> createState() => _CurrentLyricDebugState();
}

class _CurrentLyricDebugState extends State<CurrentLyricDebug> {
  CurrentLyric currentLyric = CurrentLyric();
  String lyric = 'Unknown';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Lyric'),
      ),
      body: ListView(
        children: [
          Text(lyric),
          Text(currentLyric.path??"<path>"),
          ElevatedButton(
            onPressed: () async {
              if (Global.player.currentIndex == null) {
                return;
              }
              final playlist = Global.player.audioSource;
              final currentIndex = Global.player.currentIndex;

              // 防御性检查：确保播放列表和索引有效
              if (playlist is! ConcatenatingAudioSource ||
                  currentIndex == null ||
                  currentIndex >= playlist.children.length) {
                return;
              }

              dynamic current = playlist.children[currentIndex];
              // 获取新路径
              final newPath = current.tag.id;
              if (newPath != currentLyric.path) {
                currentLyric.path = newPath;
              }
              // 获取新位置
              currentLyric.position = Global.player.position.inMilliseconds;
              await currentLyric.getCurrentLyric();
              // print(currentLyric.content);
              setState(() {
                lyric = currentLyric.content;
              });
            },
            child: Text('Get Current Lyric'),
          ),
          ElevatedButton(
            onPressed: () {
              sendLyrics();
            },
            child: Text('Send Lyric'),
          )
        ],
      ),
    );
  }
}
