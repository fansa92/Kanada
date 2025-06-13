import 'dart:typed_data';

import 'package:kanada/tool.dart';
import 'package:path_provider/path_provider.dart';
import 'metadata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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

    final appDir = await getApplicationDocumentsDirectory();
    final meta = File('${appDir.path}/cache/metadata/netease/$mid.json');

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
    if (File(
      '${appDir.path}/cache/metadata/netease/picture/$mid.jpg',
    ).existsSync()) {
      coverCache = '${appDir.path}/cache/metadata/netease/picture/$mid.jpg';
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

    final appDir = await getApplicationDocumentsDirectory();
    final lrc = File('${appDir.path}/cache/metadata/netease/lyric/$mid.lrc');

    // 检查歌词缓存
    // if (cache &&
    //     await lrc.exists() &&
    //     DateTime.now().difference(await lrc.lastModified()).inSeconds <
    //         timeout) {
    //   lyric = await lrc.readAsString();
    //   return lyric;
    // }

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

    final appDir = await getApplicationDocumentsDirectory();
    final pic = File('${appDir.path}/cache/metadata/netease/picture/$mid.jpg');

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
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/cache/metadata/netease/music/$mid.mp3';
    final dir = Directory(path.substring(0, path.lastIndexOf('/')));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return path;
  }

  @override
  Future<void> download({bool cache = true}) async {
    final path = await getPath();
    final file = File(path);
    if (cache && await file.exists()) {
      return;
    }
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

class NetEase {
  static String cookie = '';

  static Future<Map?> search(String keywords) async {
    // POST https://music.163.com/api/cloudsearch/pc?s=39music&type=1&limit=10
    // Accept: */*
    // User-Agent: Mozilla/5.0
    // Referer: https://music.163.com/
    // Cookie: MUSIC_U=1eb9ce22024bb666e99b6743b2222f29ef64a9e88fda0fd5754714b900a5d70d993166e004087dd3b95085f6a85b059f5e9aba41e3f2646e3cebdbec0317df58c119e5;os=pc;appver=8.9.75;
    try {
      final response = await http.post(
        Uri.parse('https://music.163.com/api/cloudsearch/pc').replace(
          queryParameters: {
            's': keywords,
            'type': '1', // 1: 单曲
            'limit': '30', // 搜索结果数量
          },
        ),
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          'Referer': 'https://music.163.com/',
          // 'Cookie': cookie,
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

  static Future<Map?> getDetail(int id) async {
    // GET https://interface3.music.163.com/api/v3/song/detail?c=[{'id':514774040,'v':0}]
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
        // 'Cookie': cookie,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<String?> getLyric(int id, {bool translate = true}) async {
    // POST https://interface3.music.163.com/api/song/lyric?id=514774040&cp=false&tv=0&lv=0&rv=0&kv=0&yv=0&ytv=0&yrv=0
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
        // 'Cookie': cookie,
      },
    );
    // print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(translate);
      // if (data?['yrc']?['lyric'] != null) {
      //   return parseLyric(data?['yrc']?['lyric'], data?['tlyric']?['lyric']);
      // }
      return '${data?['lrc']?['lyric']}${translate ? data?['tlyric']?['lyric'] : ''}';
    }
    return null;
  }

  static var timeRegex = RegExp(r'\[(\d{2}:\d{2}\.\d{2})]');
  static var timeRegex2 = RegExp(r'\[(\d+),(\d+)]');
  static var timeRegex3 = RegExp(r'\((\d+),(\d+),\d+\)([^(]+)');

  static Future<String> parseLyric(String lyric, String? translate) async {
    List<Map<String, dynamic>> lyrics = [];
    // for (final line in lyric.split('\n')) {
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
      // lyrics.insert((i * 2).clamp(0, lyrics.length), {
      //   'content': content,
      //   'startTime': startTime,
      //   'endTime': endTime,
      //   'lyric': lyricWords,
      //   'originalIndex': lyrics.length,
      // });
    }
    if (translate != null) {
      final List<String> lines = translate.split('\n');
      for (int i = 0; i < lines.length; i++) {
        // [00:39.94]新作動画 投稿だ
        final line = lines[i];
        final match = timeRegex.matchAsPrefix(line);
        final textParts = line.split(timeRegex);
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
        final nextMatch = timeRegex.matchAsPrefix(lines[i + 1]);
        if (nextMatch == null) continue;
        final nextTimeStamps = parseTimeToMs(nextMatch.group(1)!);
        // lyrics.add({
        //   'content': ctx,
        //   'startTime': timeStamps,
        //   'endTime': nextTimeStamps,
        //   'lyric': [
        //     {'word': ctx, 'startTime': timeStamps, 'endTime': nextTimeStamps},
        //   ],
        //   'originalIndex': lyrics.length,
        // });
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
    // lyrics.sort((a, b) {
    //   final timeCompare = a['startTime'].compareTo(b['startTime']);
    //   if (timeCompare != 0) return timeCompare;
    //   return a['originalIndex'].compareTo(b['originalIndex']);
    // });
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
        // result+='</${formatTime(word['endTime'])}>';
      }
      result += '\n';
    }
    return result;
  }

  static Future<String?> getUrl(int id) async {
    return (await urlV1(id))['data']?[0]?['url'] as String?;
    // final data = await getNetEaseSongUrl(id);
    // print(data);
    // return jsonEncode(data);
    //   requests.post('https://interface3.music.163.com/eapi/song/enhance/player/url/v1',
    // headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36 Chrome/91.0.4472.164 NeteaseMusicDesktop/2.10.2.200154','Referer': ''},
    // data={'params': 'fa90b329e9614f79e79598f37dc2edb487f00d1bc4c9b24cd57e6c318b9073569338432cd7d98d1a3626e997a2c53121b7e6bdcd17767172b92a3bc71687f2f7486a440d3ae32144703ae1e14659a098c0f7736b4bb97ae411629e1fb7f44684a3e99c3f89fb6e49c579e1bfb5113f7d4327f93b91bf71213729f9068605a0a57df7c4d4f891107bc50f47962b639b565daa7a682a72db5f7fcdb03aba4da6d48f015f679f46557137b57a72d07f0e5958ba17043beee3b51205c4967988b8c8b9d3c26e7cbc3e38da56b865b41ce938a9a4f8330d7a151b7fe6329667ff1f5549d54bc82358ef85b6f335b4c87f3b620cb2e868eeb65c5619347306f0a19fdc30f801a7b89ec0748320bf0c86012cb1'}).text

    // final response = await http.post(
    //   Uri.parse('https://interface3.music.163.com/eapi/song/enhance/player/url/v1'),
    //   headers: {
    //     'Content-Type': 'application/x-www-form-urlencoded',
    //     'User-Agent':
    //         'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36 Chrome/91.0.4472.164 NeteaseMusicDesktop/2.10.2.200154',
    //     'Referer': 'https://music.163.com/',
    //   },
    //   body: {'params': 'fa90b329e9614f79e79598f37dc2edb487f00d1bc4c9b24cd57e6c318b9073569338432cd7d98d1a3626e997a2c53121b7e6bdcd17767172b92a3bc71687f2f7486a440d3ae32144703ae1e14659a098c0f7736b4bb97ae411629e1fb7f44684a3e99c3f89fb6e49c579e1bfb5113f7d4327f93b91bf71213729f9068605a0a57df7c4d4f891107bc50f47962b639b565daa7a682a72db5f7fcdb03aba4da6d48f015f679f46557137b57a72d07f0e5958ba17043beee3b51205c4967988b8c8b9d3c26e7cbc3e38da56b865b41ce938a9a4f8330d7a151b7fe6329667ff1f5549d54bc82358ef85b6f335b4c87f3b620cb2e868eeb65c5619347306f0a19fdc30f801a7b89ec0748320bf0c86012cb1'},
    // );
    //
    // // 检查响应状态
    // if (response.statusCode == 200) {
    //   return response.body;
    // } else {
    //   throw Exception('API请求失败: ${response.statusCode}');
    // }
  }

  static const String baseUrl = "https://interface3.music.163.com";
  static const String aesKey = "e82ckenh8dichen8";

  // 获取歌曲播放链接
  static Future<Map<String, dynamic>> urlV1(
    int songId, [
    String level = 'jymaster',
    Map<String, String>? cookies,
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

    // 5. 发送请求
    final response = await _postRequest("$baseUrl$apiPath", {
      "params": encryptedParams,
    }, cookies ?? {});

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

  // 辅助方法：发送POST请求
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
      'Referer': '',
      'Cookie': _formatCookies(cookies),
    };

    return await http.post(Uri.parse(url), headers: headers, body: data);
  }

  // 辅助方法：格式化Cookies
  static String _formatCookies(Map<String, String> cookies) {
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }
}
