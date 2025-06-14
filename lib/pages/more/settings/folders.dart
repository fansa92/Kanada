import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanada/settings.dart';

import '../../../tool.dart';

class FoldersSettings extends StatefulWidget {
  const FoldersSettings({super.key});

  @override
  State<FoldersSettings> createState() => _FoldersSettingsState();
}

class _FoldersSettingsState extends State<FoldersSettings> {
  // 存储列表项的列表
  List<String>? _folders;
  static RegExp uriReg=RegExp(r'(\w+)://([^/:]+)(:\d*)?([^# ]*)');

  Future<void> _init() async {
    _folders = Settings.folders;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  // 显示对话框输入文件夹路径
  Future<void> _showAddFolderDialog([int? index]) async {
    String clipboard = '';
    if(index==null&&await Clipboard.hasStrings()){
      clipboard = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    }
    TextEditingController controller = TextEditingController();
    controller.text = index != null ? _folders![index] : clipboard;
    if(index==null){
      if(clipboard.isNotEmpty&&uriReg.hasMatch(clipboard)){
        // controller.text = uriReg.firstMatch(clipboard)?.group(0)?? '';
        final uri = Uri.parse(await checkRedirects(uriReg.firstMatch(clipboard)?.group(0)?? ''));
        if(uri.path=='/playlist'){
          controller.text = 'netease://${uri.queryParameters['id']}';
        }
      }
    }
    if(!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加文件夹'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '输入文件夹路径'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                if (index != null) {
                  _folders![index] = controller.text;
                }
                else {
                  _folders?.add(controller.text);
                }
                // 保存更新后的文件夹列表
                Settings.folders = _folders!;
                Settings.save();
                Navigator.of(context).pop();
                setState(() {});
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文件夹设置')),
      body: SafeArea(
        child: Column(
          children: [
            // 使用 Expanded 让 ReorderableListView 占据剩余空间
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final String item = _folders!.removeAt(oldIndex);
                    _folders?.insert(newIndex, item);
                    // 保存更新后的文件夹列表
                    Settings.folders = _folders!;
                    Settings.save();
                  });
                },
                children: [
                  for (int index = 0; index < _folders!.length; index++)
                    ListTile(
                      key: Key('$index'),
                      title: Text(_folders![index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _folders?.removeAt(index);
                            // 保存更新后的文件夹列表
                            Settings.folders = _folders!;
                            Settings.save();
                          });
                        },
                      ),
                      onTap: () {
                        // 显示修改文件夹路径的对话框
                        _showAddFolderDialog(index);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFolderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
