import 'package:flutter/material.dart';

/// ============================================================================
///  ملف الألوان الموحّد — المصدر الوحيد للحقيقة (Single Source of Truth)
/// ============================================================================
///
///  الهوية: Deep Space Black + Electric Violet
///  أسود عميق فاخر مع لون بنفسجي كهربائي كـ accent
///  ← احترافي، عالمي، متماسك في كلا الوضعين
///
///  ★ لتغيير هوية التطبيق: عدّل القسم (Primitives) فقط.
/// ============================================================================

class AppColors {
  AppColors._();

  // ==========================================================================
  //  1) الألوان الأساسية (Primitives)
  // ==========================================================================

  // ---------- 🌙 الوضع الليلي (Dark Mode) ----------
  static const Color _darkBg          = Color.fromARGB(255, 13, 11, 21); // أسود عميق — الخلفية
  static const Color _darkSurface     = Color(0xFF211F2B); // كروت وبطاقات
  static const Color _darkElevated    = Color(0xFF211F2B); // طبقة أعمق (modals, inputs)
  static const Color _darkBorder      = Color.fromARGB(255, 15, 18, 23); // حدود دقيقة
  static const Color _darkTextPrimary  = Color(0xFFFAFAFA); // نص أساسي أبيض ناعم
  static const Color _darkTextMuted    = Color(0xFFA1A1AA); // نص ثانوي رمادي

  // ---------- ☀️ الوضع النهاري (Light Mode) ----------
  static const Color _lightBg          = Color(0xFFF4F4F5); // خلفية فاتحة محايدة
  static const Color _lightSurface     = Color.fromARGB(255, 255, 255, 255); // كروت بيضاء نظيفة
  static const Color _lightElevated    = Color(0xFFF4F4F5); // للـ inputs
  static const Color _lightBorder      = Color.fromARGB(255, 255, 152, 43); // حدود خفيفة
  static const Color _lightTextPrimary  = Color(0xFF09090B); // نص أسود
  static const Color _lightTextMuted    = Color(0xFF71717A); // نص ثانوي

  // ---------- 🎨 Accent — مشترك بين الوضعين ----------
  // بنفسجي كهربائي (Electric Violet) — احترافي وعالمي
  static const Color _violet600  = Color(0xFF7C3AED); // اللون المميز الأساسي
  static const Color _violet400  = Color(0xFFA78BFA); // نسخة أفتح (glows, highlights)
  static const Color _violet900  = Color(0xFF4C1D95); // للحاويات الداكنة (dark container)

  // ---------- 🔴 الحالات (States) ----------
  static const Color _success = Color(0xFF22C55E); // أخضر
  static const Color _warning = Color(0xFFF59E0B); // برتقالي/ذهبي
  static const Color _error   = Color(0xFFEF4444); // أحمر
  static const Color _info    = Color(0xFF3B82F6); // أزرق

  // ---------- 🛍 ألوان الخدمات الست ----------
  static const Color _svcFood      = Color(0xFFF97316); // برتقالي دافئ — طعام
  static const Color _svcPharmacy  = Color(0xFF3B82F6); // أزرق — صيدلية
  static const Color _svcCourier   = Color(0xFFA78BFA); // بنفسجي فاتح — توصيل
  static const Color _svcRide      = Color(0xFFF59E0B); // ذهبي — مشاوير
  static const Color _svcShopping  = Color(0xFFEC4899); // وردي — تسوق
  static const Color _svcTourism   = Color(0xFF14B8A6); // تيل — سياحة

