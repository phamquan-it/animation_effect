import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'TransformVfxConfig.dart';

class TransformVfx extends StatefulWidget {
  /// Widget con cần áp VFX
  final Widget child;

  /// Danh sách hành động
  final List<TransformVfxConfig> configs;

  /// Tổng thời gian chạy — nếu null thì tự tính từ configs
  final Duration? totalDuration;

  /// Lặp lại toàn bộ array khi xong
  final bool loop;

  /// Gọi khi xong toàn bộ (chỉ gọi khi loop = false)
  final VoidCallback? onCompleted;

  /// Tâm biến đổi (mặc định giữa)
  final Alignment alignment;

  const TransformVfx({
    super.key,
    required this.child,
    required this.configs,
    this.totalDuration,
    this.loop = false,
    this.onCompleted,
    this.alignment = Alignment.center,
  });

  @override
  State<TransformVfx> createState() => _TransformVfxState();
}

class _TransformVfxState extends State<TransformVfx>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _totalMs;

  @override
  void initState() {
    super.initState();
    _totalMs = _computeTotalMs();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );

    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward().whenComplete(() {
        widget.onCompleted?.call();
      });
    }
  }

  int _computeTotalMs() {
    if (widget.totalDuration != null) {
      return widget.totalDuration!.inMilliseconds;
    }
    int maxEnd = 0;
    for (final c in widget.configs) {
      // Thời gian kết thúc của config (bao gồm cả repeat)
      final repeatCount = c.repeat < 0 ? 1 : c.repeat;
      final cycle = c.durationMs + c.repeatDelayMs;
      final cfgEnd = c.startMs + cycle * repeatCount - c.repeatDelayMs;
      if (cfgEnd > maxEnd) maxEnd = cfgEnd;
    }
    return maxEnd == 0 ? 1000 : maxEnd;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tính giá trị hiện tại của 1 config tại thời điểm `t` (ms)
  /// Trả về giá trị 0..1 (progress đã áp curve)
  double? _progressOf(TransformVfxConfig c, double t) {
    if (t < c.startMs) return null;

    final localT = t - c.startMs;
    final cycle = c.durationMs + c.repeatDelayMs;
    if (cycle <= 0) return null;

    final repeatCount = c.repeat < 0 ? double.infinity : c.repeat.toDouble();

    // Lần lặp hiện tại
    final iteration = (localT / cycle).floor();

    if (iteration >= repeatCount) {
      // Đã xong hết — giữ giá trị cuối
      final endVal = c.reverse && c.repeat % 2 == 0 ? 0.0 : 1.0;
      return c.curve.transform(endVal.clamp(0.0, 1.0));
    }

    // Trong khoảng delay của lần lặp — giữ giá trị cuối iteration trước
    final inCycle = localT - iteration * cycle;
    if (inCycle > c.durationMs) {
      // Đang trong delay → giữ giá trị cuối lần lặp
      final endIter = c.reverse ? (iteration.isEven ? 1.0 : 0.0) : 1.0;
      return c.curve.transform(endIter);
    }

    // Đang trong thời gian chạy
    double p = inCycle / c.durationMs;
    if (c.reverse && iteration.isOdd) {
      p = 1.0 - p;
    }
    return c.curve.transform(p.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * _totalMs;

        // Cộng dồn các phép biến đổi
        double flipH = 0; // radian quanh Y
        double flipV = 0; // radian quanh X
        double rotateZ = 0; // radian quanh Z
        double scale = 1.0;
        Offset translate = Offset.zero;
        double opacity = 1.0;

        for (final c in widget.configs) {
          final p = _progressOf(c, t);
          if (p == null) continue;

          switch (c.action) {
            case VfxAction.flipHorizontal:
              final turns = (c.value as double?) ?? 1.0;
              flipH += p * turns * 2 * math.pi;
              break;
            case VfxAction.flipVertical:
              final turns = (c.value as double?) ?? 1.0;
              flipV += p * turns * 2 * math.pi;
              break;
            case VfxAction.rotate:
              final turns = (c.value as double?) ?? 1.0;
              rotateZ += p * turns * 2 * math.pi;
              break;
            case VfxAction.scale:
              final to = (c.value as double?) ?? 1.0;
              // p từ 0..1, scale từ 1..to
              scale *= 1.0 + (to - 1.0) * p;
              break;
            case VfxAction.translate:
              final to = (c.value as Offset?) ?? Offset.zero;
              translate += to * p;
              break;
            case VfxAction.fade:
              final to = (c.value as double?) ?? 1.0;
              opacity *= 1.0 + (to - 1.0) * p;
              break;
          }
        }

        // ===== Áp dụng ma trận biến đổi =====
        // Kết hợp flipX, flipY (3D) + rotate Z (2D)
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective nhẹ cho 3D
          ..rotateX(flipV)
          ..rotateY(flipH)
          ..rotateZ(rotateZ);

        Widget result = widget.child;

        // Translate
        if (translate != Offset.zero) {
          result = Transform.translate(offset: translate, child: result);
        }

        // 3D flip + rotate + scale qua Matrix4
        result = Transform(
          alignment: widget.alignment,
          transform: matrix,
          child: result,
        );

        // Scale (dùng scale riêng để không xung đột với matrix 3D)
        if (scale != 1.0) {
          result = Transform.scale(
            scale: scale,
            alignment: widget.alignment,
            child: result,
          );
        }

        // Opacity
        if (opacity < 1.0) {
          result = Opacity(opacity: opacity.clamp(0.0, 1.0), child: result);
        }

        return result;
      },
    );
  }
}
