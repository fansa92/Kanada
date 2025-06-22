import 'dart:math';

import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double width;
  final double height;
  final double strokeWidth;
  final double startAngle;

  const PieChart({
    super.key,
    required this.values,
    required this.colors,
    this.width = 200,
    this.height = 200,
    this.strokeWidth = 40,
    this.startAngle = -90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: PieChartPainter(values, colors, strokeWidth: strokeWidth, startAngle: startAngle),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final double startAngle;

  PieChartPainter(this.values, this.colors, {this.strokeWidth = 40, this.startAngle = -90});

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate){
    if (oldDelegate is PieChartPainter) {
      return oldDelegate.values != values ||
          oldDelegate.colors != colors ||
          oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.startAngle != startAngle;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;
    final total = values.fold(0.0, (a, b) => a + b);

    double drawStartAngle = startAngle;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] / total * 360;

      final paint =
          Paint()
            ..color = colors[i % colors.length]
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth; // 圆环宽度

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(drawStartAngle),
        radians(sweepAngle),
        false,
        paint,
      );

      drawStartAngle += sweepAngle;
    }
  }

  double radians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
