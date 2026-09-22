// ==========================================
// 2. CLASS PARTICLE (HẠT BAY)
// ==========================================
import 'dart:math';

import 'package:flutter/material.dart';

class Particle {
  late double x, y, vx, vy, size;
  late Color color;
  late double opacity;
  late bool isSparkle;
  late double rotation;
  late double rotationSpeed;

  final Random random;

  Particle(this.random) {
    reset();
  }

  void reset() {
    x = 200;
    y = 200;
    double angle = random.nextDouble() * 2 * pi;
    double speed = 2 + random.nextDouble() * 8;
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 3.5;
    size = 2 + random.nextDouble() * 6;
    color = [
      Colors.amber,
      Colors.yellowAccent,
      Colors.orange,
      const Color(0xFFF9D976),
    ][random.nextInt(4)];
    opacity = 1.0;
    isSparkle = random.nextDouble() < 0.3;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
  }

  void update(double t) {
    x += vx * 2;
    y += vy * 2;
    opacity -= 0.015;
    rotation += rotationSpeed;
    if (opacity <= 0) reset();
  }
}
