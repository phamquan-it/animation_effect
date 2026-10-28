// import 'package:flutter/material.dart';
//
// import '../transform_vfx/TransformVfx.dart';
// import '../transform_vfx/TransformVfxConfig.dart';
//
// void main() {
//   runApp(
//     const MaterialApp(debugShowCheckedModeBanner: false, home: VfxDemoPage()),
//   );
// }
//
// class VfxDemoPage extends StatelessWidget {
//   const VfxDemoPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Transform VFX Demo'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: const Center(child: _MagicAnimationCanada()),
//     );
//   }
// }
//
// class _MagicAnimationCanada extends StatelessWidget {
//   const _MagicAnimationCanada();
//
//   @override
//   Widget build(BuildContext context) {
//     return TransformVfx(
//       loop: true,
//       configs: [
//         // Lộn ngang liên tục
//         TransformVfxConfig.flipH(
//           startMs: 0,
//           durationMs: 800,
//           turns: 1,
//           repeat: -1,
//           curve: Curves.linear,
//         ),
//
//         // Lộn dọc chậm hơn, bắt đầu sau 200ms
//         TransformVfxConfig.flipV(
//           startMs: 200,
//           durationMs: 1200,
//           turns: 1,
//           repeat: -1,
//           curve: Curves.easeInOut,
//         ),
//
//         // Xoay Z nhanh
//         TransformVfxConfig.rotate(
//           startMs: 0,
//           durationMs: 500,
//           turns: 1,
//           repeat: -1,
//           curve: Curves.linear,
//         ),
//
//         // Nhấp nhô scale
//         TransformVfxConfig.scale(
//           startMs: 0,
//           durationMs: 400,
//           to: 1.3,
//           repeat: -1,
//           reverse: true,
//           curve: Curves.easeInOut,
//         ),
//
//         // Bay lên xuống
//         TransformVfxConfig.translate(
//           startMs: 0,
//           durationMs: 600,
//           to: const Offset(0, -40),
//           repeat: -1,
//           reverse: true,
//           curve: Curves.easeInOut,
//         ),
//       ],
//       child: Container(
//         width: 120,
//         height: 120,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: const LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.pinkAccent, Colors.purple, Colors.deepPurple],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.pinkAccent.withOpacity(0.6),
//               blurRadius: 40,
//               spreadRadius: 10,
//             ),
//           ],
//         ),
//         alignment: Alignment.center,
//         child: const Text('🍁', style: TextStyle(fontSize: 60)),
//       ),
//     );
//   }
// }
