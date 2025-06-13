import 'dart:convert';

import 'package:kanada/tool.dart';

/// 歌词解析类，用于处理带时间戳的歌词格式
class Lyrics {
  /// 正则表达式匹配歌词时间戳格式 <分:秒.百分秒>
  static var timeRegex = RegExp(r'<(\d+:\d+\.\d+)>');
  static var timeRegex2 = RegExp(r'\[(\d+:\d+\.\d+)]');

  /// 原始歌词字符串
  String string;

  /// 解析后的歌词数据结构
  List<Map<String, dynamic>> lyrics = [];

  /// 构造函数，接收原始歌词字符串
  Lyrics(this.string);

  /// 解析歌词的主方法
  Future<void> parse() async {
    lyrics = [];
    List<String> lines = string.split('\n');
    Map<String, dynamic> header = {};
    if (lines[0].startsWith('[extra]')) {
      header = {'extra': jsonDecode(lines[0].substring(7))};
      lines = lines.sublist(1);
    }

    for (final line in lines) {
      // 匹配行内所有时间戳
      final timeMatches = timeRegex.allMatches(line);
      // 分割时间戳和歌词内容
      final textParts = line.split(timeRegex);

      if (timeMatches.isEmpty) continue;

      // 转换时间戳为毫秒格式
      final timeStamps = [
        for (final match in timeMatches) parseTimeToMs(match.group(1)!),
      ];

      // 过滤空字符串并获取歌词内容部分
      final contents = textParts.sublist(1).where((s) => s.isNotEmpty).toList();

      final lyricWords = <Map<String, dynamic>>[];
      final buffer = StringBuffer(); // 用于拼接完整歌词行

      // 构建逐词歌词结构
      for (int i = 0; i < contents.length; i++) {
        final content = contents[i].trim();

        lyricWords.add({
          'word': content,
          'startTime': timeStamps[i],
          'endTime': timeStamps[(i + 1).clamp(0, timeStamps.length - 1)],
        });
        buffer.write(content);
      }

      // 添加解析后的歌词行
      lyrics.add({
        'content':
            lyricWords.isEmpty
                ? textParts[0].substring(
                  textParts[0].lastIndexOf(']') + 1,
                ) // 无时间戳的纯文本行
                : buffer.toString(),
        'startTime': timeStamps.first,
        'endTime':
            timeStamps[lyricWords.length.clamp(0, timeStamps.length - 1)],
        'lyric':
            lyricWords.isEmpty
                ? [
                  {
                    'word': textParts[0].substring(
                      textParts[0].lastIndexOf(']') + 1,
                    ),
                    'startTime': timeStamps.first,
                    'endTime':
                        timeStamps[lyricWords.length.clamp(
                          0,
                          timeStamps.length - 1,
                        )],
                  },
                ]
                : lyricWords,
        'originalIndex': lyrics.length,
      });
    }

    if (lyrics.isEmpty) {
      for (int i = 0; i < lines.length; i++) {
        // [00:39.94]新作動画 投稿だ
        final line = lines[i];
        final match = timeRegex2.firstMatch(line);
        final textParts = line.split(timeRegex2);
        if (match == null) continue;
        // 转换时间戳为毫秒格式
        final timeStamps = parseTimeToMs(match.group(1)!);
        final ctx = textParts[1];
        if (i >= lines.length - 1) {
          lyrics.add({
            'content': ctx,
            'startTime': timeStamps,
            'endTime': timeStamps,
            'lyric': [
              {'word': ctx, 'startTime': timeStamps, 'endTime': timeStamps},
            ],
            'originalIndex': lyrics.length,
          });
          continue;
        }
        // print('$i ${lines.length - 1}');
        final nextMatch = timeRegex2.firstMatch(lines[i + 1]);
        if (nextMatch == null) continue;
        final nextTimeStamps = parseTimeToMs(nextMatch.group(1)!);
        lyrics.add({
          'content': ctx,
          'startTime': timeStamps,
          'endTime': nextTimeStamps,
          'lyric': [
            {'word': ctx, 'startTime': timeStamps, 'endTime': nextTimeStamps},
          ],
          'originalIndex': lyrics.length,
        });
      }
    }

    // print(header);

    if (header['extra']?['sort']==false) return;

    // 按时间戳排序
    lyrics.sort((a, b) {
      final timeCompare = a['startTime'].compareTo(b['startTime']);
      if (timeCompare != 0) return timeCompare;
      return a['originalIndex'].compareTo(b['originalIndex']);
    });
  }
}
