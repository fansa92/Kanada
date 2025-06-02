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
    return Center(
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
  }
}
