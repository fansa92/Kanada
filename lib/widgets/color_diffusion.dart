import 'dart:math';
import 'package:flutter/material.dart';

class ColorDiffusionWidget extends StatelessWidget {
  final List<Color> colors;
  final List<Offset> offsets;
  final double width;
  final double height;

  const ColorDiffusionWidget({
    super.key,
    required this.colors,
    required this.offsets,
    this.width = double.infinity,
    this.height = double.infinity,
  }) : assert(
         colors.length == offsets.length,
         'Colors and offsets must have the same length',
       );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ColorDiffusionPainter(colors: colors, offsets: offsets),
      ),
    );
  }
}

class _ColorDiffusionPainter extends CustomPainter {
  final List<Color> colors;
  final List<Offset> offsets;

  _ColorDiffusionPainter({required this.colors, required this.offsets})
    : assert(
        colors.length == offsets.length,
        'Colors and offsets must have the same length',
      );

  @override
  bool shouldRepaint(covariant _ColorDiffusionPainter old) {
    // 添加深度比较
    return old.colors != colors ||
        old.offsets != offsets;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < colors.length; i++) {
      final color = colors[i];
      final offset = offsets[i];

      // 计算实际坐标
      final centerX = offset.dx * size.width;
      final centerY = offset.dy * size.height;

      // 计算到四个角落的最大距离
      final distances = [
        _calculateDistance(centerX, centerY, 0, 0),
        _calculateDistance(centerX, centerY, size.width, 0),
        _calculateDistance(centerX, centerY, size.width, size.height),
        _calculateDistance(centerX, centerY, 0, size.height),
      ];
      final maxDistance = distances.reduce(max);

      // 计算渐变半径（相对于最大尺寸）
      final maxSize = max(size.width, size.height);
      final radius = maxDistance / (maxSize / 2);

      // 创建径向渐变
      final gradient = RadialGradient(
        center: Alignment((offset.dx * 2 - 1), (offset.dy * 2 - 1)),
        colors: [color, Colors.transparent],
        stops: const [0.0, 1.0],
        radius: radius,
        tileMode: TileMode.clamp,
      );

      // 绘制渐变
      final paint =
          Paint()
            ..shader = gradient.createShader(
              Rect.fromLTWH(0, 0, size.width, size.height),
            );

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }
}
