import 'dart:async';
import 'package:kanada_lyric_sender/kanada_lyric_sender.dart'; // 歌词发送插件
import 'package:kanada_volume/kanada_volume.dart'; // 音量控制插件
import 'global.dart';
import 'lyric.dart';
import 'metadata.dart';
import 'dart:convert'; // JSON 编码/解码
import 'dart:io'; // 文件操作

// 全局歌词实例
final CurrentLyric currentLyric = CurrentLyric();
// 播放状态标志
bool isPlaying = false;

/// 启动后台任务
Future<void> startBackground() async {
  isPlaying = true;
  // 每100毫秒执行一次定时任务
  Timer.periodic(Duration(milliseconds: 100), timerFunc);
}

/// 定时器回调函数
Future<void> timerFunc(Timer timer) async {
  await background();
  // 根据播放状态动态调整轮询间隔
  if (Global.player.playing && !isPlaying) {
    isPlaying = true;
    timer.cancel();
    Timer.periodic(Duration(milliseconds: 100), timerFunc);
  } else if (!Global.player.playing && isPlaying) {
    isPlaying = false;
    timer.cancel();
    Timer.periodic(Duration(milliseconds: 500), timerFunc);
  }
}

/// 后台任务主逻辑
Future<void> background() async {
  await mutePause();       // 静音暂停处理
  if (!await getCurrentLyric()) return; // 获取当前歌词
  await sendLyrics();      // 发送歌词到其他组件
  await writeLyrics();     // 写入歌词到文件
}

/// 获取当前播放歌词
Future<bool> getCurrentLyric() async {
  final newPath = Global.player.current;
  if (newPath != currentLyric.path) {
    currentLyric.path = newPath;
  }
  // 更新播放位置（毫秒）
  currentLyric.position = Global.player.position.inMilliseconds;
  // 获取并更新当前歌词
  if (!(await currentLyric.getCurrentLyric())) {
    return false;
  }
  return true;
}

/// 发送歌词到其他组件
Future<void> sendLyrics() async {
  KanadaLyricSenderPlugin.sendLyric(
    currentLyric.content,
    (currentLyric.duration / 1000).ceil().toInt(), // 持续时间（秒）
  );
}

/// 将歌词写入JSON文件
Future<void> writeLyrics() async {
  // 转义非ASCII字符为Unicode
  String escapeToUnicode(String input) {
    return input.replaceAllMapped(RegExp(r'[^\x00-\x7F]'),
            (match) => '\\u${match.group(0)!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}');
  }

  // 构建状态数据
  final Map<String, dynamic> state = {
    'package': 'com.hontouniyuki.kanada',
    'lyric': escapeToUnicode(currentLyric.content),
    'playing': Global.player.playing,
    'name': Global.metadataCache?.title != null
        ? escapeToUnicode(Global.metadataCache!.title!)
        : null,
    'singer': Global.metadataCache?.artist != null
        ? escapeToUnicode(Global.metadataCache!.artist!)
        : null,
    'album': Global.metadataCache?.album != null
        ? escapeToUnicode(Global.metadataCache!.album!)
        : null,
  };

  // 写入外部存储
  final file = File('/storage/emulated/0/lyric.json');
  final old = await file.readAsString();
  final encoded = json.encode(state).replaceAll('\\\\', '\\');

  // 仅在内容变化时写入
  if (old != encoded) {
    await file.writeAsString(encoded);
  }
}

/// 静音暂停处理逻辑
Future<void> mutePause() async {
  final volume = await KanadaVolumePlugin.getVolume();
  if (volume == 0) {
    Global.player.pause();

    final startTime = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;

      // 检测音量恢复
      if (await KanadaVolumePlugin.getVolume() != 0) {
        Global.player.play();
        timer.cancel();
      }

      // 5秒超时检测
      if (elapsed >= 5000) {
        timer.cancel();
      }
    });
  }
}

/// 当前歌词数据模型
class CurrentLyric {
  String? path;         // 文件路径
  int? position;         // 当前播放位置（毫秒）
  Lyrics? lyrics;        // 歌词解析器
  String content = '';   // 当前歌词内容
  int duration = 0;      // 歌词持续时间（毫秒）
  int startTime = 0;     // 歌词开始时间
  int endTime = 0;       // 歌词结束时间
  List<Map<String, dynamic>> words = []; // 逐字时间数据

  /// 获取元数据
  Future<void> getMetadata() async {
    Global.metadataCache = Metadata(path!);
    await Global.metadataCache!.getLyric();
  }

  /// 解析歌词
  Future<void> getLyrics() async {
    lyrics = Lyrics(Global.metadataCache!.lyric!);
    await lyrics!.parse();
  }

  /// 获取当前时间点的歌词
  Future<bool> getCurrentLyric() async {
    // 检查是否需要重新加载歌词
    if (Global.metadataCache == null ||
        Global.metadataCache!.path != path ||
        lyrics == null) {
      await getMetadata();
      await getLyrics();
    }

    // 遍历查找匹配时间段的歌词
    for (final lyric in lyrics!.lyrics) {
      if (position! >= lyric['startTime'] && position! < lyric['endTime']) {
        bool hasChanged = true;
        // 检查歌词内容是否变化
        if (content == lyric['content']) {
          hasChanged = false;
        }
        // 更新歌词信息
        content = lyric['content'];
        duration = lyric['endTime'] - lyric['startTime'];
        startTime = lyric['startTime'];
        endTime = lyric['endTime'];
        words = lyric['lyric'];
        return hasChanged;
      }
    }
    return false;
  }
}
