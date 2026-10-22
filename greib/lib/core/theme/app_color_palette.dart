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
  final Color onMedia; // نص فوق الصور/الفيديو (طبقة معتمة خلفه)

  const AppTextColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.inverse,
    required this.onAccent,
    required this.disabled,
    required this.link,
    required this.onMedia,
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
    Color? onMedia,
  }) {
    return AppTextColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      inverse: inverse ?? this.inverse,
      onAccent: onAccent ?? this.onAccent,
      disabled: disabled ?? this.disabled,
      link: link ?? this.link,
      onMedia: onMedia ?? this.onMedia,
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
  final Color mediaScrim; // طبقة تعتيم فوق الصور/الفيديو

  const AppBackgroundColors({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.surfaceElevated,
    required this.overlay,
    required this.scrim,
    required this.accent,
    required this.outline,
    required this.mediaScrim,
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
    Color? mediaScrim,
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
      mediaScrim: mediaScrim ?? this.mediaScrim,
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
  // ألوان الحالة الدلالية — تُستخدم بدلاً من AppColors.static للسماح بالتغيير الديناميكي
  final Color success; // نجاح / تأكيد
  final Color warning; // تحذير / انتب
  final Color error; // خطأ / حذف
  final Color info; // معلومات عامة
  final Color onMedia; // أيقونة فوق الصور/الفيديو

  const AppIconColors({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.active,
    required this.inactive,
    required this.onAccent,
    required this.onBackground,
    required this.disabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.onMedia,
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
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? onMedia,
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
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      onMedia: onMedia ?? this.onMedia,
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
  //  درجات اللون الرسمي — تُشتق وقت التشغيل من [accent] الحالي.
  //  بهذه الطريقة يظل أي لون رسمي مختار من المستخدم قادراً على إنتاج
  //  تدرّجات وتوهّجات متناسقة (بدل ثوابت AppColors الثابتة).
  // --------------------------------------------------------------------------

  /// درجة أفتح من اللون الرسمي (توهّجات، تدرّجات، إبراز).
  Color get accentLight => _shiftLightness(accent, 0.18);

  /// درجة أغمق من اللونfficial تُقرأ على الخلفيات الفاتحة (نص/أيقونة).
  Color get accentDark => _shiftLightness(accent, -0.12);

  /// إزاحة الإضاءة بلون HSL مع الحفاظ على درجة اللون والتشبّع (طابع العلامة).
  static Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// نفس اللون بشفافية محدّدة — لبناء النصوص الثانوية والحدود من لون واحد.
  static Color _fade(Color color, double alpha) =>
      color.withValues(alpha: alpha);

  /// لون مقروء فوق [color] (أبيض أو أسود) حسب سطوعه — لضمان قراءة النص.
  static Color _readableOn(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : const Color(0xFF0B0D0B);

  /// ★ نسبة التباين (WCAG) بين لونين — تُستخدم للتحذير إذا صار النص غير مقروء
  ///   على الخلفية المختارة (الحدّ الموصى به للنص العادي: 4.5).
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// التمثيل السداسي للون (بلا شفافية) — لعرضه في واجهة التخصيص.
  static String hexOf(Color color) => '#${[
        (color.r * 255).round(),
        (color.g * 255).round(),
        (color.b * 255).round(),
      ].map((v) => v.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  /// اللون الأكثر تبايناً مع [background] (أبيض أو أسود ناعم) — للتصحيح التلقائي.
  static Color bestTextOn(Color background) =>
      contrastRatio(Colors.white, background) >=
              contrastRatio(const Color(0xFF0B0D0B), background)
          ? Colors.white
          : const Color(0xFF0B0D0B);

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
        onMedia: AppColors.neutral50,
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
        mediaScrim: AppColors.neutral950,
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
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
        info: AppColors.info,
        onMedia: AppColors.neutral50,
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
        onMedia: AppColors.neutral50,
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
        mediaScrim: AppColors.neutral900,
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
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
        info: AppColors.info,
        onMedia: AppColors.neutral50,
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  ★ الاشتقاق التلقائي — لوحة كاملة متماسكة من ثلاثة قرارات فقط
  // --------------------------------------------------------------------------

  /// يبني لوحة كاملة من: [background] (الخلفية الأساسية) + [text] (النص
  /// الأساسي) + [accent] (اللون الرسمي)، ويشتق آلياً بقية الحقول:
  ///   • الطبقات (secondary/surface/surfaceElevated/overlay) ← إزاحة إضاءة الخلفية
  ///   • الحدود ← النص الأساسي بشفافية خفيفة (تعمل في الوضعين)
  ///   • النصوص الثانوية/الباهتة/المعطّلة ← النص الأساسي بشفافيات متدرّجة
  ///   • الأيقونات ← اللون الرسمي + النص الأساسي
  ///   ⇒ المستخدم يعدّل 3 قرارات بدل 30+ حقلاً، والنتيجة متماسكة دائماً.
  factory AppColorPalette.deriveFrom({
    required Color background,
    required Color text,
    required Color accent,
    required bool isDark,
  }) {
    // اللون الرسمي المقروء على الخلفية الفاتحة يُغمَّق قليلاً.
    final accentForIcons = isDark ? accent : _shiftLightness(accent, -0.12);
    final onAccent = _readableOn(accent);

    return AppColorPalette(
      accent: accent,
      isDark: isDark,
      text: AppTextColors(
        primary: text,
        secondary: _fade(text, 0.72),
        tertiary: _fade(text, 0.50),
        inverse: background,
        onAccent: onAccent,
        disabled: _fade(text, 0.35),
        link: _shiftLightness(accent, isDark ? 0.18 : -0.12),
        onMedia: Colors.white,
      ),
      background: AppBackgroundColors(
        primary: background,
        secondary: _shiftLightness(background, 0.03),
        surface: _shiftLightness(background, 0.06),
        surfaceElevated: _shiftLightness(background, 0.11),
        overlay: _shiftLightness(background, 0.11),
        scrim: _shiftLightness(background, -0.05),
        accent: accent,
        outline: _fade(text, 0.12),
        mediaScrim: _fade(Colors.black, 0.55),
      ),
      icon: AppIconColors(
        primary: accentForIcons,
        active: accentForIcons,
        secondary: _fade(text, 0.72),
        muted: _fade(text, 0.45),
        inactive: _fade(text, 0.50),
        onBackground: text,
        onAccent: onAccent,
        disabled: _fade(text, 0.30),
        onMedia: Colors.white,
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
        info: AppColors.info,
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
    final accentForIcons = isDark ? accent : _shiftLightness(accent, -0.12);
    final onAccent = _readableOn(accent);
    return copyWith(
      accent: accent,
      background: background.copyWith(accent: accent),
      icon: icon.copyWith(
        primary: accentForIcons,
        active: accentForIcons,
        onAccent: onAccent,
      ),
      text: text.copyWith(
        onAccent: onAccent,
        link: _shiftLightness(accent, isDark ? 0.18 : -0.12),
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  الوصول الموحّد بالمفتاح — عقد واحد بين الواجهة والمتحكم والتخزين
  // --------------------------------------------------------------------------

  /// يقرأ لون أي حقل عبر مفتاحه من [PaletteFieldKeys].
  /// ★ واجهة التخصيص لا تحتاج `switch` خاصاً بها ⇒ مصدر واحد للحقيقة.
  Color colorFor(String field) {
    switch (field) {
      case PaletteFieldKeys.accent:
        return accent;

      case PaletteFieldKeys.backgroundPrimary:
        return background.primary;
      case PaletteFieldKeys.backgroundSecondary:
        return background.secondary;
      case PaletteFieldKeys.backgroundSurface:
        return background.surface;
      case PaletteFieldKeys.backgroundSurfaceElevated:
        return background.surfaceElevated;
      case PaletteFieldKeys.backgroundOverlay:
        return background.overlay;
      case PaletteFieldKeys.backgroundOutline:
        return background.outline;
      case PaletteFieldKeys.backgroundScrim:
        return background.scrim;
      case PaletteFieldKeys.backgroundMediaScrim:
        return background.mediaScrim;

      case PaletteFieldKeys.textPrimary:
        return text.primary;
      case PaletteFieldKeys.textSecondary:
        return text.secondary;
      case PaletteFieldKeys.textTertiary:
        return text.tertiary;
      case PaletteFieldKeys.textInverse:
        return text.inverse;
      case PaletteFieldKeys.textOnAccent:
        return text.onAccent;
      case PaletteFieldKeys.textLink:
        return text.link;
      case PaletteFieldKeys.textDisabled:
        return text.disabled;
      case PaletteFieldKeys.textOnMedia:
        return text.onMedia;

      case PaletteFieldKeys.iconPrimary:
        return icon.primary;
      case PaletteFieldKeys.iconActive:
        return icon.active;
      case PaletteFieldKeys.iconSecondary:
        return icon.secondary;
      case PaletteFieldKeys.iconMuted:
        return icon.muted;
      case PaletteFieldKeys.iconInactive:
        return icon.inactive;
      case PaletteFieldKeys.iconOnBackground:
        return icon.onBackground;
      case PaletteFieldKeys.iconOnAccent:
        return icon.onAccent;
      case PaletteFieldKeys.iconDisabled:
        return icon.disabled;
      case PaletteFieldKeys.iconOnMedia:
        return icon.onMedia;
      case PaletteFieldKeys.iconSuccess:
        return icon.success;
      case PaletteFieldKeys.iconWarning:
        return icon.warning;
      case PaletteFieldKeys.iconError:
        return icon.error;
      case PaletteFieldKeys.iconInfo:
        return icon.info;

      default:
        return accent;
    }
  }

  /// نسخة جديدة مع تعديل حقل واحد عبر مفتاحه.
  /// ★ تعديل [PaletteFieldKeys.accent] يمرّ عبر [withAccent] فيبقى المشتق
  ///   (الأيقونات/الرابط/الخلفية الملوّنة/نص فوق اللون الرسمي) متماسكاً.
  AppColorPalette withField(String field, Color color) {
    if (field == PaletteFieldKeys.accent) return withAccent(color);

    switch (field) {
      case PaletteFieldKeys.backgroundPrimary:
        return copyWith(background: background.copyWith(primary: color));
      case PaletteFieldKeys.backgroundSecondary:
        return copyWith(background: background.copyWith(secondary: color));
      case PaletteFieldKeys.backgroundSurface:
        return copyWith(background: background.copyWith(surface: color));
      case PaletteFieldKeys.backgroundSurfaceElevated:
        return copyWith(background: background.copyWith(surfaceElevated: color));
      case PaletteFieldKeys.backgroundOverlay:
        return copyWith(background: background.copyWith(overlay: color));
      case PaletteFieldKeys.backgroundOutline:
        return copyWith(background: background.copyWith(outline: color));
      case PaletteFieldKeys.backgroundScrim:
        return copyWith(background: background.copyWith(scrim: color));
      case PaletteFieldKeys.backgroundMediaScrim:
        return copyWith(background: background.copyWith(mediaScrim: color));

      case PaletteFieldKeys.textPrimary:
        return copyWith(text: text.copyWith(primary: color));
      case PaletteFieldKeys.textSecondary:
        return copyWith(text: text.copyWith(secondary: color));
      case PaletteFieldKeys.textTertiary:
        return copyWith(text: text.copyWith(tertiary: color));
      case PaletteFieldKeys.textInverse:
        return copyWith(text: text.copyWith(inverse: color));
      case PaletteFieldKeys.textOnAccent:
        return copyWith(text: text.copyWith(onAccent: color));
      case PaletteFieldKeys.textLink:
        return copyWith(text: text.copyWith(link: color));
      case PaletteFieldKeys.textDisabled:
        return copyWith(text: text.copyWith(disabled: color));
      case PaletteFieldKeys.textOnMedia:
        return copyWith(text: text.copyWith(onMedia: color));

      case PaletteFieldKeys.iconPrimary:
        return copyWith(icon: icon.copyWith(primary: color));
      case PaletteFieldKeys.iconActive:
        return copyWith(icon: icon.copyWith(active: color));
      case PaletteFieldKeys.iconSecondary:
        return copyWith(icon: icon.copyWith(secondary: color));
      case PaletteFieldKeys.iconMuted:
        return copyWith(icon: icon.copyWith(muted: color));
      case PaletteFieldKeys.iconInactive:
        return copyWith(icon: icon.copyWith(inactive: color));
      case PaletteFieldKeys.iconOnBackground:
        return copyWith(icon: icon.copyWith(onBackground: color));
      case PaletteFieldKeys.iconOnAccent:
        return copyWith(icon: icon.copyWith(onAccent: color));
      case PaletteFieldKeys.iconDisabled:
        return copyWith(icon: icon.copyWith(disabled: color));
      case PaletteFieldKeys.iconOnMedia:
        return copyWith(icon: icon.copyWith(onMedia: color));
      case PaletteFieldKeys.iconSuccess:
        return copyWith(icon: icon.copyWith(success: color));
      case PaletteFieldKeys.iconWarning:
        return copyWith(icon: icon.copyWith(warning: color));
      case PaletteFieldKeys.iconError:
        return copyWith(icon: icon.copyWith(error: color));
      case PaletteFieldKeys.iconInfo:
        return copyWith(icon: icon.copyWith(info: color));

      default:
        return this;
    }
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
      onMedia: Color.lerp(a.onMedia, b.onMedia, t)!,
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
      mediaScrim: Color.lerp(a.mediaScrim, b.mediaScrim, t)!,
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
      success: Color.lerp(a.success, b.success, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      info: Color.lerp(a.info, b.info, t)!,
      onMedia: Color.lerp(a.onMedia, b.onMedia, t)!,
    );
  }
}

/// ---------------------------------------------------------------------------
///  مفاتيح حقول اللوحة القابلة للتخصيص (صفحة «التحكم في الألوان»)
/// ---------------------------------------------------------------------------
///  ★ عقد مشترك بين: شاشة التخصيص (كتابة/حفظ) و[ColorPaletteController.withStored]
///    (استعادة عند الإقلاع) ⇒ أي تغيير في المفاتيح يظهر في المكانين معاً.
///  ★ الترتيب هنا هو ترتيب العرض في واجهة التخصيص (أساس ⇒ طبقات ⇒ حالات)،
///    والقوائم في نهاية الفئة تُغذّي الواجهة مباشرةً بلا تكرار.
class PaletteFieldKeys {
  PaletteFieldKeys._();

  // ------------------------------- اللون الرسمي -------------------------------
  static const String accent = 'accent';

  // --------------------------- الخلفيات والطبقات ---------------------------
  static const String backgroundPrimary = 'background.primary';
  static const String backgroundSecondary = 'background.secondary';
  static const String backgroundSurface = 'background.surface';
  static const String backgroundSurfaceElevated = 'background.surfaceElevated';
  static const String backgroundOverlay = 'background.overlay';
  static const String backgroundOutline = 'background.outline';
  static const String backgroundScrim = 'background.scrim';
  static const String backgroundMediaScrim = 'background.mediaScrim';

  // --------------------------------- النصوص ---------------------------------
  static const String textPrimary = 'text.primary';
  static const String textSecondary = 'text.secondary';
  static const String textTertiary = 'text.tertiary';
  static const String textInverse = 'text.inverse';
  static const String textOnAccent = 'text.onAccent';
  static const String textLink = 'text.link';
  static const String textDisabled = 'text.disabled';
  static const String textOnMedia = 'text.onMedia';

  // -------------------------------- الأيقونات --------------------------------
  static const String iconPrimary = 'icon.primary';
  static const String iconActive = 'icon.active';
  static const String iconSecondary = 'icon.secondary';
  static const String iconMuted = 'icon.muted';
  static const String iconInactive = 'icon.inactive';
  static const String iconOnBackground = 'icon.onBackground';
  static const String iconOnAccent = 'icon.onAccent';
  static const String iconDisabled = 'icon.disabled';
  static const String iconOnMedia = 'icon.onMedia';

  // ---------------------------- ألوان الحالات (متقدّم) ----------------------------
  static const String iconSuccess = 'icon.success';
  static const String iconWarning = 'icon.warning';
  static const String iconError = 'icon.error';
  static const String iconInfo = 'icon.info';

  // ==========================================================================
  //  قوائم مجمّعة — تُستخدم في واجهة التخصيص والاشتقاق
  // ==========================================================================

  /// ★ القرارات الثلاثة الأساسية — بقية الحقول تُشتق منها تلقائياً.
  static const List<String> baseFields = [
    backgroundPrimary,
    textPrimary,
    accent,
  ];

  /// كل حقول الخلفيات والطبقات (بالترتيب المعروض).
  static const List<String> backgroundFields = [
    backgroundPrimary,
    backgroundSecondary,
    backgroundSurface,
    backgroundSurfaceElevated,
    backgroundOverlay,
    backgroundOutline,
    backgroundScrim,
    backgroundMediaScrim,
  ];

  /// كل حقول النصوص (بالترتيب المعروض).
  static const List<String> textFields = [
    textPrimary,
    textSecondary,
    textTertiary,
    textInverse,
    textOnAccent,
    textLink,
    textDisabled,
    textOnMedia,
  ];

  /// كل حقول الأيقونات: الأساسية أولاً ثم الحالات.
  static const List<String> iconFields = [
    iconPrimary,
    iconActive,
    iconSecondary,
    iconMuted,
    iconInactive,
    iconOnBackground,
    iconOnAccent,
    iconDisabled,
    iconOnMedia,
    iconSuccess,
    iconWarning,
    iconError,
    iconInfo,
  ];

  /// حقول الحالات الدلالية وحدها (تُعرض تحت «تحكم متقدم»).
  static const List<String> stateFields = [
    iconSuccess,
    iconWarning,
    iconError,
    iconInfo,
  ];
}

