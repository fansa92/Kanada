import 'package:flutter/material.dart';
import 'package:kanada/settings.dart';

class FoldersSettings extends StatefulWidget {
  const FoldersSettings({super.key});

  @override
  State<FoldersSettings> createState() => _FoldersSettingsState();
}

class _FoldersSettingsState extends State<FoldersSettings> {
  // 存储列表项的列表
  List<String>? _folders;

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
  void _showAddFolderDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('请输入文件夹路径'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '/storage/emulated/0/'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                String folderPath = controller.text;
                // 检查路径是否以 / 结尾，如果没有则加上
                if (folderPath.startsWith('/')&&!folderPath.endsWith('/')) {
                  folderPath += '/';
                }
                setState(() {
                  _folders?.add(folderPath);
                  // 保存更新后的文件夹列表
                  Settings.folders = _folders!;
                  Settings.save();
                });
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示对话框修改文件夹路径
  void _showEditFolderDialog(int index) {
    TextEditingController controller = TextEditingController(
      text: _folders![index],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('请输入文件夹路径'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '/storage/emulated/0/'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                String folderPath = controller.text;
                // 检查路径是否以 / 结尾，如果没有则加上
                if (folderPath.startsWith('/')&&!folderPath.endsWith('/')) {
                  folderPath += '/';
                }
                setState(() {
                  _folders![index] = folderPath;
                  // 保存更新后的文件夹列表
                  Settings.folders = _folders!;
                  Settings.save();
                });
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
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
                        _showEditFolderDialog(index);
                      },
                    ),
                ],
              ),
            ),
            // 添加按钮
            // ElevatedButton(
            //   onPressed: _showAddFolderDialog,
            //   child: Text(Const.addItem),
            // ),
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
