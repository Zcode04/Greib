import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_color_palette.dart';
import 'app_colors.dart';

/// ============================================================================
///  theme_presets — ★ الثيمات الجاهزة + خلفيات جاهزة.
///
///  • المستخدم يختار ثيماً جاهزاً (نقرة = مظهر كامل متناسق ومحترف).
///  • أو يغيّر الخلفية فقط (مع بقاء الثيم الحالي ونصوصه ولونه الرسمي).
///  ⇒ [AppColorPalette.deriveFrom] يشتق البقية آلياً.
///
///  ★ قواعد اختيار الألوان (لضمان وضوح القراءة):
///    - الداكن: خلفية شبه سوداء بصبغة لونية خفيفة + نص أبيض مائل للون الثيم
///      + لون رسمي ساطع (نسبة تباين ≥ 4.5).
///    - الفاتح: خلفية مائلة للون الثيم بدل الأبيض الصرف + نص داكن عميق
///      + لون رسمي أغمق قليلاً ليبقى واضحاً على الفاتح.
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
///  مرتبة من الأغمق إلى الأفتح، بصبغات حديثة بدل الرمادي الباهت.
/// ============================================================================
class BackgroundChoices {
  BackgroundChoices._();

  static const List<ColorOption> all = [
    ColorOption(Color(0xFF09090B), 'أسود عميق'),
    ColorOption(Color(0xFF0B1020), 'كحلي ليلي'),
    ColorOption(Color(0xFF16203A), 'أزرق داكن'),
    ColorOption(Color(0xFF27272A), 'جرافيت'),
    ColorOption(Color(0xFFF4F6FA), 'رمادي فاتح'),
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

  /// ★ الثيمات الجاهزة المنتقاة — الداكنة أولاً (الافتراضي) ثم الفاتحة.
  static const List<ThemePreset> all = [
    // ───────────────────────── داكنة ─────────────────────────
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
      description: 'نيلي عميق وأنيق',
      icon: LucideIcons.moon,
      prefersDark: true,
      background: Color(0xFF0B1020),
      text: Color(0xFFE8ECF8),
      accent: Color(0xFF7C83FF),
    ),
    ThemePreset(
      name: 'جرافيت',
      description: 'رمادي محايد واحترافي',
      icon: LucideIcons.zap,
      prefersDark: true,
      background: Color(0xFF0E0F12),
      text: Color(0xFFECEDEF),
      accent: Color(0xFF4F8CFF),
    ),
    ThemePreset(
      name: 'زمردي',
      description: 'أخضر نابض ومنعش',
      icon: LucideIcons.leaf,
      prefersDark: true,
      background: Color(0xFF07140F),
      text: Color(0xFFE6F4EC),
      accent: Color(0xFF34D399),
    ),
    ThemePreset(
      name: 'ملكي',
      description: 'بنفسجي فاخر',
      icon: LucideIcons.gem,
      prefersDark: true,
      background: Color(0xFF120C22),
      text: Color(0xFFF1ECFF),
      accent: Color(0xFFA78BFA),
    ),
    ThemePreset(
      name: 'ياقوتي',
      description: 'وردي جريء وعصري',
      icon: LucideIcons.flame,
      prefersDark: true,
      background: Color(0xFF1A0D14),
      text: Color(0xFFFCEFF4),
      accent: Color(0xFFFF5C8A),
    ),
    ThemePreset(
      name: 'ذهبي',
      description: 'كهرماني راقٍ ودافئ',
      icon: LucideIcons.coffee,
      prefersDark: true,
      background: Color(0xFF14100A),
      text: Color(0xFFFAF3E6),
      accent: Color(0xFFE6B450),
    ),
    ThemePreset(
      name: 'محيطي',
      description: 'تركوازي بارد وهادئ',
      icon: LucideIcons.waves,
      prefersDark: true,
      background: Color(0xFF06161F),
      text: Color(0xFFE4F4FA),
      accent: Color(0xFF22B8CF),
    ),

    // ───────────────────────── فاتحة ─────────────────────────
    ThemePreset(
      name: 'نهاري',
      description: 'نظيف ومشرق',
      icon: LucideIcons.sun,
      prefersDark: false,
      background: Color(0xFFF6F8FB),
      text: Color(0xFF0F172A),
      accent: AppColors.accentPrimary,
    ),
    ThemePreset(
      name: 'سماوي',
      description: 'أزرق صافٍ كالسماء',
      icon: LucideIcons.sunset,
      prefersDark: false,
      background: Color(0xFFF2F8FD),
      text: Color(0xFF0B2239),
      accent: Color(0xFF0A84D6),
    ),
    ThemePreset(
      name: 'نعناعي',
      description: 'فاتح بلمسة خضراء',
      icon: LucideIcons.paintbrush,
      prefersDark: false,
      background: Color(0xFFF4FAF7),
      text: Color(0xFF12261E),
      accent: Color(0xFF0F9F7A),
    ),
    ThemePreset(
      name: 'لافندر',
      description: 'بنفسجي ناعم وحديث',
      icon: LucideIcons.star,
      prefersDark: false,
      background: Color(0xFFF7F5FF),
      text: Color(0xFF1E1B3A),
      accent: Color(0xFF6D5AE6),
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