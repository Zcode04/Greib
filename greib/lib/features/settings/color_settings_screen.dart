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
import 'widgets/custom_color_dialog.dart';

/// ============================================================================
///  ColorSettingsScreen — صفحة «التحكم في الألوان» (نسخة بسيطة واحترافية)
///
///  ★ الفلسفة: لا تحكم يدوي معقّد على عشرات الحقول. المستخدم أمامه:
///     ① **ثيمات جاهزة** — 8 ثيمات منتقاة، كل بطاقة تعرض معاينة مصغّرة حقيقية
///        لمظهرها (خلفية + بطاقة + نص + زر). نقرة = مظهر كامل متماسك.
///     ② **الخلفية فقط** — 6 خلفيات + لون مخصص؛ يحافظ على لون الثيم ونصوصه
///        ويُصَحّح النص تلقائياً إن ضعف التباين (WCAG).
///  ⇒ بقية الحقول يشتقّها [AppColorPalette.deriveFrom] آلياً فتظل متماسكة.
/// ============================================================================
class ColorSettingsScreen extends StatefulWidget {
  const ColorSettingsScreen({super.key});

  @override
  State<ColorSettingsScreen> createState() => _ColorSettingsScreenState();
}

class _ColorSettingsScreenState extends State<ColorSettingsScreen> {
  bool get _isDark => context.isDarkMode;

  /// كل الحقول — تُستخدم لحفظ الثيم كاملاً كي يُستعاد بنفس الشكل.
  static final List<String> _allFields = [
    PaletteFieldKeys.accent,
    ...PaletteFieldKeys.backgroundFields,
    ...PaletteFieldKeys.textFields,
    ...PaletteFieldKeys.iconFields,
  ];

  static Map<String, int> _mapOf(AppColorPalette palette) => {
        for (final field in _allFields) field: palette.colorFor(field).toARGB32(),
      };

  // --------------------------------------------------------------------------
  //  ① تطبيق ثيم جاهز — مظهر كامل بنقرة واحدة
  // --------------------------------------------------------------------------
  Future<void> _applyPreset(ThemePreset preset) async {
    final derived = preset.paletteFor(preset.prefersDark);
    context.paletteController.applyPalette(derived, isDark: preset.prefersDark);
    context.read<ThemeController>().setDarkMode(preset.prefersDark);
    await AppPrefs.setPaletteOverrides(
      _mapOf(derived),
      isDark: preset.prefersDark,
    );
    if (!mounted) return;
    context.showSnackBar('تم تطبيق ثيم «${preset.name}»');
  }

  // --------------------------------------------------------------------------
  //  ② تغيير الخلفية فقط — يحافظ على لون الثيم ونصوصه
  // --------------------------------------------------------------------------
  Future<void> _applyBackground(Color color) async {
    // الوضع المستهدف: تحدّده إضاءة الخلفية المختارة (تناسق كامل).
    final wantsDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    final current = context.palette;

    // ★ حماية القراءة: نُبقي نص الثيم إن كان مقروءاً، وإلا نختار الأكثر تبايناً.
    final text = AppColorPalette.contrastRatio(current.text.primary, color) >= 4.5
        ? current.text.primary
        : AppColorPalette.bestTextOn(color);

    final derived = AppColorPalette.deriveFrom(
      background: color,
      text: text,
      accent: current.accent,
      isDark: wantsDark,
    );

    context.paletteController.applyPalette(derived, isDark: wantsDark);
    context.read<ThemeController>().setDarkMode(wantsDark);
    await AppPrefs.setPaletteOverrides(_mapOf(derived), isDark: wantsDark);
    if (!mounted) return;
    context.showSnackBar('تم تغيير الخلفية');
  }

  Future<void> _pickCustomBackground() async {
    final picked = await showCustomColorDialog(
      context,
      initial: context.palette.background.primary,
    );
    if (picked == null || !mounted) return;
    await _applyBackground(picked);
  }

  // --------------------------------------------------------------------------
  //  استعادة الافتراضي
  // --------------------------------------------------------------------------
  Future<void> _reset() async {
    context.paletteController.resetMode(_isDark);
    await AppPrefs.clearPaletteOverrides(isDark: _isDark);
    if (!mounted) return;
    context.showSnackBar('تمت استعادة الثيم الافتراضي');
  }

  // --------------------------------------------------------------------------
  //  البناء
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ★ إعادة البناء عند تبديل الوضع الليلي/النهاري.
    context.watch<ThemeController>();

    final palette = context.palette;
    final active = ThemePresets.activeFor(palette);

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
          // ---- سياق: أي وضع تُعدّله + اسم الثيم النشط ----
          _ModeBanner(isDark: _isDark, activeTheme: active?.name),
          const SizedBox(height: AppSpacing.xl),

