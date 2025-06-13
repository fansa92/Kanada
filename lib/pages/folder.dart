import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';
import 'package:kanada/userdata.dart';
import 'package:kanada/widgets/music_info.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../global.dart';
import '../background.dart';
import '../settings.dart';
import '../tool.dart';
import '../widgets/float_playing.dart';

class FolderPage extends StatefulWidget {
  final String path;

  const FolderPage({super.key, required this.path});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  // List<FileSystemEntity> files = [];
  static const List<String> sortTypeString = [
    '',
    PlaylistSortType.name,
    PlaylistSortType.lastModified,
  ];
  Playlist playlist = Playlist('/ALL/');
  int sortType = 0;
  final ScrollController _scrollController = ScrollController();
  Duration? durationSum;
  int initiated = 0;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 150) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (sortType == 0) {
      final settings = await UserData(
        'folder/settings/${widget.path.hashCode}.json',
      ).get(defaultValue: {'sort': 1});
      sortType = settings['sort'];
    } else {
      await UserData(
        'folder/settings/${widget.path.hashCode}.json',
      ).set({'sort': sortType});
    }
    playlist = Playlist(widget.path);
    await playlist.getSongs();
    await playlist.sort(type: sortTypeString[abs(sortType)], reverse: sortType < 0);
    Global.playlist = playlist.songs;
    setState(() {});

    durationSum = Duration.zero;
    initiated = 0;
    const batchSize = 48;
    for (var i = 0; i < playlist.songs.length; i += batchSize) {
      final batch = playlist.songs.sublist(
        i,
        i + batchSize > playlist.songs.length
            ? playlist.songs.length
            : i + batchSize,
      );

      await Future.wait(
        batch.map((element) async {
          final value = await Metadata(element).getMetadata();
          durationSum = durationSum! + (value.duration ?? Duration.zero);
          initiated++;
          if (mounted) setState(() {});
        }),
      );

      if (mounted) setState(() {});
    }
  }

  Future<void> playAll() async {
    Global.init = false;
    Global.path = widget.path;

    final playlistPaths = playlist.songs;

    playlistPaths.shuffle();

    // Global.player.setAudioSource(
    //   ConcatenatingAudioSource(children: sources),
    // );
    await Global.player.setQueue(
      playlistPaths,
      // initialIndex: idx >= 0? idx : null,
    );
    Global.init = true;
    if (!Global.lyricSenderInit) {
      // print('sendLyrics');
      // sendLyrics();
      startBackground();
      Global.lyricSenderInit = true;
    }
    await Global.player.seek(Duration.zero);
    await Global.player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatPlaying(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        controller: _scrollController, // 关联控制器
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            floating: true,
            snap: true,
            // title: _showSubtitle ? Text(
            //   widget.path.split('/')[widget.path.split('/').length - 2],
            // ) : null,  // 根据状态控制标题显示
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.path.split('/')[widget.path.split('/').length - 2],
                    style: TextStyle(fontSize: 24),
                  ),
                  Opacity(
                    opacity: Curves.easeInOut.transform(
                      _scrollController
                              .hasClients // 添加存在性检查
                          ? max(0, 1 - _scrollController.position.pixels / 100)
                          : 1.0,
                    ), // 默认完全不透明
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        '共${playlist.songs.length}首${durationSum != null ? ' ${durationSum?.inMinutes}分钟' : ''}',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

          // 列表内容部分
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  index == 0
                      ? Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Hero(
                              tag: 'search-bar',
                              child: SearchAnchor.bar(
                                // isFullScreen: false,
                                barHintText: 'Search',
                                barBackgroundColor: WidgetStateProperty.all(
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                ),
                                suggestionsBuilder:
                                    (context, controller) => List.generate(
                                      playlist.songs.length,
                                      (index) => MusicInfoSearch(
                                        path: playlist.songs[index],
                                        keywords: controller.text,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          FilledButton(onPressed: playAll, child: Text('播放全部')),
                        ],
                      )
                      : ListTile(
                        key: ValueKey(playlist.songs[index - 1]),
                        title: MusicInfo(path: playlist.songs[index - 1]),
                      ),
              childCount: playlist.songs.length + 1,
            ),
          ),

          // 底部留白（替代原有 SizedBox）
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
