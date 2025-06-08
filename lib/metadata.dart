import 'dart:convert';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:kanada_album_art/kanada_album_art.dart';
import 'package:path_provider/path_provider.dart';
import 'netease.dart';

class Metadata{
  // 使用缓存避免重复创建相同路径的元数据对象
  static final _cache = <String, Metadata>{};
  final String id;  // 音频文件路径（不可变）

  /// 工厂构造函数，保证同一路径只有一个实例
  factory Metadata(String id) {
    return _cache.putIfAbsent(id, () {
      // 将原来的get方法逻辑移动到此处
      if(id.startsWith('/')){
        return MetadataFile(id);
      }
      if(id.startsWith('netease://')){
        return MetadataNetEase(id);
      }
      return Metadata.internal(id);
    });
  }

  Metadata.internal(this.id);  // 私有构造方法

  // static Metadata get(String id){
  //   if(id.startsWith('/')){
  //     return MetadataFile(id);
  //   }
  //   return Metadata(id);
  // }

  static MetadataFile file(String id) => MetadataFile(id);

  // 元数据相关字段
  dynamic metadata;       // 原始元数据对象
  dynamic metadata2;      // 备用元数据对象（暂未使用）
  String? title;          // 歌曲标题
  String? artist;         // 艺术家
  String? album;          // 专辑名称
  String? lyric;          // 歌词
  // Uint8List? cover;       // 封面图片字节数据
  String? coverPath;      // 封面图片文件路径
  String? coverCache;     // 封面缓存路径
  Duration? duration;     // 歌曲时长
  // 缓存状态标志
  bool gotMetadata = false;  // 元数据是否已获取
  bool gotLyric = false;     // 歌词是否已获取
  bool gotCover = false;     // 封面是否已获取

  /// 获取元数据（带缓存功能）
  /// [cache] 是否使用缓存
  /// [timeout] 缓存超时时间（秒），默认7天
  Future<Metadata> getMetadata({bool cache = false, int timeout = 604800}) async {
    return this;
  }
  Future<String?> getLyric({bool cache = true, int timeout = 604800}) async {
    return lyric;
  }
  Future<String?> getCover({bool cache = true, int timeout = 604800}) async {
    return coverPath;
  }
  Future<String?> getPath({bool cache = true, int timeout = 604800}) async {
    return id;
  }
  Future<void> download({bool cache = true, int timeout = 604800}) async {
    return;
  }

  @override
  String toString() {
    return 'Metadata{id: $id, title: $title, artist: $artist, album: $album, duration: $duration, lyric: $lyric, coverPath: $coverPath, coverCache: $coverCache}';
  }
}

/// 元数据管理类，负责音频文件的元数据读取和缓存
class MetadataFile extends Metadata {
  MetadataFile(super.id) : super.internal();
  /// 获取元数据（带缓存功能）
  /// [cache] 是否使用缓存
  /// [timeout] 缓存超时时间（秒），默认7天
  @override
  Future<Metadata> getMetadata({bool cache = false, int timeout = 604800}) async {
    if(cache && gotMetadata) {
      return this;
    }
    gotMetadata = true;

    final appDir = await getApplicationDocumentsDirectory();
    final meta = File(
      '${appDir.path}/cache/metadata/metadata/${id.hashCode}.json',
    );

    // 检查缓存有效性
    if (cache &&
        await meta.exists() &&
        DateTime.now().difference(await meta.lastModified()).inSeconds < timeout) {
      final data = jsonDecode(await meta.readAsString());
      title = data['title'];
      artist = data['artist'];
      album = data['album'];
      duration = Duration(milliseconds: data['duration']);
      return this;
    }

    // 从文件读取元数据
    final file = File(id);
    metadata = readMetadata(file, getImage: false);

    // 解析不同格式的元数据
    if (metadata is Mp3Metadata) {
      // MP3文件的特殊字段处理
      title = metadata.subtitle ?? metadata.songName ?? metadata.contentGroupDescription;
      artist = metadata.leadPerformer;
      album = metadata.album;
    } else {
      // 其他音频格式的通用处理
      title = metadata.title;
      artist = metadata.artist;
      album = metadata.album;
    }

    duration = metadata.duration;

    // 检查封面缓存
    if (File('${appDir.path}/cache/metadata/picture/${id.hashCode}.jpg').existsSync()) {
      coverCache = '${appDir.path}/cache/metadata/picture/${id.hashCode}.jpg';
      coverPath = coverCache;
    }

    // 写入元数据缓存
    meta.create(recursive: true);
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
    if(cache && gotLyric) {
      return lyric;
    }
    gotLyric = true;

    final appDir = await getApplicationDocumentsDirectory();
    final lrc = File(
      '${appDir.path}/cache/metadata/lyric/${id.hashCode}.lrc',
    );

    // 检查歌词缓存
    if (cache && await lrc.exists() &&
        DateTime.now().difference(await lrc.lastModified()).inSeconds < timeout) {
      lyric = await lrc.readAsString();
      return lyric;
    }

    // 从文件读取歌词
    final file = File(id);
    final dynamic meta = readAllMetadata(file, getImage: false);
    lyric = meta.lyric;
    return lyric;
  }

  /// 获取专辑封面（带缓存功能）
  @override
  Future<String?> getCover({bool cache = true, int timeout = 604800}) async {
    if(cache && gotCover) {
      return coverPath;
    }
    gotCover = true;

    final appDir = await getApplicationDocumentsDirectory();
    final pic = File(
      '${appDir.path}/cache/metadata/picture/${id.hashCode}.jpg',
    );

    // 检查封面缓存
    if (cache && await pic.exists() &&
        DateTime.now().difference(await pic.lastModified()).inSeconds < timeout) {
      // cover = await pic.readAsBytes();
      coverPath = pic.path;
      return coverPath;
    }

    // 获取专辑封面并保存
    final cover = await KanadaAlbumArtPlugin.getAlbumArt(id);
    if (cover != null) {
      await pic.create(recursive: true);
      await pic.writeAsBytes(cover);
      coverPath = pic.path;
      return coverPath;
    }

    return null;
  }

  @override
  String toString() {
    return super.toString().replaceFirst('Metadata', 'MetadataFile');
  }
}
