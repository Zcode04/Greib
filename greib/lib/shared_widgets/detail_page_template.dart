import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/extensions/context_extensions.dart';
import '../core/theme/design_tokens.dart';
import 'app_button.dart';

class DetailPageTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final String? price;
  final String? deliveryTime;
  final String? rating;
  final String? description;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final Widget? extraContent;

  const DetailPageTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    this.price,
    this.deliveryTime,
    this.rating,
    this.description,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ★ الأسطح والخلفيات من اللوحة الديناميكية (تتبع الوضع والتخصيص).
    final bg = context.backgroundColors.primary;
    final surface = context.backgroundColors.surface;
    final outline = context.backgroundColors.outline;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية مع توهج اللون الرسمي
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.08),
                    bg,
                    bg,
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: bg,
                  leading: Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: outline),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, size: 18),
                      onPressed: () {
                        if (context.canPop()) context.pop();
                      },
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: 0.25),
                            accentColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppRadii.xxl),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(AppRadii.xxl),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: AppShadows.glowGreen,
                          ),
                          child: Icon(icon, size: 56, color: accentColor),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Text(
                          title,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // صف التفاصيل (سعر/وقت/تقييم)
                        if (price != null ||
                            deliveryTime != null ||
                            rating != null)
                          Row(
                            children: [
                              if (price != null)
                                _DetailChip(
                                  icon: LucideIcons.wallet,
                                  label: price!,
                                  color: context.accentColor,
                                ),
                              if (deliveryTime != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _DetailChip(
                                  icon: LucideIcons.clock,
                                  label: deliveryTime!,
                                  color: AppColors.info,
                                ),
                              ],
                              if (rating != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _DetailChip(
                                  icon: LucideIcons.star,
                                  label: rating!,
                                  color: AppColors.warning,
                                ),
                              ],
                            ],
                          ),

                        if (description != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        if (extraContent != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          extraContent!,
                        ],

                        const SizedBox(height: AppSpacing.xxl),

                        // أزرار الإجراء
                        AppButton(
                          label: primaryActionLabel,
                          icon: LucideIcons.arrowRight,
                          onPressed: onPrimaryAction,
                        ),
                        if (secondaryActionLabel != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: secondaryActionLabel!,
                            icon: LucideIcons.heart,
                            isOutlined: true,
                            onPressed: onSecondaryAction,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ★ لون النص من اللوحة الديناميكية.
    final textColor = context.textColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
