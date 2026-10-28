import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget hiệu ứng **Turn Transition** — chuyển lượt giữa player và enemy.
///
/// ## Đặc điểm
///
/// - **Quét ngang** (wipe) từ trái hoặc phải với gradient đỏ-vàng-navy.
/// - **Chữ "LƯỢT MỚI"** hiện ở giữa với scale overshoot.
/// - **Tia sáng quét chéo** trên dải transition.
/// - **Đường kẻ vàng** phát sáng chạy xuyên màn hình.
/// - **Fade out** ở cuối để lộ lượt mới.
/// - Tone màu hoàng gia (đỏ + vàng + navy) fix cứng.
///
/// Widget tự chạy animation 1 lần rồi gọi [onCompleted].
///
/// Widget phải nằm trong [Stack].
///
/// ## Cách dùng
///
/// ```dart
/// Stack(
///   children: [
///     // ... game world
///     if (_transitioning)
///       TurnTransition(
///         toSide: TurnSide.player,
///         onCompleted: () {
///           setState(() => _transitioning = false);
///         },
///       ),
///   ],
/// )
/// ```
///
/// ## Ví dụ: chuyển lượt enemy với label
///
/// ```dart
/// TurnTransition(
///   toSide: TurnSide.enemy,
///   label: 'LƯỢT ĐỊCH',
///   onCompleted: _onTransitionDone,
/// )
/// ```
///
/// ## Timeline (mặc định ~1.4s)
///
/// | Giai đoạn | Thời gian | Hành động |
/// |---|---|---|
/// | Wipe vào | 0 – 400ms | Dải màu quét ngang màn hình |
/// | Chữ pop | 300 – 700ms | Scale + fade chữ ở giữa |
/// | Giữ | 700 – 900ms | Dải đứng yên |
/// | Wipe ra | 900 – 1400ms | Dải quét tiếp ra cạnh đối diện |
class TurnTransition extends StatefulWidget {
  /// Bên tới lượt (dùng để chọn hướng quét + màu)
  final TurnSide toSide;

  /// Nội dung chữ hiển thị (mặc định theo [toSide])
  final String? label;

  /// Gọi khi transition kết thúc
  final VoidCallback? onCompleted;

  /// Có hiện chữ ở giữa không
  final bool showLabel;

  /// Có hiện đường kẻ vàng quét ngang không
  final bool showScanLine;

  const TurnTransition({
    super.key,
    required this.toSide,
    this.label,
    this.onCompleted,
    this.showLabel = true,
    this.showScanLine = true,
  });

  @override
  State<TurnTransition> createState() => _TurnTransitionState();
}

/// Phe nào đang tới lượt.
enum TurnSide {
  /// Player — quét từ trái, gradient đỏ-vàng
  player,

  /// Enemy — quét từ phải, gradient navy-đỏ
  enemy,
}

