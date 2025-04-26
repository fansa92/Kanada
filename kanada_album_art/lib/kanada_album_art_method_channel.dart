import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'kanada_album_art_platform_interface.dart';

/// An implementation of [KanadaAlbumArtPlatform] that uses method channels.
class MethodChannelKanadaAlbumArt extends KanadaAlbumArtPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('kanada_album_art');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
