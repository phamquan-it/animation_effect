import 'package:flutter/material.dart';

/// Controller quản lý **hit stop** (đóng băng animation trong vài chục ms).
///
/// Cách hoạt động:
/// - Phát tín hiệu `trigger()` → tất cả các widget con dùng chung controller
///   này sẽ **tạm dừng animation** trong khoảng [freezeDuration].
/// - Sau khi hết thời gian đóng băng, animation tự **tiếp tục** từ chỗ cũ.
///
/// Dùng cho: đòn crit, đòn kết liễu, skill đặc biệt...
///
/// ## Ví dụ
///
/// ```dart
/// final hitStop = HitStopController();
///
/// // Khi đánh trúng:
/// hitStop.trigger(duration: Duration(milliseconds: 80));
///
/// // Wrap widget cần freeze:
/// HitStopScope(
///   controller: hitStop,
///   child: GameWorld(),
/// )
/// ```
class HitStopController extends ChangeNotifier {
  bool _frozen = false;
  Duration _defaultDuration = const Duration(milliseconds: 80);

  /// Có đang đóng băng không
  bool get isFrozen => _frozen;

  /// Thời gian đóng băng mặc định
  Duration get defaultDuration => _defaultDuration;
  set defaultDuration(Duration d) => _defaultDuration = d;

  /// Phát tín hiệu hit stop.
  ///
  /// [duration] — thời gian đóng băng (mặc định [defaultDuration]).
  /// [intensity] — hệ số nhân, ví dụ 1.5 cho đòn nặng (kéo dài gấp rưỡi).
  Future<void> trigger({Duration? duration, double intensity = 1.0}) async {
    if (_frozen) return; // đang freeze thì bỏ qua

    _frozen = true;
    notifyListeners();

    final d = duration ?? _defaultDuration;
    final actual = Duration(
      milliseconds: (d.inMilliseconds * intensity).round(),
    );

    await Future.delayed(actual);

    _frozen = false;
    notifyListeners();
  }

  /// Reset ngay lập tức (dùng khi đổi scene).
  void reset() {
    _frozen = false;
    notifyListeners();
  }
}
