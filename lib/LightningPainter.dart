import 'dart:math';
import 'package:flutter/material.dart';

class LightningPainter extends CustomPainter {
  final double progress;
  final Offset startPoint;
  final Offset endPoint;
  final int boltCount;

  // THAM SỐ MỚI
  final bool isRandomStrike; // Bật lên để sét đánh ngẫu nhiên khắp màn hình
  final Rect strikeArea; // Vùng cho phép sét đánh (mặc định là toàn màn hình)

  LightningPainter({
    required this.progress,
    required this.startPoint,
    required this.endPoint,
    this.boltCount = 3,
    this.isRandomStrike = false,
    this.strikeArea = const Rect.fromLTWH(
      0,
      0,
      400,
      400,
    ), // Kích thước mặc định
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Hiệu ứng chớp giật
    double flicker = progress < 0.4 ? 1.0 : 0.0;
    if (flicker <= 0) return;

    final Random mainRandom = Random(
      progress * 10000 ~/ 1,
    ); // Seed thay đổi mỗi frame

    for (int i = 0; i < boltCount; i++) {
      Offset currentStart, currentEnd;

      if (isRandomStrike) {
        // --- THIÊN LÔI: Chọn vị trí ngẫu nhiên trong vùng strikeArea ---
        // Điểm xuất phát (trên trời): Random X, Y ở phần trên cùng
        currentStart = Offset(
          strikeArea.left + mainRandom.nextDouble() * strikeArea.width,
          strikeArea.top +
              mainRandom.nextDouble() *
                  (strikeArea.height * 0.2), // Phần trên 20% màn hình
        );

        // Điểm kết thúc (dưới đất): Random X, Y ở phần dưới
        currentEnd = Offset(
          strikeArea.left + mainRandom.nextDouble() * strikeArea.width,
          strikeArea.bottom -
              mainRandom.nextDouble() *
                  (strikeArea.height * 0.1), // Phần dưới 10%
        );
      } else {
        // --- CHẾ ĐỘ TĨNH: Đánh từ vị trí chỉ định sẵn ---
        currentStart = startPoint;

        // Thêm độ lệch ngang cho nhiều tia
        double offsetX = (mainRandom.nextDouble() - 0.5) * 150;
        double offsetY = (mainRandom.nextDouble() - 0.5) * 50;
        currentEnd = endPoint + Offset(offsetX, offsetY);
      }

      _drawBranch(
        canvas,
        start: currentStart,
        end: currentEnd,
        progress: progress,
        depth: 0,
        maxDepth: 6,
        random: mainRandom,
      );
    }
  }

  void _drawBranch(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required double progress,
    required int depth,
    required int maxDepth,
    required Random random,
  }) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance < 2) return;
    final direction = delta / distance;

    // --- BƯỚC NHẢY NGẪU NHIÊN ---
    double t = random.nextDouble();
    Offset mid = start + direction * (distance * t);
    Offset perpendicular = Offset(-direction.dy, direction.dx);
    double lateralOffset = (random.nextDouble() - 0.5) * (25 + depth * 15);
    mid += perpendicular * lateralOffset;

    // --- VẼ LỚP GLOW & LÕI ---
    Paint glowPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.5)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(start, mid, glowPaint);

    Paint corePaint = Paint()
      ..color = depth == 0
          ? Colors.white.withOpacity(0.95)
          : const Color(0xFFB3E5FC).withOpacity(0.7)
      ..strokeWidth = depth == 0 ? 2.0 : max(0.5, 1.5 - depth * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, mid, corePaint);

    // --- ĐỆ QUY ---
    if (depth < maxDepth && progress > 0.1) {
      int subBranchCount = depth == 0
          ? random.nextInt(2) + 2
          : random.nextInt(2);
      for (int i = 0; i < subBranchCount; i++) {
        if (random.nextDouble() < 0.85) {
          double angle = (random.nextDouble() - 0.5) * 2.0;
          double length = distance * (0.15 + random.nextDouble() * 0.4);
          Offset dir = Offset(
            cos(atan2(direction.dy, direction.dx) + angle),
            sin(atan2(direction.dy, direction.dx) + angle),
          );
          Offset branchEnd = mid + dir * length;

          _drawBranch(
            canvas,
            start: mid,
            end: branchEnd,
            progress: progress * 0.75,
            depth: depth + 1,
            maxDepth: maxDepth,
            random: random,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LightningPainter oldDelegate) => true;
}
