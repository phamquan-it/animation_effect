import 'package:animation_effect/sunburst_painter/SunburstPainter.dart';
import 'package:flutter/material.dart';

/// Cách hào quang bung theo parent.
enum SunburstFitBy {
  /// Theo chiều rộng parent
  parentWidth,

  /// Theo chiều cao parent
  parentHeight,

  /// Theo đường chéo (bao phủ cả 2 chiều, kể cả khi xoay) — mặc định
  diagonal,
}

/// Widget hiệu ứng **hào quang tỏa tia (sunburst / radial burst)** quay đều liên tục.
///
/// Các tia đậm ở tâm và **mờ dần về phía đầu mút**, phù hợp cho hiệu ứng mở quà,
/// nổ item, boss appear, v.v.
///
/// Widget tự quản lý animation xoay — không cần tạo [AnimationController] bên ngoài.
///
/// ## Cách dùng cơ bản
///
/// ```dart
/// Stack(
///   alignment: Alignment.center,
///   children: [
///     const SunburstAura(
///       numberOfRays: 20,
///       rayColor: Color(0xFFFFD54F),
///       isFullByScreen: true,
///       fitBy: SunburstFitBy.parentHeight,
///       innerRadiusRatio: 0.1,
///       fadeStartRatio: 0.3,
///       rotationDuration: Duration(seconds: 10),
///     ),
///     Container(width: 90, height: 90, color: Colors.orange),
///   ],
/// )
/// ```
///
/// ## Ví dụ: hào quang nhỏ ở giữa
///
/// ```dart
/// const SunburstAura(
///   numberOfRays: 12,
///   rayColor: Color(0xFF8BC34A),
///   size: 200,
///   rotationDuration: Duration(seconds: 4),
/// )
/// ```
///
/// ## Ví dụ: full màn hình phủ kín khi xoay (mặc định)
///
/// ```dart
/// const SunburstAura(
///   numberOfRays: 24,
///   rayColor: Color(0xFF80DEEA),
///   isFullByScreen: true,
///   fitBy: SunburstFitBy.diagonal,
///   innerRadiusRatio: 0.15,
///   fadeStartRatio: 0.5,
///   rotationDuration: Duration(seconds: 8),
/// )
/// ```
///
/// ## Ví dụ: quay ngược chiều
///
/// ```dart
/// const SunburstAura(
///   numberOfRays: 16,
///   rayColor: Color(0xFFFFAB91),
///   size: 280,
///   reverse: true,
///   rotationDuration: Duration(seconds: 5),
/// )
/// ```
///
/// ## Ghi chú
///
/// - Widget hoạt động được cả trong [Stack], [Column]/[Row], [Expanded]
///   — không cần bọc [Positioned].
/// - Khi [isFullByScreen] = `true` và [fitBy] = [SunburstFitBy.diagonal]
///   trong màn hình không vuông, hào quang sẽ **lớn hơn parent** để phủ kín
///   khi xoay — phần thừa bị cắt bởi screen.
/// - Nếu muốn hiệu ứng **expand dần** khi mở quà (thay vì quay đều mãi),
///   bọc [SunburstAura] trong [ScaleTransition] từ bên ngoài.
///
/// Xem thêm:
/// - [SunburstFitBy] — cách hào quang bung theo parent.
/// - [SunburstPainter] — phần vẽ các tia.
class SunburstAura extends StatefulWidget {
  final int numberOfRays;
  final Color rayColor;
  final bool isFullByScreen;
  final double innerRadiusRatio;
  final double rayWidthRatio;
  final double fadeStartRatio;
  final double maxOpacity;

  /// Kích thước của hào quang.
  /// - Nếu `isFullByScreen = true`: widget sẽ tự bung full màn hình bất kể giá trị này.
  /// - Nếu `isFullByScreen = false`: dùng đúng kích thước này.
  final double size;

  /// Thời gian quay 1 vòng
  final Duration rotationDuration;

  /// Quay ngược chiều kim đồng hồ
  final bool reverse;

  /// Chỉ áp dụng khi `isFullByScreen = true`.
  /// - `parentWidth`: hào quang bung theo chiều rộng parent.
  /// - `parentHeight`: hào quang bung theo chiều cao parent.
  /// - `diagonal`: bung theo đường chéo (mặc định, phủ kín khi xoay).
  final SunburstFitBy fitBy;

  const SunburstAura({
    super.key,
    this.numberOfRays = 16,
    this.rayColor = const Color(0xFF8BC34A),
    this.isFullByScreen = false,
    this.innerRadiusRatio = 0.2,
    this.rayWidthRatio = 0.7,
    this.fadeStartRatio = 0.5,
    this.maxOpacity = 0.95,
    this.size = 320,
    this.rotationDuration = const Duration(seconds: 6),
    this.reverse = false,
    this.fitBy = SunburstFitBy.diagonal,
  });

  @override
  State<SunburstAura> createState() => _SunburstAuraState();
}

class _SunburstAuraState extends State<SunburstAura>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant SunburstAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotationDuration != widget.rotationDuration) {
      _controller.duration = widget.rotationDuration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tính kích thước vẽ dựa trên constraint và lựa chọn fitBy
  Size _resolveSize(BoxConstraints constraints) {
    final screenSize = MediaQuery.of(context).size;
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : screenSize.width;
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : screenSize.height;

    switch (widget.fitBy) {
      case SunburstFitBy.parentWidth:
        // Hào quang có đường kính = chiều rộng parent
        final d = width;
        return Size(d, d);

      case SunburstFitBy.parentHeight:
        // Hào quang có đường kính = chiều cao parent
        final d = height;
        return Size(d, d);

      case SunburstFitBy.diagonal:
        // Hào quang phủ kín parent kể cả khi xoay -> dùng đường chéo
        final d = _diagonal(width, height);
        return Size(d, d);
    }
  }

  double _diagonal(double w, double h) {
    // Không import dart:math cho gọn, dùng căn bậc 2 thủ công.
    return _sqrt(w * w + h * h);
  }

  double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x;
    for (int i = 0; i < 20; i++) {
      r = 0.5 * (r + x / r);
    }
    return r;
  }

  SunburstPainter _buildPainter({required bool fullByScreen}) {
    return SunburstPainter(
      numberOfRays: widget.numberOfRays,
      rayColor: widget.rayColor,
      isFullByScreen: fullByScreen,
      innerRadiusRatio: widget.innerRadiusRatio,
      rayWidthRatio: widget.rayWidthRatio,
      fadeStartRatio: widget.fadeStartRatio,
      maxOpacity: widget.maxOpacity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final turns = widget.reverse ? ReverseAnimation(_controller) : _controller;

    if (widget.isFullByScreen) {
      return IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = _resolveSize(constraints);

            // Dùng OverflowBox để cho phép CustomPaint vẽ vượt ra ngoài vùng
            // parent khi size > parent (trường hợp diagonal).
            // Căn giữa để hào quang luôn ở giữa parent.
            return Center(
              child: OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                minHeight: 0,
                maxHeight: double.infinity,
                child: RotationTransition(
                  turns: turns,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      size: size,
                      painter: _buildPainter(fullByScreen: true),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Không full: kích thước cố định
    return RotationTransition(
      turns: turns,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _buildPainter(fullByScreen: false),
        ),
      ),
    );
  }
}
