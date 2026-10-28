import 'package:flutter/material.dart';

/// Vẽ **vòng tròn pulse** — lan ra rồi thu lại.
class PulseRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? secondaryColor;

  PulseRingPainter({
    required this.progress,
    required this.color,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.45;

    _drawPulse(canvas, center, maxR, progress, color);
    final p2 = (progress + 0.5) % 1.0;
    _drawPulse(canvas, center, maxR, p2, secondaryColor ?? color);
  }

  void _drawPulse(
    Canvas canvas,
    Offset center,
    double maxR,
    double t,
    Color c,
  ) {
    final r = maxR * t;
    final opacity = (1 - t).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t * 0.5)
        ..color = c.withOpacity(opacity),
    );

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * (1 - t * 0.5)
        ..color = c.withOpacity(opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant PulseRingPainter old) =>
      old.progress != progress || old.color != color;
}
