import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ============================================================================
///  لوحة الألوان المركزية — Color Palette / Theme Configuration
/// ============================================================================
///
///  ★ المصدر المهيكل والموحّد لكل ألوان التطبيق، مقسّم إلى ثلاث فئات واضحة:
///      1) [AppTextColors]       — ألوان النصوص
///      2) [AppBackgroundColors] — ألوان الخلفيات والأسطح
///      3) [AppIconColors]       — ألوان الأيقونات
///
///  ◆ الهدف: هيكل نظيف وجاهز للربط بنظام تخصيص ديناميكي يسمح بتغيير أي لون
///    وسريان التعديل فوراً على مستوى التطبيق بالكامل (كل الصفحات والمكونات).
///
///  ◆ كيف يسري التغيير فوراً؟
///    - [AppColorPalette] تُسجَّل كـ [ThemeExtension] داخل [ThemeData].
///    - عند تغيير لون عبر [ColorPaletteController] يُعاد بناء [MaterialApp]
///      بثيم جديد ⇒ كل من يقرأ عبر `context.palette` (أو `Theme.of(context)`)
///      يتحدّث لحظياً دون أي ربط يدوي لكل شاشة.
///
///  ◆ القراءة من أي مكان:
///      context.textColors.primary       // لون نص أساسي
///      context.backgroundColors.surface // لون سطح
///      context.iconColors.active        // لون أيقونة نشِطة
///      context.palette.accent           // اللون الرسمي
///
///  القيم الافتراضية مشتقة من [AppColors] (مصدر الحقيقة الحالي) لضمان توافق
///  الهوية البصرية بالكامل دون أي كسر.
/// ============================================================================

/// ---------------------------------------------------------------------------
///  ألوان النصوص (Text Colors)
/// ---------------------------------------------------------------------------
@immutable
class AppTextColors {
  final Color primary; // نص أساسي (عناوين، محتوى رئيسي)
  final Color secondary; // نص ثانوي (أوصاف، تفاصيل)
  final Color tertiary; // نص باهت (تلميحات، نصوص معطّلة ظاهرياً)
  final Color inverse; // نص معكوس (فوق خلفية معتمة / ملطخة باللون الرسمي)
  final Color onAccent; // نص فوق اللون الرسمي (أزرار ملوّنة، شارات)
  final Color disabled; // نص معطّل
  final Color link; // نص روابط / إجراءات

  const AppTextColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.inverse,
    required this.onAccent,
    required this.disabled,
    required this.link,
  });

  /// إرجاع نسخة مع تعديل حقول محدّدة (يُستخدم في نظام التخصيص الديناميكي).
  AppTextColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? inverse,
    Color? onAccent,
    Color? disabled,
    Color? link,
  }) {
    return AppTextColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      inverse: inverse ?? this.inverse,
      onAccent: onAccent ?? this.onAccent,
      disabled: disabled ?? this.disabled,
      link: link ?? this.link,
    );
  }
}

/// ---------------------------------------------------------------------------
///  ألوان الخلفيات (Background Colors)
/// ---------------------------------------------------------------------------
@immutable
class AppBackgroundColors {
  final Color primary; // خلفية الشاشة الرئيسية
  final Color secondary; // خلفية ثانوية (تجميعات، تبويبات)
  final Color surface; // سطح الكروت/البطاقات
  final Color surfaceElevated; // سطح مرتفع (modals, inputs, sheets)
  final Color overlay; // طبقة فوقية (overlay / حاجب)
  final Color scrim; // حاجب تعتيم (خلف الحوارات)
  final Color accent; // خلفية ملوّنة باللون الرسمي
  final Color outline; // حدود/فواصل دقيقة

  const AppBackgroundColors({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.surfaceElevated,
    required this.overlay,
    required this.scrim,
    required this.accent,
    required this.outline,
  });

  AppBackgroundColors copyWith({
    Color? primary,
    Color? secondary,
    Color? surface,
    Color? surfaceElevated,
    Color? overlay,
    Color? scrim,
    Color? accent,
    Color? outline,
  }) {
    return AppBackgroundColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      overlay: overlay ?? this.overlay,
      scrim: scrim ?? this.scrim,
      accent: accent ?? this.accent,
      outline: outline ?? this.outline,
    );
  }
}

