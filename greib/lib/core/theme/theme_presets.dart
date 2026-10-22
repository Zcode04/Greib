import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_color_palette.dart';
import 'app_colors.dart';

/// ============================================================================
///  theme_presets — ★ الثيمات الجاهزة + خلفيات جاهزة.
///
///  ★ الفلسفة الجديدة: المستخدم لا يعدّل عشرات الحقول يدوياً، بل:
///    • يختار **ثيماً جاهزاً** (نقرة = مظهر كامل متناسق ومحترف).
///    • أو يغيّر **الخلفية فقط** (مع بقاء الثيم الحالي ونصوصه ولونه الرسمي).
///  ⇒ الصفحة بسيطة واحترافية، و[AppColorPalette.deriveFrom] يشتق البقية آلياً.
/// ============================================================================

/// لون خلفية جاهز + اسمه العربي (للإتاحة والتمييز البصري).
class ColorOption {
  final Color color;
  final String name;

  const ColorOption(this.color, this.name);

  /// التمثيل السداسي للعرض في الواجهة.
  String get hex => AppColorPalette.hexOf(color);

  /// هل هذه الخلفية تنتمي للوضع الليلي؟ (تُستخدم لتبديل الوضع تلقائياً).
  bool get isDarkBackground =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
}

/// ============================================================================
///  BackgroundChoices — ★ 6 خلفيات محدودة + «لون مخصص».
/// ============================================================================
class BackgroundChoices {
  BackgroundChoices._();

  /// من الأسود العميق إلى الأبيض — مرتبة حسب الإضاءة.
  static const List<ColorOption> all = [
    ColorOption(Color(0xFF0B0D0B), 'أسود عميق'),
    ColorOption(Color(0xFF0F172A), 'كحلي'),
    ColorOption(Color(0xFF1B2537), 'أزرق داكن'),
    ColorOption(Color(0xFF334155), 'رمادي داكن'),
    ColorOption(Color(0xFFF1F5F9), 'رمادي فاتح'),
    ColorOption(Color(0xFFFFFFFF), 'أبيض'),
  ];
}

/// ============================================================================
///  ThemePreset — ثيم جاهز: ثلاثة قرارات تكفي لمظهر كامل متماسك.
/// ============================================================================
class ThemePreset {
  /// الاسم المعروض تحت المعاينة.
  final String name;

  /// وصف مختصر يوضّح طابع الثيم (سطر واحد).
  final String description;

  /// أيقونة الثيم في البطاقة.
  final IconData icon;

  /// ★ الوضع الذي ينتمي إليه الثيم — يُبدَّل وضع التطبيق تلقائياً عند التطبيق.
  final bool prefersDark;

  final Color background;
  final Color text;
  final Color accent;

  const ThemePreset({
    required this.name,
    required this.description,
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

  /// اللوحة المشتقّة بوضعها الطبيعي (للمعاينة المصغّرة في البطاقة).
  AppColorPalette get palette => paletteFor(prefersDark);

  /// هل اللوحة الحالية مطابقة لهذا الثيم؟ (لتمييز البطاقة النشطة)
  bool matches(AppColorPalette palette) =>
      background.toARGB32() == palette.background.primary.toARGB32() &&
      text.toARGB32() == palette.text.primary.toARGB32() &&
      accent.toARGB32() == palette.accent.toARGB32();
}

class ThemePresets {
  ThemePresets._();

  /// ★ الثيمات الجاهزة المنتقاة — هوية بصرية كاملة لكل ثيم (لون رسمي + طابع).
  ///   الداكنة أولاً (الافتراضي في التطبيق) ثم الفاتحة.
  static const List<ThemePreset> all = [
    ThemePreset(
      name: 'الافتراضي',
      description: 'مظهر التطبيق الأصلي',
      icon: LucideIcons.sparkles,
      prefersDark: true,
      background: Color(0xFF0B141A),
      text: Color(0xFFF8FAFC),
      accent: AppColors.accentPrimary,
    ),
    ThemePreset(
      name: 'منتصف الليل',
      description: 'كحلي هادئ للعين',
      icon: LucideIcons.moon,
      prefersDark: true,
      background: Color(0xFF0F172A),
      text: Color(0xFFF1F5F9),
      accent: Color(0xFF6366F1),
    ),
    ThemePreset(
      name: 'زمردي',
      description: 'أخضر مائي منعش',
      icon: LucideIcons.waves,
      prefersDark: true,
      background: Color(0xFF0A1A18),
      text: Color(0xFFECFDF5),
      accent: Color(0xFF14B8A6),
    ),
    ThemePreset(
      name: 'أرجواني',
      description: 'بنفسجي عصري',
      icon: LucideIcons.star,
      prefersDark: true,
      background: Color(0xFF140F26),
      text: Color(0xFFF5F3FF),
      accent: Color(0xFF8B5CF6),
    ),
    ThemePreset(
      name: 'دافئ',
      description: 'عنبري مريح',
      icon: LucideIcons.coffee,
      prefersDark: true,
      background: Color(0xFF1A120B),
      text: Color(0xFFFFF7ED),
      accent: Color(0xFFF59E0B),
    ),
    ThemePreset(
      name: 'نهاري',
      description: 'نظيف ومشرق',
      icon: LucideIcons.sun,
      prefersDark: false,
      background: Color(0xFFF1F5F9),
      text: Color(0xFF0F172A),
      accent: AppColors.accentPrimary,
    ),
    ThemePreset(
      name: 'نهاري ناعم',
      description: 'فاتح بلمسة زمردية',
      icon: LucideIcons.paintbrush,
      prefersDark: false,
      background: Color(0xFFF8FAF9),
      text: Color(0xFF1F2937),
      accent: Color(0xFF14B8A6),
    ),
    ThemePreset(
      name: 'ورقي',
      description: 'دافئ كالورق',
      icon: LucideIcons.swatchBook,
      prefersDark: false,
      background: Color(0xFFFAF7F2),
      text: Color(0xFF1F2937),
      accent: Color(0xFFF59E0B),
    ),
  ];

  /// الثيم المطابق للوحة الحالية (null = لا يوجد ⇒ خلفية مخصّصة).
  static ThemePreset? activeFor(AppColorPalette palette) {
    for (final preset in all) {
      if (preset.matches(palette)) return preset;
    }
    return null;
  }
}
