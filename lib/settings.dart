import 'dart:io';

import 'package:kanada/userdata.dart';

import 'cache.dart';

/// 应用设置管理类，使用静态成员存储全局设置
///
/// 负责：
/// - 从持久化存储加载/保存设置
/// - 管理音乐文件夹路径、调试模式等配置项
class Settings {
  // 以下为全局设置字段
  static late String name; // 当前用户名
  static late int homePage;
  static late bool searchPage;
  static late int homeWaterfallCrossAxisCount; // 首页瀑布流显示的歌曲数量
  static late List<String> folders; // 监控的音乐文件夹路径列表
  static late bool lyricShowProgressBar; // 歌曲进度开关状态
  static late bool lyricBlur; // 歌词模糊效果开关状态
  static late bool lyricComplicatedAnimation; // 歌词动画效果开关状态
  static late bool lyricGlow; // 歌词发光开关状态
  static late bool mutePause; // 静音时暂停开关状态
  static late bool lyricSend; // 发送歌词开关状态
  static late bool lyricWrite; // 写入歌词开关状态
  static late bool repeat; // 循环开关状态
  static late bool repeatOne; // 单曲循环开关状态
  static late bool shuffle; // 随机开关状态
  static late FileSize cacheSize; // 缓存大小
  static late Map<String, dynamic> netease; // 网易云音乐登录信息
  static late bool debug; // 调试模式开关状态

  /// 从持久化存储初始化设置
  ///
  /// [defaultValue] 当设置文件不存在时使用的默认值
  static Future<void> fresh() async {
    final userdata = UserData('settings.json');
    try {
      final Map json = await userdata.get(
        defaultValue: {
          'name': 'Kanade',
          'homePage': 0,
          'searchPage': true,
          'homeWaterfallCrossAxisCount': 2,
          'folders': [
            "/storage/emulated/0/Music/Yuki/ミクセカイ/",
            "/storage/emulated/0/Music/Yuki/其他/",
            "netease://13838627880",
            "netease://7495978701",
            "netease://7249212447",
            "netease://7084816374",
          ],
          'lyricShowProgressBar': true,
          'lyricBlur': false,
          'lyricComplicatedAnimation': true,
          'lyricGlow': false,
          'mutePause': false,
          'lyricSend': false,
          'lyricWrite': false,
          'repeat': false,
          'repeatOne': false,
          'shuffle': false,
          'cacheSize': FileSize(gB: 12).size,
          'netease': {'cookie': ''},
          'debug': false,
        },
      );
      name = json['name'];
      homePage = json['homePage'];
      searchPage = json['searchPage'];
      homeWaterfallCrossAxisCount = json['homeWaterfallCrossAxisCount'];
      folders = json['folders'].cast<String>();
      lyricShowProgressBar = json['lyricShowProgressBar'];
      lyricBlur = json['lyricBlur'];
      lyricComplicatedAnimation = json['lyricComplicatedAnimation'];
      lyricGlow = json['lyricGlow'];
      mutePause = json['mutePause'];
      lyricSend = json['lyricSend'];
      lyricWrite = json['lyricWrite'];
      repeat = json['repeat'];
      repeatOne = json['repeatOne'];
      shuffle = json['shuffle'];
      cacheSize = FileSize(B: json['cacheSize']);
      netease = json['netease'].cast<String, dynamic>();
      debug = json['debug'];
    } catch (e) {
      if (userdata.absPath != null) {
        await File(userdata.absPath!).delete();
        await fresh();
      }
    }
  }

  /// 保存当前设置到持久化存储
  static Future<void> save() async {
    await UserData('settings.json').set({
      'name': name,
      'homePage': homePage,
      'searchPage': searchPage,
      'homeWaterfallCrossAxisCount': homeWaterfallCrossAxisCount,
      'folders': folders,
      'lyricShowProgressBar': lyricShowProgressBar,
      'lyricBlur': lyricBlur,
      'lyricComplicatedAnimation': lyricComplicatedAnimation,
      'lyricGlow': lyricGlow,
      'mutePause': mutePause,
      'lyricSend': lyricSend,
      'lyricWrite': lyricWrite,
      'repeat': repeat,
      'repeatOne': repeatOne,
      'shuffle': shuffle,
      'cacheSize': cacheSize.size,
      'netease': netease,
      'debug': debug,
    });
  }
}