  // ---------- 🧩 ألوان الخدمات الإضافية (١٨ خدمة) ----------
  static const Color _svcMoving     = Color(0xFF0EA5E9); // سماوي — نقل
  static const Color _svcTaxi       = Color(0xFFFACC15); // أصفر — تكاسي
  static const Color _svcElectricity= Color(0xFFFDE047); // أصفر فاتح — كهرباء
  static const Color _svcWater      = Color(0xFF38BDF8); // أزرق سماوي — ماء
  static const Color _svcLaundry    = Color(0xFF22D3EE); // سماوي فاتح — غسيل
  static const Color _svcClothes    = Color(0xFFFB7185); // وردي فاتح — ملابس
  static const Color _svcPhones     = Color(0xFF6366F1); // بنفسجي أزرق — هواتف
  static const Color _svcDevices    = Color(0xFF8B5CF6); // بنفسجي — أجهزة
  static const Color _svcAppliances = Color(0xFF10B981); // أخضر — أجهزة منزلية
  static const Color _svcOffice     = Color(0xFF64748B); // رمادي أزرق — معدات مكتبية
  static const Color _svcDelivery   = Color(0xFFF472B6); // وردي — توصيل
  static const Color _svcEstore     = Color(0xFFA855F7); // بنفسجي — متاجر إلكترونية
  static const Color _svcTravel     = Color(0xFF06B6D4); // سماوي — سفر
  static const Color _svcTourismX   = Color(0xFF14B8A6); // تيل — سياحة (احتياطي)
  static const Color _svcMedicine   = Color(0xFFEF4444); // أحمر — أدوية
  static const Color _svcPharmacyX  = Color(0xFF3B82F6); // أزرق — صيدلة (احتياطي)
  static const Color _svcConsult    = Color(0xFF84CC16); // أخضر ليموني — استشارات طبية
  static const Color _svcFreight    = Color(0xFFF97316); // برتقالي — نقل بضائع

  // ==========================================================================
  //  2) الطبقة الدلالية (Semantic Layer) — لا تعدّل هنا مباشرة
  //     هذه الأسماء هي ما يستخدمه بقية الكود بالكامل
  // ==========================================================================

  // --- خلفيات وأسطح ---
  static const Color backgroundPrimary   = _darkBg;
  static const Color backgroundSecondary = _darkSurface;
  static const Color surfaceCard         = _darkSurface;
  static const Color surfaceCardElevated = _darkElevated;
  static const Color surfaceOverlay      = _darkElevated;

  // --- اللون المميز الأساسي ---
  static const Color accentPrimary      = _violet600; // ← البنفسجي الكهربائي (مش رمادي!)
  static const Color accentPrimaryDark  = _violet900;
  static const Color accentPrimaryLight = _violet400;
  static const Color accentGlow         = _violet400;

  // --- ألوان الخدمات ---
  static const Color serviceFood     = _svcFood;
  static const Color servicePharmacy = _svcPharmacy;
  static const Color serviceCourier  = _svcCourier;
  static const Color serviceRide     = _svcRide;
  static const Color serviceShopping = _svcShopping;
  static const Color serviceTourism  = _svcTourism;

  // --- ألوان الخدمات الإضافية ---
  static const Color serviceMoving     = _svcMoving;
  static const Color serviceTaxi       = _svcTaxi;
  static const Color serviceElectricity= _svcElectricity;
  static const Color serviceWater      = _svcWater;
  static const Color serviceLaundry    = _svcLaundry;
  static const Color serviceClothes    = _svcClothes;
  static const Color servicePhones     = _svcPhones;
  static const Color serviceDevices    = _svcDevices;
  static const Color serviceAppliances = _svcAppliances;
  static const Color serviceOffice     = _svcOffice;
  static const Color serviceDelivery   = _svcDelivery;
  static const Color serviceEstore     = _svcEstore;
  static const Color serviceTravel     = _svcTravel;
  static const Color serviceTourismX   = _svcTourismX;
  static const Color serviceMedicine   = _svcMedicine;
  static const Color servicePharmacyX  = _svcPharmacyX;
  static const Color serviceConsult    = _svcConsult;
  static const Color serviceFreight    = _svcFreight;

  // --- النصوص (Dark mode — الوضع الافتراضي) ---
  static const Color textPrimary   = _darkTextPrimary;
  static const Color textSecondary = _darkTextMuted;
  static const Color textTertiary  = Color(0xFF71717A);

  // --- الحدود ---
  static const Color outline      = _darkBorder;
  static const Color outlineLight = _darkBorder;

