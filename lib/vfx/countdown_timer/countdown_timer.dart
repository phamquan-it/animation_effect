import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget hiệu ứng **Countdown Timer** — vòng tròn đếm ngược thời gian.
///
/// ## Đặc điểm
///
/// - **Vòng tròn progress** chạy ngược theo thời gian.
/// - **Đổi màu theo mức**: vàng (>50%) → cam (25-50%) → đỏ (<25%) → nhấp nháy (<10%).
/// - **Số giây** ở giữa, chuyển đỏ khi sắp hết.
/// - **Pulse + shake** khi gần hết giờ.
/// - **Auto callback** khi hết giờ.
/// - Tone màu hoàng gia: đỏ imperial + vàng gold + cam (fix cứng).
///
/// Widget tự quản lý timer — không cần controller bên ngoài.
///
/// ## Cách dùng
///
/// ```dart
/// CountdownTimer(
///   duration: Duration(seconds: 10),
///   onCompleted: () {
///     // Hết giờ → auto chọn chiêu / mất lượt
///   },
/// )
/// ```
///
/// ## Ví dụ: timer nhỏ gọn không chữ
///
/// ```dart
/// CountdownTimer(
///   duration: Duration(seconds: 15),
///   size: 50,
///   showText: false,
/// )
/// ```
///
/// ## Ví dụ: timer to có label "CHỌN CHIÊU"
///
/// ```dart
/// CountdownTimer(
///   duration: Duration(seconds: 20),
///   size: 100,
///   label: 'CHỌN CHIÊU',
///   onCompleted: _autoSelect,
/// )
/// ```
///
/// ## Timeline đổi màu
///
/// | Mức thời gian | Màu | Hiệu ứng |
/// |---|---|---|
/// | > 50% | Vàng gold | Bình thường |
/// | 25-50% | Cam | Pulse nhẹ |
/// | 10-25% | Đỏ | Pulse mạnh |
/// | < 10% | Đỏ đậm | Nhấp nháy + shake |
class CountdownTimer extends StatefulWidget {
  /// Tổng thời gian đếm ngược
  final Duration duration;

  /// Đường kính widget
  final double size;

  /// Độ dày vòng tròn
  final double strokeWidth;

  /// Hiện số giây ở giữa
  final bool showText;

  /// Label phía dưới (VD: "CHỌN CHIÊU")
  final String? label;

  /// Gọi khi hết giờ
  final VoidCallback? onCompleted;

  /// Gọi mỗi giây (giây còn lại)
  final ValueChanged<int>? onTick;

  /// Có tạm dừng không (dùng khi mở menu, dialog...)
  final bool paused;

