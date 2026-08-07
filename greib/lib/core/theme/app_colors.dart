import 'package:flutter/material.dart';

/// ============================================================================
///  ملف الألوان الموحّد — المصدر الوحيد للحقيقة (Single Source of Truth)
/// ============================================================================
///
///  جميع ألوان التطبيق تُعرّف هنا فقط. لتغيير أي لون أو إعادة تصميم الهوية
///  بالكامل، عدّل القيم هنا وسيتم تحديث التطبيق بأكمله (الثيم + كل الشاشات).
///
///  الهوية البصرية: خلفية كحلية داكنة (تدرج) + لون مميز لكل خدمة.
/// ============================================================================

class AppColors {
  AppColors._();

  // ===== الألوان الأساسية (Dark Identity - Navy Gradient) =====
  static const Color backgroundPrimary = Color(0xFF061722);
  static const Color backgroundSecondary = Color(0xFF12222E);
  static const Color surfaceCard = Color(0xFF243644);
  static const Color surfaceCardElevated = Color(0xFF2E4655);
  static const Color surfaceOverlay = Color(0xFF385466);

  // ===== اللون المميز الأساسي =====
  static const Color accentPrimary = Color.fromARGB(255, 255, 237, 195);
  static const Color accentPrimaryDark = Color.fromARGB(255, 255, 237, 195);
  static const Color accentPrimaryLight = Color.fromARGB(255, 255, 237, 195);
  static const Color accentGlow = Color(0x33243644);

  // ===== ألوان الخدمات الست (تُستخدم في الشاشات والكروت) =====
  static const Color serviceFood = Color.fromARGB(255, 255, 237, 195);
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
  static const Color outline = Color(0xFF2E4655);
  static const Color outlineLight = Color(0xFF385466);

  // ===== الحالات =====
  static const Color success = Color.fromARGB(255, 255, 237, 195);
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

  // ===== أسماء مستعارة مختصرة للاستخدام السريع =====
  static const Color primary = accentPrimary;
  static const Color neon = accentPrimary;
  static const Color neonDark = accentPrimaryDark;
  static const Color background = backgroundPrimary;
  static const Color surface = surfaceCard;
  static const Color surfaceElevated = surfaceCardElevated;
  static const Color surfaceVariant = surfaceOverlay;
  static const Color textMuted = textTertiary;

  // ===== أسماء متوافقة مع الإصدار السابق (لا تغيرها إلا عند إعادة التصميم) =====
  static const Color primaryLight = accentPrimaryLight;
  static const Color primaryDark = accentPrimaryDark;
  static const Color secondary = neutral200;
  static const Color secondaryLight = neutral50;
  static const Color secondaryDark = neutral300;
  static const Color accent = info;
  static const Color darkBackground = backgroundPrimary;
  static const Color darkSurface = surfaceCard;
  static const Color darkSurfaceVariant = surfaceOverlay;
  static const Color darkText = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextTertiary = textTertiary;
  static const Color darkOutline = outline;

  // ===== تدرج البانر العلوي / الخلفية (Navy Gradient) =====
  static const List<Color> heroGradient = [
    Color(0xFF243644),
    Color(0xFF12222E), 
    Color(0xFF061722),
  ];

  static List<BoxShadow> neonGlow({double blur = 24, double alpha = 0.35}) {
    return [
      BoxShadow(
        color: accentPrimary.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: 1,
        offset: const Offset(0, 8),
      ),
    ];
  }
}