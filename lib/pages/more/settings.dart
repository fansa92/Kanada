import 'package:flutter/material.dart';
import 'package:kanada/widgets/link.dart';

import '../../settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
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
          Link(
            route: '/more/settings/player',
            child: ListTile(
              title: Text('播放器设置'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
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