  const CountdownTimer({
    super.key,
    required this.duration,
    this.size = 80,
    this.strokeWidth = 6,
    this.showText = true,
    this.label,
    this.onCompleted,
    this.onTick,
    this.paused = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;

  int _lastReportedSecond = -1;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressController.addListener(_onProgress);
    _progressController.addStatusListener(_onStatus);

    _start();
  }

  void _start() {
    if (widget.paused) return;
    _progressController.forward(from: 0);
  }

  void _onProgress() {
    if (!mounted) return;

    final remainingMs = ((1 - _progressController.value) *
            widget.duration.inMilliseconds)
        .round();
    final remainingSec = (remainingMs / 1000).ceil();

    if (remainingSec != _lastReportedSecond) {
      _lastReportedSecond = remainingSec;
      widget.onTick?.call(remainingSec);
    }

    final ratio = 1 - _progressController.value;

    // Pulse khi dưới 25%
    if (ratio < 0.25 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (ratio >= 0.25 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }

    // Shake khi dưới 10%
    if (ratio < 0.1 && !_shakeController.isAnimating) {
      _shakeController.repeat();
    } else if (ratio >= 0.1 && _shakeController.isAnimating) {
      _shakeController.stop();
      _shakeController.value = 0;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
    }
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Xử lý pause/resume
    if (widget.paused != oldWidget.paused) {
      if (widget.paused) {
        _progressController.stop();
      } else {
        final remaining = Duration(
          milliseconds: ((1 - _progressController.value) *
                  widget.duration.inMilliseconds)
              .round(),
        );
        _progressController.duration = remaining;
        _progressController.forward();
      }
    }

    // Reset khi duration đổi
    if (widget.duration != oldWidget.duration) {
      _progressController.stop();
      _progressController.duration = widget.duration;
      _progressController.forward(from: 0);
      _lastReportedSecond = -1;
    }
  }

  @override
  void dispose() {
    _progressController.removeListener(_onProgress);
    _progressController.removeStatusListener(_onStatus);
    _progressController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  double _remainingRatio() => 1 - _progressController.value;

  int _remainingSeconds() {
    final ms = (_remainingRatio() * widget.duration.inMilliseconds).round();
    return (ms / 1000).ceil().clamp(0, 999);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _progressController,
            _pulseController,
            _shakeController,
          ]),
          builder: (context, _) {
            final ratio = _remainingRatio();
            final color = _resolveColor(ratio);
            final pulse = _pulseController.value;
            final shake = _shakeController.value;

            // Shake offset khi < 10%
            final shakeDx = ratio < 0.1 ? math.sin(shake * math.pi * 6) * 2 : 0.0;

            return Transform.translate(
              offset: Offset(shakeDx, 0),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow phía sau
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(
                              0.4 + 0.4 * pulse + 0.2 * (1 - ratio),
                            ),
                            blurRadius: 15 + 15 * pulse,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // Vòng tròn progress
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _TimerRingPainter(
                        progress: 1 - ratio, // 0 → 1
                        color: color,
                        strokeWidth: widget.strokeWidth,
                      ),
                    ),

                    // Số giây
                    if (widget.showText)
                      Text(
                        '${_remainingSeconds()}',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: widget.size * 0.4,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                            Shadow(
                              color: color.withOpacity(0.8),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Label
        if (widget.label != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
              letterSpacing: 2,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 2),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Màu theo mức thời gian còn lại (fix cứng tone hoàng gia).
  Color _resolveColor(double ratio) {
    if (ratio > 0.5) {
      // Vàng gold
      return const Color(0xFFD4AF37);
    } else if (ratio > 0.25) {
      // Cam
      return const Color(0xFFFF8C00);
    } else if (ratio > 0.1) {
      // Đỏ thẫm
      return const Color(0xFFDC143C);
    } else {
      // Đỏ đậm
      return const Color(0xFF8B0000);
    }
  }
}

/// Vẽ vòng tròn progress đếm ngược.
class _TimerRingPainter extends CustomPainter {
  final double progress; // 0 → 1 (đã trôi qua bao nhiêu)
  final Color color;
  final double strokeWidth;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // ==== Nền vòng tròn (mờ) ====
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withOpacity(0.5);
    canvas.drawCircle(center, radius, bgPaint);

    // ==== Vòng viền vàng mảnh ====
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFD4AF37).withOpacity(0.3);
    canvas.drawCircle(center, radius + strokeWidth / 2 + 1, borderPaint);

    // ==== Vòng progress chính ====
    // Bắt đầu từ đỉnh (12h) đi theo chiều kim đồng hồ
    final startAngle = -math.pi / 2;
    final sweepAngle = -2 * math.pi * progress; // âm = ngược chiều kim đồng hồ

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          color.withOpacity(0.6),
          color,
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // ==== Glow ở đầu vòng progress ====
    final endAngle = startAngle + sweepAngle;
    final tip = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    canvas.drawCircle(
      tip,
      strokeWidth * 1.2,
      Paint()
        ..color = color.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawCircle(
      tip,
      strokeWidth * 0.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

/// Preset nhanh.
class CountdownTimerPresets {
  /// Timer chuẩn cho lượt đánh — 15s
  static CountdownTimer turn({
    Duration duration = const Duration(seconds: 15),
    VoidCallback? onCompleted,
  }) =>
      CountdownTimer(
        duration: duration,
        size: 80,
        onCompleted: onCompleted,
      );

  /// Timer nhỏ gọn không chữ
  static CountdownTimer compact({
    Duration duration = const Duration(seconds: 10),
    VoidCallback? onCompleted,
  }) =>
      CountdownTimer(
        duration: duration,
        size: 50,
        showText: true,
        strokeWidth: 4,
        onCompleted: onCompleted,
      );

  /// Timer to có label
  static CountdownTimer withLabel({
    Duration duration = const Duration(seconds: 20),
    String label = 'CHỌN CHIÊU',
    VoidCallback? onCompleted,
  }) =>
      CountdownTimer(
        duration: duration,
        size: 110,
        strokeWidth: 8,
        label: label,
        onCompleted: onCompleted,
      );

  /// Timer boss / skill đặc biệt — 30s
  static CountdownTimer boss({
    VoidCallback? onCompleted,
  }) =>
      CountdownTimer(
        duration: const Duration(seconds: 30),
        size: 130,
        strokeWidth: 10,
        label: 'THỜI GIAN',
        onCompleted: onCompleted,
      );
}
