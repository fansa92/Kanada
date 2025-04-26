import 'kanada_album_art_platform_interface.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class KanadaAlbumArt {
  Future<String?> getPlatformVersion() {
    return KanadaAlbumArtPlatform.instance.getPlatformVersion();
  }
}

class KanadaAlbumArtPlugin {
  // 定义与 Android 端一致的 MethodChannel 名称
  static const MethodChannel _channel = MethodChannel('kanada_album_art');

  /// 调用原生方法获取专辑封面
  ///
  /// 参数 filePath: 音频文件路径
  /// 返回 Uint8List: 封面图片的二进制数据（如 JPEG 或 PNG）
  static Future<Uint8List?> getAlbumArt(String filePath) async {
    try {
      // 通过 MethodChannel 调用原生方法 'getAlbumArt'
      final result = await _channel.invokeMethod<Uint8List>('getAlbumArt', {
        'filePath': filePath,
      });
      return result;
    } on PlatformException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }
}
