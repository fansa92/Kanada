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
      appBar: AppBar(
        title: Text('Player Settings'),
      ),
      body: ListView(
        children: [
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
        ]
      ),
    );
  }
}