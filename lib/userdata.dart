import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserData {
  final String path;
  UserData(this.path);

  Future<void> set(dynamic data) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$path');
    await file.create(recursive: true);
    await file.writeAsString(json.encode(data));
  }

  Future<dynamic> get({Object? defaultValue}) async {  // 新增可选参数
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$path');

    if (!await file.exists()) {
      final value = defaultValue ?? {};  // 使用提供的默认值或空对象
      await file.create(recursive: true);
      await file.writeAsString(json.encode(value));
      return value;
    }

    return json.decode(await file.readAsString());
  }
}