import 'package:flutter/material.dart';
import 'package:kanada/userdata.dart';
import 'package:kanada/widgets/music_info.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../global.dart';
import '../utools.dart';
import '../widgets/float_playing.dart';

class FolderPage extends StatefulWidget {
  final String path;

  const FolderPage({super.key, required this.path});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<FileSystemEntity> files = [];
  int sortType = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (sortType == 0) {
      final settings=await UserData(
        'folder/settings/${widget.path.hashCode}',
      ).get(defaultValue: {'sort': 1});
      sortType = settings['sort'];
    }
    else {
      await UserData(
        'folder/settings/${widget.path.hashCode}',
      ).set({'sort': sortType});
    }
    final dir = Directory(widget.path);
    List<FileSystemEntity> entities = await dir.list().toList();

    files =
        entities.where((entity) {
          String extension = p.extension(entity.path).toLowerCase();
          return extension == '.mp3' || extension == '.flac';
        }).toList();

    files.sort((a, b) {
      final isAscending = sortType > 0;
      switch (sortType.abs()) {
        case 1: // 按文件名排序
          final nameA = p.basename(a.path).toLowerCase();
          final nameB = p.basename(b.path).toLowerCase();
          return isAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        case 2: // 按修改时间排序
          final dateA = File(a.path).lastModifiedSync();
          final dateB = File(b.path).lastModifiedSync();
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        default:
          return 0;
      }
    });
    Global.playlist = files.map((e) => e.path).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split('/')[widget.path.split('/').length - 2]),
        actions: [
          PopupMenuButton<String>(
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'sort',
                    child: ListTile(
                      leading: const Icon(Icons.sort),
                      title: const Text('排序'),
                      onTap: () {
                        Navigator.pop(context); // 关闭一级菜单
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject()
                                as RenderBox;
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(
                              Offset.zero,
                              ancestor: overlay,
                            ),
                            button.localToGlobal(
                              button.size.bottomRight(Offset.zero),
                              ancestor: overlay,
                            ),
                          ),
                          Offset.zero & overlay.size,
                        );

                        showMenu<String>(
                          context: context,
                          position: position,
                          items: [
                            PopupMenuItem(
                              value: '_',
                              child: ListTile(
                                title: Text(
                                  '目前: ${abs(sortType) == 1 ? '名称' : (abs(sortType) == 2 ? '修改日期' : '')}(${sortType > 0 ? '升序' : '降序'})',
                                ),
                                onTap: () {},
                              ),
                            ),
                            PopupMenuItem(
                              value: 'name',
                              child: ListTile(
                                title: const Text('名称'),
                                onTap: () {
                                  if (sortType == 1) {
                                    sortType = -1;
                                    Navigator.pop(context);
                                    _init();
                                    return;
                                  }
                                  sortType = 1;
                                  Navigator.pop(context);
                                  _init();
                                },
                              ),
                            ),
                            PopupMenuItem(
                              value: 'modify_date',
                              child: ListTile(
                                title: const Text('修改日期'),
                                onTap: () {
                                  if (sortType == 2) {
                                    sortType = -2;
                                    Navigator.pop(context);
                                    _init();
                                    return;
                                  }
                                  sortType = 2;
                                  Navigator.pop(context);
                                  _init();
                                },
                              ),
                            ),
                            PopupMenuItem(
                              value: 'change',
                              child: ListTile(
                                title: Text(sortType > 0 ? '转降序' : '转升序'),
                                onTap: () {
                                  sortType = -sortType;
                                  Navigator.pop(context);
                                  _init();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('刷新'),
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'refresh') {
                _init();
              }
            },
          ),
        ],
      ),
      // body: ListView.builder(
      //   itemCount: files.length,
      //   itemBuilder: (context, index) {
      //     return ListTile(
      //       key: ValueKey(files[index].path),
      //       title: MusicInfo(path: files[index].path),
      //     );
      //   },
      // ),
      body: ListView(
        children:[
          for (final file in files) ListTile(
            key: ValueKey(file.path),
            title: MusicInfo(path: file.path),
          ),
          SizedBox(
            height: 100,
          )
        ]
      ),
      floatingActionButton: FloatPlaying(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
