import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_color_palette.dart';
import '../theme/color_palette_controller.dart';
import '../theme/design_tokens.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// -------------------------------------------------------------------------
  ///  لوحة الألوان المركزية (Color Palette) — تتبع الوضع الحالي تلقائياً.
  ///  ★ أي تغيير يُجرى عبر ColorPaletteController يسري فوراً هنا وعلى كل
  ///    المكوّنات التي تقرأ هذه القيم.
  /// -------------------------------------------------------------------------
  AppColorPalette get palette =>
      theme.extension<AppColorPalette>() ??
      (isDarkMode ? AppColorPalette.dark() : AppColorPalette.light());

  /// ألوان النصوص (نص أساسي / ثانوي / باهت / فوق اللون الرسمي …).
  AppTextColors get textColors => palette.text;

  /// ألوان الخلفيات والأسطح.
  AppBackgroundColors get backgroundColors => palette.background;

  /// ألوان الأيقونات (أساسية / ثانوية / نشِطة / معطّلة …).
  AppIconColors get iconColors => palette.icon;

  /// اللون الرسمي (Brand) للوضع الحالي.
  Color get accentColor => palette.accent;

  /// درجة أفتح من اللون الرسمي (توهّجات/تدرّجات) — تُشتق وقت التشغيل.
  Color get accentLightColor => palette.accentLight;

  /// درجة أغمق من اللون الرسمي (تُقرأ على الخلفيات الفاتحة).
  Color get accentDarkColor => palette.accentDark;

  /// توهّج بلون العلامة الحالي (يتبع اللون الرسمي المختار).
  List<BoxShadow> get brandGlow =>
      AppShadows.brandGlowFor(palette.accent);

  /// توهّج قوي بلون العلامة الحالي (يتبع اللون الرسمي المختار).
  List<BoxShadow> get brandGlowStrong =>
      AppShadows.brandGlowStrongFor(palette.accent);

  /// متحكم تخصيص الألوان (لتغيير الألوان ديناميكياً).
  ColorPaletteController get paletteController =>
      read<ColorPaletteController>();

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

