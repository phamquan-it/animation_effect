import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LuckyCardApp());
}

// ============================================================
// ============== CONFIG - CHỈNH MỌI THỨ Ở ĐÂY ================
// ============================================================
class LuckyCardConfig {
  LuckyCardConfig._(); // private constructor

  // ---------- MÀU MẶC ĐỊNH ----------
  /// Màu nháy (flash) mặc định trước khi lật
  static const Color defaultFlashColor = Color(0xFFFFD700);

  /// Màu vàng chủ đạo (dùng cho text, border, glow)
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE97A);
  static const Color goldDark = Color(0xFFFFB800);

  /// Màu nền gradient của page
  static const List<Color> pageBackground = [
    Color(0xFF3D1A6B),
    Color(0xFF1A0A2E),
    Color(0xFF0A0410),
  ];

  /// Màu mặt trước thẻ
  static const List<Color> cardFrontGradient = [
    Color(0xFF4A148C),
    Color(0xFF2C0A4E),
    Color(0xFF1A0533),
  ];

  // ---------- SỐ LẦN NHÁY ----------
  /// Số lần thẻ nháy sáng trước khi lật. Mặc định = 3
  static const int defaultFlashCount = 3;

  /// Thời gian mỗi lần nháy sáng lên (ms)
  static const int flashOnDurationMs = 150;

  /// Thời gian mỗi lần tắt sáng giữa các nháy (ms)
  static const int flashOffDurationMs = 120;

  // ---------- TIMING ----------
  /// Thời gian rung lắc (shake) mỗi lần (ms)
  static const int shakeDurationMs = 150;

  /// Thời gian lật thẻ (ms)
  static const int flipDurationMs = 900;

  /// Thời gian glow phập phồng (ms)
  static const int glowDurationMs = 1500;

  /// Thời gian burst spark (ms)
  static const int sparkDurationMs = 1200;

  // ---------- KÍCH THƯỚC ----------
  static const double cardWidth = 240;
  static const double cardHeight = 340;
  static const double cardWidthSmall = 200;
  static const double cardHeightSmall = 290;

  // ---------- HAPTIC ----------
  /// Có rung điện thoại khi nháy không
  static const bool hapticOnFlash = true;

  /// Có rung mạnh khi lật không
  static const bool hapticOnFlip = true;
}

// ============================================================
// =========================== APP ============================
// ============================================================
class LuckyCardApp extends StatelessWidget {
  const LuckyCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thẻ Bài May Mắn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LuckyCardPage(),
    );
  }
}

// ============================================================
// ======================= PAINTERS ===========================
// ============================================================
class CardPatternPainter extends CustomPainter {
  final double glow;
  CardPatternPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final gold = LuckyCardConfig.gold;

    final paint = Paint()
      ..color = gold.withOpacity(0.15 * glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(15, 15, size.width - 30, size.height - 30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );

    final rect2 = Rect.fromLTWH(25, 25, size.width - 50, size.height - 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect2, const Radius.circular(8)),
      paint,
    );

    final starPaint = Paint()..color = gold.withOpacity(0.4 * glow);
    _drawStar(canvas, const Offset(35, 35), 6, starPaint);
    _drawStar(canvas, Offset(size.width - 35, 35), 6, starPaint);
    _drawStar(canvas, Offset(35, size.height - 35), 6, starPaint);
    _drawStar(canvas, Offset(size.width - 35, size.height - 35), 6, starPaint);

    final diagPaint = Paint()
      ..color = gold.withOpacity(0.08 * glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = -size.height.toInt(); i < size.width.toInt(); i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        diagPaint,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final innerAngle = angle + pi / 5;
      final ix = center.dx + radius * 0.4 * cos(innerAngle);
      final iy = center.dy + radius * 0.4 * sin(innerAngle);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CardPatternPainter oldDelegate) =>
      oldDelegate.glow != glow;
}

