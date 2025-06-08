import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/metadata.dart';
import 'package:kanada/pages/player.dart';
import 'package:kanada/pages/lyric.dart';
import 'package:kanada/pages/playlist.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../global.dart';
import '../widgets/color_diffusion.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  static const List<Widget> pages = [PlaylistPage(), PlayerPage(), LyricPage()];
  final PageController _pageController = PageController();
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstBuild) {
        // 构建完成后执行的代码
        _pageController.jumpToPage(1);
        _isFirstBuild = false;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 透明背景
        statusBarIconBrightness: Brightness.light, // 白色图标
        systemNavigationBarColor: Colors.transparent, // 导航栏背景色
        systemNavigationBarIconBrightness: Brightness.light, // 导航栏图标
      ),
      child: Scaffold(
        body: Stack(
          children: [
            PlayerBackground(),
            PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerBackground extends StatefulWidget {
  const PlayerBackground({super.key});

  @override
  State<PlayerBackground> createState() => _PlayerBackgroundState();
}

class _PlayerBackgroundState extends State<PlayerBackground>
    with SingleTickerProviderStateMixin {
  static const double radius = 0.5;
  String? path;
  Metadata? metadata;
  StreamSubscription<SequenceState?>? _sequenceSub;
  late AnimationController _controller;
  late List<Offset> _baseOffsets;
  List<Color> colors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _baseOffsets = [
      const Offset(.5, .5),
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(0, 1),
      const Offset(1, 1),
    ];
    _init();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _sequenceSub = Global.player.sequenceStateStream.listen((state) {
      if (state?.currentIndex != null) {
        _init(); // 主动刷新
      }
    });
  }

  @override
  void dispose() {
    _sequenceSub?.cancel();
    super.dispose();
  }

  List<Offset> get _animatedOffsets {
    final value = _controller.value * 2 * 3.14159; // 转换为弧度
    return _baseOffsets.map((offset) {
      final dx = offset.dx + radius * sin(value); // X 轴波动
      final dy = offset.dy + radius * cos(value); // Y 轴波动
      return Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));
    }).toList();
  }

  Future<void> _init() async {
    // 获取新路径
    final newPath = Global.player.current;

    // 路径未变化时跳过
    if (newPath == metadata?.id) return;

    // 更新元数据
    path = newPath;
    metadata = Metadata(path!);

    await metadata!.getCover(cache: false);

    if (metadata!.coverPath== null) {
      return;
    }

    colors =
        Global.colorsCache[metadata!.id] ??
        (await PaletteGenerator.fromImageProvider(
          // MemoryImage(metadata!.cover!),
          FileImage(File(metadata!.coverPath!)),
          maximumColorCount: 10,
        )).colors.take(5).toList();
    Global.colorsCache[metadata!.id] = colors;
    if (mounted) {
      Global.playerTheme = Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors[0],
          brightness: Brightness.dark,
        ),
      );
    }
    colors =
        colors.map((color) {
          final hsv = HSVColor.fromColor(color);
          return hsv.value > 0.8
              ? hsv.withValue(hsv.value * 0.8).toColor()
              : color;
        }).toList();
    final newColors = colors.sublist(1);
    newColors.shuffle();
    colors = [
      colors[0],
      newColors[0],
      newColors[1],
      newColors[2],
      newColors[3],
    ];
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : ColorDiffusionWidget(colors: colors, offsets: _animatedOffsets);
  }
}
