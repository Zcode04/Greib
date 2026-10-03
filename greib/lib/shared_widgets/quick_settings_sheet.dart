import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/design_tokens.dart';
import 'background_color_dialog.dart';

class QuickSettingsItem {
  final String label;
  final IconData icon;
  final String? subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const QuickSettingsItem({
    required this.label,
    required this.icon,
    this.subtitle,
    this.enabled = true,
    this.onTap,
  });
}

/// ورقة سفلية للإعدادات السريعة — تلتصق بحافة الشاشة السفلية بعرض كامل،
/// قابلة للتمرير، وكل بند يحمل أيقونته ونصه فقط (تُملأ الحقول لاحقاً).
class QuickSettingsSheet extends StatelessWidget {
  final List<QuickSettingsItem> items;

  const QuickSettingsSheet({super.key, this.items = const []});

  /// البنود الافتراضية — [`context`] هو سياق الشاشة الأصلية (خارج الورقة)
  /// حتى نستطيع فتح حوار تغيير الخلفية بعد إغلاق الورقة.
  static List<QuickSettingsItem> defaultItemsFor(BuildContext context) => [
        QuickSettingsItem(
          label: 'تغيير لون الخلفية',
          icon: LucideIcons.palette,
          onTap: () {
            Navigator.of(context).pop();
            BackgroundColorDialog.show(context);
          },
        ),
        const QuickSettingsItem(
          label: 'تغيير لون الخطوط',
          icon: LucideIcons.type,
        ),
        const QuickSettingsItem(label: 'الأقسام', icon: LucideIcons.layoutGrid),
      ];

  static Future<void> show(
    BuildContext context, {
    List<QuickSettingsItem>? items,
  }) {
    final resolved = (items == null || items.isEmpty)
        ? defaultItemsFor(context)
        : items;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      builder: (_) => QuickSettingsSheet(items: resolved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = items.isEmpty ? defaultItemsFor(context) : items;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الإعدادات السريعة',
                    style: AppTypography.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: resolved.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 68,
                endIndent: AppSpacing.lg,
                color: theme.dividerColor,
              ),
              itemBuilder: (context, index) {
                final item = resolved[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.label,
                    style: AppTypography.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: item.subtitle == null
                      ? null
                      : Text(
                          item.subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                  trailing: Icon(
                    LucideIcons.chevronLeft,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: item.enabled ? item.onTap : null,
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}