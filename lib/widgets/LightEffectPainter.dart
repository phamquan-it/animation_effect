// --- 2. Lớp Painter vẽ hiệu ứng ---
import 'dart:math';

import 'package:animation_effect/entities/particle.dart';
import 'package:flutter/material.dart';

class LightEffectPainter extends CustomPainter {
  final double progress;
  final List<Particle> particles;
  final bool reverse; // Mặc định là true: Đầu tù ở trong, mũi nhọn ra ngoài

  LightEffectPainter(
    this.progress,
    this.particles, {
    this.reverse = true, // Option mặc định là true
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Cập nhật vị trí hạt
    for (var p in particles) {
      p.update(progress);
    }

    // --- A. VẼ VẦNG SÁNG TRUNG TÂM (Glow) ---
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF3B0).withOpacity(0.8),
          const Color(0xFFFFD700).withOpacity(0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 180));

    canvas.drawCircle(center, 180, glowPaint);

    // --- B. VẼ TIA SÁNG HÌNH NÓN (Light Cones) ---
    final Paint conePaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    int coneCount = 16;
    double coneLength = 120 + 40 * sin(progress * pi);

    for (int i = 0; i < coneCount; i++) {
      double angle = (i * (pi * 2 / coneCount));

      Path conePath = Path();
      Offset baseCenter = center;

      double innerRadius, baseAngleSpread, tipRadius, tipAngleSpread;

      if (reverse) {
        // Đầu tù (gốc lớn) ở trong tâm -> Mũi nhọn chĩa ra ngoài
        innerRadius = 10.0;
        baseAngleSpread = 0.20; // Góc loe lớn
        tipRadius = coneLength;
        tipAngleSpread = 0.02; // Góc loe rất nhỏ
      } else {
        // Kiểu tam giác ngược (nhọn ở tâm -> loe rộng ra ngoài)
        innerRadius = 1.0;
        baseAngleSpread = 0.02; // Góc rất nhỏ
        tipRadius = coneLength;
        tipAngleSpread = 0.12; // Góc loe rộng
      }

      // Tính toán 4 điểm của hình thang (hoặc tam giác)
      double baseX1 =
          baseCenter.dx + cos(angle - baseAngleSpread) * innerRadius;
      double baseY1 =
          baseCenter.dy + sin(angle - baseAngleSpread) * innerRadius;
      double baseX2 =
          baseCenter.dx + cos(angle + baseAngleSpread) * innerRadius;
      double baseY2 =
          baseCenter.dy + sin(angle + baseAngleSpread) * innerRadius;

      double tipX1 = baseCenter.dx + cos(angle - tipAngleSpread) * tipRadius;
      double tipY1 = baseCenter.dy + sin(angle - tipAngleSpread) * tipRadius;
      double tipX2 = baseCenter.dx + cos(angle + tipAngleSpread) * tipRadius;
      double tipY2 = baseCenter.dy + sin(angle + tipAngleSpread) * tipRadius;

      // Vẽ path
      conePath.moveTo(baseX1, baseY1);
      conePath.lineTo(tipX1, tipY1);
      conePath.lineTo(tipX2, tipY2);
      conePath.lineTo(baseX2, baseY2);
      conePath.close();

      // Gradient: Sáng rực ở tâm -> Mờ dần ra ngoài
      // Vì chúng ta vẽ hình thang từ Tâm ra Ngoài, nên Gradient luôn chạy từ Tâm ra Ngoài theo hướng của tia
      conePaint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFFFD700).withOpacity(0.9), // Sáng rực ở gốc
          const Color(0xFFFFC107).withOpacity(0.4), // Lan tỏa
          const Color(0xFFFFE082).withOpacity(0.0), // Trong suốt ở mũi nhọn
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: coneLength));

      canvas.drawPath(conePath, conePaint);
    }

    // --- C. VẼ CÁC HẠT BAY LÊN (Particles & Sparkles) ---
    for (var p in particles) {
      final particlePaint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      if (p.isSparkle) {
        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(p.rotation);

        final sparklePaint = Paint()
          ..color = p.color.withOpacity(p.opacity)
          ..style = PaintingStyle.fill;

        Path path = Path();
        path.moveTo(0, -p.size * 2);
        path.lineTo(p.size * 0.5, 0);
        path.lineTo(0, p.size * 2);
        path.lineTo(-p.size * 0.5, 0);
        path.close();

        canvas.drawPath(path, sparklePaint);

        canvas.drawLine(
          Offset(-p.size * 3, 0),
          Offset(p.size * 3, 0),
          sparklePaint..strokeWidth = 1,
        );
        canvas.drawLine(
          Offset(0, -p.size * 3),
          Offset(0, p.size * 3),
          sparklePaint,
        );

        canvas.restore();
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
