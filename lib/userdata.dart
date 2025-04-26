import 'dart:convert';
import 'dart:io';

class UserData{
  final String path;
  UserData(this.path);
  Future<void> write(dynamic data) async{
    await File(path).writeAsString(json.encode(data));
  }
  Future<dynamic> read() async{
    return json.decode(await File(path).readAsString());
  }
}