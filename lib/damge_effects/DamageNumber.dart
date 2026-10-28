import 'package:flutter/material.dart';

import 'DamageTextStyle.dart';

/// Widget hiệu ứng **số sát thương bay lên** kiểu game võ lâm / ARPG.
///
/// Đặc điểm:
/// - Xuất hiện tại vị trí `(x, y)` chỉ định trong parent [Stack].
/// - Bắt đầu **nhỏ** → **phóng to** (pop) → hơi thu lại → bay lên → mờ dần.
/// - Chữ có **gradient màu**, **viền đen đậm** và **glow** phía sau.
/// - Tự huỷ sau khi animation xong qua callback [onCompleted].
///
/// Widget phải được đặt **trực tiếp trong một [Stack]** vì nó dùng
/// [Positioned] để định vị.
///
/// ## Cách dùng cơ bản
///
/// ```dart
/// Stack(
///   children: [
///     // ... nền game
///     DamageNumber(
///       text: '1,234',
///       position: const Offset(180, 300),
///       style: DamageTextStyle.fire,
///       fontSize: 40,
///       onCompleted: () {
///         // Xoá widget khỏi list khi animation xong
///       },
///     ),
///   ],
/// )
/// ```
///
/// ## Ví dụ: spawn damage khi tap vào màn hình
///
/// ```dart
/// class GameScreen extends StatefulWidget {
///   const GameScreen({super.key});
///
///   @override
///   State<GameScreen> createState() => _GameScreenState();
/// }
///
/// class _GameScreenState extends State<GameScreen> {
///   final List<Widget> _damages = [];
///   int _id = 0;
///
///   void _spawn(Offset pos, String text, DamageTextStyle style) {
///     final id = _id++;
///     setState(() {
///       _damages.add(
///         DamageNumber(
///           key: ValueKey(id),
///           text: text,
///           position: pos,
///           style: style,
///           onCompleted: () {
///             setState(() => _damages.removeWhere(
///               (w) => w.key == ValueKey(id),
///             ));
///           },
///         ),
///       );
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: GestureDetector(
///         onTapDown: (d) => _spawn(
///           d.localPosition,
///           '999',
///           DamageTextStyle.fire,
///         ),
///         child: Stack(children: [..._damages]),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Ví dụ: crit damage to hơn, bay cao hơn
///
/// ```dart
/// DamageNumber(
///   text: '9,999!',
///   position: const Offset(180, 300),
///   style: DamageTextStyle.crit,
///   fontSize: 56,
///   duration: const Duration(milliseconds: 1500),
///   riseDistance: -200,
///   peakScale: 1.5,
/// )
/// ```
///
/// ## Ví dụ: damage hệ băng, không bay lên
///
/// ```dart
/// DamageNumber(
///   text: '888',
///   position: const Offset(200, 250),
///   style: DamageTextStyle.ice,
///   fontSize: 36,
///   riseDistance: 0, // đứng yên
///   duration: const Duration(milliseconds: 900),
/// )
/// ```
///
/// ## Ví dụ: combo damage cộng dồn tại 1 chỗ
///
/// ```dart
/// // Spawn nhiều DamageNumber liên tiếp với jitter nhẹ
/// for (int i = 0; i < 3; i++) {
///   Future.delayed(Duration(milliseconds: i * 80), () {
///     _spawn(
///       position + Offset((i - 1) * 15.0, 0),
///       '${100 + i * 50}',
///       DamageTextStyle.fire,
///     );
///   });
/// }
/// ```
///
/// ## Ghi chú
///
/// - [DamageNumber] **phải nằm trong [Stack]** — nếu không, [Positioned]
///   sẽ gây lỗi `ParentDataWidget`.
/// - Nên gán `key: ValueKey(...)` cho mỗi instance để dễ xoá khỏi list
///   khi [onCompleted] được gọi.
/// - Nếu muốn nhiều damage không đè lên nhau, cộng thêm offset ngẫu nhiên
///   vào [position] trước khi truyền vào.
/// - Xem [DamageTextStyle] để biết các preset màu có sẵn.
///
/// Xem thêm:
/// - [DamageTextStyle] — các preset màu gradient.
/// - [DamageTextStyleData] — dữ liệu màu của từng style.
class DamageNumber extends StatefulWidget {
  /// Nội dung số (hoặc chữ) hiển thị
  final String text;

  /// Vị trí xuất hiện (theo toạ độ của parent Stack)
  final Offset position;

  /// Kiểu màu gradient
  final DamageTextStyle style;

  /// Cỡ chữ tối đa sau khi phóng to
  final double fontSize;

  /// Thời gian tồn tại (bao gồm pop + bay lên + mờ dần)
  final Duration duration;

  /// Quãng đường bay lên (âm = bay lên trên)
  final double riseDistance;

  /// Gọi khi animation kết thúc để parent xoá widget khỏi list
  final VoidCallback? onCompleted;

  /// Scale lúc bắt đầu (0.0 - 1.0)
  final double startScale;

  /// Scale lúc đỉnh pop (thường > 1.0 để tạo cảm giác "nảy")
  final double peakScale;

  /// Scale lúc kết thúc
  final double endScale;

  const DamageNumber({
    super.key,
    required this.text,
    required this.position,
    this.style = DamageTextStyle.fire,
    this.fontSize = 40,
    this.duration = const Duration(milliseconds: 1200),
    this.riseDistance = -120,
    this.onCompleted,
    this.startScale = 0.2,
    this.peakScale = 1.2,
    this.endScale = 0.9,
  });

  @override
  State<DamageNumber> createState() => _DamageNumberState();
}

class _DamageNumberState extends State<DamageNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _riseAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Scale: nhỏ → phóng to → hơi thu lại
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: widget.startScale,
          end: widget.peakScale,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: widget.peakScale,
          end: widget.endScale,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(widget.endScale), weight: 55),
    ]).animate(_controller);

    // Bay lên: dùng easeOut để bay nhanh lúc đầu, chậm dần
    _riseAnim = Tween<double>(
      begin: 0,
      end: widget.riseDistance,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Opacity: hiện nhanh → giữ → mờ dần ở cuối
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
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
    final styleData = DamageTextStyleData.of(widget.style);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx,
          top: widget.position.dy + _riseAnim.value,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacityAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                alignment: Alignment.center,
                child: _GradientDamageText(
                  text: widget.text,
                  fontSize: widget.fontSize,
                  styleData: styleData,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradientDamageText extends StatelessWidget {
  final String text;
  final double fontSize;
  final DamageTextStyleData styleData;

  const _GradientDamageText({
    required this.text,
    required this.fontSize,
    required this.styleData,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      fontFamily: 'Arial', // hoặc font game của bạn
      height: 1.0,
      letterSpacing: 1.0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Lớp 1: Glow (mờ phía sau)
        Text(
          text,
          style: textStyle.copyWith(
            color: styleData.glowColor.withOpacity(0.6),
            shadows: [
              Shadow(
                color: styleData.glowColor.withOpacity(0.8),
                blurRadius: 20,
              ),
              Shadow(
                color: styleData.glowColor.withOpacity(0.6),
                blurRadius: 40,
              ),
            ],
          ),
        ),

        // Lớp 2: Outline (viền đen quanh chữ) — dùng 8 hướng offset
        _OutlinedText(
          text: text,
          textStyle: textStyle,
          outlineColor: styleData.outlineColor,
          outlineWidth: 3.0,
        ),

        // Lớp 3: Chữ chính với gradient
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: styleData.gradientColors,
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(text, style: textStyle.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Vẽ chữ với viền bằng cách vẽ 8 bản sao offset xung quanh
class _OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color outlineColor;
  final double outlineWidth;

  const _OutlinedText({
    required this.text,
    required this.textStyle,
    required this.outlineColor,
    this.outlineWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final outlineStyle = textStyle.copyWith(
      color: outlineColor,
      fontWeight: FontWeight.w900,
    );

    // 8 hướng: trên, dưới, trái, phải, 4 góc chéo
    final offsets = <Offset>[
      Offset(-outlineWidth, 0),
      Offset(outlineWidth, 0),
      Offset(0, -outlineWidth),
      Offset(0, outlineWidth),
      Offset(-outlineWidth, -outlineWidth),
      Offset(outlineWidth, -outlineWidth),
      Offset(-outlineWidth, outlineWidth),
      Offset(outlineWidth, outlineWidth),
    ];

    return Stack(
      alignment: Alignment.center,
      children: offsets.map((o) {
        return Transform.translate(
          offset: o,
          child: Text(text, style: outlineStyle),
        );
      }).toList(),
    );
  }
}
