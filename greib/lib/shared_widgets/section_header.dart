import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionTitle;
  final VoidCallback? onActionTap;
  final bool showAction;

  /// أيقونة اختيارية بجانب العنوان (بدون خلفية).
  final IconData? icon;
  final Color? iconColor;

  /// جملة القسم في منتصف السطر وبلا أيقونة (للعناوين البارزة).
  final bool centerTitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionTitle,
    this.onActionTap,
    this.showAction = true,
    this.icon,
    this.iconColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // الافتراضي: اللون الرسمي بدرجة مقروءة (داكن في الوضع النهاري).
    final color = iconColor ?? AppColors.accentFor(isDark);
    final actionColor = AppColors.accentFor(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        // ★ centerTitle ⇒ الجملة في منتصف السطر بلا أيقونة.
        mainAxisAlignment: centerTitle
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (centerTitle)
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (showAction)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionTitle ?? 'عرض الكل',
                style: TextStyle(
                  color: actionColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
