import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vẽ **hào quang phát sáng** quanh nhân vật.
class GlowAuraPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? secondaryColor;

  GlowAuraPainter({
    required this.progress,
    required this.color,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.width * 0.32;

    final pulse = 0.9 + 0.1 * math.sin(progress * 2 * math.pi);
    final r = baseR * pulse;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawCircle(
      center,
      r * 0.9,
      Paint()
        ..color = (secondaryColor ?? color).withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withOpacity(0.7),
    );

    final angle = progress * 2 * math.pi;
    final sparkPaint = Paint()..color = color;
    for (int i = 0; i < 8; i++) {
      final a = angle + i * math.pi / 4;
      final p = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      canvas.drawCircle(p, 2.5, sparkPaint);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlowAuraPainter old) =>
      old.progress != progress || old.color != color;
}
