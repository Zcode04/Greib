import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/design_tokens.dart';
import '../core/theme/home_background_controller.dart';

/// حوار اختيار خلفية الصفحة الرئيسية: ٥ ألوان سادة + ٥ تدرّجات.
class BackgroundColorDialog extends StatelessWidget {
  const BackgroundColorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const BackgroundColorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<HomeBackgroundController>();
    final solids = HomeBackgroundController.solidOptions;
    final gradients = HomeBackgroundController.gradientOptions;

    Widget swatch(HomeBackgroundOption option, int index) {
      final isSelected = controller.selectedIndex == index;
      return InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () => controller.select(index),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: option.isGradient
                ? LinearGradient(
                    colors: option.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: option.isGradient ? null : option.solid,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _readableColor(option.baseColor),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 5,
                  left: 5,
                  child: Icon(
                    LucideIcons.check,
                    size: 15,
                    color: _readableColor(option.baseColor),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      title: Row(
        children: [
          Icon(LucideIcons.palette, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('لون الخلفية')),
          IconButton(
            icon: Icon(LucideIcons.x, size: 18),
            tooltip: 'إغلاق',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ألوان طبيعية',
                style: AppTypography.labelLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.5,
                children: [
                  for (var i = 0; i < solids.length; i++) swatch(solids[i], i),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'خلفيات متدرجة',
                style: AppTypography.labelLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.5,
                children: [
                  for (var i = 0; i < gradients.length; i++)
                    swatch(gradients[i], solids.length + i),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: controller.isDefault
                      ? null
                      : () => controller.reset(),
                  icon: const Icon(LucideIcons.undo2, size: 16),
                  label: const Text('إرجاع الخلفية الافتراضية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _readableColor(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
          ? Colors.white
          : const Color(0xFF1F2937);
}