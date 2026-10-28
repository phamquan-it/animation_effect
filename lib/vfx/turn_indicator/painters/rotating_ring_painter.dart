import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vẽ **vòng tròn xoay** dưới chân nhân vật.
class RotatingRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? secondaryColor;

  RotatingRingPainter({
    required this.progress,
    required this.color,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final angle = progress * 2 * math.pi;

    _drawDashedCircle(canvas, center, radius, color.withOpacity(0.9), 3, 12, angle);
    _drawDashedCircle(
      canvas,
      center,
      radius * 0.7,
      (secondaryColor ?? color).withOpacity(0.5),
      2,
      8,
      -angle * 1.5,
    );

    final dotPaint = Paint()..color = color;
    for (int i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2;
      final p = Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      );
      canvas.drawCircle(p, 3, dotPaint);
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..color = color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double strokeWidth,
    int dashCount,
    double startAngle,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    final dashAngle = (2 * math.pi) / dashCount;
    const gapRatio = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final start = startAngle + i * dashAngle;
      final sweep = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RotatingRingPainter old) =>
      old.progress != progress || old.color != color;
}
