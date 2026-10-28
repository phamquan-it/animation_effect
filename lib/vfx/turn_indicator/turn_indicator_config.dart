import 'package:flutter/material.dart';

import 'turn_indicator_style.dart';

/// Cấu hình cho [TurnIndicator].
class TurnIndicatorConfig {
  /// Kiểu hiển thị
  final TurnIndicatorStyle style;

  /// Vị trí neo (toạ độ trong parent Stack)
  final Offset anchor;

  /// Màu chính
  final Color color;

  /// Màu phụ (dùng cho gradient / glow)
  final Color? secondaryColor;

  /// Kích thước tổng thể
  final double size;

  /// Thời gian 1 chu kỳ animation
  final Duration duration;

  /// Có chạy ngược (ping-pong) không
  final bool reverse;

  /// Có lặp vô hạn không (thường true khi chờ người chơi)
  final bool loop;

  /// Độ mờ tổng thể
  final double opacity;

  const TurnIndicatorConfig({
    required this.style,
    required this.anchor,
    this.color = const Color(0xFFFFD54F),
    this.secondaryColor,
    this.size = 48,
    this.duration = const Duration(milliseconds: 900),
    this.reverse = true,
    this.loop = true,
    this.opacity = 1.0,
  });

  /// Copy với 1 vài tham số thay đổi.
  TurnIndicatorConfig copyWith({
    TurnIndicatorStyle? style,
    Offset? anchor,
    Color? color,
    Color? secondaryColor,
    double? size,
    Duration? duration,
    bool? reverse,
    bool? loop,
    double? opacity,
  }) {
    return TurnIndicatorConfig(
      style: style ?? this.style,
      anchor: anchor ?? this.anchor,
      color: color ?? this.color,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      reverse: reverse ?? this.reverse,
      loop: loop ?? this.loop,
      opacity: opacity ?? this.opacity,
    );
  }
}
