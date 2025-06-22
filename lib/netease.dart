import 'dart:typed_data';
import 'package:kanada/settings.dart';
import 'package:kanada/tool.dart';
import 'metadata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// 元数据管理类，负责音频文件的元数据读取和缓存
class MetadataNetEase extends Metadata {
  MetadataNetEase(super.id) : super.internal();

  int get mid => int.tryParse(id.replaceAll('netease://', '')) ?? 0;
  String? coverUrl;

  /// 获取元数据（带缓存功能）
  /// [cache] 是否使用缓存
  /// [timeout] 缓存超时时间（秒），默认7天
  @override
  Future<Metadata> getMetadata({
    bool cache = false,
    int timeout = 604800,
  }) async {
    if (cache && gotMetadata && title != null) {
      return this;
    }
    gotMetadata = true;

    final meta = await Metadata.metadataCacheManager.getCachedFile(id);

    // 检查缓存有效性
    if (cache &&
        await meta.exists() &&
        DateTime.now().difference(await meta.lastModified()).inSeconds <
            timeout) {
      final data = jsonDecode(await meta.readAsString());
      title = data['title'];
      artist = data['artist'];
      album = data['album'];
      duration = Duration(milliseconds: data['duration']);
      return this;
    }

    // 从文件读取元数据
    final data = await NetEase.getDetail(mid);
    if (data == null) {
      return this;
    }
    // print(data['songs']);
    if (data['songs']?.length == 0) {
      return this;
    }
    title = data['songs']?[0]?['name'] as String?;
    artist = data['songs']?[0]?['ar']
        ?.map((e) => e['name']?.toString())
        .join('/');
    album = data['songs']?[0]?['al']?['name'] as String?;
    duration =
        data['songs']?[0]?['dt'] != null
            ? Duration(milliseconds: (data['songs'][0]['dt'] as int))
            : null;
    coverUrl = data['songs']?[0]?['al']?['picUrl'] as String?;

    // 检查封面缓存
    final cachedCover = await Metadata.coverCacheManager.getCachedFile(id);
    if (await cachedCover.exists()) {
      coverCache = cachedCover.path;
      coverPath = coverCache;
    }

    // 写入元数据缓存
    await meta.create(recursive: true);
    await meta.writeAsString(
      jsonEncode({
        'title': title,
        'artist': artist,
        'album': album,
        'duration': duration?.inMilliseconds,
      }),
    );

    return this;
  }

  /// 获取歌词（带缓存功能）
  @override
  Future<String?> getLyric({bool cache = true, int timeout = 604800}) async {
    if (cache && gotLyric && lyric != null) {
      return lyric;
    }
    gotLyric = true;

    final lrc = await Metadata.lyricCacheManager.getCachedFile(id);

    // 检查歌词缓存
    if (cache &&
        await lrc.exists() &&
        DateTime.now().difference(await lrc.lastModified()).inSeconds <
            timeout) {
      lyric = await lrc.readAsString();
      return lyric;
    }

    // 从文件读取歌词
    lyric = await NetEase.getLyric(mid);

    // 写入歌词缓存
    if (lyric != null) {
      await lrc.create(recursive: true);
      await lrc.writeAsString(lyric!);
    }
    return lyric;
  }

  /// 获取专辑封面（带缓存功能）
  @override
  Future<String?> getCover({bool cache = true, int timeout = 604800}) async {
    if (cache && gotCover && coverPath != null) {
      return coverPath;
    }
    gotCover = true;

    final pic = await Metadata.coverCacheManager.getCachedFile(id);

    // 检查封面缓存
    if (cache &&
        await pic.exists() &&
        DateTime.now().difference(await pic.lastModified()).inSeconds <
            timeout) {
      // cover = await pic.readAsBytes();
      coverPath = pic.path;
      return coverPath;
    }

    // 获取专辑封面并保存
    if (coverUrl == null) {
      await getMetadata();
    }
    if (coverUrl == null) {
      return null;
    }
    final cover = await http
        .get(Uri.parse(coverUrl!))
        .then((value) => value.bodyBytes);
    if (cover.isNotEmpty) {
      await pic.create(recursive: true);
      await pic.writeAsBytes(cover);
      coverPath = pic.path;
      return coverPath;
    }

    return null;
  }

