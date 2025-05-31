import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

import 'global.dart';

int abs(int a) {
  if (a < 0) {
    return -a;
  } else {
    return a;
  }
}

Future<ThemeData?> getThemeByImage(
  String path, {
  Brightness? brightness,
}) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        FileImage(File(path)),
        maximumColorCount: 30,
      );
  final Color? color = paletteGenerator.dominantColor?.color;
  if (color == null) {
    return null;
  }
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: color,
      brightness: brightness ?? Brightness.light,
    ),
    useMaterial3: true,
  );
}

String getCurrentUri(){
  if (Global.player.currentIndex == null) {
    return '';
  }
  final playlist = Global.player.audioSources;
  final currentIndex = Global.player.currentIndex;

  // 防御性检查：确保播放列表和索引有效
  if (currentIndex == null) {
    return '';
  }

  final current = playlist[currentIndex];
  final tag = (current as UriAudioSource).tag;
  return tag.id;
}