import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_color_palette.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';
import '../../core/widgets/super_header.dart';
import '../../shared_widgets/app_button.dart';
import 'widgets/color_field_meta.dart';
import 'widgets/color_picker_sheet.dart';
import 'widgets/color_role_row.dart';

/// ============================================================================
///  ColorSettingsScreen — صفحة «التحكم في الألوان» (النسخة المختصرة والمتماسكة)
///
///  ★ المشكلة القديمة: 22 لوناً × 6 صفوف = 132 دائرة في صفحة واحدة ⇒ إرهاق.
///  ◆ الحل:
///     1) **ثيمات جاهزة** بنقرة واحدة (تطبق مظهراً كاملاً مشتقاً).
///     2) **3 تبويبات** (خلفيات / نصوص / أيقونات) ⇒ صف واحد لكل دور.
///     3) **شيت اختيار** فيه 6 ألوان فقط لكل فئة + «لون مخصص».
///     4) **تحكم متقدم** يُخفي الحقول الدقيقة (الطبقات/الحالات) افتراضياً.
///     5) **حفظ** يثبّت التخصيص في AppPrefs، و**استعادة** تُرجع الافتراضي.
///  ⇒ المستخدم يعدّل 3 قرارات، ويشتق [AppColorPalette.deriveFrom] البقية.
/// ============================================================================
class ColorSettingsScreen extends StatefulWidget {
  const ColorSettingsScreen({super.key});

  @override
  State<ColorSettingsScreen> createState() => _ColorSettingsScreenState();
}

class _ColorSettingsScreenState extends State<ColorSettingsScreen> {
  /// الفئة المعروضة حالياً (تبويب).
  ColorGroup _group = ColorGroup.backgrounds;

  /// إظهار الحقول الدقيقة (الطبقات، الحالات الدلالية، فوق-اللون…).
  bool _advanced = false;

  /// تغييرات مطبَّقة حالياً لكن غير محفوظة بعد (مفتاح الحقل ← اللون).
  final Map<String, Color> _pending = {};

  bool get _isDark => context.isDarkMode;

  /// كل الحقول القابلة للتخصيص — تُستخدم لحفظ الثيم الجاهز كاملاً.
  static final List<String> _allFields = [
    PaletteFieldKeys.accent,
    ...PaletteFieldKeys.backgroundFields,
    ...PaletteFieldKeys.textFields,
    ...PaletteFieldKeys.iconFields,
  ];

  // --------------------------------------------------------------------------
  //  التطبيق الفوري
  // --------------------------------------------------------------------------

  /// يطبّق اللون فوراً على كل التطبيق عبر متحكم اللوحة المركزية.
  void _apply(String field, Color color) {
    context.paletteController.updateField(field, color, isDark: _isDark);
    setState(() => _pending[field] = color);
  }

  /// يفتح شيت اختيار اللون للدور المطلوب، ثم يطبّق المختار.
  Future<void> _pickField(String field) async {
    final meta = metaFor(field);
    final picked = await showColorPickerSheet(
      context,
      title: meta.title,
      icon: meta.icon,
      current: context.palette.colorFor(field),
      options: choicesForField(field, _group),
    );
    if (picked == null || !mounted) return;
    _apply(field, picked);
  }

  /// شفاء التباين: يجعل النص الأساسي الأكثر قراءةً على الخلفية الحالية.
  void _fixContrast() => _apply(
        PaletteFieldKeys.textPrimary,
        AppColorPalette.bestTextOn(context.palette.background.primary),
      );

  // --------------------------------------------------------------------------
  //  الثيمات الجاهزة
  // --------------------------------------------------------------------------

  /// ★ نقرة واحدة = مظهر كامل: تُشتق كل الحقول من القرارات الثلاثة وتُحفظ.
  Future<void> _applyPreset(ThemePreset preset) async {
    final derived = preset.paletteFor(preset.prefersDark);
    context.paletteController.applyPalette(derived, isDark: preset.prefersDark);
    context.read<ThemeController>().setDarkMode(preset.prefersDark);
    await AppPrefs.setPaletteOverrides(
      _mapOf(derived),
      isDark: preset.prefersDark,
    );
    if (!mounted) return;
    setState(() => _pending.clear());
    context.showSnackBar('تم تطبيق ثيم «${preset.name}»');
  }

