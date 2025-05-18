import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

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
