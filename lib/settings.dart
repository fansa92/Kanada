import 'package:kanada/userdata.dart';

class Settings{
  static Future<void> fresh() async {
    final Map json =await UserData('settings.json').get(
        defaultValue: {
          'name': 'Kanade',
          'folders': ['/storage/emulated/0/Music/'],
          'debug': false,
        }
    );
    name = json['name'];
    folders = json['folders'].cast<String>();
    debug = json['debug'];
  }
  static Future<void> save() async {
    await UserData('settings.json').set({
      'name': name,
      'folders': folders,
      'debug': debug,
    });
  }
  static String toString_(){
    return 'Settings{name: $name, folders: $folders, debug: $debug}';
  }
  static late String name;
  static late List<String> folders;
  static late bool debug;
}