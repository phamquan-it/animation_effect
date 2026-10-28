// // ==========================================
// // ENUM CÁC LOẠI VŨ KHÍ
// // ==========================================
// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// enum WeaponType { rock, arrow, fire, bomb }
//
// // ==========================================
// // DEMO CHÍNH
// // ==========================================
// class WeaponTrajectoryDemo extends StatefulWidget {
//   const WeaponTrajectoryDemo({super.key});
//
//   @override
//   State<WeaponTrajectoryDemo> createState() => _WeaponTrajectoryDemoState();
// }
//
// class _WeaponTrajectoryDemoState extends State<WeaponTrajectoryDemo>
//     with TickerProviderStateMixin {
//   late final AnimationController _controller;
//
//   final Offset _startPosition = const Offset(100, 500);
//
//   // Vũ khí đang chọn
//   WeaponType _currentWeapon = WeaponType.rock;
//
//   // Các mục tiêu (chỉ để chọn đích bay tới)
//   final List<GlobalKey> _targetKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
//   final List<String> _targetNames = ["Mục tiêu 1", "Mục tiêu 2", "Mục tiêu 3"];
//
//   Offset? _currentTargetPosition;
//   bool _isFiring = false;
//   bool _hasExploded = false;
//   Offset? _explosionPosition;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 1200),
//         )..addStatusListener((status) {
//           if (status == AnimationStatus.completed) {
//             setState(() {
//               _hasExploded = true;
//               _explosionPosition = _currentTargetPosition;
//             });
//
//             // Reset để bắn tiếp
//             Future.delayed(const Duration(milliseconds: 500), () {
//               if (mounted) {
//                 setState(() {
//                   _isFiring = false;
//                   _hasExploded = false;
//                   _currentTargetPosition =
//                       null; // Cho phép chọn lại mục tiêu mới
//                 });
//                 _controller.reset();
//               }
//             });
//           }
//         });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _onWeaponSelected(WeaponType type) {
//     setState(() {
//       _currentWeapon = type;
//     });
//   }
//
//   void _onTargetSelected(GlobalKey key) {
//     if (_isFiring) return;
//
//     final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null && box.hasSize) {
//       final Offset topLeft = box.localToGlobal(Offset.zero);
//       setState(() {
//         _currentTargetPosition =
//             topLeft + Offset(box.size.width / 2, box.size.height / 2);
//         _isFiring = true;
//         _hasExploded = false;
//       });
//
//       _controller.forward(from: 0.0);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       body: Stack(
//         children: [
//           // LỚP VẼ ĐẠN VÀ QUỸ ĐẠO
//           Positioned.fill(
//             child: IgnorePointer(
//               child: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return CustomPaint(
//                     size: const Size(800, 600),
//                     painter: TrajectoryPainter(
//                       progress: _controller.value,
//                       start: _startPosition,
//                       end: _currentTargetPosition,
//                       isFiring: _isFiring,
//                       hasExploded: _hasExploded,
//                       explosionPosition: _explosionPosition,
//                       weaponType: _currentWeapon,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           // CÁC MỤC TIÊU
//           Positioned(
//             left: 550,
//             top: 150,
//             child: _buildTarget(_targetKeys[0], _targetNames[0]),
//           ),
//           Positioned(
//             left: 700,
//             top: 300,
//             child: _buildTarget(_targetKeys[1], _targetNames[1]),
//           ),
//           Positioned(
//             left: 450,
//             top: 400,
//             child: _buildTarget(_targetKeys[2], _targetNames[2]),
//           ),
//
//           // MÁY BẮN
//           Positioned(
//             left: _startPosition.dx - 30,
//             top: _startPosition.dy - 20,
//             child: IgnorePointer(
//               child: Container(
//                 width: 60,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.brown.shade700,
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: const Icon(Icons.agriculture, color: Colors.brown),
//               ),
//             ),
//           ),
//
//           // THANH CHỌN VŨ KHÍ
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: WeaponType.values.map((type) {
//                 return GestureDetector(
//                   onTap: () => _onWeaponSelected(type),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: _currentWeapon == type
//                           ? Colors.orange.withOpacity(0.3)
//                           : Colors.white12,
//                       border: Border.all(
//                         color: _currentWeapon == type
//                             ? Colors.yellowAccent
//                             : Colors.transparent,
//                         width: 3,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           _getWeaponIcon(type),
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           _getWeaponName(type),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getWeaponIcon(WeaponType type) {
//     switch (type) {
//       case WeaponType.rock:
//         return Icons.circle;
//       case WeaponType.arrow:
//         return Icons.arrow_upward;
//       case WeaponType.fire:
//         return Icons.local_fire_department;
//       case WeaponType.bomb:
//         return Icons.brightness_7;
//     }
//   }
//
//   String _getWeaponName(WeaponType type) {
//     switch (type) {
//       case WeaponType.rock:
//         return "Đá";
//       case WeaponType.arrow:
//         return "Tên";
//       case WeaponType.fire:
//         return "Lửa";
//       case WeaponType.bomb:
//         return "Bom";
//     }
//   }
//
//   Widget _buildTarget(GlobalKey key, String name) {
//     return GestureDetector(
//       key: key,
//       onTap: () => _onTargetSelected(key),
//       child: Container(
//         width: 120,
//         height: 120,
//         decoration: BoxDecoration(
//           color: Colors.blueGrey.withOpacity(0.2),
//           border: Border.all(color: Colors.white24, width: 2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             name,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ==========================================
// // PAINTER VẼ QUỸ ĐẠO VÀ ĐẠN (ĐÃ SỬA LỖI)
// // ==========================================
// class TrajectoryPainter extends CustomPainter {
//   final double progress;
//   final Offset start;
//   final Offset? end;
//   final bool isFiring;
//   final bool hasExploded;
//   final Offset? explosionPosition;
//   final WeaponType weaponType;
//
//   TrajectoryPainter({
//     required this.progress,
//     required this.start,
//     required this.end,
//     required this.isFiring,
//     required this.hasExploded,
//     required this.explosionPosition,
//     required this.weaponType,
//   });
//
//   // Tính vị trí đạn theo quỹ đạo parabol KHÁC NHAU cho từng vũ khí
//   Offset getProjectilePosition(double t) {
//     if (end == null) return start;
//
//     double x = start.dx + (end!.dx - start.dx) * t;
//     double y = start.dy + (end!.dy - start.dy) * t;
//
//     // --- QUỸ ĐẠO RIÊNG CHO TỪNG VŨ KHÍ ---
//     switch (weaponType) {
//       case WeaponType.rock:
//         // Đá nặng: Bay thẳng, cong ít
//         y -= sin(t * pi) * 100;
//         break;
//       case WeaponType.arrow:
//         // Tên bay gần như thẳng tuyệt đối (arcHeight rất nhỏ)
//         y -= sin(t * pi) * 10;
//         break;
//       case WeaponType.fire:
//         // Lửa: Bay thấp, nhanh, gần như bay thẳng
//         y -= sin(t * pi) * 60;
//         break;
//       case WeaponType.bomb:
//         // Bom: Bay cao rồi lao xuống đột ngột
//         y -= sin(t * pi * 0.8) * 140;
//         break;
//     }
//
//     return Offset(x, y);
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // 1. Vẽ quỹ đạo dự kiến (Đường nét đứt, mờ)
//     Paint trajectoryPaint = Paint()
//       ..color = Colors.white24
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//
//     Path path = Path();
//     for (int i = 0; i <= 50; i++) {
//       double t = i / 50;
//       Offset pos = getProjectilePosition(t);
//       if (i == 0) {
//         path.moveTo(pos.dx, pos.dy);
//       } else {
//         path.lineTo(pos.dx, pos.dy);
//       }
//     }
//     canvas.drawPath(path, trajectoryPaint);
//
//     // 2. Vẽ đạn bay (nếu đang bắn)
//     if (isFiring && !hasExploded && progress < 1.0) {
//       Offset currentPos = getProjectilePosition(progress);
//
//       // Vệt lửa chung (ĐÃ SỬA: Đảm bảo luôn > 0)
//       int trailCount = weaponType == WeaponType.bomb
//           ? 5
//           : 4; // Giảm xuống 5 để không bao giờ = 0
//       for (int i = 1; i <= trailCount; i++) {
//         double prevT = (progress - i * 0.02).clamp(0.0, 1.0);
//         Offset trailPos = getProjectilePosition(prevT);
//         double radius = (12 - i * 2).clamp(1.0, 10.0).toDouble();
//         // SỬA LỖI Ở ĐÂY: clamp giá trị bán kính và opacity
//         double opacity = (0.6 - i * 0.1).clamp(0.1, 0.6);
//
//         canvas.drawCircle(
//           trailPos,
//           radius,
//           Paint()
//             ..color = Colors.orange.withOpacity(opacity)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
//         );
//       }
//
//       // Vẽ riêng từng loại vũ khí
//       switch (weaponType) {
//         case WeaponType.rock:
//           canvas.drawCircle(
//             currentPos,
//             10,
//             Paint()
//               ..shader = const RadialGradient(
//                 colors: [Colors.grey, Colors.brown],
//               ).createShader(Rect.fromCircle(center: currentPos, radius: 10)),
//           );
//           break;
//
//         case WeaponType.arrow:
//           // Mũi tên tự xoay theo góc quỹ đạo
//           Offset nextPos = getProjectilePosition(progress + 0.01);
//           double angle = atan2(
//             nextPos.dy - currentPos.dy,
//             nextPos.dx - currentPos.dx,
//           );
//
//           canvas.save();
//           canvas.translate(currentPos.dx, currentPos.dy);
//           canvas.rotate(angle);
//           Paint arrowPaint = Paint()
//             ..color = Colors.brown.shade600
//             ..strokeWidth = 3
//             ..strokeCap = StrokeCap.round;
//
//           canvas.drawLine(const Offset(-15, 0), const Offset(5, 0), arrowPaint);
//           canvas.drawPath(
//             Path()
//               ..moveTo(10, 0)
//               ..lineTo(2, -4)
//               ..lineTo(2, 4)
//               ..close(),
//             Paint()..color = Colors.grey,
//           );
//           canvas.restore();
//           break;
//
//         case WeaponType.fire:
//           canvas.drawCircle(
//             currentPos,
//             12,
//             Paint()
//               ..shader = const RadialGradient(
//                 colors: [
//                   Colors.yellowAccent,
//                   Colors.redAccent,
//                   Colors.transparent,
//                 ],
//               ).createShader(Rect.fromCircle(center: currentPos, radius: 12)),
//           );
//           break;
//
//         case WeaponType.bomb:
//           canvas.drawCircle(currentPos, 10, Paint()..color = Colors.black87);
//           canvas.drawLine(
//             currentPos,
//             currentPos + const Offset(5, -5),
//             Paint()
//               ..color = Colors.yellowAccent
//               ..strokeWidth = 2,
//           );
//           canvas.drawCircle(
//             currentPos + const Offset(7, -7),
//             3,
//             Paint()..color = Colors.orange,
//           );
//           break;
//       }
//     }
//
//     // 3. Hiệu ứng nổ (Khi chạm đích)
//     if (hasExploded && explosionPosition != null) {
//       double explosionProgress = (progress - 0.9) / 0.1;
//       if (explosionProgress > 0.0) {
//         // Màu nổ khác nhau cho từng vũ khí
//         Color explosionColor =
//             weaponType == WeaponType.fire || weaponType == WeaponType.bomb
//             ? Colors.redAccent
//             : Colors.orange;
//
//         // Vầng sáng (ĐÃ SỬA: Đảm bảo opacity không âm)
//         canvas.drawCircle(
//           explosionPosition!,
//           30 + explosionProgress * 40,
//           Paint()
//             ..color = explosionColor.withOpacity(
//               (1.0 - explosionProgress).clamp(0.0, 1.0) * 0.7,
//             )
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
//         );
//
//         // Tia lửa văng ra
//         int sparkCount = weaponType == WeaponType.bomb ? 20 : 10;
//         Paint sparkPaint = Paint()..color = explosionColor;
//         for (int i = 0; i < sparkCount; i++) {
//           double angle = i * (pi / (sparkCount / 2));
//           double dist = 20 + explosionProgress * 60;
//           Offset sparkPos =
//               explosionPosition! + Offset(cos(angle) * dist, sin(angle) * dist);
//           canvas.drawCircle(sparkPos, 3, sparkPaint);
//         }
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant TrajectoryPainter oldDelegate) => true;
// }
