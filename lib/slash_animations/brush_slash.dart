import 'package:flutter/material.dart';

import './painter.dart';

// ==========================================
// 2. WIDGET CHÍNH (Nhận thêm Duration, Curve & Góc nghiêng)
// ==========================================
class BrushSlashScreen extends StatefulWidget {
  final double radius;
  final bool loop;
  final double startAngle; // Đơn vị: ĐỘ (degree)
  final double endAngle; // Đơn vị: ĐỘ (degree)
  final bool reverseRotate;
  final Duration duration;
  final Curve curve;

  // 👇 THÊM MỚI: Góc nghiêng 3D (đơn vị: độ)
  final double rotateX; // Nghiêng xuống
  final double rotateY; // Nghiêng trái/phải
  final double rotateZ; // Xoay mặt phẳng
  final double perspective; // Độ sâu phối cảnh

  const BrushSlashScreen({
    super.key,
    this.radius = 180.0,
    this.loop = true,
    this.startAngle = -90,
    this.endAngle = 270,
    this.reverseRotate = false,
    this.duration = const Duration(milliseconds: 1800),
    this.curve = Curves.easeInOut,
    // 👇 Giá trị mặc định
    this.rotateX = 0.6,
    this.rotateY = 0.0,
    this.rotateZ = 0.0,
    this.perspective = 0.002,
  });

  @override
  State<BrushSlashScreen> createState() => _BrushSlashScreenState();
}

class _BrushSlashScreenState extends State<BrushSlashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Hằng số chuyển đổi độ sang radian
  static const double _degToRad = 3.141592653589793 / 180.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              // 👇 ÁP DỤNG GÓC NGHIÊNG 3D
              transform: Matrix4.identity()
                ..setEntry(3, 2, widget.perspective) // Độ sâu
                ..rotateX(widget.rotateX * _degToRad) // Nghiêng X
                ..rotateY(widget.rotateY * _degToRad) // Nghiêng Y
                ..rotateZ(widget.rotateZ * _degToRad), // Xoay Z
              child: CustomPaint(
                size: const Size(500, 500),
                painter: CustomBrushPainter(
                  progress: widget.curve.transform(_controller.value),
                  radius: widget.radius > 0 ? widget.radius : 180.0,
                  startAngleDeg: widget.startAngle,
                  endAngleDeg: widget.endAngle,
                  reverseRotate: widget.reverseRotate,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
