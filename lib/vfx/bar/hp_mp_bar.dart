import 'package:flutter/material.dart';

/// Widget hiển thị **thanh HP / MP** với animation mượt và hiệu ứng đặc biệt.
///
/// ## Tính năng
///
/// - **Tụt mượt**: khi [current] giảm, thanh chính tụt dần theo [animationDuration].
/// - **Ghost bar**: lớp trắng phía sau tụt **chậm hơn** — giúp thấy rõ lượng máu vừa mất.
/// - **Đổi màu theo mức**: xanh (>60%), vàng (30–60%), đỏ (<30%).
/// - **Low HP warning**: pulse nhấp nháy khi dưới [lowThreshold].
/// - **Label HP/MP**: hiển thị `current / max` nếu bật.
///
/// ## Cách dùng
///
/// ```dart
/// HpMpBar(
///   current: 750,
///   max: 1000,
///   type: BarType.hp,
///   width: 200,
///   height: 20,
///   showLabel: true,
/// )
/// ```
class HpMpBar extends StatefulWidget {
  final double current;
  final double max;
  final BarType type;
  final double width;
  final double height;
  final double borderRadius;
  final bool showLabel;
  final Color labelColor;
  final double lowThreshold;
  final Duration animationDuration;
  final Duration ghostDuration;
  final List<Color>? overrideGradientColors;

  const HpMpBar({
    super.key,
    required this.current,
    required this.max,
    this.type = BarType.hp,
    this.width = 200,
    this.height = 20,
    this.borderRadius = 6,
    this.showLabel = false,
    this.labelColor = Colors.white,
    this.lowThreshold = 0.25,
    this.animationDuration = const Duration(milliseconds: 350),
    this.ghostDuration = const Duration(milliseconds: 900),
    this.overrideGradientColors,
  });

  @override
  State<HpMpBar> createState() => _HpMpBarState();
}

enum BarType { hp, mp }

