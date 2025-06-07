import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// 计算整数的绝对值
/// [a] 需要计算的整数
/// 返回非负整数
int abs(int a) {
  if (a < 0) {
    return -a;
  } else {
    return a;
  }
}

/// 通过图片生成主题配置
///
/// 从指定路径的图片中提取主色调，生成对应配色的ThemeData
/// [path] 图片文件路径
/// [brightness] 主题亮度（可选，默认为亮色模式）
/// 返回包含生成配色的ThemeData，若无法提取颜色则返回null
Future<ThemeData?> getThemeByImage(
    String path, {
      Brightness? brightness,
    }) async {
  // 初始化调色板生成器（最大支持30种颜色分析）
  final PaletteGenerator paletteGenerator =
  await PaletteGenerator.fromImageProvider(
    FileImage(File(path)),
    maximumColorCount: 30,
  );

  // 获取主色调
  final Color? color = paletteGenerator.dominantColor?.color;
  if (color == null) {
    return null;
  }

  // 构建主题数据
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: color,  // 使用提取的颜色作为种子色
      brightness: brightness ?? Brightness.light,  // 默认使用亮色模式
    ),
    useMaterial3: true,  // 启用Material3设计规范
  );
}
