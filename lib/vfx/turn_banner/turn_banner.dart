import 'package:flutter/material.dart';

/// Widget hiệu ứng **Turn Banner** — chữ "LƯỢT CỦA BẠN" / "ENEMY TURN"
/// trượt vào từ cạnh màn hình rồi biến mất.
///
/// ## Đặc điểm
///
/// - **Trượt vào** từ trái (player) hoặc phải (enemy) với hiệu ứng overshoot.
/// - **Dải màu hoàng gia**: đỏ imperial + vàng gold + navy (fix cứng).
/// - **Hiệu ứng phụ**: tia sáng quét ngang, viền vàng phát sáng, hạt lấp lánh.
/// - **Tự động ẩn** sau [holdDuration] bằng hiệu ứng trượt ra + mờ dần.
/// - **Callback** [onCompleted] khi toàn bộ animation kết thúc.
///
/// Widget phải nằm trong [Stack] (dùng [Positioned]).
///
/// ## Cách dùng
///
/// ```dart
/// Stack(
///   children: [
///     // ... game world
///     if (_showBanner)
///       TurnBanner(
///         text: 'LƯỢT CỦA BẠN',
///         side: TurnSide.player,
///         onCompleted: () => setState(() => _showBanner = false),
///       ),
///   ],
/// )
/// ```
///
/// ## Ví dụ: enemy turn
///
/// ```dart
/// TurnBanner(
///   text: 'ENEMY TURN',
///   side: TurnSide.enemy,
///   width: 320,
///   height: 90,
/// )
/// ```
///
/// ## Ví dụ: banner siêu to cho boss
///
/// ```dart
/// TurnBanner(
///   text: 'BOSS TURN',
///   side: TurnSide.enemy,
///   width: 400,
///   height: 120,
///   fontSize: 36,
///   holdDuration: Duration(milliseconds: 1200),
/// )
/// ```
///
/// ## Timeline animation (mặc định ~1.8s)
///
/// | Giai đoạn | Thời gian | Hành động |
/// |---|---|---|
/// | Trượt vào | 0 – 400ms | X + opacity + scale overshoot |
/// | Quét sáng | 300 – 700ms | Vệt sáng chạy ngang banner |
/// | Giữ | 400ms – (hold) | Banner đứng yên, viền pulse nhẹ |
/// | Trượt ra | cuối | Trượt ra cạnh đối diện + mờ dần |
class TurnBanner extends StatefulWidget {
  /// Nội dung chữ hiển thị
  final String text;

  /// Bên nào xuất hiện (player = trái, enemy = phải)
  final TurnSide side;

  /// Chiều rộng banner
  final double width;

  /// Chiều cao banner
  final double height;

  /// Cỡ chữ
  final double fontSize;

  /// Thời gian giữ banner ở giữa trước khi trượt ra
  final Duration holdDuration;

  /// Thời gian trượt vào
  final Duration slideInDuration;

  /// Thời gian trượt ra
  final Duration slideOutDuration;

  /// Gọi khi toàn bộ animation kết thúc
  final VoidCallback? onCompleted;

  /// Có hiện hiệu ứng tia sáng quét ngang không
  final bool showShine;

  /// Có hiện hạt lấp lánh không
  final bool showSparkles;

  const TurnBanner({
    super.key,
    required this.text,
    this.side = TurnSide.player,
    this.width = 280,
    this.height = 80,
    this.fontSize = 28,
    this.holdDuration = const Duration(milliseconds: 800),
    this.slideInDuration = const Duration(milliseconds: 400),
    this.slideOutDuration = const Duration(milliseconds: 350),
    this.onCompleted,
    this.showShine = true,
    this.showSparkles = true,
  });

  @override
  State<TurnBanner> createState() => _TurnBannerState();
}

/// Bên xuất hiện của banner.
enum TurnSide {
  /// Player — trượt từ trái, màu đỏ-vàng
  player,

  /// Enemy — trượt từ phải, màu đỏ-navy đậm
  enemy,
}

