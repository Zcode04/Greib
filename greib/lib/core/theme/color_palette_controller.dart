import 'package:flutter/material.dart';

import '../storage/app_prefs.dart';
import 'app_color_palette.dart';

/// ============================================================================
///  ColorPaletteController — محرّك التخصيص الديناميكي للألوان
/// ============================================================================
///
///  ★ يربط لوحة الألوان ([AppColorPalette]) ببقية التطبيق بحيث يسري أي تغيير
///    **فوراً** على مستوى التطبيق بالكامل (كل الصفحات والمكونات).
///
///  ◆ آلية السريان:
///    1) هو `ChangeNotifier` ⇒ عند تغيير أي لون يستدعي [notifyListeners].
///    2) `MaterialApp` يستمع له (`context.watch`) ويعيد بناء الثيم باللوحة
///       الجديدة عبر [AppTheme.applyPalette] ⇒ كل من يقرأ `Theme.of(context)`
///       أو `context.palette` يتحدّث لحظياً.
///
///  ◆ أمثلة الاستخدام (من أي مكان بالسياق):
///      `context.read<ColorPaletteController>().setAccent(Colors.teal);`
///      `context.read<ColorPaletteController>().updateTextPrimary(Colors.white);`
///      `context.read<ColorPaletteController>().resetAll();`
///
///  ◆ جاهزية للحفظ لاحقاً: يمكن ربط [AppColorPalette] بـ [AppPrefs] لتخزين
///    تخصيص المستخدم واسترجاعه عند إعادة التشغيل (بنية الملف تهيئة لذلك).
/// ============================================================================
class ColorPaletteController extends ChangeNotifier {
  AppColorPalette _dark;
  AppColorPalette _light;

  ColorPaletteController({
    AppColorPalette? dark,
    AppColorPalette? light,
  })  : _dark = dark ?? AppColorPalette.dark(),
        _light = light ?? AppColorPalette.light();

  /// ★ يبني المتحكم مع تطبيق تخصيصات المستخدم المحفوظة محلياً (AppPrefs)
  ///   فوق اللوحات الافتراضية — فتُستعاد ألوانه المختارة بعد إعادة التشغيل.
  ///
  ///   ★ معلومة: ميزة «التحكم في الألوان» معطّلة حالياً (المطلوب اعتماد
  ///   اللوحة الافتراضية)، فالتطبيق يستخدم المُنشئ العادي. هذا المُنشئ
  ///   محفوظ كما هو لتفعيل الميزة لاحقاً.
  factory ColorPaletteController.withStored() {
    final controller = ColorPaletteController();
    controller._applyStoredOverrides();
    return controller;
  }

  /// يطبّق كل الألوان المحفوظة (لكل وضع) فوق اللوحة الحالية.
  void _applyStoredOverrides() {
    for (final isDark in const [true, false]) {
      final stored = AppPrefs.paletteOverrides(isDark: isDark);
      if (stored.isEmpty) continue;
      final base = paletteFor(isDark);
      var text = base.text;
      var background = base.background;
      var icon = base.icon;
      stored.forEach((field, argb) {
        final color = Color(argb);
        switch (field) {
          case PaletteFieldKeys.backgroundPrimary:
            background = background.copyWith(primary: color);
          case PaletteFieldKeys.backgroundSurface:
            background = background.copyWith(surface: color);
          case PaletteFieldKeys.textPrimary:
            text = text.copyWith(primary: color);
          case PaletteFieldKeys.textSecondary:
            text = text.copyWith(secondary: color);
          case PaletteFieldKeys.iconPrimary:
            icon = icon.copyWith(primary: color);
          case PaletteFieldKeys.iconActive:
            icon = icon.copyWith(active: color);
        }
      });
      _replace(
        isDark: isDark,
        palette: base.copyWith(text: text, background: background, icon: icon),
      );
    }
  }

  /// اللوحة الحالية حسب الوضع (داكن/نهاري).
  AppColorPalette paletteFor(bool isDark) => isDark ? _dark : _light;

  AppColorPalette get darkPalette => _dark;
  AppColorPalette get lightPalette => _light;

  // ==========================================================================
  //  1) تغيير اللون الرسمي (Brand) — يسري على الأزرار والتبويبات والأيقونات
  // ==========================================================================
  void setAccent(Color accent, {required bool isDark}) {
    _replace(
      isDark: isDark,
      palette: paletteFor(isDark).withAccent(accent),
    );
  }

  // ==========================================================================
  //  2) تعديل فئة ألوان كاملة (نصوص / خلفيات / أيقونات)
  // ==========================================================================
  void updateText(AppTextColors text, {required bool isDark}) =>
      _replace(isDark: isDark, palette: paletteFor(isDark).copyWith(text: text));

  void updateBackground(AppBackgroundColors background,
          {required bool isDark}) =>
      _replace(
          isDark: isDark,
          palette: paletteFor(isDark).copyWith(background: background));

  void updateIcon(AppIconColors icon, {required bool isDark}) =>
      _replace(isDark: isDark, palette: paletteFor(isDark).copyWith(icon: icon));

  // ==========================================================================
  //  3) اختصارات لتعديل حقول مفردة (سهّل الاستخدام من واجهات الإعدادات)
  // ==========================================================================
  void updateTextPrimary(Color color, {required bool isDark}) =>
      updateText(paletteFor(isDark).text.copyWith(primary: color),
          isDark: isDark);

  void updateTextSecondary(Color color, {required bool isDark}) =>
      updateText(paletteFor(isDark).text.copyWith(secondary: color),
          isDark: isDark);

  void updateBackgroundPrimary(Color color, {required bool isDark}) =>
      updateBackground(
          paletteFor(isDark).background.copyWith(primary: color), isDark: isDark);

  void updateSurface(Color color, {required bool isDark}) =>
      updateBackground(paletteFor(isDark).background.copyWith(surface: color),
          isDark: isDark);

  void updateIconActive(Color color, {required bool isDark}) =>
      updateIcon(paletteFor(isDark).icon.copyWith(active: color),
          isDark: isDark);

  void updateIconPrimary(Color color, {required bool isDark}) =>
      updateIcon(paletteFor(isDark).icon.copyWith(primary: color),
          isDark: isDark);

  // ==========================================================================
  //  4) إعادة التعيين / تطبيق لوحة جاهزة
  // ==========================================================================

  /// يعيد الوضع المعطى إلى لوحته الافتراضية.
  void resetMode(bool isDark) {
    _replace(
      isDark: isDark,
      palette: isDark ? AppColorPalette.dark() : AppColorPalette.light(),
    );
  }

  /// يعيد كل الأوضاع إلى الافتراضي.
  void resetAll() {
    _dark = AppColorPalette.dark();
    _light = AppColorPalette.light();
    notifyListeners();
  }

  /// يطبّق لوحة جاهزة على وضع محدّد (يسمح بمظاهر/ثيمات محفوظة مسبقاً).
  void applyPalette(AppColorPalette palette, {required bool isDark}) =>
      _replace(
        isDark: isDark,
        palette: palette.copyWith(isDark: isDark),
      );

  // ==========================================================================
  //  داخلي
  // ==========================================================================
  void _replace({required bool isDark, required AppColorPalette palette}) {
    if (isDark) {
      _dark = palette;
    } else {
      _light = palette;
    }
    notifyListeners();
  }
}
