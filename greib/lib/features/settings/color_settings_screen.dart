import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_color_palette.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/super_header.dart';

/// ============================================================================
///  ColorSettingsScreen — صفحة «التحكم في الألوان»
///
///  ★ تتيح للمستخدم تخصيص ثلاثة عناصر من اللوحة المركزية (Color Palette):
///      • لون الخلفية (الشاشة + الأسطح)
///      • لون النصوص (أساسي + ثانوي)
///      • لون الأيقونات (أساسية + نشطة)
///
///  ◆ كل نقرة على لون تُطبّق **فوراً** عبر [ColorPaletteController] ⇒ يسري
///    التغيير لحظياً على كل صفحات التطبيق (اللوحة ThemeExtension واحدة).
///  ◆ «حفظ» يثبّت التخصيص في AppPrefs فيبقى بعد إعادة تشغيل التطبيق.
///  ◆ «استعادة الافتراضي» يُرجع لوحة الوضع الحالي لقيمها الأصلية.
/// ============================================================================
class ColorSettingsScreen extends StatefulWidget {
  const ColorSettingsScreen({super.key});

  @override
  State<ColorSettingsScreen> createState() => _ColorSettingsScreenState();
}

/// وصف صف اختيار لون واحد داخل قسم.
class _ColorRow {
  final String field;
  final String title;
  final IconData icon;
  const _ColorRow(this.field, this.title, this.icon);
}

/// لون متاح للاختيار + اسمه العربي (للإتاحة والتمييز).
class _Swatch {
  final Color color;
  final String name;
  const _Swatch(this.color, this.name);
}

class _ColorSettingsScreenState extends State<ColorSettingsScreen> {
  /// تغييرات مطبَّقة حالياً لكن غير محفوظة بعد (مفتاح الحقل ← اللون).
  final Map<String, Color> _pending = {};

  bool get _isDark => context.isDarkMode;

  // --------------------------------------------------------------------------
  //  الألوان المتاحة لكل عنصر
  // --------------------------------------------------------------------------
  static const List<_Swatch> _swatches = [
    _Swatch(Color(0xFFFFFFFF), 'أبيض'),
    _Swatch(Color(0xFFF1F5F9), 'رمادي فاتح'),
    _Swatch(Color(0xFF94A3B8), 'رمادي'),
    _Swatch(Color(0xFF475569), 'رمادي داكن'),
    _Swatch(Color(0xFF1B2537), 'كحلي'),
    _Swatch(Color(0xFF0F172A), 'كحلي غامق'),
    _Swatch(Color(0xFF000000), 'أسود'),
    _Swatch(Color(0xFF3B82F6), 'أزرق'),
    _Swatch(Color(0xFF1D4ED8), 'أزرق داكن'),
    _Swatch(Color(0xFF06B6D4), 'سماوي'),
    _Swatch(Color(0xFF14B8A6), 'أخضر مائي'),
    _Swatch(Color(0xFF10B981), 'أخضر'),
    _Swatch(Color(0xFF84CC16), 'ليموني'),
    _Swatch(Color(0xFFEAB308), 'أصفر'),
    _Swatch(Color(0xFFF59E0B), 'عَنْبري'),
    _Swatch(Color(0xFFF97316), 'برتقالي'),
    _Swatch(Color(0xFFEF4444), 'أحمر'),
    _Swatch(Color(0xFFEC4899), 'وردي'),
    _Swatch(Color(0xFFA855F7), 'بنفسجي'),
    _Swatch(Color(0xFF8B5CF6), 'بنفسجي فاتح'),
    _Swatch(Color(0xFF6366F1), 'نيلي'),
    _Swatch(Color(0xFF78716C), 'بُنّي'),
  ];

  // --------------------------------------------------------------------------
  //  أقسام الصفحة الثلاثة (خلفية / نصوص / أيقونات)
  // --------------------------------------------------------------------------
  static const List<_ColorRow> _backgroundRows = [
    _ColorRow(PaletteFieldKeys.backgroundPrimary, 'خلفية الشاشة', LucideIcons.house),
    _ColorRow(PaletteFieldKeys.backgroundSurface, 'الأسطح والبطاقات', LucideIcons.layoutGrid),
  ];

  static const List<_ColorRow> _textRows = [
    _ColorRow(PaletteFieldKeys.textPrimary, 'النص الأساسي', LucideIcons.textQuote),
    _ColorRow(PaletteFieldKeys.textSecondary, 'النص الثانوي', LucideIcons.pencil),
  ];

