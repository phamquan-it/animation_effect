// ==========================================
// 3. PAINTER
import 'dart:math' as math;
// ==========================================
import 'package:animation_effect/slash_animations/config/BrushStrokeConfig.dart';
import 'package:flutter/material.dart';

const double _degToRad = math.pi / 180.0;

class CustomBrushPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double startAngleDeg;
  final double endAngleDeg;
  final bool reverseRotate;

  final List<BrushStrokeConfig> _strokes = const [
    BrushStrokeConfig(
      thickness: 8.0,
      color: Color(0xFF0055A4),
      opacity: 0.9,
      taperStart: 0.6,
      taperEnd: 1.0,
    ),
    BrushStrokeConfig(
      thickness: 14.0,
      color: Color(0xFF1E90FF),
      opacity: 1.0,
      taperStart: 0.8,
      taperEnd: 0.9,
    ),
    BrushStrokeConfig(
      thickness: 22.0,
      color: Color(0xFF87CEFA),
      opacity: 0.5,
      taperStart: 0.3,
      taperEnd: 0.7,
    ),
    BrushStrokeConfig(
      thickness: 3.0,
      color: Colors.white,
      opacity: 1.0,
      taperStart: 1.0,
      taperEnd: 1.0,
      roundedCap: true,
    ),
  ];

  CustomBrushPainter({
    required this.progress,
    required this.radius,
    required this.startAngleDeg,
    required this.endAngleDeg,
    required this.reverseRotate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 ||
        progress >= 1.0 ||
        size.width <= 0 ||
        size.height <= 0)
      return;

    Offset center = Offset(size.width / 2, size.height / 2);

    double startRad = startAngleDeg * _degToRad;
    double endRad = endAngleDeg * _degToRad;

    double sweepAngle = endRad - startRad;

    if (reverseRotate) {
      sweepAngle = -sweepAngle;
    }

    double currentAngle = startRad + (sweepAngle * progress);

    double trailLength = 0.6;
    double tailAngle = reverseRotate
        ? (currentAngle + trailLength)
        : (currentAngle - trailLength);

    double headY = center.dy + math.sin(currentAngle) * radius;
    double normalizedY = (headY - center.dy) / radius;
    double depth = (normalizedY + 1) / 2;
    double scale = 0.5 + depth * 0.5;

    for (var config in _strokes) {
      _drawBrushStroke(
        canvas,
        center: center,
        radius: radius,
        startAngle: tailAngle,
        endAngle: currentAngle,
        config: config,
        scale: scale,
        reverse: reverseRotate,
      );
    }
  }

  void _drawBrushStroke(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double startAngle,
    required double endAngle,
    required BrushStrokeConfig config,
    required double scale,
    required bool reverse,
  }) {
    if (radius <= 0 || scale <= 0) return;

    Path path = Path();
    double midAngle = (startAngle + endAngle) / 2;

    Offset start = Offset(
      center.dx + math.cos(startAngle) * radius,
      center.dy + math.sin(startAngle) * radius,
    );
    Offset mid = Offset(
      center.dx + math.cos(midAngle) * radius,
      center.dy + math.sin(midAngle) * radius,
    );
    Offset end = Offset(
      center.dx + math.cos(endAngle) * radius,
      center.dy + math.sin(endAngle) * radius,
    );

    double normalX = math.sin(midAngle);
    double normalY = -math.cos(midAngle);

    if (reverse) {
      normalX = -normalX;
      normalY = -normalY;
    }
    Offset normal = Offset(normalX, normalY);

    double realThickness = config.thickness * scale;

    Offset startOffset = normal * (realThickness * config.taperStart / 2);
    Offset midOffset = normal * (realThickness / 2);
    Offset endOffset = normal * (realThickness * config.taperEnd / 2);

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    path.lineTo(end.dx + endOffset.dx, end.dy + endOffset.dy);
    path.quadraticBezierTo(
      mid.dx + midOffset.dx,
      mid.dy + midOffset.dy,
      start.dx + startOffset.dx,
      start.dy + startOffset.dy,
    );
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = config.color.withValues(alpha: config.opacity),
    );
  }

  @override
  bool shouldRepaint(covariant CustomBrushPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
