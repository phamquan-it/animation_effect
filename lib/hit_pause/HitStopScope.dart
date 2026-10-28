import 'package:animation_effect/hit_pause/HitStopController.dart';
import 'package:animation_effect/hit_pause/HitStopTickerProvider.dart';
import 'package:flutter/material.dart';

/// Widget bọc subtree để áp dụng hiệu ứng **hit stop toàn cục**.
///
/// Bất kỳ [AnimationController] nào được tạo bên trong scope đều sẽ bị
/// tạm dừng khi [HitStopController.trigger] được gọi.
///
/// Cách hoạt động: cung cấp [TickerProvider] tùy chỉnh — khi freeze,
/// `Ticker` sẽ không được schedule frame mới → mọi animation con dừng lại.
///
/// **Lưu ý:** chỉ hoạt động với các animation **được tạo bên trong scope**
/// thông qua [HitStopScope.of(context)]. Nếu bạn tạo controller bên ngoài
/// (dùng `SingleTickerProviderStateMixin` của widget cha), nó sẽ không bị ảnh hưởng.
class HitStopScope extends StatefulWidget {
  final HitStopController controller;
  final Widget child;

  const HitStopScope({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Lấy [TickerProvider] đã được gắn hit-stop từ context.
  ///
  /// Dùng thay cho `SingleTickerProviderStateMixin`:
  ///
  /// ```dart
  /// class _MyWidgetState extends State<MyWidget> {
  ///   late AnimationController _c;
  ///
  ///   @override
  ///   void didChangeDependencies() {
  ///     super.didChangeDependencies();
  ///     _c = AnimationController(
  ///       vsync: HitStopScope.of(context),  // <- dùng cái này
  ///       duration: Duration(seconds: 1),
  ///     );
  ///   }
  /// }
  /// ```
  static HitStopTickerProvider of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_HitStopInherited>();
    assert(provider != null, 'HitStopScope chưa được đặt ở trên widget này');
    return provider!.tickerProvider;
  }

  @override
  State<HitStopScope> createState() => _HitStopScopeState();
}

class _HitStopScopeState extends State<HitStopScope>
    with TickerProviderStateMixin {
  late HitStopTickerProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = HitStopTickerProvider(
      parent: this,
      controller: widget.controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _HitStopInherited(tickerProvider: _provider, child: widget.child);
  }
}

class _HitStopInherited extends InheritedWidget {
  final HitStopTickerProvider tickerProvider;

  const _HitStopInherited({required this.tickerProvider, required super.child});

  @override
  bool updateShouldNotify(_HitStopInherited old) =>
      old.tickerProvider != tickerProvider;
}
