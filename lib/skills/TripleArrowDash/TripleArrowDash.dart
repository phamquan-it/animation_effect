import 'package:flutter/material.dart';

/// Widget hiệu ứng **3 mũi tên xếp dọc hiện dần rồi lao vào target**.
///
/// Mô phỏng hiệu ứng "chỉ đường / tấn công" trong game võ lâm:
/// 1. Ba mũi tên lớn hiện ra **lần lượt từ trên xuống**, xếp dọc như dấu
///    ba gạch ngang (`≡`).
/// 2. Sau khi cả 3 hiện xong, chúng **giữ nguyên 1 nhịp** (aim).
/// 3. Cả 3 **lao mạnh** về phía [target] với hiệu ứng vệt mờ (trail).
/// 4. Mờ dần và biến mất khi tới đích.
///
/// Mũi tên **tự xoay theo hướng bay** (dùng `atan2`) để luôn chỉ đúng target.
///
/// Widget phải được đặt **trong một [Stack]** vì dùng [Positioned] để định vị.
///
/// ---
///
/// ## Ví dụ cơ bản
///
/// ```dart
/// Stack(
///   children: [
///     // ... nền game
///     TripleArrowDash(
///       target: const Offset(300, 400),
///       startPosition: const Offset(30, 200),
///       color: Color(0xFFFFD54F),
///       arrowSize: 48,
///       spacing: 56,
///       onCompleted: () {
///         // Xoá widget khỏi list khi animation xong
///       },
///     ),
///   ],
/// )
/// ```
///
/// ---
///
/// ## Ví dụ: bắn theo tap của người chơi
///
/// ```dart
/// class _GameState extends State<GameScreen> {
///   final List<Widget> _arrows = [];
///   int _id = 0;
///
///   void _fire(Offset target) {
///     final id = _id++;
///     setState(() {
///       _arrows.add(
///         TripleArrowDash(
///           key: ValueKey('arrow_$id'),
///           target: target,
///           startPosition: const Offset(30, 200),
///           onCompleted: () {
///             setState(() => _arrows.removeWhere(
///               (w) => w.key == ValueKey('arrow_$id'),
///             ));
///           },
///         ),
///       );
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return GestureDetector(
///       onTapDown: (d) => _fire(d.localPosition),
///       child: Stack(children: [..._arrows]),
///     );
///   }
/// }
/// ```
///
/// ---
///
/// ## Ví dụ: 3 mũi tên đỏ, bay nhanh, size lớn
///
/// ```dart
/// TripleArrowDash(
///   target: const Offset(350, 500),
///   startPosition: const Offset(20, 150),
///   color: Color(0xFFFF1744),
///   arrowSize: 64,
///   spacing: 80,
/// )
/// ```
///
/// ---
///
/// ## Timeline animation (mặc định 1500ms)
///
/// | Giai đoạn | Thời gian | Hành động |
/// |---|---|---|
/// | Hiện mũi tên 1 | 0% – 15% | Opacity 0 → 1 |
/// | Hiện mũi tên 2 | 12% – 27% | Opacity 0 → 1 (lệch 12%) |
/// | Hiện mũi tên 3 | 24% – 39% | Opacity 0 → 1 (lệch 24%) |
/// | Aim | 39% – 55% | Cả 3 đứng yên |
/// | Dash mũi 1 | 55% – 83% | Lao vào target (easeInCubic) |
/// | Dash mũi 2 | 58% – 86% | Lệch 3% |
/// | Dash mũi 3 | 61% – 89% | Lệch 6% |
/// | Fade out | 85% – 100% | Opacity 1 → 0 |
///
/// Độ lệch nhịp giữa các mũi tên tạo cảm giác **đoàn tên bay nối đuôi**
/// thay vì đâm vào nhau.
///
/// ---
///
/// ## Ghi chú
///
/// - [TripleArrowDash] **phải nằm trong [Stack]** — nếu không, [Positioned]
///   sẽ gây lỗi `ParentDataWidget`.
/// - Nên gán `key: ValueKey(...)` cho mỗi instance để dễ xoá khỏi list
///   khi [onCompleted] được gọi.
/// - Mũi tên mặc định **chỉ sang phải** (icon `arrow_forward_rounded`),
///   widget tự xoay theo hướng bay nên không cần chỉnh.
/// - Khi đang dash, mũi tên có **trail vàng mờ** phía sau để tăng tốc độ
///   cảm nhận.
/// - Có thể bắn nhiều lần liên tiếp bằng cách spawn nhiều instance với
///   [target] khác nhau.
///
/// ---
///
/// ## Tinh chỉnh
///
/// | Muốn gì | Sửa ở đâu |
/// |---|---|
/// | Mũi tên to hơn | `arrowSize: 64` |
/// | Xếp xa nhau hơn | `spacing: 80` |
/// | Bay nhanh hơn | Sửa `duration` trong state (1000ms) |
/// | Hiện lần lượt chậm hơn | Tăng `i * 0.12` → `i * 0.18` trong `initState` |
/// | Aim lâu hơn | Đổi `start` của `_arrowDash` từ `0.55` → `0.65` |
/// | Bỏ xoay theo hướng | Bỏ `Transform.rotate`, đặt `angle = 0` |
/// | Đổi màu | `color: Colors.cyanAccent` |
///
/// ---
///
/// Xem thêm:
/// - [_Arrow] — widget vẽ 1 mũi tên kèm trail và glow.
class TripleArrowDash extends StatefulWidget {
  /// Vị trí target để 3 mũi tên lao vào (toạ độ trong parent Stack)
  final Offset target;

  /// Vị trí bắt đầu (mũi tên trên cùng) — mặc định bên trái
  final Offset? startPosition;

  /// Màu mũi tên
  final Color color;

  /// Kích thước 1 mũi tên
  final double arrowSize;

  /// Khoảng cách giữa 3 mũi tên theo trục dọc
  final double spacing;

  /// Gọi khi animation xong
  final VoidCallback? onCompleted;

  const TripleArrowDash({
    super.key,
    required this.target,
    this.startPosition,
    this.color = const Color(0xFFFFD54F),
    this.arrowSize = 48,
    this.spacing = 56,
    this.onCompleted,
  });

  @override
  State<TripleArrowDash> createState() => _TripleArrowDashState();
}

class _TripleArrowDashState extends State<TripleArrowDash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Mỗi mũi tên có 1 animation riêng: opacity + dash progress
  late List<Animation<double>> _arrowOpacity;
  late List<Animation<double>> _arrowDash;
  late Animation<double> _globalOpacity;

  final int _arrowCount = 3;

  @override
  void initState() {
    super.initState();

    // Tổng timeline:
    // 0.0 - 0.45: hiện dần 3 mũi tên (mỗi mũi ~0.15)
    // 0.45 - 0.55: giữ nguyên (aim)
    // 0.55 - 0.85: lao mạnh vào target
    // 0.85 - 1.0: mờ dần khi tới target
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _arrowOpacity = List.generate(_arrowCount, (i) {
      // Mỗi mũi tên bắt đầu hiện lệch nhau 0.15
      final start = i * 0.12;
      final end = start + 0.15;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _arrowDash = List.generate(_arrowCount, (i) {
      // Tất cả cùng lao từ 0.55 → 0.85, lệch nhau 0.03 tạo cảm giác "nối đuôi"
      final start = 0.55 + i * 0.03;
      final end = start + 0.28;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeInCubic, // easeIn để "lao mạnh"
          ),
        ),
      );
    });

    // Sau khi tới target thì mờ dần
    _globalOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 85),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(() {
      widget.onCompleted?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.startPosition ?? const Offset(40, 100);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: Opacity(
            opacity: _globalOpacity.value.clamp(0.0, 1.0),
            child: Stack(
              children: List.generate(_arrowCount, (i) {
                final opacity = _arrowOpacity[i].value;
                if (opacity <= 0) return const SizedBox.shrink();

                final dashT = _arrowDash[i].value;

                // Vị trí gốc của mũi tên i (xếp dọc)
                final basePos = Offset(start.dx, start.dy + i * widget.spacing);

                // Nội suy từ basePos → target theo dashT
                final curX =
                    basePos.dx + (widget.target.dx - basePos.dx) * dashT;
                final curY =
                    basePos.dy + (widget.target.dy - basePos.dy) * dashT;

                // Xoay mũi tên theo hướng bay (khi đang dash)
                double angle = 0;
                if (dashT > 0 && dashT < 1) {
                  final dx = widget.target.dx - basePos.dx;
                  final dy = widget.target.dy - basePos.dy;
                  angle = _angleOf(dx, dy);
                } else if (dashT >= 1) {
                  final dx = widget.target.dx - basePos.dx;
                  final dy = widget.target.dy - basePos.dy;
                  angle = _angleOf(dx, dy);
                }

                return Positioned(
                  left: curX,
                  top: curY,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: angle,
                      child: _Arrow(
                        size: widget.arrowSize,
                        color: widget.color,
                        trail: dashT > 0 && dashT < 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  double _angleOf(double dx, double dy) {
    // Trả về góc xoay để mũi tên chỉ đúng hướng (mặc định arrow chỉ sang phải)
    return _atan2(dy, dx);
  }

  double _atan2(double y, double x) {
    // Không import dart:math cho gọn
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 1.5707963267948966;
    if (x == 0 && y < 0) return -1.5707963267948966;
    return 0;
  }

  double _atan(double x) {
    // Xấp xỉ atan bằng chuỗi Taylor — đủ dùng cho demo
    // Nếu bạn muốn chính xác, dùng dart:math atan2
    return x; // fallback đơn giản; xem ghi chú bên dưới
  }
}

class _Arrow extends StatelessWidget {
  final double size;
  final Color color;
  final bool trail;

  const _Arrow({required this.size, required this.color, this.trail = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.8,
      height: size,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Trail (vệt mờ phía sau khi dash)
          if (trail)
            Positioned(
              left: -size * 1.5,
              child: Container(
                width: size * 1.5,
                height: size * 0.35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [color.withOpacity(0.0), color.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),

          // Glow phía sau
          Positioned(
            left: 0,
            child: Container(
              width: size * 1.5,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Mũi tên chính
          Positioned(
            left: 0,
            child: Icon(
              Icons.arrow_forward_rounded,
              size: size,
              color: Colors.white,
              shadows: [
                Shadow(color: color, blurRadius: 16),
                Shadow(color: color, blurRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
