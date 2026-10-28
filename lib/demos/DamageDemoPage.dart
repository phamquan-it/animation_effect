// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
//
// import '../damge_effects/DamageNumber.dart';
// import '../damge_effects/DamageTextStyle.dart';
//
// void main() {
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DamageDemoPage(),
//     ),
//   );
// }
//
// class DamageDemoPage extends StatefulWidget {
//   const DamageDemoPage({super.key});
//
//   @override
//   State<DamageDemoPage> createState() => _DamageDemoPageState();
// }
//
// class _DamageDemoPageState extends State<DamageDemoPage> {
//   final List<Widget> _damageNumbers = [];
//   int _idCounter = 0;
//   final math.Random _random = math.Random();
//
//   /// Spawn một damage number tại vị trí cho trước
//   void _spawnDamage({
//     required Offset position,
//     required String text,
//     required DamageTextStyle style,
//     double fontSize = 40,
//   }) {
//     final id = _idCounter++;
//
//     // Random x offset nhẹ để nhiều damage không đè lên nhau
//     final jitterX = (_random.nextDouble() - 0.5) * 50;
//     final finalPos = Offset(position.dx + jitterX, position.dy);
//
//     final widget = DamageNumber(
//       key: ValueKey('dmg_$id'),
//       text: text,
//       position: finalPos,
//       style: style,
//       fontSize: fontSize,
//       duration: const Duration(milliseconds: 1300),
//       riseDistance: -140,
//       onCompleted: () {
//         if (!mounted) return;
//         setState(() {
//           _damageNumbers.removeWhere((w) => w.key == ValueKey('dmg_$id'));
//         });
//       },
//     );
//
//     setState(() => _damageNumbers.add(widget));
//   }
//
//   /// Tạo damage ngẫu nhiên (style + số + size)
//   void _spawnRandomDamage(Offset position) {
//     final roll = _random.nextDouble();
//     DamageTextStyle style;
//     double fontSize;
//     bool isCrit = false;
//
//     if (roll < 0.6) {
//       style = DamageTextStyle.fire;
//       fontSize = 36;
//     } else if (roll < 0.8) {
//       style = DamageTextStyle.ice;
//       fontSize = 38;
//     } else if (roll < 0.92) {
//       style = DamageTextStyle.poison;
//       fontSize = 38;
//     } else {
//       style = DamageTextStyle.crit;
//       fontSize = 56;
//       isCrit = true;
//     }
//
//     final damage = _random.nextInt(9999) + 100;
//     final text = isCrit ? '${_formatNumber(damage)}!' : _formatNumber(damage);
//
//     _spawnDamage(
//       position: position,
//       text: text,
//       style: style,
//       fontSize: fontSize,
//     );
//   }
//
//   String _formatNumber(int n) {
//     // 1234 -> 1,234
//     final s = n.toString();
//     final buf = StringBuffer();
//     for (int i = 0; i < s.length; i++) {
//       if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
//       buf.write(s[i]);
//     }
//     return buf.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTapDown: (details) {
//           _spawnRandomDamage(details.localPosition);
//         },
//         child: Stack(
//           children: [
//             // ===== Background giả lập =====
//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: RadialGradient(
//                     colors: [Colors.brown.shade900, Colors.black],
//                     radius: 0.9,
//                   ),
//                 ),
//               ),
//             ),
//
//             // ===== Nhân vật giả lập =====
//             Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: const LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [Colors.redAccent, Colors.deepOrange],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.red.withOpacity(0.5),
//                           blurRadius: 30,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.local_fire_department,
//                       color: Colors.white,
//                       size: 60,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'TAP ANYWHERE',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                       letterSpacing: 4,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ===== Damage numbers (luôn ở trên cùng) =====
//             ..._damageNumbers,
//
//             // ===== Nút test nhanh ở dưới =====
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 40,
//               child: Wrap(
//                 alignment: WrapAlignment.center,
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: [
//                   _TestButton(
//                     label: 'Fire',
//                     color: Colors.orange,
//                     onTap: () => _spawnDamage(
//                       position: const Offset(180, 300),
//                       text: '1,234',
//                       style: DamageTextStyle.fire,
//                     ),
//                   ),
//                   _TestButton(
//                     label: 'Crit',
//                     color: Colors.red,
//                     onTap: () => _spawnDamage(
//                       position: const Offset(180, 300),
//                       text: '9,999!',
//                       style: DamageTextStyle.crit,
//                       fontSize: 56,
//                     ),
//                   ),
//                   _TestButton(
//                     label: 'Ice',
//                     color: Colors.lightBlue,
//                     onTap: () => _spawnDamage(
//                       position: const Offset(180, 300),
//                       text: '888',
//                       style: DamageTextStyle.ice,
//                     ),
//                   ),
//                   _TestButton(
//                     label: 'Poison',
//                     color: Colors.purple,
//                     onTap: () => _spawnDamage(
//                       position: const Offset(180, 300),
//                       text: '666',
//                       style: DamageTextStyle.poison,
//                     ),
//                   ),
//                   _TestButton(
//                     label: 'Normal',
//                     color: Colors.grey,
//                     onTap: () => _spawnDamage(
//                       position: const Offset(180, 300),
//                       text: '42',
//                       style: DamageTextStyle.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _TestButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _TestButton({
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.2),
//           border: Border.all(color: color, width: 1.5),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//           ),
//         ),
//       ),
//     );
//   }
// }