/// ---------------------------------------------------------------------------
///  ألوان الأيقونات (Icon Colors)
/// ---------------------------------------------------------------------------
@immutable
class AppIconColors {
  final Color primary; // أيقونة أساسية / بارزة
  final Color secondary; // أيقونة ثانوية
  final Color muted; // أيقونة باهتة / غير مفعّلة بصرياً
  final Color active; // أيقونة نشِطة (تبويب/حالة مختارة)
  final Color inactive; // أيقونة غير نشِطة
  final Color onAccent; // أيقونة فوق اللون الرسمي
  final Color onBackground; // أيقونة فوق خلفية (تكيّف مع الوضع)
  final Color disabled; // أيقونة معطّلة

  const AppIconColors({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.active,
    required this.inactive,
    required this.onAccent,
    required this.onBackground,
    required this.disabled,
  });

  AppIconColors copyWith({
    Color? primary,
    Color? secondary,
    Color? muted,
    Color? active,
    Color? inactive,
    Color? onAccent,
    Color? onBackground,
    Color? disabled,
  }) {
    return AppIconColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      muted: muted ?? this.muted,
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      onAccent: onAccent ?? this.onAccent,
      onBackground: onBackground ?? this.onBackground,
      disabled: disabled ?? this.disabled,
    );
  }
}

/// ---------------------------------------------------------------------------
///  اللوحة المجمّعة — تُسجَّل كـ ThemeExtension ليقرأها أي مكوّن عبر Theme.of
/// ---------------------------------------------------------------------------
class AppColorPalette extends ThemeExtension<AppColorPalette> {
  final AppTextColors text;
  final AppBackgroundColors background;
  final AppIconColors icon;

  /// اللون الرسمي (Brand) — يُغذّي ColorScheme.primary (أزرار، تبويبات، …).
  final Color accent;

  /// هل هذه لوحة الوضع الداكن؟ (يُستخدم في انتقالات الثيم والمنطق الشرطي).
  final bool isDark;