  @override
  String toString() {
    return super.toString().replaceFirst('Metadata', 'MetadataNetEase');
  }

  @override
  Future<String> getPath() async {
    // final appDir = await getApplicationDocumentsDirectory();
    // final path = '${appDir.path}/cache/metadata/netease/music/$mid.mp3';
    final path = await Metadata.musicCacheManager.getCachedPath(id);
    // final dir = Directory(path.substring(0, path.lastIndexOf('/')));
    // if (!dir.existsSync()) {
    //   dir.createSync(recursive: true);
    // }
    return path;
  }

  @override
  Future<void> download({bool cache = true}) async {
    // final path = await getPath();
    // final file = File(path);
    final file = await Metadata.musicCacheManager.getCachedFile(id);
    if (cache && await file.exists()) {
      return;
    }
    await file.create(recursive: true);
    final url = await NetEase.getUrl(mid);
    if (url == null) {
      return;
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    }
  }
}

class PlaylistNetEase extends Playlist {
  int get mid => int.tryParse(id.replaceAll('netease://', '')) ?? 0;

  PlaylistNetEase(super.id) : super.internal() {
    init();
  }

  @override
  Future<void> init() async {
    name =
        (await NetEase.getPlaylistInfo(mid))['playlist']?['name'] ??
        id.replaceFirst('netease://', '');
  }

  @override
  Future<void> getSongs() async {
    songs =
        (await NetEase.getPlaylist(mid)).map((e) => 'netease://$e').toList();
  }

  @override
  Future<void> sort({
    String type = PlaylistSortType.name,
    bool reverse = false,
  }) async {
    if (type == PlaylistSortType.noSort) return;
    if ([PlaylistSortType.name].contains(type)) {
      const batchSize = 48;
      for (var i = 0; i < songs.length; i += batchSize) {
        final batch = songs.sublist(i, min(i + batchSize, songs.length));
        final futures = batch.map((id) => MetadataNetEase(id).getMetadata());
        await Future.wait(futures);
      }
    }
    songs.sort((a, b) {
      if (type == PlaylistSortType.id) {
        return int.parse(
          a.replaceAll('netease://', ''),
        ).compareTo(int.parse(b.replaceAll('netease://', '')));
      }
      final ma = MetadataNetEase(a);
      final mb = MetadataNetEase(b);
      if (type == PlaylistSortType.name) {
        if (ma.title == null || mb.title == null) {
          return 0;
        }
        return ma.title!.compareTo(mb.title!);
      }
      return 0;
    });
    if (reverse) {
      songs = songs.reversed.toList();
    }
  }

  @override
  String toString() {
    return super.toString().replaceFirst('Playlist', 'PlaylistNetEase');
  }
}

class NetEase {
  // static String cookie = '';
  static String get cookie => Settings.netease['cookie'];

  static Map<String, String> get cookiesMap => _parseCookies(cookie);

  // 新增Cookie解析方法
  static Map<String, String> _parseCookies(String cookieStr) {
    final cookies = <String, String>{};
    for (final pair in cookieStr.split(';')) {
      final index = pair.indexOf('=');
      if (index > 0) {
        final key = pair.substring(0, index).trim();
        final value = pair.substring(index + 1).trim();
        cookies[key] = value;
      }
    }
    return cookies;
  }

