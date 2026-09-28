import 'package:flutter/material.dart';

/// ============================================================================
///  ملف الألوان الموحّد — المصدر الوحيد للحقيقة (Single Source of Truth)
/// ============================================================================
///
///  الهوية: Slate 900 + Sapphire (#3B82F6)
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
  static const Color _slate50  = Color(0xFFF8FAFC);
  static const Color _slate100 = Color(0xFFF1F5F9);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate300 = Color(0xFFCBD5E1);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate600 = Color(0xFF475569);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slate800 = Color(0xFF1B2537); // سطح أساسي
  static const Color _slate850 = Color(0xFF141D2D); // درجة وسيطة: slate-800 ⟶ slate-700
  static const Color _slate900 = Color(0xFF0F172A); // ★ لون الخلفية الرسمي
  static const Color _slate950 = Color(0xFF070C17); // أعمق درجة

  // ---------- 🌙 الوضع الليلي (Dark Mode) — خلفية Slate 900 ----------
  // ★ تحسين: فصل واضح بين الخلفية والسطح (كانا متقاربين جداً سابقاً)
  static const Color _darkBg          = _slate900;  // #0F172A — الخلفية الرسمية
  static const Color _darkSurface     = _slate800;  // كروت وبطاقات
  static const Color _darkElevated    = _slate850;  // طبقة أعمق (modals, inputs)
  static const Color _darkBorder      = _slate700;  // حدود دقيقة
  static const Color _darkTextPrimary = _slate50;   // نص أساسي أبيض ناعم
  static const Color _darkTextMuted   = _slate400;  // نص ثانوي رمادي

  // ---------- ☀️ الوضع النهاري (Light Mode) ----------
  static const Color _lightBg          = _slate100;           // خلفية فاتحة محايدة
  static const Color _lightSurface     = Color(0xFFFFFFFF);   // كروت بيضاء نظيفة
  static const Color _lightElevated    = _slate50;            // للـ inputs
  static const Color _lightBorder      = _slate200;           // حدود خفيفة
  static const Color _lightTextPrimary = _slate900;           // نص داكن
  static const Color _lightTextMuted   = _slate500;           // نص ثانوي

  // ---------- 🎨 اللون الرسمي (Brand) — Sapphire #3B82F6 ----------
  // ★ ترقية: من Ice Blue باهت (#BEDBED) إلى أزرق باكن مشبع — هوية أقوى + توهّج صحيح
  static const Color _brand      = Color(0xFF3B82F6); // ★ اللون الرسمي
  static const Color _brandLight = Color(0xFF93C5FD); // تدرّج أفتح (highlights / glows)
  static const Color _brandMid   = Color(0xFF2563EB); // تدرّج أعمق (وسط التدرجات)
  static const Color _brandDark  = Color(0xFF1D4ED8); // يُقرأ على خلفية فاتحة (نص/أيقونة)
  static const Color _brandDeep  = Color(0xFF1E3A8A); // حاوية داكنة (dark container)
  static const Color _onBrand    = Color(0xFFFFFFFF); // محتوى فوق اللون الرسمي (أبيض)

  // ---------- 🟠 برتقالي التنبيهات (كهرماني دافئ) ----------
  static const Color _accentOrange = Color(0xFFF59E0B); // كهرماني — Badges / أزرار ثانوية

  // ---------- 🔴 الحالات (States) ----------
  static const Color _success = Color(0xFF10B981); // أخضر زمردي (متناسق مع أزرق البريق)
  static const Color _warning = Color(0xFFF59E0B); // كهرماني
  static const Color _error   = Color(0xFFEF4444); // أحمر
  static const Color _info    = Color(0xFF38BDF8); // سماوي

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
  static const Color accentPrimary              = _brand;      // ★ #3B82F6 — اللون الرسمي
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
  static const Color textTertiary  = _slate500;

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
  static const Color lightTextTertiary   = _slate400;
  static const Color lightOutline        = _lightBorder;

  // ==========================================================================
  //  3) أسماء مختصرة للاستخدام السريع
  //     (مترادفات للأسماء الدلالية أعلاه)
  // ==========================================================================
  static const Color primary         = accentPrimary;   // ★ اللون الرسمي #3B82F6
  static const Color primaryLight    = accentPrimaryLight;
  static const Color primaryDark     = accentPrimaryDark;
  static const Color neon            = accentPrimary;    // للـ glows والتوهج (نفس اللون الرسمي)
  static const Color neonDark        = accentPrimaryDark;
  static const Color brand           = _brand;           // ★ اللون الرسمي (190, 219, 237)
  static const Color onBrand         = _onBrand;         // محتوى داكن فوق اللون الرسمي
  static const Color gray900         = _slate900;         // ★ لون الخلفية الرسمي
  static const Color background      = backgroundPrimary;
  static const Color surface         = surfaceCard;
  static const Color surfaceElevated = surfaceCardElevated;
  static const Color surfaceVariant  = surfaceOverlay;
  static const Color textMuted       = textTertiary;

  // للتوافق مع الكود القديم
  static const Color secondary          = _slate700;
  static const Color secondaryLight     = _slate400;
  static const Color secondaryDark      = _slate800;
  static const Color accent             = info;
  static const Color darkBackground     = backgroundPrimary;
  static const Color darkSurface        = surfaceCard;
  static const Color darkSurfaceVariant = surfaceOverlay;
  static const Color darkText           = textPrimary;
  static const Color darkTextSecondary  = textSecondary;
  static const Color darkTextTertiary   = textTertiary;
  static const Color darkOutline        = outline;

  // --- محايدات (Neutrals) — سلّم رمادي موحّد (Tailwind Gray) ---
  static const Color neutral50  = _slate50;
  static const Color neutral100 = _slate100;
  static const Color neutral200 = _slate200;
  static const Color neutral300 = _slate300;
  static const Color neutral400 = _slate400;
  static const Color neutral500 = _slate500;
  static const Color neutral600 = _slate600;
  static const Color neutral700 = _slate700;
  static const Color neutral800 = _slate800;
  static const Color neutral900 = _slate900;  // ★ خلفية التطبيق الرسمية
  static const Color neutral950 = _slate950;

  // ==========================================================================
  //  4) التدرجات الجاهزة
  // ==========================================================================

  /// تدرج البانر الرئيسي: اللون الرسمي → أزرق أعمق → خلفية Slate 900
  static const List<Color> heroGradient = [
    _brandLight, // #93C5FD — تدرّج أفتح (تباين أفضل مع النص فوقه)
    _brand,      // #3B82F6 — اللون الرسمي
    _slate900,   // خلفية Slate 900
  ];

  /// تدرج الحلقة الدائرية (Dial) — اللون الرسمي → أزرق أعمق
  static const List<Color> dialGradient = [
    _brand,
    _brandMid,
  ];

  /// تدرج بطاقات الكاتالوج في الوضع الفاتح (نص أبيض فوقه)
  static const List<Color> catalogCardGradientLight = [
    _brandDark, // #1D4ED8 — يُقرأ معه الأبيض
    _brandDeep, // #1E3A8A
  ];

  /// تدرج بطاقات الكاتالوج في الوضع الداكن — لا يُستخدم (flat surface)
  static const List<Color> catalogCardGradientDark = [
    _slate800,
    _slate900,
  ];

  // ==========================================================================
  //  5) ظلال جاهزة
  // ==========================================================================

  /// اللون الرسمي بدرجة مقروءة حسب الوضع:
  /// ليلي ⇒ اللون الرسمي #3B82F6، نهاري ⇒ الدرجة الداكنة #1D4ED8.
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