  static const List<_ColorRow> _iconRows = [
    _ColorRow(PaletteFieldKeys.iconPrimary, 'أيقونة أساسية', LucideIcons.sparkles),
    _ColorRow(PaletteFieldKeys.iconActive, 'أيقونة نشطة', LucideIcons.star),
  ];

  // --------------------------------------------------------------------------
  //  القراءة والتطبيق الفوري
  // --------------------------------------------------------------------------

  /// لون الحقل الحالي من اللوحة المركزية (يتحدّث لحظياً مع كل تغيير).
  Color _currentColor(String field) {
    final p = context.palette;
    switch (field) {
      case PaletteFieldKeys.backgroundPrimary:
        return p.background.primary;
      case PaletteFieldKeys.backgroundSurface:
        return p.background.surface;
      case PaletteFieldKeys.textPrimary:
        return p.text.primary;
      case PaletteFieldKeys.textSecondary:
        return p.text.secondary;
      case PaletteFieldKeys.iconPrimary:
        return p.icon.primary;
      case PaletteFieldKeys.iconActive:
        return p.icon.active;
    }
    return context.accentColor;
  }

  /// يطبّق اللون فوراً على كل التطبيق عبر متحكم اللوحة المركزية.
  void _apply(String field, Color color) {
    final controller = context.paletteController;
    switch (field) {
      case PaletteFieldKeys.backgroundPrimary:
        controller.updateBackgroundPrimary(color, isDark: _isDark);
      case PaletteFieldKeys.backgroundSurface:
        controller.updateSurface(color, isDark: _isDark);
      case PaletteFieldKeys.textPrimary:
        controller.updateTextPrimary(color, isDark: _isDark);
      case PaletteFieldKeys.textSecondary:
        controller.updateTextSecondary(color, isDark: _isDark);
      case PaletteFieldKeys.iconPrimary:
        controller.updateIconPrimary(color, isDark: _isDark);
      case PaletteFieldKeys.iconActive:
        controller.updateIconActive(color, isDark: _isDark);
    }
    setState(() => _pending[field] = color);
  }

  // --------------------------------------------------------------------------
  //  الحفظ / الاستعادة
  // --------------------------------------------------------------------------
  Future<void> _save() async {
    if (_pending.isEmpty) return;
    for (final entry in _pending.entries) {
      await AppPrefs.setPaletteOverride(
        entry.key,
        entry.value.toARGB32(),
        isDark: _isDark,
      );
    }
    if (!mounted) return;
    setState(() => _pending.clear());
    context.showSnackBar('تم حفظ الألوان ✨ — ستظهر بنفس الشكل بعد إعادة التشغيل');
  }

  Future<void> _reset() async {
    context.paletteController.resetMode(_isDark);
    await AppPrefs.clearPaletteOverrides(isDark: _isDark);
    if (!mounted) return;
    setState(() => _pending.clear());
    context.showSnackBar('تمت استعادة الألوان الافتراضية');
  }

