import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanada/global.dart';
import 'package:kanada/metadata.dart';
import '../background.dart';

/// 音乐信息展示组件，包含封面、标题、艺术家信息和播放功能
class MusicInfo extends StatefulWidget {
  final String path; // 音乐文件路径
  final bool play; // 是否启用播放功能
  final ThemeData? theme; // 自定义主题
  final bool nextPlay; // 是否显示添加到下一首播放按钮

  const MusicInfo({
    super.key,
    required this.path,
    this.play = true,
    this.theme,
    this.nextPlay = true,
  });

  @override
  State<MusicInfo> createState() => _MusicInfoState();
}

class _MusicInfoState extends State<MusicInfo> {
  late Metadata metadata; // 音乐元数据
  late ThemeData theme; // 当前使用的主题

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// 初始化元数据和封面
  Future<void> _init() async {
    metadata = Metadata(widget.path);
    await metadata.getMetadata();
    if (mounted) setState(() {});
    await metadata.getCover();
    if (mounted) setState(() {});
  }

  /// 播放控制方法
  Future<void> play() async {
    Global.init = false;
    Global.path = widget.path;

    // 准备播放队列
    List<String> playlistPaths = Global.playlist;
    // playlistPaths.shuffle();
    int idx = playlistPaths.indexOf(widget.path);
    if (idx < 0) {
      playlistPaths = [widget.path];
      idx = 0;
    }

    // 设置播放队列
    await Global.player.setQueue(
      playlistPaths,
      initialIndex: idx >= 0 ? idx : null,
    );
    Global.init = true;

    // 初始化歌词后台服务
    if (!Global.lyricSenderInit) {
      startBackground();
      Global.lyricSenderInit = true;
    }

    // 跳转到当前曲目并开始播放
    if (idx >= 0) {
      await Global.player.skipToQueueItem(idx);
    }
    await Global.player.play();
  }

  @override
  Widget build(BuildContext context) {
    theme = widget.theme ?? Theme.of(context);
    return InkWell(
      onTap: widget.play ? play : null,
      child: Row(
        children: [
          // 封面显示区域
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child:
                  metadata.coverPath != null
                      ? Image.file(File(metadata.coverPath!), fit: BoxFit.cover)
                      : const Icon(Icons.music_note),
            ),
          ),
          const SizedBox(width: 10),
          // 文字信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata.title ?? widget.path.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  metadata.artist ?? 'Unknown Artist',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // if (widget.nextPlay) IconButton(
          //   onPressed: () async {
          //     Global.player.insertQueueItem(Global.player.currentIndex + 1, widget.path);
          //   },
          //   icon: Icon(
          //     Icons.add_circle,
          //     color: theme.colorScheme.primary,
          //   ),
          // )
        ],
      ),
    );
  }
}

/// 支持搜索的音乐信息组件，继承自MusicInfo
class MusicInfoSearch extends StatefulWidget {
  final String path; // 文件路径
  final String keywords; // 搜索关键词

  const MusicInfoSearch({
    super.key,
    required this.path,
    required this.keywords,
  });

  @override
  State<MusicInfoSearch> createState() => _MusicInfoSearchState();
}

class _MusicInfoSearchState extends State<MusicInfoSearch> {
  bool show = false; // 是否显示组件
  Metadata metadata = Metadata(''); // 元数据实例

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant MusicInfoSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keywords != oldWidget.keywords) {
      _init();
    }
  }

  /// 初始化并过滤搜索结果
  Future<void> _init() async {
    if (widget.keywords.isEmpty) {
      show = true;
      setState(() {});
    } else {
      if (metadata.id != widget.path) {
        metadata = Metadata(widget.path);
        await metadata.getMetadata();
      }
      // 关键词匹配逻辑（标题、艺术家、专辑）
      final keywordLower = widget.keywords.toLowerCase();
      final matchTitle =
          metadata.title?.toLowerCase().contains(keywordLower) ?? false;
      final matchArtist =
          metadata.artist?.toLowerCase().contains(keywordLower) ?? false;
      final matchAlbum =
          metadata.album?.toLowerCase().contains(keywordLower) ?? false;

      show = matchTitle || matchArtist || matchAlbum;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? ListTile(
          key: ValueKey(widget.path),
          title: MusicInfo(path: widget.path),
        )
        : Container();
  }
}
