import 'package:flutter/material.dart';

/// ============================================================================
///  AppMotion — رموز الحركة الموحّدة (Single Source of Truth)
///  مدة كل انتقال/تفاعل ومنحنيه في مكان واحد لتجربة متسقة 2026.
///  الاستخدام: AnimatedContainer(duration: AppMotion.normal, curve: AppMotion.smooth)
/// ============================================================================
class AppMotion {
  AppMotion._();

  // ---- المدد الزمنية (Durations) ----
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration pageTransition = Duration(milliseconds: 300);

  // ---- المنحنيات (Curves) ----
  /// خروج سريع وناعم — الافتراضي للتفاعلات الدقيقة.
  static const Curve fastOut = Curves.easeOutCubic;

  /// حركة «نابضية» تُستخدم للظهور والعودة (مثل scale على الكروت).
  static const Curve spring = Curves.easeOutBack;

  /// حركة سلسة بين بين — للانتقالات الطويلة.
  static const Curve smooth = Curves.easeInOutCubic;
}