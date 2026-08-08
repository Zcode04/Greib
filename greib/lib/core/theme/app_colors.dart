import 'package:flutter/material.dart';

/// ============================================================================
///  ملف الألوان الموحّد — المصدر الوحيد للحقيقة (Single Source of Truth)
/// ============================================================================
///
///  ★ لتغيير هوية التطبيق كاملة: عدّل قسم "الألوان الأساسية" بالأسفل فقط (Primitives).
///    كل اسم آخر بالملف (والتطبيق كله) يشاور على هذي القيم، فما تحتاج تدور
///    على اللون بكل مكان — غيّره مرة وحدة وينتشر تلقائياً.
///
///  الهوية الحالية: خلفية داكنة (أسود مائل للأخضر) + لون مميز أخضر نيون
///  (بنفس روح تطبيق Sneaker Shopping المرجعي).
/// ============================================================================

class AppColors {
  AppColors._();

  // ==========================================================================
  //  1) الألوان الأساسية (Primitives)
  //     ↓↓↓ منطقتين تحكم منفصلتين: وحدة للوضع الليلي، ووحدة للوضع النهاري ↓↓↓
  //     عدّل داخل وحدة واحدة فقط = يتغيّر وضعها بس، ما يأثر على الوضع الثاني
  // ==========================================================================

  // ---------- 🌙 تحكم الوضع الليلي (Dark Mode) — كل شي هنا خاص بالداكن فقط ----------
  static const Color _inkDark      = Color.fromARGB(255, 1, 1, 11); // خلفية الوضع الليلي (أسود مائل للأخضر الداكن جداً)
  static const Color _inkMid       = Color.fromARGB(255, 30, 28, 42); // سطح الوضع الليلي (كروت، بطاقات)
  static const Color _inkLight     = Color.fromARGB(255, 24, 24, 31); // سطح مرتفع بالوضع الليلي (حدود، طبقات فوقية)
  static const Color _textOnDark      = Color.fromARGB(255, 255, 255, 255); // نص أساسي بالوضع الليلي
  static const Color _textOnDarkMuted = Color(0xFFA1A1AA); // نص ثانوي بالوضع الليلي
  // ------------------------------------------------------------------------------

  // ---------- ☀️ تحكم الوضع النهاري (Light Mode) — كل شي هنا خاص بالفاتح فقط ----------
  static const Color _lightBg      = Color.fromARGB(255, 236, 236, 235); // خلفية الوضع النهاري (الأساسية)
  static const Color _lightSurface = Color.fromARGB(255, 195, 184, 184); // سطح الوضع النهاري (كروت، بطاقات)
  static const Color _textOnLight      = Color(0xFF0A090C); // نص أساسي بالوضع النهاري
  static const Color _textOnLightMuted = Color(0xFF6B6B70); // نص ثانوي بالوضع النهاري
  // -------------------------------------------------------------------------------

  // ---------- 🎨 مشترك بين الوضعين (اللون المميز يبقى نفسه ليلاً ونهاراً) ----------
  // أخضر نيون فسفوري (Volt Green) — نفس اللون المميز في صورة Sneaker Shopping App
  static const Color _gold     = Color(0xFFCCFF00); // الأخضر النيون - اللون المميز للهوية
  static const Color _goldSoft = Color(0xFFE3FF7A); // نسخة أفتح منه (توهج/خلفيات ثانوية)
  // -------------------------------------------------------------------------------

  // ألوان الخدمات الست — نفسها بالوضعين، لأنها هوية كل خدمة مش متعلقة بالثيم
  static const Color _svcFood      = _gold;
  static const Color _svcPharmacy  = Color(0xFF60A5FA);
  static const Color _svcCourier   = Color(0xFFA78BFA);
  static const Color _svcRide      = Color(0xFFFBBF24);
  static const Color _svcShopping  = Color(0xFFF472B6);
  static const Color _svcTourism   = Color(0xFF2DD4BF);

  static const Color _success = _gold;
  static const Color _warning = Color(0xFFFBBF24);
  static const Color _error   = Color(0xFFF87171);
  static const Color _info    = Color(0xFF60A5FA);

