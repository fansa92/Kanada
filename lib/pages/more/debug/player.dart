import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../../global.dart';

class PlayerDebug extends StatefulWidget {
  const PlayerDebug({super.key});
  @override
  State<PlayerDebug> createState() => _PlayerDebugState();
}

class _PlayerDebugState extends State<PlayerDebug> {
  String echo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Debug')),
      body: Center(
        child: Column(
          children: [
            Text(echo),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  echo = 'Init() Start';
                });
                setState(() {
                  echo = 'Init() End';
                });
              },
              child: const Text('Init'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  echo = 'Start() Start';
                });
                // var item = MediaItem(
                //   id: 'http://192.168.31.151:5244/d/SYSTEM-MEMZ-CAO/D/code/python/qqmusic%E6%95%B4%E7%90%86%E9%9F%B3%E4%B9%90/miku/7870229.mp3',
                //   album: 'Album name',
                //   title: 'Track title',
                //   artist: 'Artist name',
                //   duration: const Duration(seconds: 200),
                //   artUri: Uri.parse('http://192.168.31.151:5244/d/SYSTEM-MEMZ-CAO/D/90422/Desktop/temp/emu.jpg'),
                // );
                // Global.audioHandler.playMediaItem(item);
                // Global.player.setAudioSource(AudioSource.uri(
                //     Uri.parse('http://10.0.2.3:5244/d/SYSTEM-MEMZ-CAO/D/code/python/qqmusic%E6%95%B4%E7%90%86%E9%9F%B3%E4%B9%90/miku/7870229.mp3'),
                //     tag: MediaItem(
                //       id: '7870229.mp3',
                //       album: 'Album name',
                //       title: 'Track title',
                //       artist: 'Artist name',
                //       duration: const Duration(seconds: 220),
                //       artUri: Uri.parse('http://10.0.2.3:5244/d/SYSTEM-MEMZ-CAO/D/90422/Desktop/temp/emu.jpg'),
                //     )
                // ));
                // Global.player.setUrl('http://192.168.31.151:5244/d/SYSTEM-MEMZ-CAO/D/code/python/qqmusic%E6%95%B4%E7%90%86%E9%9F%B3%E4%B9%90/miku/7870229.mp3');
                // Global.player.setFilePath('/storage/emulated/0/miku/ハローセカイ.mp3');
                // Global.player.setAudioSource(AudioSource.file(
                //     '/storage/emulated/0/miku/ハローセカイ.mp3',
                //     tag: MediaItem(
                //       id: 'ハローセカイ.mp3',
                //       album: 'Album name',
                //       title: 'Track title',
                //       artist: 'Artist name',
                //       duration: const Duration(seconds: 160),
                //       artUri: Uri.parse('http://192.168.31.151:5244/d/SYSTEM-MEMZ-CAO/D/90422/Desktop/temp/emu.jpg'),
                //     )
                // ));
                Global.player.setAudioSource(
                  AudioSource.file(
                    '/storage/emulated/0/Music/Yuki/miku/102220648.mp3',
                    tag: MediaItem(
                      id: '102220648.mp3',
                      album: 'Album name',
                      title: 'Track title',
                      artist: 'Artist name',
                      duration: const Duration(seconds: 160),
                      artUri: Uri.parse(
                        'http://192.168.31.151:5244/d/SYSTEM-MEMZ-CAO/D/90422/Desktop/temp/emu.jpg',
                      ),
                    ),
                  ),
                );
                setState(() {
                  echo = 'Start() End';
                });
              },
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  echo = 'Stop() Start';
                });
                // Global.audioHandler.stop();
                Global.player.stop();
                setState(() {
                  echo = 'Stop() End';
                });
              },
              child: const Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  echo = 'Pause() Start';
                });
                // Global.audioHandler.pause();
                Global.player.pause();
                setState(() {
                  echo = 'Pause() End';
                });
              },
              child: const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  echo = 'Play() Start';
                });
                // Global.audioHandler.play();
                Global.player.play();
                setState(() {
                  echo = 'Play() End';
                });
              },
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  echo =
                      'position: ${Global.player.position}\nduration: ${Global.player.duration}';
                });
              },
              child: const Text('Check'),
            ),
          ],
        ),
      ),
    );
  }
}
