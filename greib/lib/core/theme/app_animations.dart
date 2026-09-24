import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // Curves
  static const Curve easeOutExpo = Curves.easeOutExpo;
  static const Curve springBounce = Curves.bounceOut;
  static const Curve smoothDecel = Curves.decelerate;
}
