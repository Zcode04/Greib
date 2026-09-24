import 'package:flutter/material.dart';

/// ============================================================================
///  ملف الألوان الموحّد — المصدر الوحيد للحقيقة (Single Source of Truth)
/// ============================================================================
///
///  الهوية: Gray 900 + Ice Blue (#BEDBED)
///  خلفية رمادية داكنة (Gray 900 = #111827) مع لون رسمي أزرق جليدي فاتح
///  ← احترافي، عالمي، متماسك في كلا الوضعين
///
///  ★ لتغيير هوية التطبيق: عدّل القسم (Primitives) فقط.
/// ============================================================================

class AppColors {
  AppColors._();

  // ==========================================================================
  //  1) الألوان الأساسية (Primitives)
  // ==========================================================================

  // ---------- ⚫ سلّم الرمادي (Tailwind Gray) — أساس الخلفيات ----------
  static const Color _gray50  = Color(0xFFF9FAFB);
  static const Color _gray100 = Color(0xFFF3F4F6);
  static const Color _gray200 = Color(0xFFE5E7EB);
  static const Color _gray300 = Color(0xFFD1D5DB);
  static const Color _gray400 = Color(0xFF9CA3AF);
  static const Color _gray500 = Color(0xFF6B7280);
  static const Color _gray600 = Color(0xFF4B5563);
  static const Color _gray700 = Color(0xFF374151);
  static const Color _gray800 = Color(0xFF1F2937);
  static const Color _gray850 = Color(0xFF2B3544); // درجة وسيطة: gray-800 ⟶ gray-700
  static const Color _gray900 = Color(0xFF111827); // ★ لون الخلفية الرسمي (gray-900)
  static const Color _gray950 = Color(0xFF030712);

  // ---------- 🌙 الوضع الليلي (Dark Mode) — خلفية Gray 900 ----------
  static const Color _darkBg          = _gray900;  // #111827 — الخلفية الرسمية
  static const Color _darkSurface     = _gray800;  // كروت وبطاقات
  static const Color _darkElevated    = _gray850;  // طبقة أعمق (modals, inputs)
  static const Color _darkBorder      = _gray700;  // حدود دقيقة
  static const Color _darkTextPrimary = _gray50;   // نص أساسي أبيض ناعم
  static const Color _darkTextMuted   = _gray400;  // نص ثانوي رمادي

  // ---------- ☀️ الوضع النهاري (Light Mode) ----------
  static const Color _lightBg          = _gray100;            // خلفية فاتحة محايدة
  static const Color _lightSurface     = Color(0xFFFFFFFF);   // كروت بيضاء نظيفة
  static const Color _lightElevated    = _gray100;            // للـ inputs
  static const Color _lightBorder      = _gray200;            // حدود خفيفة
  static const Color _lightTextPrimary = _gray900;            // نص داكن
  static const Color _lightTextMuted   = _gray500;            // نص ثانوي

  // ---------- 🎨 اللون الرسمي (Brand) — Ice Blue #BEDBED ----------
  // اللون الرسمي للتطبيق: أزرق جليدي فاتح (rgb 190, 219, 237)
  static const Color _brand      = Color(0xFFBEDBED); // ★ اللون الرسمي
  static const Color _brandLight = Color(0xFFDFEDF6); // تدرّج أفتح (highlights / glows)
  static const Color _brandMid   = Color(0xFF5B93B4); // تدرّج أعمق (وسط التدرجات)
  static const Color _brandDark  = Color(0xFF2A6E98); // يُقرأ على خلفية فاتحة (نص/أيقونة)
  static const Color _brandDeep  = Color(0xFF1C4864); // حاوية داكنة (dark container)
  static const Color _onBrand    = _gray900;          // المحتوى فوق اللون الرسمي (نص/أيقونة)

  // ---------- 🟠 برتقالي التنبيهات (من نفس اللوحة المرجعية) ----------
  static const Color _accentOrange = Color(0xFFFF8A3D); // برتقالي دافئ — Badges / أزرار ثانوية

  // ---------- 🔴 الحالات (States) ----------
  static const Color _success = Color(0xFF22C55E); // أخضر
  static const Color _warning = Color(0xFFFF8A3D); // برتقالي دافئ (من اللوحة المرجعية)
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

  // --- اللون المميز الأساسي (اللون الرسمي للتطبيق) ---
  static const Color accentPrimary              = _brand;      // ★ #BEDBED — اللون الرسمي
  static const Color accentPrimaryLight         = _brandLight; // درجة أفتح (glows / highlights)
  static const Color accentPrimaryDark          = _brandDark;  // درجة داكنة تُقرأ على الخلفية الفاتحة
  static const Color accentPrimaryContainer     = _brandLight; // حاوية فاتحة (light container)
  static const Color accentPrimaryContainerDark = _brandDeep;  // حاوية داكنة (dark container)
  static const Color onAccentPrimary            = _onBrand;    // النص/الأيقونة فوق اللون الرسمي
  static const Color accentGlow                 = _brand;      // توهّج اللون الرسمي