  const AppColorPalette({
    required this.text,
    required this.background,
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  // --------------------------------------------------------------------------
  //  اللوحات الافتراضية (مشتقة من AppColors — توافق هوية بصري كامل)
  // --------------------------------------------------------------------------

  /// لوحة الوضع الداكن (الافتراضية في التطبيق).
  factory AppColorPalette.dark({Color? accent}) {
    final brand = accent ?? AppColors.accentPrimary;
    return AppColorPalette(
      accent: brand,
      isDark: true,
      text: AppTextColors(
        primary: AppColors.textPrimary,
        secondary: AppColors.textSecondary,
        tertiary: AppColors.textTertiary,
        inverse: AppColors.neutral50,
        onAccent: AppColors.onAccentPrimary,
        disabled: AppColors.neutral500,
        link: AppColors.accentPrimaryLight,
      ),
      background: AppBackgroundColors(
        primary: AppColors.backgroundPrimary,
        secondary: AppColors.backgroundSecondary,
        surface: AppColors.surfaceCard,
        surfaceElevated: AppColors.surfaceCardElevated,
        overlay: AppColors.surfaceOverlay,
        scrim: AppColors.neutral950,
        accent: brand,
        outline: AppColors.outline,
      ),
      icon: AppIconColors(
        primary: brand,
        secondary: AppColors.textSecondary,
        muted: AppColors.textTertiary,
        active: brand,
        inactive: AppColors.textTertiary,
        onAccent: AppColors.onAccentPrimary,
        onBackground: AppColors.textPrimary,
        disabled: AppColors.neutral500,
      ),
    );
  }


  /// لوحة الوضع النهاري.
  factory AppColorPalette.light({Color? accent}) {
    final brand = accent ?? AppColors.accentPrimary;
    return AppColorPalette(
      accent: brand,
      isDark: false,
      text: AppTextColors(
        primary: AppColors.lightText,
        secondary: AppColors.lightTextSecondary,
        tertiary: AppColors.lightTextTertiary,
        inverse: AppColors.neutral900,
        onAccent: AppColors.onAccentPrimary,
        disabled: AppColors.neutral400,
        link: AppColors.accentPrimaryDark,
      ),
      background: AppBackgroundColors(
        primary: AppColors.lightBackground,
        secondary: AppColors.neutral100,
        surface: AppColors.lightSurface,
        surfaceElevated: AppColors.lightSurfaceVariant,
        overlay: AppColors.lightSurface,
        scrim: AppColors.neutral900,
        accent: brand,
        outline: AppColors.lightOutline,
      ),
      icon: AppIconColors(
        primary: AppColors.accentPrimaryDark,
        secondary: AppColors.lightTextSecondary,
        muted: AppColors.lightTextTertiary,
        active: AppColors.accentPrimaryDark,
        inactive: AppColors.lightTextSecondary,
        onAccent: AppColors.onAccentPrimary,
        onBackground: AppColors.lightText,
        disabled: AppColors.neutral400,
      ),
    );
  }


  // --------------------------------------------------------------------------
  //  أدوات التعديل الديناميكي
  // --------------------------------------------------------------------------

  /// نسخة جديدة مع تعديل فئات/حقول محدّدة (يُستخدم في ColorPaletteController).
  @override
  AppColorPalette copyWith({
    AppTextColors? text,
    AppBackgroundColors? background,
    AppIconColors? icon,
    Color? accent,
    bool? isDark,
  }) {
    return AppColorPalette(
      text: text ?? this.text,
      background: background ?? this.background,
      icon: icon ?? this.icon,
      accent: accent ?? this.accent,
      isDark: isDark ?? this.isDark,
    );
  }

  /// يطبّق لوناً رسمياً (Brand) جديداً على كامل اللوحة بشكل متّسق.
  AppColorPalette withAccent(Color accent) {
    return copyWith(
      accent: accent,
      background: background.copyWith(accent: accent),
      icon: icon.copyWith(
        primary: isDark ? accent : AppColors.accentPrimaryDark,
        active: isDark ? accent : AppColors.accentPrimaryDark,
      ),
      text: text.copyWith(
        onAccent: AppColors.onAccentPrimary,
        link: isDark ? AppColors.accentPrimaryLight : AppColors.accentPrimaryDark,
      ),
    );
  }

  /// مزج سلس بين لوحتين — يُستخدم في انتقالات/أنيميشن الثيم.
  @override
  AppColorPalette lerp(covariant AppColorPalette? other, double t) {
    if (other == null) return this;
    return AppColorPalette(
      accent: Color.lerp(accent, other.accent, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
      text: _lerpText(text, other.text, t),
      background: _lerpBackground(background, other.background, t),
      icon: _lerpIcon(icon, other.icon, t),
    );
  }

  // --- مساعدات مزج داخلية (لا تُستخدم خارجياً) ---
  static AppTextColors _lerpText(AppTextColors a, AppTextColors b, double t) {
    return AppTextColors(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      tertiary: Color.lerp(a.tertiary, b.tertiary, t)!,
      inverse: Color.lerp(a.inverse, b.inverse, t)!,
      onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
      disabled: Color.lerp(a.disabled, b.disabled, t)!,
      link: Color.lerp(a.link, b.link, t)!,
    );
  }

  static AppBackgroundColors _lerpBackground(
      AppBackgroundColors a, AppBackgroundColors b, double t) {
    return AppBackgroundColors(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceElevated: Color.lerp(a.surfaceElevated, b.surfaceElevated, t)!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      scrim: Color.lerp(a.scrim, b.scrim, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      outline: Color.lerp(a.outline, b.outline, t)!,
    );
  }

  static AppIconColors _lerpIcon(AppIconColors a, AppIconColors b, double t) {
    return AppIconColors(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      active: Color.lerp(a.active, b.active, t)!,
      inactive: Color.lerp(a.inactive, b.inactive, t)!,
      onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
      onBackground: Color.lerp(a.onBackground, b.onBackground, t)!,
      disabled: Color.lerp(a.disabled, b.disabled, t)!,
    );
  }
}

/// ---------------------------------------------------------------------------
///  مفاتيح حقول اللوحة القابلة للتخصيص (صفحة «التحكم في الألوان»)
/// ---------------------------------------------------------------------------
///  ★ عقد مشترك بين: شاشة التخصيص (كتابة/حفظ) و[ColorPaletteController.withStored]
///    (استعادة عند الإقلاع) ⇒ أي تغيير في المفاتيح يظهر في المكانين معاً.
class PaletteFieldKeys {
  PaletteFieldKeys._();

  // الخلفيات
  static const String backgroundPrimary = 'background.primary';
  static const String backgroundSurface = 'background.surface';

  // النصوص
  static const String textPrimary = 'text.primary';
  static const String textSecondary = 'text.secondary';

  // الأيقونات
  static const String iconPrimary = 'icon.primary';
  static const String iconActive = 'icon.active';
}

