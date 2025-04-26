import 'dart:io';
import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:kanada_album_art/kanada_album_art.dart';

class Metadata {
  String path;

  Metadata(this.path);

  Future<void> getMetadata() async {
    final file = File(path);
    metadata = readAllMetadata(file, getImage: true);
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
      title = metadata.title[0];
      artist = metadata.artist[0];
      album = metadata.album[0];
    }
    lyric = metadata.lyric;
    // picture = metadata.pictures[0].bytes;
    // picture = await metadata2!.albumArt;
    duration = metadata.duration;
    picture = await KanadaAlbumArtPlugin.getAlbumArt(path);
    // File('/sdcard/cover.jpg').writeAsBytes(picture!);
    // title = metadata.toString();
  }

  dynamic metadata;
  dynamic metadata2;
  String? title;
  String? artist;
  String? album;
  String? lyric;
  Uint8List? picture;
  Duration? duration;
}
