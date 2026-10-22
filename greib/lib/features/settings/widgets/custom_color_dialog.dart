import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/app_button.dart';

/// ============================================================================
///  showCustomColorDialog — حوار «لون مخصص» للخلفية.
///
///  ★ ثلاثة مقابض HSL بدل شبكة ألوان ضخمة ⇒ اختيار دقيق بأقل عناصر ممكنة.
///  يُرجع اللون المختار، أو null عند الإلغاء.
/// ============================================================================
Future<Color?> showCustomColorDialog(
  BuildContext context, {
  required Color initial,
}) =>
    showDialog<Color>(
      context: context,
      builder: (_) => _CustomColorDialog(initial: initial),
    );

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
      title: Row(
        children: [
          Icon(LucideIcons.pipette, size: 18, color: context.accentColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'لون خلفية مخصص',
            style: AppTypography.titleLarge.copyWith(
              color: context.textColors.primary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- معاينة اللون + قيمته السداسية ----
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
