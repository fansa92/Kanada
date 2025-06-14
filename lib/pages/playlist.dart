import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/global.dart';

import '../widgets/music_info.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final _scrollController = ScrollController();
  final GlobalKey _firstItemKey = GlobalKey();
  StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<SequenceState?>? _sequenceSub;
  List<String> playlist = [];
  bool _firstBuild = true;

  @override
  void initState() {
    super.initState();
    _init();
    _currentIndexSub = Global.player.currentIndexStream.listen((index) {
      if (index != null) {
        _init();
      }
    });
    _sequenceSub = Global.player.sequenceStateStream.listen((state) {
      _init();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_firstBuild && Global.player.currentIndex != -1) {
        _firstBuild = false;
        _scrollController.jumpTo(
          max(
            _scrollController.position.minScrollExtent,
            _firstItemKey.currentContext!.size!.height *
                ((Global.player.currentIndex) - 3),
          ),
          // duration: const Duration(milliseconds: 300),
          // curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currentIndexSub?.cancel();
    _sequenceSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    playlist = Global.player.queue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Global.player.repeat=!Global.player.repeat;
                    Global.player.updatePlayMode();
                    setState(() {});
                  },
                  icon: Icon(Icons.repeat, color: Global.player.repeat?Global.playerTheme.colorScheme.primary:Global.playerTheme.colorScheme.onPrimary)
                ),
                IconButton(
                  onPressed: () {
                    Global.player.repeatOne=!Global.player.repeatOne;
                    Global.player.updatePlayMode();
                    setState(() {});
                  },
                  icon: Icon(Icons.repeat_one, color: Global.player.repeatOne?Global.playerTheme.colorScheme.primary:Global.playerTheme.colorScheme.onPrimary)
                ),
                IconButton(
                  onPressed: () {
                    Global.player.shuffle=!Global.player.shuffle;
                    Global.player.updatePlayMode();
                    setState(() {});
                  },
                  icon: Icon(Icons.shuffle, color: Global.player.shuffle?Global.playerTheme.colorScheme.primary:Global.playerTheme.colorScheme.onPrimary)
                ),
              ],
            ),
          ),
          Expanded(
              child:LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ShaderMask(
                    // 关键：使用线性渐变作为遮罩
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, // 渐变开始
                          Colors.black, // 底部完全不透明
                        ],
                        stops: [0.0, 50 / bounds.height], // 调整渐变区域
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn, // 使用目标输入混合模式
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: index == 0 ? _firstItemKey : null,
                          title: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color:
                              Global.player.currentIndex == index
                                  ? Global.playerTheme.colorScheme.secondaryContainer
                                  .withValues(alpha: .4)
                                  : null,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MusicInfo(
                                      path: playlist[index],
                                      play: false,
                                      theme: Global.playerTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            Global.player.skipToQueueItem(index);
                            Global.player.play();
                          },
                        );
                      },
                    ),
                  );
                },
              )
          )
        ]
    );
  }
}