  /// يحوّل اللوحة كاملة إلى خريطة (مفتاح الحقل ← ARGB) للحفظ.
  static Map<String, int> _mapOf(AppColorPalette palette) => {
        for (final field in _allFields) field: palette.colorFor(field).toARGB32(),
      };

  // --------------------------------------------------------------------------
  //  الحفظ / الاستعادة
  // --------------------------------------------------------------------------

  Future<void> _save() async {
    if (_pending.isEmpty) return;
    await AppPrefs.setPaletteOverrides(
      {for (final e in _pending.entries) e.key: e.value.toARGB32()},
      isDark: _isDark,
    );
    if (!mounted) return;
    setState(() => _pending.clear());
    context.showSnackBar('تم حفظ الألوان — تبقى كما هي بعد إعادة التشغيل');
  }

  Future<void> _reset() async {
    context.paletteController.resetMode(_isDark);
    await AppPrefs.clearPaletteOverrides(isDark: _isDark);
    if (!mounted) return;
    setState(() => _pending.clear());
    context.showSnackBar('تمت استعادة الألوان الافتراضية');
  }

  // --------------------------------------------------------------------------
  //  البناء
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // ★ إعادة البناء عند تبديل الوضع الليلي/النهاري.
    context.watch<ThemeController>();

    final palette = context.palette;
    final hasPending = _pending.isNotEmpty;

    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: const SuperHeader(showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          // ---- أي وضع يتم تعديله + عدد التغييرات غير المحفوظة ----
          _ModeBanner(isDark: _isDark, pendingCount: _pending.length),
          const SizedBox(height: AppSpacing.lg),

          // ---- ① ثيمات جاهزة ----
          const _SectionTitle(
            icon: LucideIcons.swatchBook,
            title: 'ثيمات جاهزة',
            subtitle: 'مظهر كامل بنقرة واحدة',
          ),
          const SizedBox(height: AppSpacing.sm),
          _PresetStrip(current: palette, onTap: _applyPreset),
          const SizedBox(height: AppSpacing.lg),

          // ---- ② معاينة حيّة ----
          _LivePreview(palette: palette, onFixContrast: _fixContrast),
          const SizedBox(height: AppSpacing.lg),

          // ---- ③ تبويبات الفئات ----
          _GroupTabs(
            value: _group,
            onChanged: (g) => setState(() => _group = g),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ---- ④ تحكم متقدم ----
          _AdvancedRow(
            value: _advanced,
            onChanged: (v) => setState(() => _advanced = v),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ---- ⑤ صفوف الأدوار ----
          Container(
            decoration: BoxDecoration(
              color: context.backgroundColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: context.backgroundColors.outline),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (final field in _visibleFields())
                  ColorRoleRow(
                    title: metaFor(field).title,
                    icon: metaFor(field).icon,
                    color: palette.colorFor(field),
                    hint: _pending.containsKey(field)
                        ? '${AppColorPalette.hexOf(palette.colorFor(field))} • غير محفوظ'
                        : AppColorPalette.hexOf(palette.colorFor(field)),
                    onTap: () => _pickField(field),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- ⑥ الأزرار (Pill) ----
          AppButton(
            label: hasPending
                ? 'حفظ التغييرات (${_pending.length})'
                : 'لا توجد تغييرات غير محفوظة',
            icon: LucideIcons.save,
            onPressed: hasPending ? _save : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'استعادة الألوان الافتراضية',
            icon: LucideIcons.refreshCw,
            type: ButtonType.secondary,
            onPressed: _reset,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'التغييرات تظهر فوراً على كل الصفحات، و«حفظ» يثبّتها بعد إعادة التشغيل.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// حقول الفئة الحالية — تُخفي الحقول المتقدّمة إلا عند تفعيل المفتاح.
  List<String> _visibleFields() => _group.fields
      .where((field) => _advanced || !metaFor(field).advanced)
      .toList();
}

// ============================================================================
//  مكوّنات الواجهة
// ============================================================================

/// عنوان قسم صغير: أيقونة + عنوان + وصف.
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: context.accentColor),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: context.textColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}

/// شريط الثيمات الجاهزة (تمرير أفقي) — كل شريحة تعرض ألوانها الثلاثة.
class _PresetStrip extends StatelessWidget {
  final AppColorPalette current;
  final Future<void> Function(ThemePreset preset) onTap;

  const _PresetStrip({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: ThemePresets.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final preset = ThemePresets.all[index];
          return _PresetChip(
            preset: preset,
            selected: preset.matches(current),
            onTap: () => onTap(preset),
          );
        },
      ),
    );
  }
}

/// شريحة ثيم: ثلاث دوائر (خلفية/نص/لون رسمي) + الاسم + الأيقونة.
class _PresetChip extends StatelessWidget {
  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: preset.name,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 108,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.backgroundColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected
                  ? context.accentColor
                  : context.backgroundColors.outline,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- معاينة الألوان الثلاثة ----
              Row(
                children: [
                  _dot(preset.background),
                  const SizedBox(width: 4),
                  _dot(preset.text),
                  const SizedBox(width: 4),
                  _dot(preset.accent),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    preset.icon,
                    size: 14,
                    color: selected
                        ? context.accentColor
                        : context.iconColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: selected
                            ? context.accentColor
                            : context.textColors.secondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
      );
}

/// تبويبات الفئات الثلاث — تتوسّع أفقياً بحدود خفيفة مثل شيبس الفلاتر.
class _GroupTabs extends StatelessWidget {
  final ColorGroup value;
  final ValueChanged<ColorGroup> onChanged;

  const _GroupTabs({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final group in ColorGroup.values)
            Flexible(child: _tab(context, group)),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, ColorGroup group) {
    final selected = group == value;
    return ChoiceChip(
      label: Text(
        group.label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      avatar: Icon(
        group.icon,
        size: 14,
        color: selected ? context.accentColor : context.iconColors.muted,
      ),
      selected: selected,
      onSelected: (_) => onChanged(group),
      showCheckmark: false,
      labelStyle: AppTypography.bodySmall.copyWith(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? context.accentColor : context.textColors.secondary,
      ),
      selectedColor: context.accentColor.withValues(alpha: 0.14),
      backgroundColor: Colors.transparent,
      // ★ حدّ خفيف (30%) لغير المختار، ولون التمييز للمختار.
      side: BorderSide(
        color: selected
            ? context.accentColor
            : context.backgroundColors.outline.withValues(alpha: 0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// صف «تحكم متقدم» — يُظهر/يُخفي الحقول الدقيقة.
class _AdvancedRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AdvancedRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.slidersHorizontal,
              size: 17,
              color: context.iconColors.secondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تحكم متقدم',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'إظهار الطبقات والحالات وألوان فوق-الوسائط',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textColors.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// شريط معلومات: أي وضع يتم تعديله + عدد التغييرات غير المحفوظة.
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

/// معاينة حيّة + تحذير التباين (WCAG) مع «تصحيح تلقائي».
class _LivePreview extends StatelessWidget {
  final AppColorPalette palette;
  final VoidCallback onFixContrast;

  const _LivePreview({required this.palette, required this.onFixContrast});

  @override
  Widget build(BuildContext context) {
    final ratio = AppColorPalette.contrastRatio(
      palette.text.primary,
      palette.background.primary,
    );
    final lowContrast = ratio < 4.5;

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
          Row(
            children: [
              Text(
                'معاينة مباشرة',
                style: AppTypography.labelMedium.copyWith(
                  color: palette.text.tertiary,
                ),
              ),
              const Spacer(),
              Text(
                'التباين ${ratio.toStringAsFixed(1)}:1',
                style: AppTypography.bodySmall.copyWith(
                  color: lowContrast
                      ? palette.icon.warning
                      : palette.text.tertiary,
                  fontWeight: lowContrast ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
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
          if (lowContrast) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: palette.icon.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.contrast,
                    size: 16,
                    color: palette.icon.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'تباين النص مع الخلفية ضعيف — قد يصعب القراءة.',
                      style: AppTypography.bodySmall.copyWith(
                        color: palette.text.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onFixContrast,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.full),
                      ),
                    ),
                    child: Text(
                      'تصحيح تلقائي',
                      style: AppTypography.bodySmall.copyWith(
                        color: palette.icon.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
