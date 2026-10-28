import 'package:flutter/scheduler.dart';

import 'HitStopController.dart';

/// [TickerProvider] đặc biệt: khi [HitStopController] báo freeze,
/// tất cả [Ticker] con sẽ bị **mute** (không tick) → animation dừng.
///
/// Thông thường không cần dùng trực tiếp — hãy dùng qua `HitStopScope`.
class HitStopTickerProvider implements TickerProvider {
  final TickerProvider parent;
  final HitStopController controller;
  final List<Ticker> _tickers = [];
  bool _disposed = false;

  HitStopTickerProvider({required this.parent, required this.controller}) {
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_disposed) return;
    final frozen = controller.isFrozen;
    for (final t in _tickers) {
      t.muted = frozen;
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = parent.createTicker(onTick);
    if (controller.isFrozen) {
      ticker.muted = true;
    }
    _tickers.add(ticker);
    return ticker;
  }

  /// Gọi khi không dùng nữa (trong `State.dispose()`).
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    controller.removeListener(_onControllerChanged);
    _tickers.clear();
  }
}