class _TurnTransitionState extends State<TurnTransition>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _scanController;

  late Animation<double> _wipeProgress;
  late Animation<double> _labelOpacity;
  late Animation<double> _labelScale;
  late Animation<double> _scanProgress;
  late Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _setupAnimations();

    _mainController.forward().whenComplete(() {
      if (!mounted) return;
      widget.onCompleted?.call();
    });

    // Scan line chạy 2 lần
    _scanController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _scanController.forward(from: 0);
    });
  }

  void _setupAnimations() {
    // ==== Wipe: 0 → 1 (phủ màn hình) → 1 (giữ) → 2 (rời màn hình) ====
    // Ta dùng 1 giá trị liên tục 0..1, nhưng chia interval:
    //   0.0 → 0.3 : wipe vào (0 → 1 coverage)
    //   0.3 → 0.65: giữ (coverage = 1)
    //   0.65 → 1.0: wipe ra (coverage 1 → 0, dịch chuyển)
    _wipeProgress = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 2.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 35,
      ),
    ]).animate(_mainController);

    // ==== Label: hiện sau khi wipe xong ~1/2, mờ dần khi bắt đầu wipe ra ====
    _labelOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_mainController);

    // ==== Label scale: overshoot ====
    _labelScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    ]).animate(_mainController);

    // ==== Scan line: chạy liên tục, không theo mainController ====
    _scanProgress = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    // ==== Flash trắng: chớp nhẹ khi wipe phủ đầy ====
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 55),
    ]).animate(_mainController);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _mainController,
            _scanController,
          ]),
          builder: (context, _) {
            return Stack(
              children: [
                // ==== Dải wipe chính ====
                _buildWipe(screenSize),

                // ==== Flash trắng ====
                _buildFlash(),

                // ==== Scan line ====
                if (widget.showScanLine) _buildScanLine(screenSize),

                // ==== Chữ ====
                if (widget.showLabel) _buildLabel(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWipe(Size size) {
    final t = _wipeProgress.value; // 0 → 2

    // Vị trí dải: -1.5 → 0.5 → 2.5 (theo trục X)
    // t = 0: dải ngoài trái (-1.5)
    // t = 1: dải phủ đầy (0.5 = giữa)
    // t = 2: dải ngoài phải (2.5)
    final isPlayer = widget.toSide == TurnSide.player;
    final pos = isPlayer ? (-1.5 + t * 2.0) : (2.5 - t * 2.0);

    final gradientColors = isPlayer
        ? [
            const Color(0xFF8B0000), // đỏ imperial
            const Color(0xFFD4AF37), // vàng gold
            const Color(0xFF8B0000),
          ]
        : [
            const Color(0xFF003366), // navy
            const Color(0xFFDC143C), // crimson
            const Color(0xFF003366),
          ];

    return Positioned.fill(
      child: FractionallySizedBox(
        widthFactor: 1.4, // dải rộng hơn màn hình để phủ kín
        alignment: Alignment(pos, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: (isPlayer
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFDC143C))
                    .withOpacity(0.8),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _buildInnerDecoration(isPlayer),
        ),
      ),
    );
  }

  Widget _buildInnerDecoration(bool isPlayer) {
    // Viền vàng 2 đầu + kẻ dọc
    final borderColor =
        isPlayer ? const Color(0xFFFFD700) : const Color(0xFFDC143C);

    return Stack(
      children: [
        // Viền trên
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(height: 3, color: borderColor),
        ),
        // Viền dưới
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(height: 3, color: borderColor),
        ),
        // Kẻ dọc giữa (trang trí)
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 2,
            color: borderColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFlash() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.white.withOpacity(_flashOpacity.value.clamp(0.0, 1.0)),
        ),
      ),
    );
  }

  Widget _buildScanLine(Size size) {
    final t = _scanProgress.value; // -1 → 2
    final x = t * size.width;
    final isPlayer = widget.toSide == TurnSide.player;
    final color =
        isPlayer ? const Color(0xFFFFD700) : const Color(0xFFDC143C);

    return Positioned(
      left: x,
      top: 0,
      bottom: 0,
      child: Container(
        width: 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.0),
              color,
              Colors.white,
              color,
              color.withOpacity(0.0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel() {
    final label = widget.label ??
        (widget.toSide == TurnSide.player ? 'LƯỢT CỦA BẠN' : 'LƯỢT ĐỊCH');

    return Center(
      child: Opacity(
        opacity: _labelOpacity.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: _labelScale.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD700),
                letterSpacing: 4,
                height: 1.0,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
                  Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-2, -2)),
                  Shadow(color: Color(0xFFFFD700), blurRadius: 16),
                  Shadow(color: Color(0xFFFFD700), blurRadius: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Preset nhanh.
class TurnTransitionPresets {
  /// Chuyển lượt player
  static TurnTransition player({
    String? label,
    VoidCallback? onCompleted,
  }) =>
      TurnTransition(
        toSide: TurnSide.player,
        label: label,
        onCompleted: onCompleted,
      );

  /// Chuyển lượt enemy
  static TurnTransition enemy({
    String? label,
    VoidCallback? onCompleted,
  }) =>
      TurnTransition(
        toSide: TurnSide.enemy,
        label: label,
        onCompleted: onCompleted,
      );

  /// Transition tối giản — không chữ, không scan
  static TurnTransition minimal({
    TurnSide side = TurnSide.player,
    VoidCallback? onCompleted,
  }) =>
      TurnTransition(
        toSide: side,
        showLabel: false,
        showScanLine: false,
        onCompleted: onCompleted,
      );
}
