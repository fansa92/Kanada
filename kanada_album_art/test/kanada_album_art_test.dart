import 'package:flutter_test/flutter_test.dart';
import 'package:kanada_album_art/kanada_album_art.dart';
import 'package:kanada_album_art/kanada_album_art_platform_interface.dart';
import 'package:kanada_album_art/kanada_album_art_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKanadaAlbumArtPlatform
    with MockPlatformInterfaceMixin
    implements KanadaAlbumArtPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KanadaAlbumArtPlatform initialPlatform = KanadaAlbumArtPlatform.instance;

  test('$MethodChannelKanadaAlbumArt is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKanadaAlbumArt>());
  });

  test('getPlatformVersion', () async {
    KanadaAlbumArt kanadaAlbumArtPlugin = KanadaAlbumArt();
    MockKanadaAlbumArtPlatform fakePlatform = MockKanadaAlbumArtPlatform();
    KanadaAlbumArtPlatform.instance = fakePlatform;

    expect(await kanadaAlbumArtPlugin.getPlatformVersion(), '42');
  });
}
