// core/theme/dark_palette.dart
//
// لوحة الألوان الداكنة المستوحاة من التصميم المرفق (خلفية شبه سوداء + أخضر نيون).
// اربطها بملف design_tokens.dart عندك، أو استخدمها مباشرة كما هي.

import 'package:flutter/material.dart';

class DarkPalette {
  DarkPalette._();

  // خلفيات
  static const Color background = Color(0xFF0B0C0E);       // خلفية الشاشة شبه السوداء
  static const Color surface = Color(0xFF16181B);          // خلفية الكروت
  static const Color surfaceElevated = Color(0xFF1E2125);  // كروت مرفوعة (سبوت لايت)
  static const Color surfaceVariant = Color(0xFF232629);   // خلفية الشريط السفلي / الأزرار الدائرية

  // اللون المميز (نيون)
  static const Color neon = Color(0xFFB6FF3C);
  static const Color neonDark = Color(0xFF8FD62B);

  // نصوص
  static const Color textPrimary = Color(0xFFF5F6F7);
  static const Color textSecondary = Color(0xFF9A9DA3);
  static const Color textMuted = Color(0xFF6C6F75);

  // حالات
  static const Color success = Color(0xFF3DDC84);
  static const Color warning = Color(0xFFFFC24B);
  static const Color info = Color(0xFF4EA1FF);
  static const Color error = Color(0xFFFF5C5C);

  // تدرج البانر العلوي (Explore new collection)
  static const List<Color> heroGradient = [
    Color(0xFF15170F),
    Color(0xFF1E2A12),
  ];

  static BoxShadow neonGlow({double blur = 24, double alpha = 0.35}) {
    return BoxShadow(
      color: neon.withValues(alpha: alpha),
      blurRadius: blur,
      spreadRadius: 1,
      offset: const Offset(0, 8),
    );
  }

  static ThemeData themeData() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neon,
        secondary: neon,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: surface,
      dividerColor: Colors.white10,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
