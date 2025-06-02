// import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:kanada/background.dart';

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
      appBar: AppBar(title: Text('Current Lyric')),
      body: ListView(
        children: [
          Text(lyric),
          Text(currentLyric.path ?? "<path>"),
          ElevatedButton(
            onPressed: () async {
              final newPath = Global.player.current;
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
              background();
            },
            child: Text('Send Lyric'),
          ),
          ElevatedButton(
            onPressed: () async {
              // final playlist = Global.player.audioSource;
              // final currentIndex = Global.player.currentIndex;
              // if (playlist is! ConcatenatingAudioSource ||
              //     currentIndex == null ||
              //     currentIndex >= playlist.children.length) {
              //   return;
              // }
              // final sources = playlist.children;
              // final current = sources[currentIndex];
              // final tag = (current as UriAudioSource).tag;
              // currentLyric.path = tag.id;
              // currentLyric.position = Global.player.position.inMilliseconds;
              // sources[currentIndex] = AudioSource.file(
              //   tag.id,
              //   tag: MediaItem(
              //     id: tag.id,
              //     album: tag.album,
              //     title: currentLyric.content,
              //     artist:
              //         '${Global.metadataCache?.title} - ${Global.metadataCache?.artist}',
              //     duration: tag.duration,
              //     artUri: tag.artUri,
              //   ),
              // );
              // // Global.player.setAudioSources(sources, initialIndex: currentIndex);
              // Global.player.setAudioSource(
              //   ConcatenatingAudioSource(children: sources),
              //   initialIndex: currentIndex,
              // );
              // if(Global.player.audioSources.isNotEmpty) {
              //   await currentLyric.getMetadata();
              //   await currentLyric.getCurrentLyric();
              //   final playlist = Global.player.audioSources;
              //   final currentIndex = Global.player.currentIndex;
              //   if (currentIndex == null ||
              //       currentIndex >= playlist.length) {
              //     return;
              //   }
              //   final sources = playlist;
              //   final current = sources[currentIndex];
              //   final tag = (current as UriAudioSource).tag;
              //   // final audioSource = AudioSource.file(
              //   //     tag.id,
              //   //     tag: MediaItem(
              //   //       id: tag.id,
              //   //       album: tag.album,
              //   //       title: currentLyric.content,
              //   //       artist:
              //   //           '${Global.metadataCache?.title} - ${Global.metadataCache?.artist}',
              //   //       duration: tag.duration,
              //   //       artUri: tag.artUri,
              //   //     ),
              //   //   );
              //   final position = Global.player.position;
              //   // await (Global.player.audioSource as ConcatenatingAudioSource).removeAt(currentIndex);
              //   // await (Global.player.audioSource as ConcatenatingAudioSource).insert(currentIndex, audioSource);
              //   // await Global.player.seekToPrevious();
              //   // Global.player.seekToNext();
              //   await Global.player.seek(position, index: Global.player.currentIndex!-1);
              //   // Global.player.setAudioSource(Global.player.audioSource!);
              //   // lyric =
              //   //     ((Global.player.audioSource as ConcatenatingAudioSource)
              //   //         .children[currentIndex]
              //   //     as UriAudioSource)
              //   //         .tag
              //   //         .title;
              //   setState(() {});
              // }
            },
            child: const Text('Set Title'),
          ),
        ],
      ),
    );
  }
}
