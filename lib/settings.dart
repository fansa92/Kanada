import 'package:kanada/userdata.dart';

/// 应用设置管理类，使用静态成员存储全局设置
///
/// 负责：
/// - 从持久化存储加载/保存设置
/// - 管理音乐文件夹路径、调试模式等配置项
class Settings {
  // 以下为全局设置字段
  static late String name;         // 当前用户名
  static late List<String> folders;// 监控的音乐文件夹路径列表
  static late bool lyricBlur;      // 歌词模糊效果开关状态
  static late bool debug;          // 调试模式开关状态

  /// 从持久化存储初始化设置
  ///
  /// [defaultValue] 当设置文件不存在时使用的默认值：
  /// - name: 默认用户名
  /// - folders: 默认音乐文件夹路径列表
  /// - debug: 调试模式开关
  static Future<void> fresh() async {
    final Map json = await UserData('settings.json').get(
        defaultValue: {
          'name': 'Kanade',
          'folders': ['/storage/emulated/0/Music/Yuki/ミクセカイ/'],
          'lyricBlur': false,
          'debug': false,
        }
    );
    name = json['name'];
    folders = json['folders'].cast<String>();
    lyricBlur = json['lyricBlur'];
    debug = json['debug'];
  }

  /// 保存当前设置到持久化存储
  ///
  /// 保存字段包括：
  /// - 用户名
  /// - 音乐文件夹路径列表
  /// - 调试模式状态
  static Future<void> save() async {
    await UserData('settings.json').set({
      'name': name,
      'folders': folders,
      'lyricBlur': lyricBlur,
      'debug': debug,
    });
  }
}