class _TurnBannerState extends State<TurnBanner>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shineController;
  late AnimationController _pulseController;

  late Animation<Offset> _slideAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    final totalMs = widget.slideInDuration.inMilliseconds +
        widget.holdDuration.inMilliseconds +
        widget.slideOutDuration.inMilliseconds;

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _setupAnimations();

    _slideController.forward().whenComplete(() {
      if (!mounted) return;
      widget.onCompleted?.call();
    });

    // Bắt đầu shine sau khi banner đã trượt vào ~70%
    Future.delayed(
      Duration(
        milliseconds: (widget.slideInDuration.inMilliseconds * 0.5).round(),
      ),
      () {
        if (mounted && widget.showShine) {
          _shineController.forward();
        }
      },
    );
  }

  void _setupAnimations() {
    final total = _slideController.duration!.inMilliseconds;
    final inEnd = widget.slideInDuration.inMilliseconds / total;
    final holdEnd =
        (widget.slideInDuration.inMilliseconds + widget.holdDuration.inMilliseconds) /
            total;

    // Trượt: từ ngoài màn hình → giữa → ra ngoài cạnh đối diện
    final isPlayer = widget.side == TurnSide.player;

    _slideAnim = TweenSequence<Offset>([
      // Trượt vào từ cạnh
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(isPlayer ? -1.5 : 1.5, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: inEnd * 100,
      ),
      // Giữ
      TweenSequenceItem(
        tween: ConstantTween(Offset.zero),
        weight: (holdEnd - inEnd) * 100,
      ),
      // Trượt ra cạnh đối diện
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: Offset(isPlayer ? 1.5 : -1.5, 0),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: (1 - holdEnd) * 100,
      ),
    ]).animate(_slideController);

    // Opacity: hiện nhanh → giữ → mờ cuối
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: inEnd * 50,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (holdEnd - inEnd) * 50 + inEnd * 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: (1 - holdEnd) * 100,
      ),
    ]).animate(_slideController);

    // Scale: hơi overshoot khi vào
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: inEnd * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 80,
      ),
    ]).animate(_slideController);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      top: screenSize.height * 0.35,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _slideController,
            _shineController,
            _pulseController,
          ]),
          builder: (context, _) {
            return Align(
              alignment: Alignment.center,
              child: FractionalTranslation(
                translation: _slideAnim.value,
                child: Opacity(
                  opacity: _opacityAnim.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: _BannerContent(
                      text: widget.text,
                      side: widget.side,
                      width: widget.width,
                      height: widget.height,
                      fontSize: widget.fontSize,
                      shineProgress: _shineController.value,
                      pulseValue: _pulseController.value,
                      showShine: widget.showShine,
                      showSparkles: widget.showSparkles,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final String text;
  final TurnSide side;
  final double width;
  final double height;
  final double fontSize;
  final double shineProgress;
  final double pulseValue;
  final bool showShine;
  final bool showSparkles;

  const _BannerContent({
    required this.text,
    required this.side,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.shineProgress,
    required this.pulseValue,
    required this.showShine,
    required this.showSparkles,
  });

  @override
  Widget build(BuildContext context) {
    // ===== Màu theo side (fix cứng tone hoàng gia) =====
    final isPlayer = side == TurnSide.player;

    // Màu chính
    const imperialRed = Color(0xFF8B0000);
    const imperialGold = Color(0xFFD4AF37);
    const royalNavy = Color(0xFF003366);
    const metallicGold = Color(0xFFFFD700);
    const crimson = Color(0xFFDC143C);
    const midnightBlue = Color(0xFF191970);

    // Player: đỏ → vàng. Enemy: navy → đỏ
    final gradientColors = isPlayer
        ? [imperialRed, crimson, imperialGold]
        : [midnightBlue, royalNavy, imperialRed];

    final borderColor = isPlayer ? imperialGold : crimson;
    final glowColor = isPlayer ? metallicGold : crimson;
    final textColor = metallicGold;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ===== Khung banner chính =====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5 + 0.3 * pulseValue),
                  blurRadius: 20 + 10 * pulseValue,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Viền trong mảnh (double border)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: borderColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // ===== Chữ =====
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 3,
                          height: 1.0,
                          shadows: [
                            // Outline đen
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                              offset: Offset(2, 2),
                            ),
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                              offset: Offset(-2, -2),
                            ),
                            // Glow vàng
                            Shadow(
                              color: glowColor.withOpacity(0.8),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: glowColor.withOpacity(0.6),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ===== Shine quét ngang =====
                if (showShine)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _ShineOverlay(progress: shineProgress),
                    ),
                  ),

                // ===== Sparkles =====
                if (showSparkles)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _SparklesLayer(
                        progress: pulseValue,
                        color: glowColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ===== Trang trí 2 đầu (tam giác nhọn) =====
          Positioned(
            left: -8,
            top: height / 2 - 8,
            child: _Diamond(size: 16, color: borderColor),
          ),
          Positioned(
            right: -8,
            top: height / 2 - 8,
            child: _Diamond(size: 16, color: borderColor),
          ),
        ],
      ),
    );
  }
}

