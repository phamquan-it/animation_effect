import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'painters/bouncing_arrow_painter.dart';
import 'painters/glow_aura_painter.dart';
import 'painters/pulse_ring_painter.dart';
import 'painters/rotating_ring_painter.dart';
import 'painters/spotlight_painter.dart';
import 'turn_indicator_config.dart';
import 'turn_indicator_style.dart';

/// Widget hiển thị **turn indicator** — dấu hiệu cho biết ai đang tới lượt.
///
/// Hỗ trợ 5 kiểu trong [TurnIndicatorStyle]:
/// - [TurnIndicatorStyle.bouncingArrow] — mũi tên nhấp nhô
/// - [TurnIndicatorStyle.rotatingRing] — vòng xoay dưới chân
/// - [TurnIndicatorStyle.pulseRing] — vòng pulse lan ra
/// - [TurnIndicatorStyle.glowAura] — hào quang quanh nhân vật
/// - [TurnIndicatorStyle.spotlight] — cột sáng từ trên
///
/// Widget phải nằm trong [Stack] (dùng [Positioned]).
class TurnIndicator extends StatefulWidget {
  final TurnIndicatorConfig config;
  final VoidCallback? onCycleCompleted;

  const TurnIndicator({
    super.key,
    required this.config,
    this.onCycleCompleted,
  });

  @override
  State<TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<TurnIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    if (widget.config.loop) {
      _controller.repeat(reverse: widget.config.reverse);
    } else {
      _controller.forward().whenComplete(() {
        widget.onCycleCompleted?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TurnIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.duration != widget.config.duration) {
      _controller.duration = widget.config.duration;
      if (widget.config.loop) {
        _controller.repeat(reverse: widget.config.reverse);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;

    return Positioned(
      left: cfg.anchor.dx - cfg.size / 2,
      top: cfg.anchor.dy - cfg.size / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: cfg.opacity.clamp(0.0, 1.0),
          child: SizedBox(
            width: cfg.size * 2,
            height: cfg.size * 2,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return CustomPaint(
                  size: Size(cfg.size * 2, cfg.size * 2),
                  painter: _painterFor(cfg, t),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  CustomPainter _painterFor(TurnIndicatorConfig cfg, double t) {
    switch (cfg.style) {
      case TurnIndicatorStyle.bouncingArrow:
        return BouncingArrowPainter(
          progress: t,
          color: cfg.color,
          secondaryColor: cfg.secondaryColor,
        );
      case TurnIndicatorStyle.rotatingRing:
        return RotatingRingPainter(
          progress: t,
          color: cfg.color,
          secondaryColor: cfg.secondaryColor,
        );
      case TurnIndicatorStyle.pulseRing:
        return PulseRingPainter(
          progress: t,
          color: cfg.color,
          secondaryColor: cfg.secondaryColor,
        );
      case TurnIndicatorStyle.glowAura:
        return GlowAuraPainter(
          progress: t,
          color: cfg.color,
          secondaryColor: cfg.secondaryColor,
        );
      case TurnIndicatorStyle.spotlight:
        return SpotlightPainter(
          progress: t,
          color: cfg.color,
          secondaryColor: cfg.secondaryColor,
        );
    }
  }
}

/// Helper tạo nhanh indicator với style cụ thể.
class TurnIndicatorPresets {
  static TurnIndicator playerBouncingArrow({
    required Offset anchor,
    double size = 48,
  }) =>
      TurnIndicator(
        config: TurnIndicatorConfig(
          style: TurnIndicatorStyle.bouncingArrow,
          anchor: anchor,
          color: const Color(0xFFFFD54F),
          size: size,
        ),
      );

  static TurnIndicator enemyBouncingArrow({
    required Offset anchor,
    double size = 48,
  }) =>
      TurnIndicator(
        config: TurnIndicatorConfig(
          style: TurnIndicatorStyle.bouncingArrow,
          anchor: anchor,
          color: const Color(0xFFFF1744),
          size: size,
        ),
      );

  static TurnIndicator playerRotatingRing({
    required Offset anchor,
    double size = 60,
  }) =>
      TurnIndicator(
        config: TurnIndicatorConfig(
          style: TurnIndicatorStyle.rotatingRing,
          anchor: anchor,
          color: const Color(0xFF4FC3F7),
          size: size,
          reverse: false,
          duration: const Duration(milliseconds: 2000),
        ),
      );

  static TurnIndicator bossPulseRing({
    required Offset anchor,
    double size = 80,
  }) =>
      TurnIndicator(
        config: TurnIndicatorConfig(
          style: TurnIndicatorStyle.pulseRing,
          anchor: anchor,
          color: const Color(0xFFFF1744),
          secondaryColor: const Color(0xFFFFD54F),
          size: size,
          duration: const Duration(milliseconds: 1200),
          reverse: false,
        ),
      );

  static TurnIndicator allyGlowAura({
    required Offset anchor,
    double size = 90,
  }) =>
      TurnIndicator(
        config: TurnIndicatorConfig(
          style: TurnIndicatorStyle.glowAura,
          anchor: anchor,
          color: const Color(0xFF80DEEA),
          size: size,
          duration: const Duration(milliseconds: 1000),
        ),
      );

  static TurnIndicator bossSpotlight({
    required Offset anchor,
    double size = 120,
  }) =>
      TurnIndicator(
        config: TurnIndicatorConfig(
          style: TurnIndicatorStyle.spotlight,
          anchor: anchor,
          color: const Color(0xFFFFD54F),
          secondaryColor: const Color(0xFFFF6F00),
          size: size,
          reverse: false,
          duration: const Duration(milliseconds: 1500),
        ),
      );
}

/// Tiện ích toán học cho turn indicator.
class TurnIndicatorMath {
  static double bounce(double t, double amplitude) =>
      math.sin(t * math.pi) * amplitude;

  static double pulseScale(double t, {double min = 0.8, double max = 1.2}) =>
      min + (max - min) * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
}
