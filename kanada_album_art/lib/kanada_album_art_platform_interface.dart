import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'kanada_album_art_method_channel.dart';

abstract class KanadaAlbumArtPlatform extends PlatformInterface {
  /// Constructs a KanadaAlbumArtPlatform.
  KanadaAlbumArtPlatform() : super(token: _token);

  static final Object _token = Object();

  static KanadaAlbumArtPlatform _instance = MethodChannelKanadaAlbumArt();

  /// The default instance of [KanadaAlbumArtPlatform] to use.
  ///
  /// Defaults to [MethodChannelKanadaAlbumArt].
  static KanadaAlbumArtPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KanadaAlbumArtPlatform] when
  /// they register themselves.
  static set instance(KanadaAlbumArtPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
