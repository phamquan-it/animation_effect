// ==========================================
// 1. RAIN PAINTER (VẼ MƯA RƠI)
// ==========================================
import 'dart:math';

import 'package:flutter/material.dart';

class RainPainter extends CustomPainter {
  final double progress;
  RainPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(1); // Cố định để mưa không đổi vị trí
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.3)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 80; i++) {
      double x = random.nextDouble() * size.width;
      double speed = 300 + random.nextDouble() * 200;
      double y =
          (random.nextDouble() * size.height + progress * speed) % size.height;

      canvas.drawLine(Offset(x, y), Offset(x - 5, y + 15), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => true;
}
