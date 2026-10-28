import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Model cho 1 item trong action menu.
class ActionMenuItem {
  /// Icon hiển thị
  final IconData icon;

  /// Label (VD: "Đánh", "Chiêu", "Item")
  final String label;

  /// Có bị disable không (mờ, không bấm được)
  final bool disabled;

  /// Badge nhỏ (VD: số lượng item, "x3")
  final String? badge;

  /// Callback khi bấm
  final VoidCallback? onTap;

  const ActionMenuItem({
    required this.icon,
    required this.label,
    this.disabled = false,
    this.badge,
    this.onTap,
  });
}

/// Widget hiệu ứng **Action Menu Pop** — menu hành động bay lên từ dưới
/// với hiệu ứng pop + stagger.
///
/// ## Đặc điểm
///
/// - **Bay lên** từ dưới màn hình theo hình vòng cung.
/// - **Stagger**: từng item xuất hiện lần lượt, lệch nhau ~50ms.
/// - **Pop effect**: mỗi item overshoot nhẹ (scale 0.5 → 1.1 → 1.0).
/// - **Hover/tap feedback**: item phóng to + viền vàng sáng khi chạm.
/// - **Tone màu hoàng gia**: đỏ + vàng + navy (fix cứng).
/// - Tự ẩn khi chọn xong hoặc bấm ra ngoài.
///
/// Widget phải nằm trong [Stack] (dùng [Positioned]).
///
/// ## Cách dùng
///
/// ```dart
/// Stack(
///   children: [
///     // ... game world
///     if (_showMenu)
///       ActionMenuPop(
///         items: [
///           ActionMenuItem(
///             icon: Icons.gavel,
///             label: 'Đánh',
///             onTap: () => _attack(),
///           ),
///           ActionMenuItem(
///             icon: Icons.auto_awesome,
///             label: 'Chiêu',
///             onTap: () => _skill(),
///           ),
///           ActionMenuItem(
///             icon: Icons.inventory_2,
///             label: 'Item',
///             badge: 'x3',
///             onTap: () => _item(),
///           ),
///           ActionMenuItem(
///             icon: Icons.shield,
///             label: 'Thủ',
///             onTap: () => _defend(),
///           ),
///           ActionMenuItem(
///             icon: Icons.directions_run,
///             label: 'Chạy',
///             disabled: true, // boss fight không cho chạy
///           ),
///         ],
///         onDismiss: () => setState(() => _showMenu = false),
///       ),
///   ],
/// )
/// ```
///
/// ## Ví dụ: menu chỉ 2 lựa chọn
///
/// ```dart
/// ActionMenuPop(
///   items: [
///     ActionMenuItem(icon: Icons.check, label: 'Có', onTap: _yes),
///     ActionMenuItem(icon: Icons.close, label: 'Không', onTap: _no),
///   ],
///   direction: MenuDirection.bottom,
///   onDismiss: _close,
/// )
/// ```
class ActionMenuPop extends StatefulWidget {
  /// Danh sách item
  final List<ActionMenuItem> items;

  /// Hướng bay lên (mặc định từ dưới)
  final MenuDirection direction;

  /// Vị trí neo (nếu null thì ở giữa dưới màn hình)
  final Offset? anchor;

  /// Khoảng cách giữa các item
  final double spacing;

  /// Kích thước mỗi item
  final double itemSize;

  /// Stagger giữa các item (ms)
  final int staggerMs;

  /// Gọi khi menu đóng (bấm ra ngoài hoặc chọn item)
  final VoidCallback? onDismiss;

  /// Có hiện overlay mờ phía sau không
  final bool showBackdrop;

  const ActionMenuPop({
    super.key,
    required this.items,
    this.direction = MenuDirection.bottom,
    this.anchor,
    this.spacing = 12,
    this.itemSize = 64,
    this.staggerMs = 60,
    this.onDismiss,
    this.showBackdrop = true,
  });

  @override
  State<ActionMenuPop> createState() => _ActionMenuPopState();
}

/// Hướng bay lên của menu.
enum MenuDirection {
  /// Từ dưới lên
  bottom,

  /// Từ trên xuống
  top,

  /// Từ trái sang
  left,

  /// Từ phải sang
  right,
}