  // --- الحالات ---
  static const Color success = _success;
  static const Color warning = _warning;
  static const Color error   = _error;
  static const Color info    = _info;

  // --- الوضع الفاتح ---
  static const Color lightBackground     = _lightBg;
  static const Color lightSurface        = _lightSurface;
  static const Color lightSurfaceVariant = _lightElevated;
  static const Color lightText           = _lightTextPrimary;
  static const Color lightTextSecondary  = _lightTextMuted;
  static const Color lightTextTertiary   = Color(0xFFA1A1AA);
  static const Color lightOutline        = _lightBorder;

  // ==========================================================================
  //  3) أسماء مختصرة للاستخدام السريع
  //     (مترادفات للأسماء الدلالية أعلاه)
  // ==========================================================================
  static const Color primary         = accentPrimary;   // ← بنفسجي الآن ✓
  static const Color primaryLight    = accentPrimaryLight;
  static const Color primaryDark     = accentPrimaryDark;
  static const Color neon            = accentPrimaryLight; // للـ glows والتوهج
  static const Color neonDark        = accentPrimary;
  static const Color background      = backgroundPrimary;
  static const Color surface         = surfaceCard;
  static const Color surfaceElevated = surfaceCardElevated;
  static const Color surfaceVariant  = surfaceOverlay;
  static const Color textMuted       = textTertiary;

  // للتوافق مع الكود القديم
  static const Color secondary          = Color(0xFF3F3F46);
  static const Color secondaryLight     = Color(0xFFA1A1AA);
  static const Color secondaryDark      = Color(0xFF27272A);
  static const Color accent             = info;
  static const Color darkBackground     = backgroundPrimary;
  static const Color darkSurface        = surfaceCard;
  static const Color darkSurfaceVariant = surfaceOverlay;
  static const Color darkText           = textPrimary;
  static const Color darkTextSecondary  = textSecondary;
  static const Color darkTextTertiary   = textTertiary;
  static const Color darkOutline        = outline;

  // --- محايدات (Neutrals) ---
  static const Color neutral50  = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF4F4F5);
  static const Color neutral200 = Color(0xFFE4E4E7);
  static const Color neutral300 = Color(0xFFD4D4D8);
  static const Color neutral400 = Color(0xFFA1A1AA);
  static const Color neutral500 = Color(0xFF71717A);
  static const Color neutral600 = Color(0xFF52525B);
  static const Color neutral700 = Color(0xFF3F3F46);
  static const Color neutral800 = Color(0xFF27272A);
  static const Color neutral900 = Color(0xFF18181B);
  static const Color neutral950 = Color(0xFF09090B);

  // ==========================================================================
  //  4) التدرجات الجاهزة
  // ==========================================================================

  /// تدرج البانر الرئيسي: بنفسجي عميق → أزرق داكن (Hero Banner)
  static const List<Color> heroGradient = [
    Color(0xFF4C1D95), // بنفسجي عميق
    Color(0xFF1E3A8A), // أزرق داكن
    Color(0xFF09090B), // أسود
  ];

  /// تدرج بطاقات الكاتالوج في الوضع الفاتح
  static const List<Color> catalogCardGradientLight = [
    Color(0xFF6D28D9), // violet 700
    Color(0xFF4338CA), // indigo 700
  ];

  /// تدرج بطاقات الكاتالوج في الوضع الداكن — لا يُستخدم (flat surface)
  static const List<Color> catalogCardGradientDark = [
    Color(0xFF27272A),
    Color(0xFF18181B),
  ];

  // ==========================================================================
  //  5) ظلال جاهزة
  // ==========================================================================

  /// توهج البنفسجي (للأزرار والعناصر المميزة)
  static List<BoxShadow> violetGlow({double blur = 24, double alpha = 0.35}) {
    return [
      BoxShadow(
        color: _violet600.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: blur * 0.1,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// للتوافق مع الكود القديم الذي يستدعي neonGlow
  static List<BoxShadow> neonGlow({double blur = 24, double alpha = 0.35}) =>
      violetGlow(blur: blur, alpha: alpha);
}