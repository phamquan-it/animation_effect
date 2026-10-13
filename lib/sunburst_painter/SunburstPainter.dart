import 'dart:math' as math;

import 'package:flutter/material.dart';

class SunburstPainter extends CustomPainter {
  /// Số lượng tia hào quang
  final int numberOfRays;

  /// Màu của tia (sẽ tự động mờ dần về phía đầu mút)
  final Color rayColor;

  /// Nếu true: hào quang tự tính bán kính theo kích thước canvas
  /// (dùng cho trường hợp full màn hình).
  /// Nếu false: hào quang dùng đúng kích thước canvas truyền vào.
  final bool isFullByScreen;

  /// Tỷ lệ khoảng trống ở tâm (0.0 - 1.0).
  /// Ví dụ 0.2 => tâm trống chiếm 20% bán kính.
  final double innerRadiusRatio;

  /// Độ rộng của tia so với góc chia (0.0 - 1.0).
  /// 1.0 = các tia sát nhau, 0.5 = có khe hở rộng.
  final double rayWidthRatio;

  /// Điểm bắt đầu mờ dần (0.0 - 1.0 theo chiều dài tia).
  /// Ví dụ 0.5 => tia đậm từ tâm đến 50%, sau đó mờ dần.
  final double fadeStartRatio;

  /// Độ mờ tối đa ở tâm tia (0.0 - 1.0).
  final double maxOpacity;

  const SunburstPainter({
    this.numberOfRays = 16,
    this.rayColor = const Color(0xFF8BC34A),
    this.isFullByScreen = false,
    this.innerRadiusRatio = 0.2,
    this.rayWidthRatio = 0.7,
    this.fadeStartRatio = 0.5,
    this.maxOpacity = 0.95,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Tính bán kính tối đa
    final double maxRadius;
    if (isFullByScreen) {
      // Đường chéo / 2 để phủ kín màn hình kể cả khi xoay
      maxRadius =
          math.sqrt(size.width * size.width + size.height * size.height) / 2;
    } else {
      // Dùng đúng kích thước canvas
      maxRadius = math.min(size.width, size.height) / 2;
    }

    final innerRadius = maxRadius * innerRadiusRatio;
    final anglePerRay = (2 * math.pi) / numberOfRays;
    final rayWidth = anglePerRay * rayWidthRatio;

    for (int i = 0; i < numberOfRays; i++) {
      final midAngle = (i * anglePerRay) - (math.pi / 2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(midAngle);

      // Gradient mờ dần về đầu mút
      final rayPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader =
            LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                rayColor.withValues(alpha: maxOpacity),
                rayColor.withValues(alpha: maxOpacity * 0.6),
                rayColor.withValues(alpha: 0.0),
              ],
              stops: [0.0, fadeStartRatio.clamp(0.0, 0.99), 1.0],
            ).createShader(
              Rect.fromLTWH(
                innerRadius,
                -maxRadius,
                maxRadius - innerRadius,
                maxRadius * 2,
              ),
            );

      final halfWidthInner = innerRadius * math.tan(rayWidth / 2);
      final halfWidthOuter = maxRadius * math.tan(rayWidth / 2);

      final path = Path()
        ..moveTo(innerRadius, -halfWidthInner)
        ..lineTo(maxRadius, -halfWidthOuter)
        ..lineTo(maxRadius, halfWidthOuter)
        ..lineTo(innerRadius, halfWidthInner)
        ..close();

      canvas.drawPath(path, rayPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SunburstPainter oldDelegate) {
    return oldDelegate.numberOfRays != numberOfRays ||
        oldDelegate.rayColor != rayColor ||
        oldDelegate.isFullByScreen != isFullByScreen ||
        oldDelegate.innerRadiusRatio != innerRadiusRatio ||
        oldDelegate.rayWidthRatio != rayWidthRatio ||
        oldDelegate.fadeStartRatio != fadeStartRatio ||
        oldDelegate.maxOpacity != maxOpacity;
  }
}
