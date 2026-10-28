import 'package:animation_effect/hit_pause/HitStopController.dart';
import 'package:animation_effect/hit_pause/HitStopScope.dart';
import 'package:flutter/material.dart';

class HitStopExample extends StatefulWidget {
  const HitStopExample({super.key});

  @override
  State<HitStopExample> createState() => _HitStopExampleState();
}

class _HitStopExampleState extends State<HitStopExample> {
  final _hitStop = HitStopController();

  @override
  void dispose() {
    _hitStop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hit Stop Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: HitStopScope(
        controller: _hitStop,
        child: Stack(
          children: [
            // Nhân vật quay liên tục — sẽ bị dừng khi hit stop
            const Center(child: _SpinningEnemy()),

            // Nút trigger
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Btn(
                    label: 'Hit nhẹ (50ms)',
                    color: Colors.orange,
                    onTap: () => _hitStop.trigger(
                      duration: const Duration(milliseconds: 50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _Btn(
                    label: 'Crit (120ms)',
                    color: Colors.red,
                    onTap: () => _hitStop.trigger(
                      duration: const Duration(milliseconds: 120),
                      intensity: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Overlay flash khi freeze (optional)
            _FreezeOverlay(controller: _hitStop),
          ],
        ),
      ),
    );
  }
}

class _SpinningEnemy extends StatefulWidget {
  const _SpinningEnemy();

  @override
  State<_SpinningEnemy> createState() => _SpinningEnemyState();
}

class _SpinningEnemyState extends State<_SpinningEnemy>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  // Chú ý: dùng HitStopScope.of trong didChangeDependencies
  // nhưng vì State này không có context ban đầu → dùng cách khác.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _c = AnimationController(
      vsync: HitStopScope.of(context), // <- ticker bị ảnh hưởng hit stop
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.pinkAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text('👹', style: TextStyle(fontSize: 50)),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Btn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FreezeOverlay extends StatelessWidget {
  final HitStopController controller;

  const _FreezeOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isFrozen) return const SizedBox.shrink();
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.white.withOpacity(0.15)),
          ),
        );
      },
    );
  }
}
