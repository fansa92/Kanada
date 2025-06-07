import 'package:flutter/material.dart';
import 'package:kanada/pages/app.dart';
import 'package:kanada/pages/folders.dart';
import 'package:kanada/pages/home.dart';
import 'package:kanada/pages/more.dart';
import 'package:kanada/pages/more/cache.dart';
import 'package:kanada/pages/more/debug.dart';
import 'package:kanada/pages/more/debug/color.dart';
import 'package:kanada/pages/more/debug/color_diffusion.dart';
import 'package:kanada/pages/more/debug/current_lyric.dart';
import 'package:kanada/pages/more/debug/file_choose.dart';
import 'package:kanada/pages/more/debug/link.dart';
import 'package:kanada/pages/more/debug/lyric.dart';
import 'package:kanada/pages/more/debug/lyric_sender.dart';
import 'package:kanada/pages/more/debug/pick_color.dart';
import 'package:kanada/pages/more/debug/player.dart';
import 'package:kanada/pages/more/debug/toast.dart';
import 'package:kanada/pages/more/settings.dart';
import 'package:kanada/pages/more/settings/folders.dart';
import 'package:kanada/pages/more/settings/player.dart';
import 'package:kanada/pages/playing.dart';
import 'package:kanada/pages/search.dart';
import 'package:kanada/player.dart';

import 'metadata.dart';

class Global {
  /// 应用路由表
  /// 键：路由路径，值：对应的页面组件构造器
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AppPage(),
    '/home': (context) => const HomePage(),
    '/search': (context) => const SearchPage(),
    '/folders': (context) => const FoldersPage(),
    '/more': (context) => const MorePage(),
    '/more/debug': (context) => const DebugPage(),
    '/more/debug/link': (context) => const LinkDebug(),
    '/more/debug/player': (context) => const PlayerDebug(),
    '/more/debug/toast': (context) => const ToastDebug(),
    '/more/debug/file_choose': (context) => const FileChooseDebug(),
    '/more/debug/lyric_sender': (context) => const LyricSenderDebug(),
    '/more/debug/lyric': (context) => const LyricDebug(),
    '/more/debug/pick_color': (context) => const PickColorDebug(),
    '/more/debug/color_diffusion': (context) => const ColorDiffusionDebug(),
    '/more/debug/current_lyric': (context) => const CurrentLyricDebug(),
    '/more/debug/color': (context) => const ColorDebug(),
    '/more/settings': (context) => const SettingsPage(),
    '/more/settings/folders': (context) => const FoldersSettings(),
    '/more/settings/player': (context) => const PlayerSettings(),
    '/more/cache': (context) => const CachePage(),
    '/player': (context) => const PlayingPage(),
  };

  /// 全局播放器实例（延迟初始化）
  static late Player player;

  /// 应用初始化状态标记
  static bool init = false;

  /// 当前播放文件路径
  static String path = '';

  /// 当前播放列表
  static List<String> playlist = [];

  /// 元数据缓存（用于快速访问当前播放文件的元信息）
  static Metadata? metadataCache;

  /// 播放器页面专用主题
  static ThemeData playerTheme = ThemeData();

  /// 歌词发送器初始化状态标记
  static bool lyricSenderInit = false;

  /// 颜色缓存表
  /// 键：文件路径，值：从文件中提取的颜色列表
  static Map<String, List<Color>> colorsCache = {};
}
