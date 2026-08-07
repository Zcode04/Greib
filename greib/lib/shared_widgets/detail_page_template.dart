import 'package:flutter/material.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية مع توهج أخضر
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          accentColor.withValues(alpha: 0.08),
                          AppColors.backgroundPrimary,
                          AppColors.backgroundPrimary,
                        ]
                      : [
                          accentColor.withValues(alpha: 0.06),
                          AppColors.lightBackground,
                          AppColors.lightBackground,
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
                  backgroundColor: isDark
                      ? AppColors.backgroundPrimary
                      : AppColors.lightBackground,
                  leading: Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceCard.withValues(alpha: 0.9)
                          : AppColors.lightSurface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.outline : AppColors.lightOutline,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.maybePop(context),
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
                            color: isDark
                                ? AppColors.surfaceCard
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(AppRadii.xxl),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: AppShadows.glowGreen,
                          ),
                          child: Icon(
                            icon,
                            size: 56,
                            color: accentColor,
                          ),
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
                        if (price != null || deliveryTime != null || rating != null)
                          Row(
                            children: [
                              if (price != null)
                                _DetailChip(
                                  icon: Icons.payments_outlined,
                                  label: price!,
                                  color: AppColors.accentPrimary,
                                ),
                              if (deliveryTime != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _DetailChip(
                                  icon: Icons.schedule,
                                  label: deliveryTime!,
                                  color: AppColors.info,
                                ),
                              ],
                              if (rating != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _DetailChip(
                                  icon: Icons.star,
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
                          icon: Icons.arrow_forward,
                          onPressed: onPrimaryAction,
                        ),
                        if (secondaryActionLabel != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: secondaryActionLabel!,
                            icon: Icons.favorite_border,
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}