import 'dart:math' as math;

import 'package:flutter/material.dart';

// ==========================================
// ENUM: CẤP ĐỘ HIẾM (RARITY)
// ==========================================
enum Rarity {
  common(label: 'Common', color: Color(0xFFB0BEC5)),
  uncommon(label: 'Uncommon', color: Color(0xFF4CAF50)),
  rare(label: 'Rare', color: Color(0xFF2196F3)),
  epic(label: 'Epic', color: Color(0xFF9C27B0)),
  legendary(label: 'Legendary', color: Color(0xFFFFC107)),
  mythic(label: 'Mythic', color: Color(0xFFFF1744));

  final String label;
  final Color color;

  const Rarity({required this.label, required this.color});
}

// ==========================================
// WIDGET: Ô VẬT PHẨM THEO CẤP ĐỘ HIẾM
// ==========================================
class LegendaryItemBox extends StatefulWidget {
  final String itemName;
  final IconData? itemIcon;
  final Widget? imageWidget;
  final double size;
  final Rarity rarity;
  final int quantity; // 👉 THÊM MỚI: Số lượng vật phẩm

  const LegendaryItemBox({
    super.key,
    required this.itemIcon,
    this.imageWidget,
    this.itemName = '',
    this.size = 100.0,
    this.rarity = Rarity.common,
    this.quantity = 0, // Mặc định không hiển thị số lượng (nếu = 0)
  });

  @override
  State<LegendaryItemBox> createState() => _LegendaryItemBoxState();
}

class _LegendaryItemBoxState extends State<LegendaryItemBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color rarityColor = widget.rarity.color;
    bool isMythic = widget.rarity == Rarity.mythic;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFF151E2E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Nền Gradient phát sáng
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double pulse =
                    0.3 + 0.2 * math.sin(_controller.value * 2 * math.pi);
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        isMythic
                            ? Color.lerp(
                                Colors.white,
                                rarityColor,
                                0.3,
                              )!.withOpacity(pulse)
                            : rarityColor.withOpacity(pulse),
                        rarityColor.withOpacity(0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                );
              },
            ),

            // 2. Viền sáng chạy quanh
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: GlowingBorderPainter(
                    progress: _controller.value,
                    color: rarityColor,
                    isMythic: isMythic,
                  ),
                );
              },
            ),

            // 3. Nội dung: Ảnh hoặc Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                child: widget.imageWidget != null
                    ? FittedBox(fit: BoxFit.contain, child: widget.imageWidget!)
                    : Icon(
                        widget.itemIcon,
                        size: widget.size * 0.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: rarityColor.withOpacity(0.8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
              ),
            ),

            // 4. Hạt sáng lấp lánh
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SparklePainter(
                    progress: _controller.value,
                    color: rarityColor,
                  ),
                );
              },
            ),

            // 5. Tên vật phẩm
            if (widget.itemName.isNotEmpty)
              Positioned(
                bottom: 6,
                child: Text(
                  widget.itemName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),

            // 6. Nhãn độ hiếm
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.rarity.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 👉 THÊM MỚI: 7. Số lượng vật phẩm (góc dưới trái)
            if (widget.quantity > 0)
              Positioned(
                bottom: 4,
                left: 4,
                child: Text(
                  'x${widget.quantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PAINTER 1: Viền sáng chạy quanh (Glow Border)
// ==========================================
class GlowingBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isMythic;

  GlowingBorderPainter({
    required this.progress,
    required this.color,
    required this.isMythic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    double cornerRadius = 12.0;

    double sweep = progress * 2 * math.pi;
    double lightX =
        rect.left + rect.width / 2 + math.cos(sweep) * (rect.width / 2);
    double lightY =
        rect.top + rect.height / 2 + math.sin(sweep) * (rect.height / 2);

    Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMythic ? 3.5 : 2.5
      ..shader =
          RadialGradient(
            colors: [isMythic ? Colors.white : color, color.withOpacity(0.0)],
          ).createShader(
            Rect.fromCircle(center: Offset(lightX, lightY), radius: 30),
          )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GlowingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==========================================
// PAINTER 2: Hạt sáng lấp lánh quay quanh
// ==========================================
class SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 4; i++) {
      double angle = (progress * 2 * math.pi) + (i * math.pi / 2);
      double radiusX = size.width * 0.35;
      double radiusY = size.height * 0.35;

      double x = center.dx + math.cos(angle) * radiusX;
      double y = center.dy + math.sin(angle) * radiusY;

      double sparkle = 0.5 + 0.5 * math.sin(progress * 10 * math.pi + i * 2);

      Paint paint = Paint()
        ..color = color.withOpacity(sparkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), 2.0 * sparkle, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==========================================
// MAIN - Ví dụ sử dụng
// ==========================================
void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              LegendaryItemBox(
                itemIcon: Icons.shield,
                itemName: 'Khiên Gỗ',
                rarity: Rarity.common,
                size: 100,
                quantity: 20,
              ),
              LegendaryItemBox(
                itemIcon: Icons.diamond,
                itemName: 'Cổ Kiếm',
                rarity: Rarity.legendary,
                size: 100,
                quantity: 1,
              ),
              LegendaryItemBox(
                itemIcon: Icons.local_fire_department,
                itemName: 'Hỏa Ngục',
                rarity: Rarity.mythic,
                size: 100,
                quantity: 999,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
