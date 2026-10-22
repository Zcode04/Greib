import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/design_tokens.dart';

/// ============================================================================
///  ColorRoleRow — صف دور لون واحد.
///
///  ★ بدل عرض 22 دائرة لون تحت كل صف، السطر يعرض اللون الحالي فقط،
///    والضغط عليه يفتح شيت اختيار الألوان ⇒ صفحة قصيرة ومريحة.
/// ============================================================================
class ColorRoleRow extends StatelessWidget {
  final String title;
  final IconData icon;

  /// اللون الحالي — يُعرض كشريحة، ويُلوَّن به صندوق الأيقونة.
  final Color color;

  /// سطر صغير أسفل العنوان (القيمة السداسية).
  final String? hint;

  final VoidCallback onTap;

  const ColorRoleRow({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // صندوق الأيقونة ملوَّن بالدور نفسه ⇒ تمييز بصري فوري.
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, size: 17, color: context.iconColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: context.textColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hint != null)
                    Text(
                      hint!,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textColors.tertiary,
                      ),
                    ),
                ],
              ),
            ),
            // شريحة اللون الحالي.
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: context.backgroundColors.outline),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              LucideIcons.chevronLeft,
              size: 16,
              color: context.iconColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
