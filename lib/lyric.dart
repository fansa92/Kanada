class Lyrics {
  static var timeRegex = RegExp(r'<(\d{2}:\d{2}\.\d{2})>');
  String string;

  Lyrics(this.string);

  List<Map<String, dynamic>> lyrics = [];

  Future<void> parse() async {
    lyrics = [];
    List<String> lines = string.split('\n');
    // lyrics =
    //     lines.map((line) {
    //       return {'content': line};
    //     }).toList();
    for (final line in lines) {
      final timeMatches = timeRegex.allMatches(line);
      final textParts = line.split(timeRegex);

      if (timeMatches.isEmpty) continue;

      final timeStamps = [
        for (final match in timeMatches) _parseTimeToMs(match.group(1)!),
      ];

      final contents = textParts.sublist(1).where((s) => s.isNotEmpty).toList();

      // if (timeStamps.length < 2 || contents.isEmpty) continue;

      final lyricWords = <Map<String, dynamic>>[];
      final buffer = StringBuffer();

      for (int i = 0; i < contents.length; i++) {
        final content = contents[i].trim();
        // if (content.isEmpty) continue;

        lyricWords.add({
          'word': content,
          'startTime': timeStamps[i],
          'endTime': timeStamps[i + 1],
        });
        buffer.write(content);
      }

      // if (lyricWords.isEmpty) continue;

      lyrics.add({
        'content':
            lyricWords.isEmpty
                ? textParts[0].substring(textParts[0].lastIndexOf(']') + 1)
                : buffer.toString(),
        'startTime': timeStamps.first,
        'endTime': timeStamps[lyricWords.length],
        'lyric':
            lyricWords.isEmpty
                ? {
                  'word':
                      lyricWords.isEmpty
                          ? textParts[0].substring(
                            textParts[0].lastIndexOf(']') + 1,
                          )
                          : buffer.toString(),
                  'startTime': timeStamps.first,
                  'endTime': timeStamps[lyricWords.length],
                }
                : lyricWords,
      });
    }
  }

  int _parseTimeToMs(String time) {
    final parts = time.split(':');
    final minute = int.parse(parts[0]);
    final secondParts = parts[1].split('.');
    final second = int.parse(secondParts[0]);
    final ms = int.parse(secondParts[1]) * 10;
    return minute * 60 * 1000 + second * 1000 + ms;
  }
}