  static Future<Map?> search(String keywords, {int limit = 30}) async {
    try {
      final response = await http.post(
        Uri.parse('https://music.163.com/api/cloudsearch/pc').replace(
          queryParameters: {
            's': keywords,
            'type': '1', // 1: 单曲
            'limit': limit.toString(), // 搜索结果数量
          },
        ),
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          'Referer': 'https://music.163.com/',
          // 'Cookie': cookie, // 新增：使用cookie
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<int>> searchIds(String keywords, {int limit = 30}) async {
    final data = await search(keywords, limit: limit);
    if (data == null) {
      return [];
    }
    final List<int> ids = [];
    for (final song in data['result']['songs']) {
      ids.add(song['id']);
    }
    return ids;
  }

  static Future<Map?> getDetail(int id) async {
    final url = Uri.https('interface3.music.163.com', '/api/v3/song/detail', {
      'c': jsonEncode([
        {'id': id, 'v': 0},
      ]),
    });

    final response = await http.get(
      url,
      headers: {
        'Accept': '*/*',
        'User-Agent': 'Mozilla/5.0',
        'Referer': 'https://music.163.com/',
        // 'Cookie': cookie, // 新增：使用cookie
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<String?> getLyric(int id, {bool translate = true}) async {
    final url = Uri.https('interface3.music.163.com', '/api/song/lyric', {
      'id': id.toString(),
      'cp': 'false',
      'tv': '0',
      'lv': '0',
      'rv': '0',
      'kv': '0',
      'yv': '0',
      'ytv': '0',
      'yrv': '0',
    });
    final response = await http.get(
      url,
      headers: {
        'Accept': '*/*',
        'User-Agent': 'Mozilla/5.0',
        'Referer': 'https://music.163.com/',
        // 'Cookie': cookie, // 新增：使用cookie
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return '${data?['lrc']?['lyric']}${translate ? data?['tlyric']?['lyric'] : ''}';
    }
    return null;
  }

  static var timeRegex = RegExp(r'\[(\d{2}:\d{2}\.\d{2})]');
  static var timeRegex2 = RegExp(r'\[(\d+),(\d+)]');
  static var timeRegex3 = RegExp(r'\((\d+),(\d+),\d+\)([^(]+)');

  static Future<String> parseLyric(String lyric, String? translate) async {
    // 解析歌词的方法未涉及HTTP请求，无需修改
    List<Map<String, dynamic>> lyrics = [];
    final lines = lyric.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = timeRegex2.firstMatch(line);
      final int startTime = int.tryParse(match?.group(1) ?? '0') ?? 0;
      final int duration = int.tryParse(match?.group(2) ?? '0') ?? 0;
      final int endTime = startTime + duration;
      final matches = timeRegex3.allMatches(line);
      String content = '';
      final List<Map<String, dynamic>> lyricWords = [];
      for (final match in matches) {
        final int startTime = int.tryParse(match.group(1) ?? '0') ?? 0;
        final int duration = int.tryParse(match.group(2) ?? '0') ?? 0;
        final int endTime = startTime + duration;
        final String word = match.group(3) ?? '';
        lyricWords.add({
          'word': word,
          'startTime': startTime,
          'endTime': endTime,
        });
        content += word;
      }
      lyrics.add({
        'content': content,
        'startTime': startTime,
        'endTime': endTime,
        'lyric': lyricWords,
        'originalIndex': lyrics.length,
      });
    }
    if (translate != null) {
      final List<String> lines = translate.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final match = timeRegex.matchAsPrefix(line);
        final textParts = line.split(timeRegex);
        if (match == null) continue;
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
        final nextMatch = timeRegex.matchAsPrefix(lines[i + 1]);
        if (nextMatch == null) continue;
        final nextTimeStamps = parseTimeToMs(nextMatch.group(1)!);
        lyrics.insert((i * 2).clamp(0, lyrics.length), {
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
    String result = '[extra]{"sort":false}\n';
    for (final line in lyrics) {
      if (line['content'].isEmpty) {
        continue;
      }
      result += '[${formatTime(line['startTime'])}]';
      for (final word in line['lyric']) {
        result += '<${formatTime(word['startTime'])}>';
        result += word['word'];
        if (word['endTime'] == line['endTime']) {
          result += '<${formatTime(word['endTime'])}>';
        }
      }
      result += '\n';
    }
    return result;
  }

  static Future<String?> getUrl(int id) async {
    return (await urlV1(id))['data']?[0]?['url'] as String?;
  }

  static const String baseUrl = "https://interface3.music.163.com";
  static const String aesKey = "e82ckenh8dichen8";

  // 获取歌曲播放链接
  static Future<Map<String, dynamic>> urlV1(
      int songId, [
        String level = 'jymaster',
      ]) async {
    // 1. 构造请求参数
    final requestId = _generateRequestId();
    final config = {
      "os": "pc",
      "appver": "",
      "osver": "",
      "deviceId": "pyncm!",
      "requestId": requestId,
    };

    final payload = {
      'ids': [songId],
      'level': level,
      'encodeType': 'flac',
      'header': jsonEncode(config),
    };

    if (level == 'sky') {
      payload['immerseType'] = 'c51';
    }

    // 2. 构造签名
    final apiPath = "/eapi/song/enhance/player/url/v1";
    final shortApiPath = apiPath.replaceAll("/eapi/", "/api/");

    final payloadJson = jsonEncode(payload).replaceAll(' ', '');
    final signData = "nobody${shortApiPath}use${payloadJson}md5forencrypt";
    final digest = _hashHexDigest(signData);

    // 3. 构造待加密数据
    final paramsToEncrypt =
        "$shortApiPath-36cd479b6b5-$payloadJson-36cd479b6b5-$digest";

    // 4. AES加密
    final encryptedParams = _aesEncrypt(paramsToEncrypt, aesKey);

    // 5. 发送请求，传递cookiesMap
    final response = await _postRequest("$baseUrl$apiPath", {
      "params": encryptedParams,
    }, cookiesMap);

    return json.decode(response.body);
  }

  // 辅助方法：生成随机请求ID
  static String _generateRequestId() {
    final random = Random();
    return (20000000 + random.nextInt(10000000)).toString();
  }

  // 辅助方法：计算MD5并转为16进制
  static String _hashHexDigest(String text) {
    final bytes = utf8.encode(text);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // 辅助方法：AES加密
  static String _aesEncrypt(String plaintext, String key) {
    final keyBytes = utf8.encode(key);
    final iv = IV.fromLength(16); // ECB模式不需要IV

    // 创建加密器
    final encrypter = Encrypter(
      AES(
        Key(Uint8List.fromList(keyBytes)),
        mode: AESMode.ecb,
        padding: 'PKCS7',
      ),
    );

    // 加密并转为16进制
    final encrypted = encrypter.encryptBytes(
      Uint8List.fromList(utf8.encode(plaintext)),
      iv: iv,
    );

    return _bytesToHex(encrypted.bytes);
  }

  // 辅助方法：字节数组转16进制字符串
  static String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  // 辅助方法：发送POST请求，使用cookiesMap
  static Future<http.Response> _postRequest(
      String url,
      Map<String, String> data,
      Map<String, String> cookies,
      ) async {
    final headers = {
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Safari/537.36 Chrome/91.0.4472.164 '
          'NeteaseMusicDesktop/2.10.2.200154',
      'Referer': 'https://music.163.com/', // 修正：添加Referer
      'Cookie': _formatCookies(cookies), // 使用格式化后的cookies
    };

    return await http.post(Uri.parse(url), headers: headers, body: data);
  }

  // 辅助方法：格式化Cookies
  static String _formatCookies(Map<String, String> cookies) {
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  static Future<Map> getPlaylistInfo(int id) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://music.163.com/api/v6/playlist/detail',
        ).replace(queryParameters: {'id': id.toString()}),
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          'Referer': 'https://music.163.com/',
          'Cookie': cookie, // 新增：使用cookie
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<List<int>> getPlaylist(int id) async {
    final data = await getPlaylistInfo(id);
    // 解析歌曲ID列表
    return (data['playlist']['trackIds'] as List)
        .map<int>((e) => e['id'] as int)
        .toList();
  }
}