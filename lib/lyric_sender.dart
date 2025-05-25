import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada_lyric_sender/kanada_lyric_sender.dart';
import 'global.dart';
import 'lyric.dart';
import 'metadata.dart';

final CurrentLyric currentLyric = CurrentLyric();
// bool isPlaying= false;

Future<void> sendLyrics() async {
  // print('sendLyrics');
  if (Global.player.currentIndex == null) {
    // await Future.delayed(Duration(milliseconds: 1), sendLyrics);
    return;
  }
  final playlist = (Global.player.audioSource as ConcatenatingAudioSource).children;
  final currentIndex = Global.player.currentIndex;

  // 防御性检查：确保播放列表和索引有效
  if (currentIndex == null) {
    return;
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
    return;
  }
  // 发送歌词
  // print(
  //   'content: ${currentLyric.content} duration: ${currentLyric.duration}',
  // );
  KanadaLyricSenderPlugin.sendLyric(
    currentLyric.content,
    // currentLyric.duration,
  );
  // final sources = playlist;
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
  // Global.player.setAudioSource(
  //   ConcatenatingAudioSource(children: sources),
  //   initialIndex: currentIndex,
  // );
  // Global.player.setAudioSources(sources, initialIndex: currentIndex);
  // final audioSource = AudioSource.file(
  //   tag.id,
  //   tag: MediaItem(
  //     id: tag.id,
  //     album: tag.album,
  //     title: currentLyric.content,
  //     artist:
  //     '${Global.metadataCache?.title} - ${Global.metadataCache?.artist}',
  //     duration: tag.duration,
  //     artUri: tag.artUri,
  //   ),
  // );
  // final position = Global.player.position;
  // await (Global.player.audioSource as ConcatenatingAudioSource).removeAt(currentIndex);
  // await (Global.player.audioSource as ConcatenatingAudioSource).insert(currentIndex, audioSource);
  // // await Global.player.seekToPrevious();
  // // Global.player.seekToNext();
  // await Global.player.seek(position, index: currentIndex);
}

class CurrentLyric {
  String? path;
  int? position;
  Lyrics? lyrics;
  String content = '';
  int duration = 0;
  int startTime = 0;
  int endTime = 0;
  List<Map<String, dynamic>> words=[];

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
