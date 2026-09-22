import 'package:animation_effect/slash_animations/brush_slash.dart';
import 'package:flutter/material.dart';

// ==========================================
// 4. MAIN - CHẠY THEO CẤU HÌNH CỦA BẠN
// ==========================================
void main() {
  runApp(
    const MaterialApp(
      home: BrushSlashScreen(
        radius: 250.0,
        loop: true, // Không lặp lại
        startAngle: 90, // Bắt đầu từ 180 độ (bên trái)
        endAngle: 0, // Kết thúc ở 0 độ (bên phải)
        reverseRotate: true,
        // 👇 THÊM MỚI:
        duration: Duration(
          milliseconds: 300,
        ), // Animate trong 0.8 giây (cực nhanh)
        curve:
            Curves.easeOut, // Bắt đầu nhanh, chậm dần về cuối (giống vụt chém)
        rotateZ: 40,
        rotateY: 30,
      ),
    ),
  );
}