  // --- اللون المميز الثانوي (برتقالي — Badges / تنبيهات / أزرار ثانوية) ---
  static const Color accentSecondary    = _accentOrange;

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
  static const Color textTertiary  = _gray500;

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
  static const Color lightTextTertiary   = _gray400;
  static const Color lightOutline        = _lightBorder;

  // ==========================================================================
  //  3) أسماء مختصرة للاستخدام السريع
  //     (مترادفات للأسماء الدلالية أعلاه)
  // ==========================================================================
  static const Color primary         = accentPrimary;   // ★ اللون الرسمي #BEDBED
  static const Color primaryLight    = accentPrimaryLight;
  static const Color primaryDark     = accentPrimaryDark;
  static const Color neon            = accentPrimary;    // للـ glows والتوهج (نفس اللون الرسمي)
  static const Color neonDark        = accentPrimaryDark;
  static const Color brand           = _brand;           // ★ اللون الرسمي (190, 219, 237)
  static const Color onBrand         = _onBrand;         // محتوى داكن فوق اللون الرسمي
  static const Color gray900         = _gray900;         // ★ لون الخلفية الرسمي
  static const Color background      = backgroundPrimary;
  static const Color surface         = surfaceCard;
  static const Color surfaceElevated = surfaceCardElevated;
  static const Color surfaceVariant  = surfaceOverlay;
  static const Color textMuted       = textTertiary;

  // للتوافق مع الكود القديم
  static const Color secondary          = _gray700;
  static const Color secondaryLight     = _gray400;
  static const Color secondaryDark      = _gray800;
  static const Color accent             = info;
  static const Color darkBackground     = backgroundPrimary;
  static const Color darkSurface        = surfaceCard;
  static const Color darkSurfaceVariant = surfaceOverlay;
  static const Color darkText           = textPrimary;
  static const Color darkTextSecondary  = textSecondary;
  static const Color darkTextTertiary   = textTertiary;
  static const Color darkOutline        = outline;

  // --- محايدات (Neutrals) — سلّم رمادي موحّد (Tailwind Gray) ---
  static const Color neutral50  = _gray50;
  static const Color neutral100 = _gray100;
  static const Color neutral200 = _gray200;
  static const Color neutral300 = _gray300;
  static const Color neutral400 = _gray400;
  static const Color neutral500 = _gray500;
  static const Color neutral600 = _gray600;
  static const Color neutral700 = _gray700;
  static const Color neutral800 = _gray800;
  static const Color neutral900 = _gray900;  // ★ خلفية التطبيق الرسمية
  static const Color neutral950 = _gray950;

  // ==========================================================================
  //  4) التدرجات الجاهزة
  // ==========================================================================

  /// تدرج البانر الرئيسي: اللون الرسمي → أزرق أعمق → خلفية Gray 900
  static const List<Color> heroGradient = [
    _brand,      // #BEDBED — اللون الرسمي
    _brandMid,   // أزرق أعمق
    _gray900,    // خلفية Gray 900
  ];

  /// تدرج الحلقة الدائرية (Dial) — اللون الرسمي → أزرق أعمق
  static const List<Color> dialGradient = [
    _brand,
    _brandMid,
  ];

  /// تدرج بطاقات الكاتالوج في الوضع الفاتح (نص أبيض فوقه)
  static const List<Color> catalogCardGradientLight = [
    _brandDark, // #2A6E98 — يُقرأ معه الأبيض
    _brandDeep, // #1C4864
  ];

  /// تدرج بطاقات الكاتالوج في الوضع الداكن — لا يُستخدم (flat surface)
  static const List<Color> catalogCardGradientDark = [
    _gray800,
    _gray900,
  ];

  // ==========================================================================
  //  5) ظلال جاهزة
  // ==========================================================================

  /// اللون الرسمي بدرجة مقروءة حسب الوضع:
  /// ليلي ⇒ اللون الرسمي #BEDBED، نهاري ⇒ الدرجة الداكنة #2A6E98.
  static Color accentFor(bool isDark) => isDark ? accentPrimary : accentPrimaryDark;

  /// توهّج اللون الرسمي (للأزرار والعناصر المميزة)
  static List<BoxShadow> brandGlow({double blur = 24, double alpha = 0.35}) {
    return [
      BoxShadow(
        color: _brand.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: blur * 0.1,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// للتوافق مع الكود القديم الذي يستدعي violetGlow
  static List<BoxShadow> violetGlow({double blur = 24, double alpha = 0.35}) =>
      brandGlow(blur: blur, alpha: alpha);

  /// للتوافق مع الكود القديم الذي يستدعي neonGlow
  static List<BoxShadow> neonGlow({double blur = 24, double alpha = 0.35}) =>
      brandGlow(blur: blur, alpha: alpha);
}