import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      seedColor: color, // 使用提取的颜色作为种子色
      brightness: brightness ?? Brightness.light, // 默认使用亮色模式
    ),
    useMaterial3: true, // 启用Material3设计规范
  );
}

int calculateLineCount(
  String text,
  double maxWidth,
  double fontSize, [
  FontWeight fontWeight = FontWeight.normal,
  String fontFamily = 'sans-serif',
]) {
  if (text.isEmpty) return 0;

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    ),
    maxLines: null, // 允许无限行数
  );

  // 执行布局计算
  textPainter.layout(maxWidth: maxWidth);

  // 获取文本行信息
  final lines = textPainter.computeLineMetrics();
  return lines.length;
}

/// 将时间字符串转换为毫秒数
int parseTimeToMs(String time) {
  final parts = time.split(':');
  final minute = int.parse(parts[0]);
  final secondParts = parts[1].split('.');
  final second = int.parse(secondParts[0]);
  final ms = int.parse(secondParts[1]) * pow(10, 3-secondParts[1].length).toInt(); // 百分秒转毫秒
  return minute * 60 * 1000 + second * 1000 + ms;
}

String formatTime(int time) {
  final minute = (time / 60000).floor();
  final second = ((time % 60000) / 1000).floor();
  final ms = (time % 1000).floor();
  return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
}

Future<String> checkRedirects(String url) async {
  http.Request req = http.Request("Get", Uri.parse(url))..followRedirects = false;
  http.Client baseClient = http.Client();
  http.StreamedResponse response = await baseClient.send(req);
  return response.headers['location']??url;
}