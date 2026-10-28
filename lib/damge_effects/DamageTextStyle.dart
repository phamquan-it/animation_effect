import 'package:flutter/material.dart';

enum DamageTextStyle {
  /// Vàng cam cháy (sát thương thường)
  fire,

  /// Đỏ rực (crit / bạo kích)
  crit,

  /// Xanh băng (sát thương hệ thủy)
  ice,

  /// Tím (sát thương hệ độc / âm)
  poison,

  /// Trắng xanh (sát thương chay)
  normal,
}

class DamageTextStyleData {
  final List<Color> gradientColors;
  final Color outlineColor;
  final Color glowColor;

  const DamageTextStyleData({
    required this.gradientColors,
    required this.outlineColor,
    required this.glowColor,
  });

  static DamageTextStyleData of(DamageTextStyle style) {
    switch (style) {
      case DamageTextStyle.fire:
        return const DamageTextStyleData(
          gradientColors: [
            Color(0xFFFFF176),
            Color(0xFFFFB300),
            Color(0xFFE65100),
          ],
          outlineColor: Color(0xFF3E2723),
          glowColor: Color(0xFFFF6F00),
        );
      case DamageTextStyle.crit:
        return const DamageTextStyleData(
          gradientColors: [
            Color(0xFFFFEBEE),
            Color(0xFFFF1744),
            Color(0xFF8E0000),
          ],
          outlineColor: Color(0xFF1A0000),
          glowColor: Color(0xFFFF1744),
        );
      case DamageTextStyle.ice:
        return const DamageTextStyleData(
          gradientColors: [
            Color(0xFFE1F5FE),
            Color(0xFF4FC3F7),
            Color(0xFF01579B),
          ],
          outlineColor: Color(0xFF001A33),
          glowColor: Color(0xFF29B6F6),
        );
      case DamageTextStyle.poison:
        return const DamageTextStyleData(
          gradientColors: [
            Color(0xFFE1BEE7),
            Color(0xFFAB47BC),
            Color(0xFF4A148C),
          ],
          outlineColor: Color(0xFF1A0022),
          glowColor: Color(0xFF9C27B0),
        );
      case DamageTextStyle.normal:
        return const DamageTextStyleData(
          gradientColors: [
            Color(0xFFFFFFFF),
            Color(0xFFB0BEC5),
            Color(0xFF455A64),
          ],
          outlineColor: Color(0xFF000000),
          glowColor: Color(0xFF90A4AE),
        );
    }
  }
}
