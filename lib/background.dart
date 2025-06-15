import 'dart:async';
import 'package:kanada/settings.dart';
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
    KanadaLyricSenderPlugin.clearLyric();
  }
}

/// 后台任务主逻辑
Future<void> background() async {
  if (Settings.mutePause) {
    mutePause(); // 静音暂停处理
  }
  // 获取当前歌词
  getCurrentLyric().then((bool state) {
    if (Global.player.playing && Settings.lyricSend) {
      sendLyrics(); // 发送歌词到其他组件
    }
    if (Settings.lyricWrite) {
      writeLyrics(); // 写入歌词到文件
    }
  });
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
  return await currentLyric.getCurrentLyric();
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
    return input.replaceAllMapped(
      RegExp(r'[^\x00-\x7F]'),
      (match) =>
          '\\u${match.group(0)!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}',
    );
  }

  // 构建状态数据
  final Map<String, dynamic> state = {
    'package': 'com.hontouniyuki.kanada',
    'lyric': escapeToUnicode(currentLyric.content),
    'playing': Global.player.playing,
    'name':
        Global.metadataCache?.title != null
            ? escapeToUnicode(Global.metadataCache!.title!)
            : null,
    'singer':
        Global.metadataCache?.artist != null
            ? escapeToUnicode(Global.metadataCache!.artist!)
            : null,
    'album':
        Global.metadataCache?.album != null
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
  if (!Global.player.playing) return;
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
  String? path; // 文件路径
  int? position; // 当前播放位置（毫秒）
  Lyrics? lyrics; // 歌词解析器
  int index = -1; // 当前歌词索引
  String content = ''; // 当前歌词内容
  int duration = 0; // 歌词持续时间（毫秒）
  int startTime = 0; // 歌词开始时间
  int endTime = 0; // 歌词结束时间
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
    // 元数据检查逻辑保持不变...
    if (Global.metadataCache == null ||
        Global.metadataCache!.id != path ||
        lyrics == null) {
      await getMetadata();
      await getLyrics();
    }

    // 空歌词处理
    if (lyrics!.lyrics.isEmpty) {
      return handleEmptyLyrics();
    }

    final lyricList = lyrics!.lyrics;
    final int pos = position!;

    // 1. 快速路径：检查当前行和相邻行
    if (index >= 0 && index < lyricList.length) {
      final currentLyric = lyricList[index];

      // 检查当前行是否仍然有效
      if (pos >= currentLyric['startTime'] && pos < currentLyric['endTime']) {
        return false; // 歌词未变化
      }

      // 检查相邻行（针对连续播放优化）
      if (_checkAdjacentLines(pos, lyricList)) {
        return true;
      }
    }

    // 2. 二分查找核心 - 确保找到第一个匹配行
    int low = 0;
    int high = lyricList.length - 1;
    int? firstMatchIndex;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final lyric = lyricList[mid];
      final start = lyric['startTime'];
      final end = lyric['endTime'];

      if (pos >= start && pos < end) {
        // 找到匹配行，但需要检查前面是否有更早的匹配
        firstMatchIndex = _findFirstMatch(mid, pos, lyricList);
        break;
      } else if (pos < start) {
        high = mid - 1;
      } else { // pos >= end
        low = mid + 1;
      }
    }

    // 3. 结果处理
    if (firstMatchIndex != null) {
      return updateLyricState(firstMatchIndex, lyricList[firstMatchIndex]);
    }

    // 4. 边界情况处理
    return handleEdgeCases(lyricList, pos);
  }

  /// 向前搜索找到第一个匹配行
  int _findFirstMatch(int startIndex, int pos, List<dynamic> lyricList) {
    int firstMatch = startIndex;

    // 向前搜索可能的更早匹配
    for (int i = startIndex - 1; i >= 0; i--) {
      final lyric = lyricList[i];
      if (pos >= lyric['startTime'] && pos < lyric['endTime']) {
        firstMatch = i; // 找到更早的匹配
      } else {
        break; // 已超出匹配范围
      }
    }

    return firstMatch;
  }

  /// 检查相邻行（针对连续播放场景优化）
  bool _checkAdjacentLines(int pos, List<dynamic> lyricList) {
    // 优先检查下一行（常见于正常播放）
    if (index + 1 < lyricList.length) {
      final nextLyric = lyricList[index + 1];
      if (pos >= nextLyric['startTime'] && pos < nextLyric['endTime']) {
        return updateLyricState(index + 1, nextLyric);
      }
    }
    if (index + 2 < lyricList.length) {
      final nextLyric = lyricList[index + 2];
      if (pos >= nextLyric['startTime'] && pos < nextLyric['endTime']) {
        return updateLyricState(index + 2, nextLyric);
      }
    }

    // 检查上一行（常见于回退操作）
    if (index - 1 >= 0) {
      final prevLyric = lyricList[index - 1];
      if (pos >= prevLyric['startTime'] && pos < prevLyric['endTime']) {
        return updateLyricState(index - 1, prevLyric);
      }
    }

    return false;
  }

  /// 边界情况处理
  bool handleEdgeCases(List<dynamic> lyricList, int pos) {
    // 播放进度在首行之前
    if (pos < lyricList.first['startTime']) {
      return resetLyricState();
    }
    // 播放进度在末行之后
    else if (pos >= lyricList.last['endTime']) {
      final lastIndex = lyricList.length - 1;
      return updateLyricState(lastIndex, lyricList[lastIndex]);
    }
    return false;
  }

  /// 更新歌词状态
  bool updateLyricState(int newIndex, Map<String, dynamic> lyric) {
    // 检查是否真正需要更新
    if (index == newIndex &&
        content == lyric['content'] &&
        startTime == lyric['startTime']) {
      return false;
    }

    // 更新状态
    index = newIndex;
    content = lyric['content'];
    startTime = lyric['startTime'];
    endTime = lyric['endTime'];
    duration = endTime - startTime;
    words = lyric['lyric'] ?? [];

    return true;
  }

  /// 处理空歌词情况
  bool handleEmptyLyrics() {
    if (content.isNotEmpty) {
      resetLyricState();
      return true;
    }
    return false;
  }

  /// 重置歌词状态
  bool resetLyricState() {
    if (index != -1 || content.isNotEmpty) {
      index = -1;
      content = '';
      duration = 0;
      startTime = 0;
      endTime = 0;
      words = [];
      return true;
    }
    return false;
  }
}
