import 'dart:math';
import 'package:flutter/material.dart';

class CatapultSimulation extends StatefulWidget {
  const CatapultSimulation({super.key});

  @override
  State<CatapultSimulation> createState() => _CatapultSimulationState();
}

class _CatapultSimulationState extends State<CatapultSimulation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Vị trí bắt đầu (X) và kết thúc (Y)
  final Offset startPoint = const Offset(100, 400);
  final Offset endPoint = const Offset(700, 200);

  @override
  void initState() {
    super.initState();
    // Thời gian bay 1.5 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Lặp lại để test
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(800, 600),
              painter: CatapultPainter(
                progress: _controller.value,
                start: startPoint,
                end: endPoint,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// PAINTER: VẼ CATAPULT, QUỸ ĐẠO VÀ ĐẠN BAY
// ==========================================
class CatapultPainter extends CustomPainter {
  final double progress;
  final Offset start;
  final Offset end;

  CatapultPainter({
    required this.progress,
    required this.start,
    required this.end,
  });

  // Tính điểm trên quỹ đạo parabol dựa trên progress
  Offset getProjectilePosition(double t) {
    // Linear Interpolation (Lerp) giữa X và Y
    double x = start.dx + (end.dx - start.dx) * t;
    double y = start.dy + (end.dy - start.dy) * t;

    // Cộng thêm độ cong lên (Parabolic arc)
    // Dùng hàm sin: t = 0 -> 0, t = 0.5 -> max, t = 1 -> 0
    double arcHeight = 180; // Độ cao của cung
    y -= sin(t * pi) * arcHeight;

    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Vẽ máy bắn đá (Catapult) đơn giản tại điểm xuất phát X
    Paint catapultPaint = Paint()..color = Colors.brown.shade600;

    // Thân máy
    canvas.drawRect(
      Rect.fromCenter(center: start, width: 60, height: 40),
      catapultPaint,
    );
    // Tay đòn (Arm)
    canvas.drawLine(
      start,
      start - const Offset(30, 100), // Giả lập cánh tay đòn
      Paint()
        ..color = Colors.brown.shade800
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // 2. Vẽ quỹ đạo dự kiến (đường đứt nét)
    Paint trajectoryPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path();
    for (int i = 0; i <= 50; i++) {
      double t = i / 50;
      Offset pos = getProjectilePosition(t);
      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }
    canvas.drawPath(path, trajectoryPaint);

    // 3. Vẽ viên đạn đang bay
    Offset projectilePos = getProjectilePosition(progress);
    Paint projectilePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.yellowAccent, Colors.orange],
      ).createShader(Rect.fromCircle(center: projectilePos, radius: 15));

    // Tạo hiệu ứng lửa (trail) bằng cách vẽ thêm các vòng tròn mờ phía sau
    for (int i = 1; i <= 4; i++) {
      double prevT = (progress - i * 0.02).clamp(0.0, 1.0);
      Offset trailPos = getProjectilePosition(prevT);
      canvas.drawCircle(
        trailPos,
        10 - i * 2,
        Paint()
          ..color = Colors.orange.withOpacity(0.5 - i * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawCircle(projectilePos, 12, projectilePaint);

    // Thêm chút tia lửa nhỏ quanh đạn
    Paint sparkPaint = Paint()..color = Colors.yellowAccent;
    for (int i = 0; i < 6; i++) {
      double angle = i * (pi / 3) + progress * 5; // Xoay tròn theo thời gian
      Offset sparkPos =
          projectilePos + Offset(cos(angle) * 15, sin(angle) * 15);
      canvas.drawCircle(sparkPos, 2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CatapultPainter oldDelegate) => true;
}
