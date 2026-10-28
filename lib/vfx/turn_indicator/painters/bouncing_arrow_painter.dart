import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vẽ **mũi tên nhấp nhô** trên đầu nhân vật.
class BouncingArrowPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? secondaryColor;

  BouncingArrowPainter({
    required this.progress,
    required this.color,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bounce = math.sin(progress * math.pi) * size.height * 0.08;
    final y = cy + bounce;

    final arrowH = size.height * 0.4;
    final arrowW = size.width * 0.35;

    final arrowPath = _buildArrowPath(cx, y, arrowW, arrowH);

    // Glow
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Trail
    final trailPath = Path()
      ..moveTo(cx - arrowW * 0.15, y - arrowH * 0.6)
      ..lineTo(cx, y - arrowH * 1.8)
      ..lineTo(cx + arrowW * 0.15, y - arrowH * 0.6)
      ..close();
    canvas.drawPath(
      trailPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.0), color.withOpacity(0.4)],
        ).createShader(Rect.fromLTWH(
          cx - arrowW / 2,
          y - arrowH * 1.8,
          arrowW,
          arrowH * 1.2,
        )),
    );

    // Main
    canvas.drawPath(
      arrowPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [secondaryColor ?? color, color],
        ).createShader(Rect.fromLTWH(
          cx - arrowW / 2,
          y - arrowH / 2,
          arrowW,
          arrowH,
        )),
    );

    // Outline
    canvas.drawPath(
      arrowPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.9),
    );
  }

  Path _buildArrowPath(double cx, double cy, double w, double h) {
    return Path()
      ..moveTo(cx - w / 2, cy - h / 2)
      ..lineTo(cx + w / 2, cy - h / 2)
      ..lineTo(cx, cy + h / 2)
      ..close();
  }

  @override
  bool shouldRepaint(covariant BouncingArrowPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.secondaryColor != secondaryColor;
}
