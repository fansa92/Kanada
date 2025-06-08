import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'metadata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
    final meta = File(
      '${appDir.path}/cache/metadata/netease/${id.hashCode}.json',
    );

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
      '${appDir.path}/cache/metadata/netease/picture/${id.hashCode}.jpg',
    ).existsSync()) {
      coverCache =
          '${appDir.path}/cache/metadata/netease/picture/${id.hashCode}.jpg';
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
    print('getLyric');
    if (cache && gotLyric && lyric != null) {
      return lyric;
    }
    gotLyric = true;
    print('getLyric--');

    final appDir = await getApplicationDocumentsDirectory();
    final lrc = File(
      '${appDir.path}/cache/metadata/netease/lyric/${id.hashCode}.lrc',
    );

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
    print('lyric$lyric');

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
    final pic = File(
      '${appDir.path}/cache/metadata/netease/picture/${id.hashCode}.jpg',
    );

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
            'type': "1", // 1: 单曲
            'limit': "30", // 搜索结果数量
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
    // GET https://interface3.music.163.com/api/v3/song/detail?c=[{"id":514774040,"v":0}]
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
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<String?> getLyric(int id) async {
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
      return data?['lrc']?['lyric'];
    }
    return null;
  }
}
