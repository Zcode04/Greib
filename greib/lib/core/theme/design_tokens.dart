import 'package:flutter/material.dart';

/// نظام التصميم (Design Tokens) لتطبيق "گريب منك"
/// هوية بصرية: داكن + نيون أخضر + ألوان مميزة لكل خدمة
class AppColors {
  // ===== الألوان الأساسية (Dark Identity) =====
  static const Color backgroundPrimary = Color(0xFF0D0F0D);
  static const Color backgroundSecondary = Color(0xFF121412);
  static const Color surfaceCard = Color(0xFF1A1D1A);
  static const Color surfaceCardElevated = Color(0xFF202420);
  static const Color surfaceOverlay = Color(0xFF262B26);

  // ===== النيون الأخضر (Accent) =====
  static const Color accentPrimary = Color(0xFF4ADE80);
  static const Color accentPrimaryDark = Color(0xFF22C55E);
  static const Color accentPrimaryLight = Color(0xFF86EFAC);
  static const Color accentGlow = Color(0x334ADE80);

  // ===== ألوان الخدمات الست =====
  static const Color serviceFood = Color(0xFF4ADE80);
  static const Color servicePharmacy = Color(0xFF60A5FA);
  static const Color serviceCourier = Color(0xFFA78BFA);
  static const Color serviceRide = Color(0xFFFBBF24);
  static const Color serviceShopping = Color(0xFFF472B6);
  static const Color serviceTourism = Color(0xFF2DD4BF);

  // ===== النصوص (Dark) =====
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);

  // ===== الحدود =====
  static const Color outline = Color(0xFF2E332E);
  static const Color outlineLight = Color(0xFF3A403A);

  // ===== الحالات =====
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // ===== الوضع الفاتح (ثانوي) =====
  static const Color lightBackground = Color(0xFFF8FAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F4F0);
  static const Color lightText = Color(0xFF1A1D1A);
  static const Color lightTextSecondary = Color(0xFF5C635C);
  static const Color lightTextTertiary = Color(0xFF8E958E);
  static const Color lightOutline = Color(0xFFD8DED8);

  // ===== ألوان محايدة =====
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ===== توافق مع الإصدار السابق =====
  static const Color primary = accentPrimary;
  static const Color primaryLight = accentPrimaryLight;
  static const Color primaryDark = accentPrimaryDark;
  static const Color secondary = Color(0xFFFBBF24);
  static const Color secondaryLight = Color(0xFFFCD34D);
  static const Color secondaryDark = Color(0xFFD97706);
  static const Color accent = info;
  static const Color darkBackground = backgroundPrimary;
  static const Color darkSurface = surfaceCard;
  static const Color darkSurfaceVariant = surfaceOverlay;
  static const Color darkText = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextTertiary = textTertiary;
  static const Color darkOutline = outline;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}

class AppElevation {
  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 12;
}

class AppShadows {
  static List<BoxShadow> get glowGreen => [
        BoxShadow(
          color: AppColors.accentGlow,
          blurRadius: 24,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowGreenStrong => [
        BoxShadow(
          color: AppColors.accentGlow,
          blurRadius: 40,
          spreadRadius: 6,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get xs => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.2),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.5),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.6),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

class AppTypography {
  static const String fontFamily = 'Cairo';

  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
}