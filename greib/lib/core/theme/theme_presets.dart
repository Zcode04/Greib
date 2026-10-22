import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_color_palette.dart';
import 'app_colors.dart';

/// ============================================================================
///  theme_presets — الألوان المحدودة والثيمات الجاهزة لتخصيص المظهر.
///
///  ★ الفلسفة: لا نطلب من المستخدم تعديل 30+ حقلاً، بل نعطيه:
///    • 6 ألوان فقط لكل فئة (خلفيات / نصوص / لهجات) — منسّقة وسهلة.
///    • ثيمات جاهزة بنقرة واحدة تغيّر المظهر كاملاً.
///    ثم يشتق [AppColorPalette.deriveFrom] بقية الحقول آلياً.
/// ============================================================================

/// لون متاح للاختيار + اسمه العربي (للإتاحة والتمييز البصري).
class ColorOption {
  final Color color;
  final String name;

  const ColorOption(this.color, this.name);

  /// التمثيل السداسي للعرض في الواجهة.
  String get hex => AppColorPalette.hexOf(color);
}

/// ============================================================================
///  ColorChoices — ★ الألوان المحدودة: 6 لكل فئة.
/// ============================================================================
class ColorChoices {
  ColorChoices._();

  /// خلفيات (6) — من الأسود العميق إلى الأبيض.
  static const List<ColorOption> backgrounds = [
    ColorOption(Color(0xFF0B0D0B), 'أسود عميق'),
    ColorOption(Color(0xFF0F172A), 'كحلي'),
    ColorOption(Color(0xFF1B2537), 'أزرق داكن'),
    ColorOption(Color(0xFF334155), 'رمادي داكن'),
    ColorOption(Color(0xFFF1F5F9), 'رمادي فاتح'),
    ColorOption(Color(0xFFFFFFFF), 'أبيض'),
  ];

  /// نصوص (6) — من الأبيض إلى الأسود.
  static const List<ColorOption> texts = [
    ColorOption(Color(0xFFFFFFFF), 'أبيض'),
    ColorOption(Color(0xFFE2E8F0), 'رمادي فاتح'),
    ColorOption(Color(0xFF94A3B8), 'رمادي'),
    ColorOption(Color(0xFF475569), 'رمادي داكن'),
    ColorOption(Color(0xFF111827), 'أسود ناعم'),
    ColorOption(Color(0xFF000000), 'أسود'),
  ];

  /// لهجات وأيقونات (6) — الأول هو اللون الرسمي الافتراضي للتطبيق.
  static const List<ColorOption> accents = [
    ColorOption(AppColors.accentPrimary, 'أزرق'),
    ColorOption(Color(0xFF06B6D4), 'سماوي'),
    ColorOption(Color(0xFF14B8A6), 'أخضر مائي'),
    ColorOption(Color(0xFF8B5CF6), 'بنفسجي'),
    ColorOption(Color(0xFFF97316), 'برتقالي'),
    ColorOption(Color(0xFFEC4899), 'وردي'),
  ];
}

/// ============================================================================
///  ThemePreset — ثيم جاهز: ثلاثة قرارات تكفي لمظهر كامل متماسك.
/// ============================================================================
class ThemePreset {
  /// الاسم المعروض في الشريحة.
  final String name;

  /// أيقونة الشريحة.
  final IconData icon;

  /// ★ هل يناسب هذا الثيم الوضع الليلي؟ يُبدَّل الوضع تلقائياً عند التطبيق.
  final bool prefersDark;

  final Color background;
  final Color text;
  final Color accent;

  const ThemePreset({
    required this.name,
    required this.icon,
    required this.prefersDark,
    required this.background,
    required this.text,
    required this.accent,
  });

  /// اللوحة الكاملة المشتقّة من هذا الثيم — تُستخدم للمعاينة والتطبيق معاً.
  AppColorPalette paletteFor(bool isDark) => AppColorPalette.deriveFrom(
        background: background,
        text: text,
        accent: accent,
        isDark: isDark,
      );

  /// هل اللوحة الحالية مطابقة لهذا الثيم؟ (لتمييز الشريحة النشطة)
  bool matches(AppColorPalette palette) =>
      background.toARGB32() == palette.background.primary.toARGB32() &&
      text.toARGB32() == palette.text.primary.toARGB32() &&
      accent.toARGB32() == palette.accent.toARGB32();
}

class ThemePresets {
  ThemePresets._();

  /// ★ الثيمات الجاهزة — نقرة واحدة = مظهر كامل.
  static const List<ThemePreset> all = [
    ThemePreset(
      name: 'الافتراضي',
      icon: LucideIcons.sparkles,
      prefersDark: true,
      background: Color(0xFF0B141A),
      text: Color(0xFFF8FAFC),
      accent: AppColors.accentPrimary,
    ),
    ThemePreset(
      name: 'ليلي هادئ',
      icon: LucideIcons.moon,
      prefersDark: true,
      background: Color(0xFF0B0D0B),
      text: Color(0xFFE2E8F0),
      accent: Color(0xFF14B8A6),
    ),
    ThemePreset(
      name: 'كحلي',
      icon: LucideIcons.waves,
      prefersDark: true,
      background: Color(0xFF0F172A),
      text: Color(0xFFF1F5F9),
      accent: Color(0xFF6366F1),
    ),
    ThemePreset(
      name: 'رمادي داكن',
      icon: LucideIcons.square,
      prefersDark: true,
      background: Color(0xFF1B2537),
      text: Color(0xFFE2E8F0),
      accent: Color(0xFF94A3B8),
    ),
    ThemePreset(
      name: 'نهاري',
      icon: LucideIcons.sun,
      prefersDark: false,
      background: Color(0xFFF1F5F9),
      text: Color(0xFF0F172A),
      accent: AppColors.accentPrimary,
    ),
    ThemePreset(
      name: 'نهاري دافئ',
      icon: LucideIcons.coffee,
      prefersDark: false,
      background: Color(0xFFFAF7F2),
      text: Color(0xFF1F2937),
      accent: Color(0xFFF59E0B),
    ),
  ];
}
