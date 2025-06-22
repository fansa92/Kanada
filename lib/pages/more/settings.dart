import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanada/pages/more/settings/cache.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kanada/pages/app.dart';
import 'package:kanada/widgets/link.dart';
import 'package:kanada_lyric_sender/kanada_lyric_sender.dart';

import '../../cache.dart';
import '../../settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double homePageWaterFallItemCount =
      Settings.homeWaterfallCrossAxisCount.toDouble();
  bool lyricSendState = false;

  @override
  void initState() {
    super.initState();
    Settings.fresh().then((value) {
      setState(() {});
    });
    KanadaLyricSenderPlugin.hasEnable().then((value) {
      lyricSendState = value;
      if (!lyricSendState) {
        Settings.lyricSend = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Link(
            route: '/more/settings/folders',
            child: ListTile(
              title: Text('文件夹设置'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          Divider(),
          ListTile(
            title: Text('首页'),
            trailing: Text(AppPage.homePageNames[Settings.homePage]),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('设置首页'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 4; i++)
                          RadioListTile(
                            title: Text(AppPage.homePageNames[i]),
                            value: i,
                            groupValue: Settings.homePage,
                            onChanged: (value) {
                              Settings.homePage = value!;
                              Settings.save();
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('搜索页面'),
            trailing: Switch(
              value: Settings.searchPage,
              onChanged: (bool value) {
                Settings.searchPage = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.searchPage = !Settings.searchPage;
              Settings.save();
              setState(() {});
            },
          ),
          ListTile(
            title: Text('首页瀑布流宽度'),
            trailing: Text('${Settings.homeWaterfallCrossAxisCount}'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => StatefulBuilder(
                      builder:
                          (context, setState) => AlertDialog(
                            title: Text('调整瀑布流宽度'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                  value: homePageWaterFallItemCount,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label:
                                      homePageWaterFallItemCount
                                          .round()
                                          .toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      homePageWaterFallItemCount = value;
                                    });
                                  },
                                ),
                                Text(
                                  '当前值: ${homePageWaterFallItemCount.round()}',
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Settings.homeWaterfallCrossAxisCount =
                                      homePageWaterFallItemCount.round();
                                  Settings.save();
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text('确定'),
                              ),
                            ],
                          ),
                    ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
          Divider(),
          // Link(
          //   route: '/more/settings/player',
          //   child: ListTile(
          //     title: Text('播放器设置'),
          //     trailing: Icon(Icons.arrow_forward_ios),
          //   ),
          // ),
          ListTile(
            title: Text('歌词页面进度条显示'),
            trailing: Switch(
              value: Settings.lyricShowProgressBar,
              onChanged: (bool value) {
                Settings.lyricShowProgressBar = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.lyricShowProgressBar = !Settings.lyricShowProgressBar;
              Settings.save();
              setState(() {});
            },
          ),
          ListTile(
            title: Text('歌词发光效果'),
            trailing: Switch(
              value: Settings.lyricGlow,
              onChanged: (bool value) {
                Settings.lyricGlow = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.lyricGlow = !Settings.lyricGlow;
              Settings.save();
              setState(() {});
            },
          ),
          ListTile(
            title: Text('歌词模糊效果'),
            trailing: Switch(
              value: Settings.lyricBlur,
              onChanged: (bool value) {
                Settings.lyricBlur = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.lyricBlur = !Settings.lyricBlur;
              Settings.save();
              setState(() {});
            },
          ),
          ListTile(
            title: Text('歌词发送器可用？'),
            trailing: Text(lyricSendState ? '可用' : '不可用'),
            onTap: () async {
              //   https://github.com/xiaowine/Lyric-Getter/releases/latest
              final uri = Uri.parse(
                'https://github.com/xiaowine/Lyric-Getter/releases/latest',
              );
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              } catch (e) {
                Fluttertoast.showToast(msg: 'Lyric-Getter网站打开失败');
              }
            },
          ),
          ListTile(
            title: Text('歌词发送'),
            trailing: Switch(
              value: Settings.lyricSend,
              onChanged:
                  !lyricSendState
                      ? null
                      : (bool value) {
                        Settings.lyricSend = value;
                        Settings.save();
                        setState(() {});
                        if (!value) {
                          KanadaLyricSenderPlugin.clearLyric();
                        }
                      },
            ),
            onTap: () {
              if (!lyricSendState) return;
              Settings.lyricSend = !Settings.lyricSend;
              Settings.save();
              setState(() {});
              if (!Settings.lyricSend) {
                KanadaLyricSenderPlugin.clearLyric();
              }
            },
          ),
          ListTile(
            title: Text('歌词写入文件'),
            trailing: Switch(
              value: Settings.lyricWrite,
              onChanged: (bool value) {
                if (value) {
                  Fluttertoast.showToast(
                    msg: '歌词写入文件到/storage/emulated/0/lyric.json',
                    toastLength: Toast.LENGTH_LONG,
                  );
                  Clipboard.setData(
                    ClipboardData(text: '/storage/emulated/0/lyric.json'),
                  );
                }
                Settings.lyricWrite = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.lyricWrite = !Settings.lyricWrite;
              Settings.save();
              setState(() {});
            },
          ),
          Divider(),
          ListTile(
            title: Text('静音暂停'),
            trailing: Switch(
              value: Settings.mutePause,
              onChanged: (bool value) {
                Settings.mutePause = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.mutePause = !Settings.mutePause;
              Settings.save();
              setState(() {});
            },
          ),
          Divider(),
          ListTile(
            title: Text('缓存大小'),
            trailing: Text(Settings.cacheSize.toString()),
            onTap: () {
              Settings.cacheSize = Settings.cacheSize.clamp(
                FileSize(gB: 1),
                FileSize(gB: 24),
              );
              showDialog(
                context: context,
                builder:
                    (context) => StatefulBuilder(
                      builder:
                          (context, setState) => AlertDialog(
                            title: Text('调整缓存大小'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                  value: Settings.cacheSize.size.toDouble(),
                                  min: 1024 * 1024 * 1024,
                                  max: 1024 * 1024 * 1024 * 24,
                                  divisions: 23,
                                  label: Settings.cacheSize.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      Settings.cacheSize = FileSize(
                                        B: value.round(),
                                      );
                                    });
                                  },
                                ),
                                Text('当前值: ${Settings.cacheSize.toString()}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CacheSettings(),
                                      ),
                                    ),
                                child: Text('详情'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Settings.save();
                                  Fluttertoast.showToast(
                                    msg: '重启生效',
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text('确定'),
                              ),
                            ],
                          ),
                    ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Debug模式'),
            trailing: Switch(
              value: Settings.debug,
              onChanged: (bool value) {
                Settings.debug = value;
                Settings.save();
                setState(() {});
              },
            ),
            onTap: () {
              Settings.debug = !Settings.debug;
              Settings.save();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