          // ---- ① الثيمات الجاهزة ----
          const _SectionTitle(
            icon: LucideIcons.palette,
            title: 'الثيمات الجاهزة',
            subtitle: 'اختر مظهراً كاملاً بنقرة واحدة',
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: ThemePresets.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final preset = ThemePresets.all[index];
              return _ThemeCard(
                preset: preset,
                selected: preset == active,
                onTap: () => _applyPreset(preset),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- ② الخلفية فقط ----
          const _SectionTitle(
            icon: LucideIcons.layers,
            title: 'الخلفية',
            subtitle: 'غيّر الخلفية مع الحفاظ على الثيم',
          ),
          const SizedBox(height: AppSpacing.md),
          _BackgroundPicker(
            current: palette.background.primary,
            onPick: _applyBackground,
            onCustom: _pickCustomBackground,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'تغيير الخلفية يبقي لون الثيم ونصوصه، ويُضبط النص تلقائياً ليبقى مقروءاً.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- استعادة ----
          AppButton(
            label: 'استعادة الثيم الافتراضي',
            icon: LucideIcons.refreshCw,
            type: ButtonType.secondary,
            onPressed: _reset,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  مكوّنات الواجهة
// ============================================================================

/// عنوان قسم: أيقونة + عنوان + وصف.
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

/// سياق أعلى الصفحة: الوضع الجاري + اسم الثيم النشط.
class _ModeBanner extends StatelessWidget {
  final bool isDark;
  final String? activeTheme;

  const _ModeBanner({required this.isDark, required this.activeTheme});

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
              isDark ? 'الوضع الليلي' : 'الوضع النهاري',
              style: AppTypography.bodySmall.copyWith(
                color: context.textColors.secondary,
              ),
            ),
          ),
          Text(
            activeTheme ?? 'خلفية مخصّصة',
            style: AppTypography.bodySmall.copyWith(
              color: context.accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة ثيم: معاينة مصغّرة حقيقية + الاسم والوصف + علامة الثيم النشط.
class _ThemeCard extends StatelessWidget {
  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = preset.palette;

    return Semantics(
      label: preset.name,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.backgroundColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: selected
                  ? context.accentColor
                  : context.backgroundColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- معاينة مصغّرة بلوحة الثيم نفسه ----
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _ThemeMock(palette: p)),
                    if (selected)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: context.accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.check,
                            size: 12,
                            color: context.textColors.onAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    preset.icon,
                    size: 13,
                    color: selected
                        ? context.accentColor
                        : context.iconColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: selected
                            ? context.accentColor
                            : context.textColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                preset.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textColors.tertiary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// معاينة مصغّرة لمظهر الثيم: شريط علوي + بطاقة بنصين + زر بلون الثيم.
class _ThemeMock extends StatelessWidget {
  final AppColorPalette palette;

  const _ThemeMock({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.background.primary,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: palette.background.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- شريط علوي: نقطة اللون الرسمي + عنصر باهت ----
          Row(
            children: [
              _box(palette.accent, 8, 8, circle: true),
              const SizedBox(width: 5),
              _box(palette.text.primary, 22, 4, radius: AppRadii.full),
              const Spacer(),
              _box(palette.text.tertiary, 10, 4, radius: AppRadii.full),
            ],
          ),
          const SizedBox(height: 6),
          // ---- بطاقة بنصين (أساسي + ثانوي) ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: palette.background.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: palette.background.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(palette.text.primary, 38, 5, radius: AppRadii.full),
                const SizedBox(height: 4),
                _box(palette.text.secondary, 24, 4, radius: AppRadii.full),
              ],
            ),
          ),
          const Spacer(),
          // ---- زر بلون الثيم ----
          _box(palette.accent, 40, 11, radius: AppRadii.full),
        ],
      ),
    );
  }

  Widget _box(
    Color color,
    double width,
    double height, {
    double radius = 2,
    bool circle = false,
  }) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// قسم الخلفية: 6 خلفيات جاهزة + لون مخصص، مع إبراز الخلفية الحالية.
class _BackgroundPicker extends StatelessWidget {
  final Color current;
  final ValueChanged<Color> onPick;
  final VoidCallback onCustom;

  const _BackgroundPicker({
    required this.current,
    required this.onPick,
    required this.onCustom,
  });

  @override
  Widget build(BuildContext context) {
    // هل الخلفية الحالية مطابقة لأحد الألوان الجاهزة؟ (وإلا فهي مخصّصة)
    final matchedIndex = BackgroundChoices.all.indexWhere(
      (option) => option.color.toARGB32() == current.toARGB32(),
    );

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
              Text(
                matchedIndex >= 0
                    ? BackgroundChoices.all[matchedIndex].name
                    : 'لون مخصّص',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                AppColorPalette.hexOf(current),
                style: AppTypography.bodySmall.copyWith(
                  color: context.textColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (var i = 0; i < BackgroundChoices.all.length; i++)
                _Swatch(
                  color: BackgroundChoices.all[i].color,
                  label: BackgroundChoices.all[i].name,
                  selected: i == matchedIndex,
                  onTap: () => onPick(BackgroundChoices.all[i].color),
                ),
              // ---- لون مخصص ----
              _Swatch(
                color: current,
                label: 'لون مخصص',
                icon: LucideIcons.pipette,
                selected: matchedIndex < 0,
                onTap: onCustom,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// دائرة خلفية واحدة (أو زر اللون المخصص).
class _Swatch extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _Swatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? context.accentColor
                    : context.backgroundColors.outline,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: icon != null
                // زر اللون المخصص: أيقونة القطارة بلون مقروء داخل الدائرة.
                ? Icon(
                    icon,
                    size: 18,
                    color: AppColorPalette.bestTextOn(color),
                  )
                : selected
                    ? Icon(
                        LucideIcons.check,
                        size: 20,
                        color: AppColorPalette.bestTextOn(color),
                      )
                    : null,
          ),
        ),
      ),
    );
  }
}
