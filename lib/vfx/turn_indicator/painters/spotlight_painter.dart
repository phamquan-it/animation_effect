import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vẽ **cột sáng** chiếu xuống từ trên (kiểu Disgaea).
class SpotlightPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? secondaryColor;

  SpotlightPainter({
    required this.progress,
    required this.color,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final topY = size.height * 0.05;
    final bottomY = size.height * 0.9;

    // Nhấp nhô độ sáng
    final pulse = 0.7 + 0.3 * math.sin(progress * 2 * math.pi);

    // ==== Cột sáng chính ====
    final beam = Path()
      ..moveTo(cx - size.width * 0.08, topY)
      ..lineTo(cx + size.width * 0.08, topY)
      ..lineTo(cx + size.width * 0.3, bottomY)
      ..lineTo(cx - size.width * 0.3, bottomY)
      ..close();

    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.0),
            color.withOpacity(0.5 * pulse),
            (secondaryColor ?? color).withOpacity(0.7 * pulse),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromLTWH(0, topY, size.width, bottomY - topY)),
    );

    // ==== Vòng sáng dưới chân ====
    final baseR = size.width * 0.28;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottomY),
        width: baseR * 2,
        height: baseR * 0.6,
      ),
      Paint()
        ..color = color.withOpacity(0.5 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottomY),
        width: baseR * 2,
        height: baseR * 0.6,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withOpacity(0.9),
    );

    // ==== Hạt sáng bay lên ====
    final sparkPaint = Paint()..color = color;
    for (int i = 0; i < 6; i++) {
      final phase = (progress + i / 6.0) % 1.0;
      final y = bottomY - (bottomY - topY) * phase;
      final x = cx + math.sin(phase * 6 * math.pi + i) * size.width * 0.08;
      final opacity = (1 - phase).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        2,
        sparkPaint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter old) =>
      old.progress != progress || old.color != color;
}
