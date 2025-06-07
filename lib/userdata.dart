import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 应用数据存储管理类
///
/// 提供基于JSON的持久化存储能力，数据存储在应用文档目录下的指定路径
class UserData {
  /// 数据存储的相对路径（基于应用文档目录）
  final String path;
  String? absPath;
  UserData(this.path);

  /// 保存数据到本地
  ///
  /// [data]: 要保存的数据对象，可以是任意可JSON序列化的类型
  /// 会自动创建不存在的目录结构
  Future<void> set(dynamic data) async {
    final appDir = await getApplicationDocumentsDirectory();
    absPath = '${appDir.path}/$path';
    final file = File(absPath!);
    await file.create(recursive: true);
    await file.writeAsString(json.encode(data)); // 序列化为JSON字符串
  }

  /// 读取存储的数据
  ///
  /// [defaultValue]: 当数据文件不存在时使用的默认值（需可JSON序列化）
  /// 返回动态类型，调用方需自行处理类型转换
  Future<dynamic> get({Object? defaultValue}) async {
    final appDir = await getApplicationDocumentsDirectory();
    absPath = '${appDir.path}/$path';
    final file = File(absPath!);

    if (!await file.exists()) {
      final value = defaultValue ?? {};  // 优先使用调用方提供的默认值
      await file.create(recursive: true);
      await file.writeAsString(json.encode(value));
      return value;
    }
    try {
      return json.decode(await file.readAsString()); // 反序列化JSON数据
    }
    catch(e) {
      return defaultValue?? {};  // 读取失败返回默认值
    }
  }
}
