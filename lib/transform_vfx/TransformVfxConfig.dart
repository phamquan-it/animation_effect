import 'package:flutter/material.dart';

/// Loại hành động VFX áp lên widget.
enum VfxAction {
  /// Lộn ngang (quay quanh trục Y) — 360deg
  flipHorizontal,

  /// Lộn dọc (quay quanh trục X) — 360deg
  flipVertical,

  /// Xoay trong mặt phẳng (quay quanh trục Z) — 360deg
  rotate,

  /// Phóng to / thu nhỏ
  scale,

  /// Di chuyển tới offset
  translate,

  /// Mờ dần / hiện dần
  fade,
}

/// Cấu hình 1 hành động VFX.
class TransformVfxConfig {
  /// Loại hành động
  final VfxAction action;

  /// Thời điểm bắt đầu (ms) — tính từ lúc widget build
  final int startMs;

  /// Thời gian thực hiện 1 lần (ms)
  final int durationMs;

  /// Số lần thực hiện (âm = lặp vô hạn)
  final int repeat;

  /// Độ trễ giữa các lần lặp (ms)
  final int repeatDelayMs;

  /// Đảo chiều (chạy ngược lại sau khi xong 1 lần)
  final bool reverse;

  /// Curve easing
  final Curve curve;

  /// Tham số phụ thuộc action:
  /// - flipHorizontal/Vertical/rotate: số vòng (1.0 = 360deg)
  /// - scale: giá trị scale đích (1.0 = giữ nguyên)
  /// - translate: Offset đích
  /// - fade: opacity đích (0.0 - 1.0)
  final dynamic value;

  const TransformVfxConfig({
    required this.action,
    required this.startMs,
    required this.durationMs,
    this.repeat = 1,
    this.repeatDelayMs = 0,
    this.reverse = false,
    this.curve = Curves.linear,
    this.value,
  });

  // ===== Helpers tạo nhanh =====

  /// Lộn ngang `turns` vòng (1.0 = 360deg)
  factory TransformVfxConfig.flipH({
    int startMs = 0,
    int durationMs = 1000,
    double turns = 1.0,
    int repeat = 1,
    bool reverse = false,
    Curve curve = Curves.easeInOut,
  }) => TransformVfxConfig(
    action: VfxAction.flipHorizontal,
    startMs: startMs,
    durationMs: durationMs,
    repeat: repeat,
    reverse: reverse,
    curve: curve,
    value: turns,
  );

  /// Lộn dọc `turns` vòng
  factory TransformVfxConfig.flipV({
    int startMs = 0,
    int durationMs = 1000,
    double turns = 1.0,
    int repeat = 1,
    bool reverse = false,
    Curve curve = Curves.easeInOut,
  }) => TransformVfxConfig(
    action: VfxAction.flipVertical,
    startMs: startMs,
    durationMs: durationMs,
    repeat: repeat,
    reverse: reverse,
    curve: curve,
    value: turns,
  );

  /// Xoay `turns` vòng
  factory TransformVfxConfig.rotate({
    int startMs = 0,
    int durationMs = 1000,
    double turns = 1.0,
    int repeat = 1,
    bool reverse = false,
    Curve curve = Curves.linear,
  }) => TransformVfxConfig(
    action: VfxAction.rotate,
    startMs: startMs,
    durationMs: durationMs,
    repeat: repeat,
    reverse: reverse,
    curve: curve,
    value: turns,
  );

  factory TransformVfxConfig.scale({
    int startMs = 0,
    int durationMs = 500,
    double to = 1.2,
    int repeat = 1,
    bool reverse = true,
    Curve curve = Curves.easeInOut,
  }) => TransformVfxConfig(
    action: VfxAction.scale,
    startMs: startMs,
    durationMs: durationMs,
    repeat: repeat,
    reverse: reverse,
    curve: curve,
    value: to,
  );

  factory TransformVfxConfig.translate({
    int startMs = 0,
    int durationMs = 800,
    Offset to = Offset.zero,
    int repeat = 1,
    bool reverse = true,
    Curve curve = Curves.easeInOut,
  }) => TransformVfxConfig(
    action: VfxAction.translate,
    startMs: startMs,
    durationMs: durationMs,
    repeat: repeat,
    reverse: reverse,
    curve: curve,
    value: to,
  );

  factory TransformVfxConfig.fade({
    int startMs = 0,
    int durationMs = 500,
    double to = 1.0,
    int repeat = 1,
    bool reverse = false,
    Curve curve = Curves.easeInOut,
  }) => TransformVfxConfig(
    action: VfxAction.fade,
    startMs: startMs,
    durationMs: durationMs,
    repeat: repeat,
    reverse: reverse,
    curve: curve,
    value: to,
  );
}
