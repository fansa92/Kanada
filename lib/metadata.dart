import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:kanada_album_art/kanada_album_art.dart';
import 'package:path_provider/path_provider.dart';

class Metadata {
  String path;

  Metadata(this.path);

  Future<void> getMetadata({bool cache = false, int timeout = 604800}) async {
  final appDir = await getApplicationDocumentsDirectory();
  final meta = File(
  '${appDir.path}/cache/metadata/metadata/${path.hashCode}.json',
  );
  if (cache &&
  await meta.exists() &&
  DateTime.now().difference(await meta.lastModified()).inSeconds <
  timeout) {
  final data = jsonDecode(await meta.readAsString());
  title = data['title'];
  artist = data['artist'];
  album = data['album'];
  // lyric = data['lyric'];
  duration = Duration(milliseconds: data['duration']);
  return;
  }
  final file = File(path);
  metadata = readMetadata(file, getImage: false);
  // metadata2 = await MetadataRetriever.fromFile(file);
  // print(metadata);
  // String? contentGroupDescription; // TIT1
  // String? songName; // TIT2
  // String? subtitle; // TIT3
  if (metadata is Mp3Metadata) {
  title =
  metadata.subtitle ??
  metadata.songName ??
  metadata.contentGroupDescription;
  artist = metadata.leadPerformer;
  album = metadata.album;
  } else {
  // title = metadata.title?.isNotEmpty==true?metadata.title[0]:null;
  // artist = metadata.artist?.isNotEmpty==true?metadata.artist[0]:null;
  // album = metadata.album?.isNotEmpty==true?metadata.album[0]:null;
  title = metadata.title;
  artist = metadata.artist;
  album = metadata.album;
  }
  // lyric = metadata.lyric;
  // picture = metadata.pictures[0].bytes;
  // picture = await metadata2!.albumArt;
  duration = metadata.duration;
  // File('/sdcard/cover.jpg').writeAsBytes(picture!);
  // title = metadata.toString();
  if (File(
  '${appDir.path}/cache/metadata/picture/${path.hashCode}.jpg',
  ).existsSync()) {
  pictureCache =
  '${appDir.path}/cache/metadata/picture/${path.hashCode}.jpg';
  }
  meta.create(recursive: true);
  await meta.writeAsString(
  jsonEncode({
  'title': title,
  'artist': artist,
  'album': album,
  // 'lyric': lyric,
  'duration': duration?.inMilliseconds,
  }),
  );
  }

  @override
  String toString() {
  return 'Metadata{path: $path, title: $title, artist: $artist, album: $album, duration: $duration}';
  }

  Future<void> getLyric({bool cache = true, int timeout = 604800}) async {
  final appDir = await getApplicationDocumentsDirectory();
  final lrc = File(
  '${appDir.path}/cache/metadata/lyric/${path.hashCode}.lrc',
  );
  if (cache &&
  await lrc.exists() &&
  DateTime.now().difference(await lrc.lastModified()).inSeconds <
  timeout) {
  lyric = await lrc.readAsString();
  return;
  }
  final file = File(path);
  final dynamic meta = readAllMetadata(file, getImage: false);
  lyric = meta.lyric;
  }

  Future<void> getPicture({bool cache = true, int timeout = 604800}) async {
  final appDir = await getApplicationDocumentsDirectory();
  final pic = File(
  '${appDir.path}/cache/metadata/picture/${path.hashCode}.jpg',
  );
  if (cache &&
  await pic.exists() &&
  DateTime.now().difference(await pic.lastModified()).inSeconds <
  timeout) {
  picture = await pic.readAsBytes();
  picturePath = pic.path;
  return;
  }
  picture = await KanadaAlbumArtPlugin.getAlbumArt(path);
  if (picture != null) {
  await pic.create(recursive: true);
  await pic.writeAsBytes(picture!);
  picturePath = pic.path;
  }
  }

  dynamic metadata;
  dynamic metadata2;
  String? title;
  String? artist;
  String? album;
  String? lyric;
  Uint8List? picture;
  String? picturePath;
  String

  ?

  pictureCache;

  Duration

  ?

  duration;
}
