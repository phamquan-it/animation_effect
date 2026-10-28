import 'package:flutter/material.dart';

import '../skills/TripleArrowDash/TripleArrowDash.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ArrowDashDemo()),
  );
}

class ArrowDashDemo extends StatefulWidget {
  const ArrowDashDemo({super.key});

  @override
  State<ArrowDashDemo> createState() => _ArrowDashDemoState();
}

class _ArrowDashDemoState extends State<ArrowDashDemo> {
  final List<Widget> _arrows = [];
  int _id = 0;

  void _fire(Offset target) {
    final id = _id++;
    setState(() {
      _arrows.add(
        TripleArrowDash(
          key: ValueKey('arrow_$id'),
          target: target,
          startPosition: const Offset(30, 200),
          color: const Color(0xFFFFD54F),
          arrowSize: 48,
          spacing: 56,
          onCompleted: () {
            if (!mounted) return;
            setState(() {
              _arrows.removeWhere((w) => w.key == ValueKey('arrow_$id'));
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _fire(d.localPosition),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.indigo.shade900, Colors.black],
                    radius: 1.0,
                  ),
                ),
              ),
            ),

            // Hướng dẫn
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Text(
                'TAP ĐỂ BẮN 3 MŨI TÊN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Hiệu ứng mũi tên
            ..._arrows,
          ],
        ),
      ),
    );
  }
}
