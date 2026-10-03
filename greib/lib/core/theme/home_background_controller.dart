import 'package:flutter/material.dart';

import '../storage/app_prefs.dart';

/// خيار خلفية واحدة: لون خفيف ثابت أو تدرّج.
class HomeBackgroundOption {
  final String id;
  final String label;
  final Color? solid;
  final List<Color>? gradient;

  const HomeBackgroundOption({
    required this.id,
    required this.label,
    this.solid,
    this.gradient,
  });

  bool get isGradient => gradient != null;

  List<Color> get colors => gradient ?? [solid ?? Colors.transparent];

  /// أول لون أساسي — يُستخدم لخدعة توحّد لون الأيقونات مع الخلفية.
  Color get baseColor => colors.first;
}

/// ============================================================================
///  HomeBackgroundController — خلفية الصفحة الرئيسية فقط (خيارات المستخدم).
///
///  لا affect على بقية الصفحات: كل صفحة تقرأ الخلفية من ThemeController
///  (AppColors.background / lightBackground) إلا الرئيسية فهذه تقرأ من هنا.
///  الافتراضي [-1] يعني «الوضع الافتراضي» بدون أي اختيار من المستخدم.
/// ============================================================================
class HomeBackgroundController extends ChangeNotifier {

  /// ٥ ألوان خلفية طبيعية (سادة).
  static const List<HomeBackgroundOption> solidOptions = [
    HomeBackgroundOption(id: 'solid_navy', label: 'كحلي عميق', solid: Color(0xFF0F172A)),
    HomeBackgroundOption(id: 'solid_ink', label: 'فحمي', solid: Color(0xFF18181B)),
    HomeBackgroundOption(id: 'solid_cream', label: 'كريمي', solid: Color(0xFFFDF6EC)),
    HomeBackgroundOption(id: 'solid_mist', label: 'رمادي ضبابي', solid: Color(0xFFF1F5F9)),
    HomeBackgroundOption(id: 'solid_sand', label: 'رملي', solid: Color(0xFFEDE7D9)),
  ];

  /// ٥ خلفيات متدرجة (Gradient).
  static const List<HomeBackgroundOption> gradientOptions = [
    HomeBackgroundOption(
      id: 'grad_ocean',
      label: 'محيط',
      gradient: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
    ),
    HomeBackgroundOption(
      id: 'grad_royal',
      label: 'ملكي',
      gradient: [Color(0xFF1E1B4B), Color(0xFF6D28D9)],
    ),
    HomeBackgroundOption(
      id: 'grad_sunset',
      label: 'غروب',
      gradient: [Color(0xFF7C2D12), Color(0xFFF59E0B)],
    ),
    HomeBackgroundOption(
      id: 'grad_forest',
      label: 'غابة',
      gradient: [Color(0xFF052E16), Color(0xFF059669)],
    ),
    HomeBackgroundOption(
      id: 'grad_aurora',
      label: 'شفق',
      gradient: [Color(0xFF082F49), Color(0xFF0E7490)],
    ),
  ];

  static List<HomeBackgroundOption> get allOptions => [
        ...solidOptions,
        ...gradientOptions,
      ];

  int _selectedIndex = -1;

  /// -1 = لم يختر المستخدم شيئاً (نستخدم الخلفية الافتراضية للوضع الحالي).
  int get selectedIndex => _selectedIndex;

  bool get isDefault => _selectedIndex < 0;

  HomeBackgroundOption? get selected {
    if (_selectedIndex < 0 || _selectedIndex >= allOptions.length) return null;
    return allOptions[_selectedIndex];
  }

  /// قراءة التفضيل المحفوظ — تُستدعى مرة واحدة بعد تهيئة AppPrefs.
  void loadFromPrefs() {
    _selectedIndex = AppPrefs.homeBackgroundIndex;
    notifyListeners();
  }

  void select(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    AppPrefs.setHomeBackgroundIndex(index).ignore();
  }

  void reset() => select(-1);
}