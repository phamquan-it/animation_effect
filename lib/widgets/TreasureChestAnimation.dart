import 'dart:math';

import 'package:animation_effect/entities/particle.dart';
import 'package:animation_effect/widgets/LightEffectPainter.dart';
import 'package:flutter/material.dart';

class TreasureChestAnimation extends StatefulWidget {
  const TreasureChestAnimation({super.key});

  @override
  State<TreasureChestAnimation> createState() => _TreasureChestAnimationState();
}

class _TreasureChestAnimationState extends State<TreasureChestAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Animation chạy lặp lại vô hạn
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Sinh ra 60 hạt bay lên
    _particles = List.generate(60, (index) => Particle(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A00), // Màu nền tối
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(400, 400),
              painter: LightEffectPainter(_controller.value, _particles),
            );
          },
        ),
      ),
    );
  }
}
