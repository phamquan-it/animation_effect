import 'dart:math';

import 'package:animation_effect/LightningPainter.dart';
import 'package:animation_effect/backgrounds/rain.dart';
import 'package:animation_effect/entities/particle.dart';
import 'package:flutter/material.dart';

class StormEffectDemo extends StatefulWidget {
  const StormEffectDemo({super.key});

  @override
  State<StormEffectDemo> createState() => _StormEffectDemoState();
}

class _StormEffectDemoState extends State<StormEffectDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Chu kỳ 3 giây: 1 giây đầu có sét, 2 giây sau yên tĩnh
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _particles = List.generate(40, (index) => Particle(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm tính độ sáng của màn hình dựa trên progress
  double getScreenFlashOpacity(double progress) {
    // Giả sử trong 1 chu kỳ 3s:
    // Sét đánh ở thời điểm progress = 0.1 và 0.5
    // Màn hình sẽ sáng rực lên rồi tắt ngay lập tức
    double flash = 0.0;

    // Lần chớp 1 (Mạnh)
    if (progress > 0.08 && progress < 0.15) {
      double p = (progress - 0.08) / 0.07; // 0 -> 1 -> 0
      flash = sin(p * pi); // Lên đỉnh rồi xuống
    }
    // Lần chớp 2 (Yếu hơn - nhấp nháy)
    else if (progress > 0.45 && progress < 0.55) {
      double p = (progress - 0.45) / 0.10;
      // Tạo hiệu ứng nhấp nháy nhiều lần trong khoảng thời gian ngắn
      flash = sin(p * pi * 3) * 0.5;
    }

    // Giới hạn độ sáng tối đa (tránh làm chói mắt quá 0.6)
    return flash.clamp(0.0, 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04070D), // Nền xanh đen rất tối
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double flashOpacity = getScreenFlashOpacity(_controller.value);

          return Stack(
            children: [
              // 1. LỚP NỀN MƯA (Tối)
              Positioned.fill(
                child: CustomPaint(
                  painter: RainPainter(progress: _controller.value),
                ),
              ),

              // 2. HIỆU ỨNG ÁNH SÁNG RƯƠNG BÁU / SÉT (Ở giữa màn hình)
              Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(400, 400),
                        painter: LightningPainter(
                          progress: _controller.value,
                          startPoint: const Offset(200, 0),
                          endPoint: const Offset(200, 400),
                          isRandomStrike: true,
                          strikeArea: const Rect.fromLTWH(0, 0, 400, 400),

                          // // Cấu hình "Ghim sét" cho nó giận dữ:
                          // strikeStart: 0.15,   // 15% đầu chu kỳ yên tĩnh (300ms)
                          // strikeDuration: 0.35, // Sét giữ nguyên trong 35% chu kỳ (700ms)
                          // flickerIntensity: 1.5, // Tăng độ sáng tối đa (chói hơn)
                        ),
                      ),
                      // Lớp tia sét tự nhiên
                      CustomPaint(
                        size: const Size(500, 500),
                        painter: LightningPainter(
                          progress: _controller.value,
                          startPoint: const Offset(200, 350),
                          endPoint: const Offset(200, 50),
                          boltCount: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. LỚP PHỦ CHỚP SÁNG TOÀN MÀN HÌNH (Quan trọng nhất)
              IgnorePointer(
                child: Container(color: Colors.white.withOpacity(flashOpacity)),
              ),
            ],
          );
        },
      ),
    );
  }
}