/// Vệt sáng quét ngang banner.
class _ShineOverlay extends StatelessWidget {
  final double progress;

  const _ShineOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();

    return FractionallySizedBox(
      widthFactor: 0.4,
      alignment: Alignment(-2 + 4 * progress, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.6),
              Colors.white.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vài hạt lấp lánh nhỏ trong banner.
class _SparklesLayer extends StatelessWidget {
  final double progress;
  final Color color;

  const _SparklesLayer({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklesPainter(progress: progress, color: color),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklesPainter({required this.progress, required this.color});

  // Vị trí cố định (normalize 0..1) của các hạt
  static const List<Offset> _spots = [
    Offset(0.12, 0.3),
    Offset(0.28, 0.75),
    Offset(0.5, 0.2),
    Offset(0.65, 0.8),
    Offset(0.82, 0.35),
    Offset(0.9, 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _spots.length; i++) {
      // Phase lệch nhau để hạt nhấp nháy so le
      final phase = (progress + i * 0.15) % 1.0;
      final opacity = (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);

      final p = Offset(
        _spots[i].dx * size.width,
        _spots[i].dy * size.height,
      );

      // Glow
      canvas.drawCircle(
        p,
        3,
        Paint()
          ..color = color.withOpacity(opacity * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Core
      canvas.drawCircle(
        p,
        1.2,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) =>
      old.progress != progress || old.color != color;
}

/// Hình thoi nhỏ ở 2 đầu banner.
class _Diamond extends StatelessWidget {
  final double size;
  final Color color;

  const _Diamond({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398, // 45 độ
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Preset nhanh cho 2 phe.
class TurnBannerPresets {
  /// Banner lượt player — đỏ vàng
  static TurnBanner player({
    String text = 'LƯỢT CỦA BẠN',
    VoidCallback? onCompleted,
    double width = 300,
    double height = 80,
  }) =>
      TurnBanner(
        text: text,
        side: TurnSide.player,
        width: width,
        height: height,
        fontSize: 28,
        onCompleted: onCompleted,
      );

  /// Banner lượt enemy — navy đỏ
  static TurnBanner enemy({
    String text = 'ENEMY TURN',
    VoidCallback? onCompleted,
    double width = 300,
    double height = 80,
  }) =>
      TurnBanner(
        text: text,
        side: TurnSide.enemy,
        width: width,
        height: height,
        fontSize: 28,
        onCompleted: onCompleted,
      );

  /// Banner boss — to, đỏ đậm, giữ lâu
  static TurnBanner boss({
    String text = 'BOSS TURN',
    VoidCallback? onCompleted,
    double width = 400,
    double height = 120,
  }) =>
      TurnBanner(
        text: text,
        side: TurnSide.enemy,
        width: width,
        height: height,
        fontSize: 40,
        holdDuration: const Duration(milliseconds: 1200),
        onCompleted: onCompleted,
      );
}