class _ActionMenuPopState extends State<ActionMenuPop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _itemScale;
  late List<Animation<double>> _itemOpacity;
  late List<Animation<Offset>> _itemSlide;

  @override
  void initState() {
    super.initState();

    // Tổng thời gian = thời gian vào + stagger
    final totalMs = 300 + widget.items.length * widget.staggerMs;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    _buildItemAnimations();
    _controller.forward();
  }

  void _buildItemAnimations() {
    final totalMs = 300 + widget.items.length * widget.staggerMs;

    _itemScale = [];
    _itemOpacity = [];
    _itemSlide = [];

    final offsetStart = _slideStartOffset();

    for (int i = 0; i < widget.items.length; i++) {
      // Mỗi item bắt đầu lệch nhau
      final startMs = i * widget.staggerMs;
      final endMs = startMs + 300;

      final start = (startMs / totalMs).clamp(0.0, 1.0);
      final end = (endMs / totalMs).clamp(0.0, 1.0);

      // Scale: overshoot nhẹ (0.5 → 1.1 → 1.0)
      _itemScale.add(
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.5, end: 1.1)
                .chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 70,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.1, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.linear),
          ),
        ),
      );

      // Opacity: hiện nhanh
      _itemOpacity.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, (start + (end - start) * 0.5).clamp(0.0, 1.0)),
          ),
        ),
      );

      // Slide: từ offset start → Offset.zero
      _itemSlide.add(
        Tween<Offset>(begin: offsetStart, end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }
  }

  Offset _slideStartOffset() {
    switch (widget.direction) {
      case MenuDirection.bottom:
        return const Offset(0, 1.5);
      case MenuDirection.top:
        return const Offset(0, -1.5);
      case MenuDirection.left:
        return const Offset(-1.5, 0);
      case MenuDirection.right:
        return const Offset(1.5, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleItemTap(ActionMenuItem item) {
    if (item.disabled) return;
    item.onTap?.call();
    widget.onDismiss?.call();
  }

  void _handleDismiss() {
    // Đóng menu: chạy ngược animation rồi gọi callback
    _controller.reverse().then((_) {
      if (!mounted) return;
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Vị trí neo
    final anchor = widget.anchor ??
        Offset(screenSize.width / 2, screenSize.height * 0.7);

    // Tính offset cho từng item dựa trên direction
    final itemOffsets = _computeItemOffsets();

    return Stack(
      children: [
        // ==== Backdrop (bấm để đóng) ====
        if (widget.showBackdrop)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleDismiss,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Container(
                    color: Colors.black
                        .withOpacity(0.4 * _controller.value.clamp(0.0, 1.0)),
                  );
                },
              ),
            ),
          ),

        // ==== Các item ====
        ...List.generate(widget.items.length, (i) {
          final item = widget.items[i];
          final offset = itemOffsets[i];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final scale = _itemScale[i].value;
              final opacity = _itemOpacity[i].value;
              final slide = _itemSlide[i].value;

              // Áp dụng slide như translate offset
              final slideDx = slide.dx * 30;
              final slideDy = slide.dy * 30;

              return Positioned(
                left: anchor.dx + offset.dx - widget.itemSize / 2 + slideDx,
                top: anchor.dy + offset.dy - widget.itemSize / 2 + slideDy,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: _MenuItem(
                      item: item,
                      size: widget.itemSize,
                      onTap: () => _handleItemTap(item),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  /// Tính vị trí các item dựa trên hướng.
  /// Item xếp thành hàng ngang (bottom/top) hoặc hàng dọc (left/right).
  List<Offset> _computeItemOffsets() {
    final n = widget.items.length;
    final step = widget.itemSize + widget.spacing;

    if (widget.direction == MenuDirection.bottom ||
        widget.direction == MenuDirection.top) {
      // Xếp ngang
      final totalWidth = n * step - widget.spacing;
      final startX = -totalWidth / 2 + widget.itemSize / 2;
      return List.generate(
        n,
        (i) => Offset(startX + i * step, 0),
      );
    } else {
      // Xếp dọc
      final totalHeight = n * step - widget.spacing;
      final startY = -totalHeight / 2 + widget.itemSize / 2;
      return List.generate(
        n,
        (i) => Offset(0, startY + i * step),
      );
    }
  }
}

/// Widget vẽ 1 item trong menu.
class _MenuItem extends StatefulWidget {
  final ActionMenuItem item;
  final double size;
  final VoidCallback onTap;

  const _MenuItem({
    required this.item,
    required this.size,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.item.disabled;

    return GestureDetector(
      onTapDown: disabled ? null : (_) {
        setState(() => _pressed = true);
        _hoverController.forward();
      },
      onTapUp: disabled ? null : (_) {
        setState(() => _pressed = false);
        _hoverController.reverse();
      },
      onTapCancel: disabled ? null : () {
        setState(() => _pressed = false);
        _hoverController.reverse();
      },
      onTap: disabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, _) {
          final hover = _hoverController.value;

          // Màu theo disabled / hover
          final borderColor = disabled
              ? const Color(0xFF666666)
              : Color.lerp(
                  const Color(0xFFD4AF37), // vàng
                  const Color(0xFFFFD700), // vàng sáng
                  hover,
                )!;

          final glowOpacity = disabled ? 0.0 : (0.4 + 0.4 * hover);

          return Transform.scale(
            scale: 1.0 + 0.08 * hover,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ==== Glow phía sau ====
                  if (!disabled)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withOpacity(glowOpacity),
                              blurRadius: 15 + 10 * hover,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ==== Khung chính ====
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: disabled
                            ? [
                                const Color(0xFF444444),
                                const Color(0xFF222222),
                              ]
                            : [
                                const Color(0xFF8B0000), // đỏ imperial
                                const Color(0xFF5A0000),
                                const Color(0xFF003366), // navy
                              ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: 2 + hover,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.item.icon,
                        color: disabled
                            ? const Color(0xFF888888)
                            : const Color(0xFFFFD700),
                        size: widget.size * 0.42,
                        shadows: disabled
                            ? null
                            : [
                                const Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                                Shadow(
                                  color: const Color(0xFFFFD700)
                                      .withOpacity(0.8),
                                  blurRadius: 8,
                                ),
                              ],
                      ),
                    ),
                  ),

                  // ==== Label dưới ====
                  Positioned(
                    left: -10,
                    right: -10,
                    bottom: -22,
                    child: Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: disabled
                            ? const Color(0xFF888888)
                            : const Color(0xFFFFD700),
                        letterSpacing: 1,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 3),
                        ],
                      ),
                    ),
                  ),

                  // ==== Badge (số lượng) ====
                  if (widget.item.badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFDC143C),
                              Color(0xFF8B0000),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC143C)
                                  .withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Preset nhanh cho battle turn-based.
class ActionMenuPresets {
  /// Menu chuẩn 5 lựa chọn: Đánh, Chiêu, Item, Thủ, Chạy
  static ActionMenuPop battle({
    required VoidCallback onAttack,
    required VoidCallback onSkill,
    required VoidCallback onItem,
    required VoidCallback onDefend,
    required VoidCallback onFlee,
    required VoidCallback onDismiss,
    bool canFlee = true,
    int? itemCount,
  }) =>
      ActionMenuPop(
        items: [
          ActionMenuItem(
            icon: Icons.gavel,
            label: 'Đánh',
            onTap: onAttack,
          ),
          ActionMenuItem(
            icon: Icons.auto_awesome,
            label: 'Chiêu',
            onTap: onSkill,
          ),
          ActionMenuItem(
            icon: Icons.inventory_2,
            label: 'Item',
            badge: itemCount != null ? 'x$itemCount' : null,
            disabled: itemCount == 0,
            onTap: onItem,
          ),
          ActionMenuItem(
            icon: Icons.shield,
            label: 'Thủ',
            onTap: onDefend,
          ),
          ActionMenuItem(
            icon: Icons.directions_run,
            label: 'Chạy',
            disabled: !canFlee,
            onTap: onFlee,
          ),
        ],
        onDismiss: onDismiss,
      );

  /// Menu cho dialog xác nhận: Có / Không
  static ActionMenuPop confirm({
    required VoidCallback onYes,
    required VoidCallback onNo,
    String yesLabel = 'Có',
    String noLabel = 'Không',
    VoidCallback? onDismiss,
  }) =>
      ActionMenuPop(
        items: [
          ActionMenuItem(
            icon: Icons.check,
            label: yesLabel,
            onTap: onYes,
          ),
          ActionMenuItem(
            icon: Icons.close,
            label: noLabel,
            onTap: onNo,
          ),
        ],
        onDismiss: onDismiss ?? () {},
        itemSize: 72,
      );

  /// Menu 3 lựa chọn cho skill
  static ActionMenuPop skill({
    required VoidCallback onFire,
    required VoidCallback onIce,
    required VoidCallback onThunder,
    required VoidCallback onDismiss,
  }) =>
      ActionMenuPop(
        items: [
          ActionMenuItem(
            icon: Icons.local_fire_department,
            label: 'Hỏa',
            onTap: onFire,
          ),
          ActionMenuItem(
            icon: Icons.ac_unit,
            label: 'Băng',
            onTap: onIce,
          ),
          ActionMenuItem(
            icon: Icons.flash_on,
            label: 'Lôi',
            onTap: onThunder,
          ),
        ],
        onDismiss: onDismiss,
      );
}