class _HpMpBarState extends State<HpMpBar>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _ghostController;
  late AnimationController _pulseController;

  late Tween<double> _mainTween;
  late Tween<double> _ghostTween;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _ghostController = AnimationController(
      vsync: this,
      duration: widget.ghostDuration,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final r = _ratio(widget.current, widget.max);
    _mainTween = Tween(begin: r, end: r);
    _ghostTween = Tween(begin: r, end: r);

    _mainController.addListener(_onTick);
    _ghostController.addListener(_onTick);
    _pulseController.addListener(_onTick);

    _updatePulse();
  }

  @override
  void didUpdateWidget(covariant HpMpBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldRatio = _ratio(oldWidget.current, oldWidget.max);
    final newRatio = _ratio(widget.current, widget.max);

    if (oldRatio == newRatio) return;

    if (newRatio > oldRatio) {
      // Tăng máu → nhảy ngay
      _mainController.stop();
      _ghostController.stop();
      _mainController.value = 1.0;
      _ghostController.value = 1.0;
      _mainTween = Tween(begin: newRatio, end: newRatio);
      _ghostTween = Tween(begin: newRatio, end: newRatio);
      setState(() {});
    } else {
      // Giảm máu → thanh chính tụt nhanh, ghost tụt chậm
      _mainTween = Tween(begin: _currentMainRatio(), end: newRatio);
      _ghostTween = Tween(begin: _currentGhostRatio(), end: newRatio);
      _mainController.forward(from: 0).then((_) {
        if (!mounted) return;
        _ghostController.forward(from: 0);
      });
    }

    _updatePulse();
  }

  double _ratio(double c, double m) {
    if (m <= 0) return 0;
    return (c / m).clamp(0.0, 1.0);
  }

  double _currentMainRatio() => _mainTween.evaluate(_mainController);
  double _currentGhostRatio() => _ghostTween.evaluate(_ghostController);

  void _onTick() {
    if (!mounted) return;
    setState(() {});
  }

  void _updatePulse() {
    if (!mounted) return;
    final ratio = _ratio(widget.current, widget.max);
    final shouldPulse = widget.type == BarType.hp && ratio < widget.lowThreshold;

    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _mainController.removeListener(_onTick);
    _ghostController.removeListener(_onTick);
    _pulseController.removeListener(_onTick);
    _mainController.dispose();
    _ghostController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainRatio = _currentMainRatio();
    final ghostRatio = _currentGhostRatio();
    final colors = _resolveColors(widget.current / widget.max);
    final isLow = widget.type == BarType.hp &&
        (widget.current / widget.max) < widget.lowThreshold;
    final pulse = _pulseController.value;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        // ==== Nền ngoài + viền ====
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Padding(
          // Padding để thanh không dính viền
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius - 2),
            child: Stack(
              // Stack có kích thước cố định từ cha → con không bị unbounded
              fit: StackFit.expand,
              children: [
                // ==== Ghost bar (lớp máu vừa mất) ====
                if (ghostRatio > mainRatio)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: ghostRatio,
                      heightFactor: 1.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.85),
                              Colors.white.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ==== Thanh chính ====
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: mainRatio,
                    heightFactor: 1.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: colors,
                        ),
                        boxShadow: isLow
                            ? [
                                BoxShadow(
                                  color: Colors.red
                                      .withOpacity(0.4 + 0.4 * pulse),
                                  blurRadius: 8 + 4 * pulse,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: _buildGloss(),
                    ),
                  ),
                ),

                // ==== Label ====
                if (widget.showLabel)
                  Center(
                    child: Text(
                      '${widget.current.toInt()} / ${widget.max.toInt()}',
                      style: TextStyle(
                        color: widget.labelColor,
                        fontSize: widget.height * 0.55,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGloss() {
    return Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
        heightFactor: 0.4,
        widthFactor: 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.35),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _resolveColors(double ratio) {
    if (widget.overrideGradientColors != null) {
      return widget.overrideGradientColors!;
    }
    switch (widget.type) {
      case BarType.hp:
        if (ratio > 0.6) {
          return const [Color(0xFF66BB6A), Color(0xFF2E7D32)];
        } else if (ratio > 0.3) {
          return const [Color(0xFFFFD54F), Color(0xFFF57F17)];
        } else {
          return const [Color(0xFFEF5350), Color(0xFFB71C1C)];
        }
      case BarType.mp:
        return const [Color(0xFF42A5F5), Color(0xFF0D47A1)];
    }
  }
}

/// Helper tạo nhanh HP bar / MP bar với preset.
class HpMpBarPresets {
  static HpMpBar playerHp({
    required double current,
    required double max,
    double width = 200,
    double height = 20,
    bool showLabel = true,
  }) =>
      HpMpBar(
        current: current,
        max: max,
        type: BarType.hp,
        width: width,
        height: height,
        showLabel: showLabel,
      );

  static HpMpBar enemyHp({
    required double current,
    required double max,
    double width = 200,
    double height = 18,
    bool showLabel = false,
  }) =>
      HpMpBar(
        current: current,
        max: max,
        type: BarType.hp,
        width: width,
        height: height,
        showLabel: showLabel,
        overrideGradientColors: const [
          Color(0xFFE53935),
          Color(0xFF8E0000),
        ],
      );

  static HpMpBar mp({
    required double current,
    required double max,
    double width = 200,
    double height = 16,
    bool showLabel = true,
  }) =>
      HpMpBar(
        current: current,
        max: max,
        type: BarType.mp,
        width: width,
        height: height,
        showLabel: showLabel,
      );

  static HpMpBar bossHp({
    required double current,
    required double max,
    double width = 320,
    double height = 28,
  }) =>
      HpMpBar(
        current: current,
        max: max,
        type: BarType.hp,
        width: width,
        height: height,
        showLabel: true,
        lowThreshold: 0.2,
        overrideGradientColors: const [
          Color(0xFFFF5252),
          Color(0xFF7F0000),
        ],
      );
}
