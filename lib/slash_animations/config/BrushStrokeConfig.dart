import 'package:flutter/material.dart';

class BrushStrokeConfig {
  final double thickness;
  final Color color;
  final double opacity;
  final double taperStart;
  final double taperEnd;
  final bool roundedCap;

  const BrushStrokeConfig({
    required this.thickness,
    required this.color,
    this.opacity = 1.0,
    this.taperStart = 0.8,
    this.taperEnd = 1.0,
    this.roundedCap = false,
  });
}