  // --------------------------------------------------------------------------
  //  أدوات مساعدة
  // --------------------------------------------------------------------------
  static String _hex(Color c) => '#'
      '${[
        (c.r * 255).round(),
        (c.g * 255).round(),
        (c.b * 255).round(),
      ].map((v) => v.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    // ★ إعادة البناء عند تبديل الوضع الليلي/النهاري.
    context.watch<ThemeController>();

    final topInset = MediaQuery.paddingOf(context).top + 16;
    final palette = context.palette;

    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: const SuperHeader(showBackButton: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topInset,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          // ---- شريط معلومات: أي وضع يتم تعديله ----
          _ModeBanner(isDark: _isDark, pendingCount: _pending.length),
          const SizedBox(height: AppSpacing.md),

          // ---- معاينة حيّة ----
          _LivePreview(palette: palette),
          const SizedBox(height: AppSpacing.lg),

          // ---- القسم 1: لون الخلفية ----
          _SectionCard(
            icon: LucideIcons.layers,
            title: 'لون الخلفية',
            subtitle: 'خلفية الشاشة والبطاقات',
            children: [
              for (final row in _backgroundRows) ...[
                _buildRow(row),
                if (row != _backgroundRows.last)
                  const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ---- القسم 2: لون النصوص ----
          _SectionCard(
            icon: LucideIcons.textQuote,
            title: 'لون النصوص',
            subtitle: 'النصوص الأساسية والثانوية',
            children: [
              for (final row in _textRows) ...[
                _buildRow(row),
                if (row != _textRows.last) const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ---- القسم 3: لون الأيقونات ----
          _SectionCard(
            icon: LucideIcons.sparkles,
            title: 'لون الأيقونات',
            subtitle: 'ألوان الأيقونات الرئيسية والنشطة',
            children: [
              for (final row in _iconRows) ...[
                _buildRow(row),
                if (row != _iconRows.last) const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- الأزرار ----
          FilledButton.icon(
            onPressed: _pending.isEmpty ? null : _save,
            icon: const Icon(LucideIcons.save, size: 18),
            label: Text(
              _pending.isEmpty
                  ? 'لا توجد تغييرات غير محفوظة'
                  : 'حفظ التغييرات (${_pending.length})',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'التغييرات تظهر فوراً على كل الصفحات — «حفظ» يثبّتها بعد إعادة التشغيل.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('استعادة الألوان الافتراضية'),
          ),
        ],
      ),
    );
  }

  /// صف اختيار لون: العنوان + اللون الحالي + شبكة الألوان المتاحة.
  Widget _buildRow(_ColorRow row) {
    final current = _currentColor(row.field);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(row.icon, size: 16, color: context.iconColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              row.title,
              style: AppTypography.titleMedium.copyWith(
                color: context.textColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            // شريحة اللون الحالي + قيمته السداسية.
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: current,
                shape: BoxShape.circle,
                border: Border.all(color: context.backgroundColors.outline),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _hex(current),
              style: AppTypography.bodySmall.copyWith(
                color: context.textColors.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final swatch in _swatches)
              _SwatchButton(
                swatch: swatch,
                selected: swatch.color.toARGB32() == current.toARGB32(),
                onTap: () => _apply(row.field, swatch.color),
              ),
          ],
        ),
      ],
    );
  }
}

/// شريط أعلى الصفحة: الوضع الذي يتم تعديله + عدد التغييرات غير المحفوظة.
class _ModeBanner extends StatelessWidget {
  final bool isDark;
  final int pendingCount;

  const _ModeBanner({required this.isDark, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? LucideIcons.moon : LucideIcons.sun,
            size: 18,
            color: context.iconColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isDark
                  ? 'يتم تعديل ألوان الوضع الليلي'
                  : 'يتم تعديل ألوان الوضع النهاري',
              style: AppTypography.bodySmall.copyWith(
                color: context.textColors.secondary,
              ),
            ),
          ),
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: context.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              child: Text(
                '$pendingCount غير محفوظ',
                style: AppTypography.bodySmall.copyWith(
                  color: context.accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// معاينة حيّة تُظهر شكل الألوان المختارة على بطاقة نموذجية.
class _LivePreview extends StatelessWidget {
  final AppColorPalette palette;

  const _LivePreview({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.background.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: palette.background.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة مباشرة',
            style: AppTypography.labelMedium.copyWith(
              color: palette.text.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'نص أساسي — عنوان',
            style: AppTypography.titleMedium.copyWith(
              color: palette.text.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'نص ثانوي — وصف وتفاصيل',
            style: AppTypography.bodySmall.copyWith(
              color: palette.text.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final icon in const [
                LucideIcons.house,
                LucideIcons.bell,
                LucideIcons.user,
              ]) ...[
                Icon(icon, size: 20, color: palette.icon.primary),
                const SizedBox(width: AppSpacing.md),
              ],
              Icon(LucideIcons.star, size: 20, color: palette.icon.active),
            ],
          ),
        ],
      ),
    );
  }
}

/// بطاقة قسم (خلفية/نصوص/أيقونات) تحتوي صفوف اختيار الألوان.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, size: 18, color: context.accentColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: context.textColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

/// زر لون واحد من الألوان المتاحة (دائرة قابلة للنقر).
class _SwatchButton extends StatelessWidget {
  final _Swatch swatch;
  final bool selected;
  final VoidCallback onTap;

  const _SwatchButton({
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // علامة الصح داكنة أو فاتحة حسب سطوع اللون (لقراءة مريحة).
    final checkColor =
        ThemeData.estimateBrightnessForColor(swatch.color) == Brightness.light
            ? Colors.black
            : Colors.white;
    return Tooltip(
      message: swatch.name,
      child: Semantics(
        label: swatch.name,
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.full),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: swatch.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? context.textColors.primary
                    : context.backgroundColors.outline,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: selected
                ? Icon(LucideIcons.check, size: 18, color: checkColor)
                : null,
          ),
        ),
      ),
    );
  }
}
