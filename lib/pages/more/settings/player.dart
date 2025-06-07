import 'package:flutter/material.dart';

import '../../../settings.dart';

class PlayerSettings extends StatefulWidget {
  const PlayerSettings({super.key});

  @override
  State<PlayerSettings> createState() => _PlayerSettingsState();
}

class _PlayerSettingsState extends State<PlayerSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Player Settings')),
      body: ListView(
        children: [
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
          // ListTile(
          //   title: Text('歌词复杂动画效果'),
          //   trailing: Switch(
          //     value: Settings.lyricComplicatedAnimation,
          //     onChanged: (bool value) {
          //       Settings.lyricComplicatedAnimation = value;
          //       Settings.save();
          //       setState(() {});
          //     },
          //   ),
          //   onTap: () {
          //     Settings.lyricComplicatedAnimation =
          //         !Settings.lyricComplicatedAnimation;
          //     Settings.save();
          //     setState(() {});
          //   },
          // ),
        ],
      ),
    );
  }
}
