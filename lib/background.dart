import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:kanada_lyric_sender/kanada_lyric_sender.dart';
import 'package:kanada_volume/kanada_volume.dart';
import 'global.dart';
import 'lyric.dart';
import 'metadata.dart';
import 'dart:convert';
import 'dart:io';

final CurrentLyric currentLyric = CurrentLyric();
// bool isPlaying = false;

// Future<void> startBackground() async {
//   isPlaying = true;
//   Timer.periodic(Duration(milliseconds: 100), timerFunc);
// }
//
// Future<void> timerFunc(Timer timer) async {
//   background();
//   if (Global.player.playing&&!isPlaying) {
//     isPlaying = true;
//     timer.cancel();
//     Timer.periodic(Duration(milliseconds: 100), timerFunc);
//   }
//   else if (!Global.player.playing&&isPlaying) {
//     isPlaying = false;
//     timer.cancel();
//     Timer.periodic(Duration(milliseconds: 500), timerFunc);
//   }
// }

Future<void> background() async {
  if (!await getCurrentLyric()) return;

  sendLyrics();
  writeLyrics();
  mutePause();
}

Future<bool> getCurrentLyric() async {
  if (Global.player.currentIndex == null) {
    // await Future.delayed(Duration(milliseconds: 1), sendLyrics);
    return false;
  }
  final playlist = Global.player.audioSources;
  final currentIndex = Global.player.currentIndex;

  // 防御性检查：确保播放列表和索引有效
  if (currentIndex == null) {
    return false;
  }

  final current = playlist[currentIndex];
  final tag = (current as UriAudioSource).tag;
  // 获取新路径
  final newPath = tag.id;
  if (newPath != currentLyric.path) {
    currentLyric.path = newPath;
  }
  // 获取新位置
  currentLyric.position = Global.player.position.inMilliseconds;
  // 获取当前歌词
  if (!(await currentLyric.getCurrentLyric())) {
    // await Future.delayed(Duration(milliseconds: 1), sendLyrics);
    return false;
  }
  return true;
}

Future<void> sendLyrics() async {
  KanadaLyricSenderPlugin.sendLyric(
    currentLyric.content,
    (currentLyric.duration / 1000).ceil().toInt(),
  );
}

Future<void> writeLyrics() async {
  final Map<String, dynamic> state = {
    'package': 'com.hontouniyuki.kanada',
    'lyric': currentLyric.content,
    'playing': Global.player.playing,
    'name': Global.metadataCache?.title,
    'singer': Global.metadataCache?.artist,
    'album': Global.metadataCache?.album,
  };
  // /storage/emulated/0/lyric.json
  final file = File('/storage/emulated/0/lyric.json');
  final old = await file.readAsString();
  final encoded = json.encode(state);
  final st = old;
  if (st != encoded) {
    await file.writeAsString(encoded);
  }
}

Future<void> mutePause() async {
  final volume = await KanadaVolumePlugin.getVolume();
  print('$volume ${DateTime.now().toIso8601String()}');
  if (volume == 0) {
    Global.player.pause();

    final startTime = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;

      if (await KanadaVolumePlugin.getVolume() != 0) {
        Global.player.play();
        timer.cancel();
      }

      if (elapsed >= 5000) {
        // 5秒后停止
        timer.cancel();
      }
    });
  }
}

class CurrentLyric {
  String? path;
  int? position;
  Lyrics? lyrics;
  String content = '';
  int duration = 0;
  int startTime = 0;
  int endTime = 0;
  List<Map<String, dynamic>> words = [];

  Future<void> getMetadata() async {
    Global.metadataCache = Metadata(path!);
    await Global.metadataCache!.getLyric();
  }

  Future<void> getLyrics() async {
    lyrics = Lyrics(Global.metadataCache!.lyric!);
    await lyrics!.parse();
  }

  Future<bool> getCurrentLyric() async {
    if (Global.metadataCache == null ||
        Global.metadataCache!.path != path ||
        lyrics == null) {
      await getMetadata();
      await getLyrics();
    }
    for (final lyric in lyrics!.lyrics) {
      if (position! >= lyric['startTime'] && position! < lyric['endTime']) {
        bool f2 = true;
        if (content == lyric['content']) {
          f2 = false;
        }
        content = lyric['content'];
        duration = lyric['endTime'] - lyric['startTime'];
        startTime = lyric['startTime'];
        endTime = lyric['endTime'];
        words = lyric['lyric'];
        // print(content);
        return f2;
      }
    }
    return false;
  }
}