class RayBurstPainter extends CustomPainter {
  final Color color;
  final double progress;
  RayBurstPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.3 * progress)
      ..style = PaintingStyle.fill;

    const rayCount = 12;
    final maxLength = size.width * 0.7;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * pi;
      final length = maxLength * progress * (0.6 + 0.4 * (i % 2));
      final path = Path();
      path.moveTo(center.dx, center.dy);

      const spread = 0.05;
      final x1 = center.dx + length * cos(angle - spread);
      final y1 = center.dy + length * sin(angle - spread);
      final x2 = center.dx + length * cos(angle + spread);
      final y2 = center.dy + length * sin(angle + spread);

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RayBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class SparkPainter extends CustomPainter {
  final List<Spark> sparks;
  SparkPainter({required this.sparks});

  @override
  void paint(Canvas canvas, Size size) {
    for (final spark in sparks) {
      final paint = Paint()
        ..color = spark.color.withOpacity(spark.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(spark.position, spark.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparkPainter oldDelegate) => true;
}

/// Painter phủ sáng toàn thẻ khi "nháy" flash
class FlashOverlayPainter extends CustomPainter {
  final double intensity; // 0 -> 1
  final Color color;
  FlashOverlayPainter({required this.intensity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    // Lớp sáng phủ đều
    final fillPaint = Paint()..color = color.withOpacity(0.55 * intensity);
    canvas.drawRRect(rrect, fillPaint);

    // Hào quang tỏa ra ngoài
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant FlashOverlayPainter oldDelegate) =>
      oldDelegate.intensity != intensity || oldDelegate.color != color;
}

class Spark {
  Offset position;
  double radius;
  double opacity;
  Color color;

  Spark({
    required this.position,
    required this.radius,
    required this.opacity,
    required this.color,
  });
}

// ============================================================
// ======================= LUCKY CARD =========================
// ============================================================
class LuckyCard extends StatelessWidget {
  final double flipProgress;
  final double scale;
  final double glow;
  final double flashIntensity;
  final Color flashColor;
  final Map<String, dynamic>? prize;
  final double cardWidth;
  final double cardHeight;

  const LuckyCard({
    super.key,
    required this.flipProgress,
    required this.scale,
    required this.glow,
    required this.flashIntensity,
    required this.flashColor,
    required this.prize,
    this.cardWidth = LuckyCardConfig.cardWidth,
    this.cardHeight = LuckyCardConfig.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final angle = flipProgress * pi;
    final isBack = angle > pi / 2;

    return Transform.scale(
      scale: scale,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(angle),
        child: isBack
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: _buildBack(),
              )
            : _buildFront(),
      ),
    );
  }

  Widget _buildFront() {
    return Stack(
      children: [
        // Thân thẻ
        Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: LuckyCardConfig.cardFrontGradient,
            ),
            border: Border.all(color: LuckyCardConfig.gold, width: 3),
            boxShadow: [
              BoxShadow(
                color: LuckyCardConfig.gold.withOpacity(glow * 0.6),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: CardPatternPainter(glow: glow)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            LuckyCardConfig.gold.withOpacity(glow * 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.question_mark,
                        size: 90,
                        color: LuckyCardConfig.gold,
                        shadows: [
                          Shadow(
                            color: LuckyCardConfig.goldDark,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MAY MẮN',
                      style: TextStyle(
                        color: LuckyCardConfig.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: LuckyCardConfig.goldDark,
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lớp flash overlay
        if (flashIntensity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: FlashOverlayPainter(
                  intensity: flashIntensity,
                  color: flashColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBack() {
    if (prize == null) return _buildFront();
    final color = prize!['color'] as Color;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + value * 0.2,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.6),
                    const Color(0xFF1A0533),
                  ],
                ),
                border: Border.all(color: LuckyCardConfig.gold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.8),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RayBurstPainter(color: color, progress: value),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: LuckyCardConfig.gold,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            prize!['icon'] as IconData,
                            size: 70,
                            color: LuckyCardConfig.gold,
                            shadows: const [
                              Shadow(
                                color: LuckyCardConfig.goldDark,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            prize!['name'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: LuckyCardConfig.gold,
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '🎉 CHÚC MỪNG 🎉',
                          style: TextStyle(
                            color: LuckyCardConfig.goldLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// ========================== PAGE ============================
// ============================================================
class LuckyCardPage extends StatefulWidget {
  const LuckyCardPage({super.key});

  @override
  State<LuckyCardPage> createState() => _LuckyCardPageState();
}

class _LuckyCardPageState extends State<LuckyCardPage>
    with TickerProviderStateMixin {
  // ==================== CẤU HÌNH PHẦN THƯỞNG ====================
  final List<Map<String, dynamic>> _prizes = [
    {
      'name': '100 Vàng',
      'icon': Icons.monetization_on,
      'color': const Color(0xFFFFC107),
      'weight': 30,
    },
    {
      'name': 'Skin VIP',
      'icon': Icons.diamond,
      'color': const Color(0xFFE91E63),
      'weight': 5,
    },
    {
      'name': 'Ngọc Quý',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFF9C27B0),
      'weight': 10,
    },
    {
      'name': 'Trang Bị',
      'icon': Icons.shield,
      'color': const Color(0xFF2196F3),
      'weight': 20,
    },
    {
      'name': '1000 Vàng',
      'icon': Icons.savings,
      'color': const Color(0xFFFF9800),
      'weight': 8,
    },
    {
      'name': 'Skin Hiếm',
      'icon': Icons.star,
      'color': const Color(0xFF00BCD4),
      'weight': 2,
    },
  ];

  // ==================== CONFIG CÓ THỂ OVERRIDE ====================
  /// Số lần nháy - CÓ THỂ CHỈNH TỪ NGOÀI
  int _flashCount = LuckyCardConfig.defaultFlashCount;

  /// Màu nháy - CÓ THỂ CHỈNH TỪ NGOÀI
  Color _flashColor = LuckyCardConfig.defaultFlashColor;

  // ==================== CONTROLLERS ====================
  late AnimationController _flipController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _sparkController;
  late AnimationController _flashController;

  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _flashIntensityAnimation;

  // ==================== STATE ====================
  bool _isSpinning = false;
  int? _resultIndex;
  final List<Spark> _sparks = [];

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: LuckyCardConfig.flipDurationMs),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: LuckyCardConfig.shakeDurationMs),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(_scaleController);

    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: LuckyCardConfig.glowDurationMs),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // -------- FLASH CONTROLLER --------
    // Mỗi chu kỳ flash = on (150ms) + off (120ms) = 270ms
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 270),
    );
    _flashIntensityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: LuckyCardConfig.flashOnDurationMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: LuckyCardConfig.flashOffDurationMs.toDouble(),
      ),
    ]).animate(_flashController);

    _sparkController =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: LuckyCardConfig.sparkDurationMs),
        )..addListener(() {
          setState(() {
            for (final s in _sparks) {
              final t = _sparkController.value;
              s.position += s._velocity * (1 - t) * 4;
              s.opacity = (1 - t).clamp(0.0, 1.0);
              s.radius = s.radius * (1 - t * 0.05);
            }
          });
        });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _sparkController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  // ==================== LOGIC ====================
  int _pickWeightedPrize() {
    final totalWeight = _prizes.fold<int>(
      0,
      (sum, p) => sum + (p['weight'] as int),
    );
    final random = Random();
    int roll = random.nextInt(totalWeight);
    for (int i = 0; i < _prizes.length; i++) {
      roll -= _prizes[i]['weight'] as int;
      if (roll < 0) return i;
    }
    return 0;
  }

  /// Chạy hiệu ứng nháy sáng `count` lần
  Future<void> _runFlashSequence(int count) async {
    for (int i = 0; i < count; i++) {
      // Bật sáng
      if (LuckyCardConfig.hapticOnFlash) {
        HapticFeedback.selectionClick();
      }
      await _flashController.forward(from: 0);
    }
  }

  Future<void> _drawCard() async {
    if (_isSpinning) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isSpinning = true;
      _resultIndex = null;
      _sparks.clear();
    });

    // Reset
    _flipController.value = 0;
    _flashController.value = 0;
    await Future.delayed(const Duration(milliseconds: 100));

    // 1. Rung lắc nhẹ
    for (int i = 0; i < 2; i++) {
      await _scaleController.forward();
      await _scaleController.reverse();
    }

    // 2. NHÁY SÁNG `_flashCount` LẦN (configurable)
    await _runFlashSequence(_flashCount);

    // 3. Chọn kết quả + lật thẻ
    final result = _pickWeightedPrize();
    await _flipController.forward();

    if (LuckyCardConfig.hapticOnFlip) {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _resultIndex = result;
      _isSpinning = false;
    });

    _burstSparks();
  }

  void _burstSparks() {
    final random = Random();
    final color = _prizes[_resultIndex!]['color'] as Color;

    _sparks.clear();
    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 2.0 + random.nextDouble() * 4.0;
      _sparks.add(
        Spark(
          position: Offset.zero,
          radius: 2 + random.nextDouble() * 4,
          opacity: 1.0,
          color: i % 3 == 0 ? LuckyCardConfig.gold : color,
        ).._velocity = Offset(cos(angle) * speed, sin(angle) * speed),
      );
    }
    _sparkController.forward(from: 0);
  }

  void _reset() {
    if (_isSpinning) return;
    setState(() {
      _resultIndex = null;
      _sparks.clear();
    });
    _flipController.value = 0;
    _flashController.value = 0;
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: LuckyCardConfig.pageBackground,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: isSmall ? 20 : 40),

              // Tiêu đề
              const Text(
                '✦ THẺ BÀI MAY MẮN ✦',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: LuckyCardConfig.goldLight,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(color: LuckyCardConfig.goldDark, blurRadius: 20),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 10 : 20),

              // Thẻ bài
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hào quang phía sau
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 280,
                            height: 380,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: LuckyCardConfig.gold.withOpacity(
                                    _glowAnimation.value * 0.25,
                                  ),
                                  blurRadius: 100,
                                  spreadRadius: 30,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Thẻ bài + hạt sáng
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _flipAnimation,
                              _scaleAnimation,
                              _glowAnimation,
                              _flashIntensityAnimation,
                            ]),
                            builder: (context, child) {
                              return LuckyCard(
                                flipProgress: _flipAnimation.value,
                                scale: _scaleAnimation.value,
                                glow: _glowAnimation.value,
                                flashIntensity: _flashIntensityAnimation.value,
                                flashColor: _flashColor,
                                prize: _resultIndex != null
                                    ? _prizes[_resultIndex!]
                                    : null,
                                cardWidth: isSmall
                                    ? LuckyCardConfig.cardWidthSmall
                                    : LuckyCardConfig.cardWidth,
                                cardHeight: isSmall
                                    ? LuckyCardConfig.cardHeightSmall
                                    : LuckyCardConfig.cardHeight,
                              );
                            },
                          ),

                          if (_sparks.isNotEmpty)
                            IgnorePointer(
                              child: SizedBox(
                                width: 500,
                                height: 500,
                                child: CustomPaint(
                                  painter: SparkPainter(sparks: _sparks),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Kết quả
              SizedBox(
                height: 60,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _resultIndex != null
                      ? _buildResultText()
                      : const SizedBox.shrink(),
                ),
              ),

              // Nút điều khiển
              Padding(
                padding: EdgeInsets.only(bottom: isSmall ? 20 : 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_resultIndex != null)
                      _buildButton(
                        'CHƠI LẠI',
                        Icons.refresh,
                        const Color(0xFF607D8B),
                        _reset,
                      ),
                    if (_resultIndex != null) const SizedBox(width: 16),
                    _buildButton(
                      _isSpinning ? '...' : 'RÚT THẺ',
                      Icons.casino,
                      const Color(0xFFC10000),
                      _isSpinning ? null : _drawCard,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultText() {
    if (_resultIndex == null) return const SizedBox.shrink();
    final prize = _prizes[_resultIndex!];
    return Container(
      key: ValueKey(_resultIndex),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            LuckyCardConfig.gold.withOpacity(0.2),
            const Color(0xFFFF9800).withOpacity(0.1),
          ],
        ),
        border: Border.all(color: LuckyCardConfig.gold.withOpacity(0.7)),
      ),
      child: Text(
        'Bạn nhận được: ${prize['name']}',
        style: const TextStyle(
          color: LuckyCardConfig.goldLight,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          shadows: [Shadow(color: LuckyCardConfig.goldDark, blurRadius: 10)],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: disabled
                ? [Colors.grey.shade700, Colors.grey.shade900]
                : [color.withOpacity(0.9), color.withOpacity(0.6)],
          ),
          border: Border.all(color: LuckyCardConfig.gold, width: 2),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension để thêm velocity vào Spark
extension on Spark {
  static final Expando<Offset> _velocities = Expando();

  Offset get _velocity => _velocities[this] ?? Offset.zero;
  set _velocity(Offset v) => _velocities[this] = v;
}
