import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../shared_widgets/app_button.dart';

/// ============================================================================
///  showColorPickerSheet — شيت اختيار لون دور واحد.
///
///  ★ يعرض الألوان المحدودة للفئة (6) + «لون مخصص» لمن يحتاج لوناً خاصاً.
///  يُرجع اللون المختار، أو null عند الإغلاق بلا اختيار.
/// ============================================================================
Future<Color?> showColorPickerSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color current,
  required List<ColorOption> options,
}) =>
    showAppSheet<Color>(
      context,
      builder: (_) => _ColorPickerSheet(
        title: title,
        icon: icon,
        current: current,
        options: options,
      ),
    );

class _ColorPickerSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color current;
  final List<ColorOption> options;

  const _ColorPickerSheet({
    required this.title,
    required this.icon,
    required this.current,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- العنوان + اللون الحالي ----
          Row(
            children: [
              Icon(icon, size: 18, color: context.iconColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.textColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                AppColorPalette.hexOf(current),
                style: AppTypography.bodySmall.copyWith(
                  color: context.textColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- الألوان المحدودة (6 لكل فئة) ----
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSpacing.md;
              final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
              return Wrap(
                spacing: spacing,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final option in options)
                    SizedBox(
                      width: itemWidth,
                      child: _OptionTile(
                        option: option,
                        selected:
                            option.color.toARGB32() == current.toARGB32(),
                        onTap: () => Navigator.of(context).pop(option.color),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- لون مخصص (لمن يحتاج دقة كاملة) ----
          AppButton(
            label: 'لون مخصص',
            icon: LucideIcons.pipette,
            type: ButtonType.secondary,
            onPressed: () async {
              final custom = await showDialog<Color>(
                context: context,
                builder: (_) => _CustomColorDialog(initial: current),
              );
              if (custom != null && context.mounted) {
                Navigator.of(context).pop(custom);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// خيار لون واحد داخل الشيت: دائرة + الاسم.
class _OptionTile extends StatelessWidget {
  final ColorOption option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // علامة الصح داكنة أو فاتحة حسب سطوع اللون (لقراءة مريحة).
    final checkColor =
        ThemeData.estimateBrightnessForColor(option.color) == Brightness.light
            ? Colors.black
            : Colors.white;

    return Semantics(
      label: option.name,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? context.accentColor
                        : context.backgroundColors.outline,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: selected
                    ? Icon(LucideIcons.check, size: 22, color: checkColor)
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: selected
                      ? context.textColors.primary
                      : context.textColors.tertiary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// حوار اللون المخصص — ثلاثة مقابض HSL بدل شبكة ألوان ضخمة.
class _CustomColorDialog extends StatefulWidget {
  final Color initial;

  const _CustomColorDialog({required this.initial});

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late HSLColor _hsl = HSLColor.fromColor(widget.initial);

  @override
  Widget build(BuildContext context) {
    final color = _hsl.toColor();

    return AlertDialog(
      backgroundColor: context.backgroundColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      title: Text(
        'لون مخصص',
        style: AppTypography.titleLarge.copyWith(
          color: context.textColors.primary,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: context.backgroundColors.outline),
              ),
              child: Text(
                AppColorPalette.hexOf(color),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColorPalette.bestTextOn(color),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _slider(
              context,
              'درجة اللون',
              _hsl.hue,
              360,
              (v) => setState(() => _hsl = _hsl.withHue(v)),
            ),
            _slider(
              context,
              'التشبّع',
              _hsl.saturation * 100,
              100,
              (v) => setState(() => _hsl = _hsl.withSaturation(v / 100)),
            ),
            _slider(
              context,
              'الإضاءة',
              _hsl.lightness * 100,
              100,
              (v) => setState(() => _hsl = _hsl.withLightness(v / 100)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: AppTypography.labelLarge.copyWith(
              color: context.textColors.secondary,
            ),
          ),
        ),
        AppButton(
          label: 'اختيار',
          isFullWidth: false,
          onPressed: () => Navigator.pop(context, color),
        ),
      ],
    );
  }

  Widget _slider(
    BuildContext context,
    String label,
    double value,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final color = _hsl.toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textColors.secondary,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: context.backgroundColors.outline,
          ),
          child: Slider(
            value: value.clamp(0.0, max),
            min: 0,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