  // ==========================================================================
  //  2) الأسماء الدلالية (Semantic) — لا تعدّل هنا، كلها تشاور على القسم أعلاه
  // ==========================================================================

  // خلفيات وأسطح (Dark - الوضع الافتراضي)
  static const Color backgroundPrimary   = Color.fromARGB(255, 6, 31, 122);
  static const Color backgroundSecondary = Color.fromARGB(255, 3, 47, 128);
  static const Color surfaceCard         = _inkMid;
  static const Color surfaceCardElevated = _inkLight;
  static const Color surfaceOverlay      = _inkLight;

  // اللون المميز الأساسي
  static const Color accentPrimary      = Color.fromARGB(255, 189, 191, 187);
  static const Color accentPrimaryDark  = _gold;
  static const Color accentPrimaryLight = _goldSoft;
  static const Color accentGlow         = _goldSoft;

  // ألوان الخدمات الست
  static const Color serviceFood      = _svcFood;
  static const Color servicePharmacy  = _svcPharmacy;
  static const Color serviceCourier   = _svcCourier;
  static const Color serviceRide      = _svcRide;
  static const Color serviceShopping  = _svcShopping;
  static const Color serviceTourism   = _svcTourism;

  // النصوص (Dark)
  static const Color textPrimary   = _textOnDark;
  static const Color textSecondary = _textOnDarkMuted;
  static const Color textTertiary  = Color(0xFF71717A);

  // الحدود
  static const Color outline      = _inkLight;
  static const Color outlineLight = _inkLight;

  // الحالات
  static const Color success = _success;
  static const Color warning = _warning;
  static const Color error   = _error;
  static const Color info    = _info;

  // الوضع الفاتح (ثانوي)
  static const Color lightBackground     = _lightBg;
  static const Color lightSurface        = _lightSurface;
  static const Color lightSurfaceVariant = Color(0xFFF0F4F0);
  static const Color lightText           = _textOnLight;
  static const Color lightTextSecondary  = _textOnLightMuted;
  static const Color lightTextTertiary   = Color(0xFF9A9A9E);
  static const Color lightOutline        = Color(0xFFD8DED8);

  // ألوان محايدة (Neutrals) — تدرّج رمادي فعلي، مو ألوان عشوائية
  static const Color neutral50  = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF4F4F5);
  static const Color neutral200 = Color(0xFFE4E4E7);
  static const Color neutral300 = Color(0xFFD4D4D8);
  static const Color neutral400 = Color(0xFFA1A1AA);
  static const Color neutral500 = Color(0xFF71717A);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // أسماء مستعارة مختصرة للاستخدام السريع
  static const Color primary         = accentPrimary;
  static const Color neon            = accentPrimary;
  static const Color neonDark        = accentPrimaryDark;
  static const Color background      = _inkDark;
  static const Color surface         = _inkLight;
  static const Color surfaceElevated = surfaceCardElevated;
  static const Color surfaceVariant  = surfaceOverlay;
  static const Color textMuted       = textTertiary;

  // أسماء متوافقة مع الإصدار السابق (لا تغيرها إلا عند إعادة التصميم)
  static const Color primaryLight   = Color.fromARGB(255, 156, 176, 174);
  static const Color primaryDark    = Color.fromARGB(255, 164, 215, 196);
  static const Color secondary      = neutral200;
  static const Color secondaryLight = neutral50;
  static const Color secondaryDark  = neutral300;
  static const Color accent         = info;
  static const Color darkBackground = _inkDark;
  static const Color darkSurface    = surfaceCard;
  static const Color darkSurfaceVariant = surfaceOverlay;
  static const Color darkText          = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextTertiary  = textTertiary;
  static const Color darkOutline       = outline;

  // تدرج البانر العلوي / الخلفية (Dark Green/Black Gradient)
  static const List<Color> heroGradient = [Color.fromARGB(255, 178, 115, 209), Color.fromARGB(255, 250, 223, 202), Color(0xFF1A2A1C)];

  static List<BoxShadow> neonGlow({double blur = 24, double alpha = 0.35}) {
    return [
      BoxShadow(
        color: const Color.fromARGB(255, 170, 200, 205).withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: 1,
        offset: const Offset(0, 8),
      ),
    ];
  }
}