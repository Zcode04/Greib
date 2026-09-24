import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../location/location_controller.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';
import 'location_picker.dart';

/// ============================================================================
///  SuperHeader — هيدر التطبيق الموحّد (Super-App 2026):
///   شعار + المدينة المختارة + بحث + قائمة سريعة + ليلي + إشعارات.
///  الاستخدام داخل الـ Shell: appBar: SuperHeader(onSearch:, onMore:)
/// ============================================================================
class SuperHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearch;
  final VoidCallback? onMore;

  const SuperHeader({super.key, this.onSearch, this.onMore});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _openLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      builder: (_) => const LocationPickerSheet(),
    );
  }

  void _handleSearch(BuildContext context) {
    if (onSearch != null) {
      onSearch!();
    } else {
      context.push('/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = context.watch<LocationController>();

    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentFor(isDark).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: AppColors.accentFor(isDark).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              LucideIcons.rocket,
              color: AppColors.accentFor(isDark),
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'گريب منك',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimary : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  onTap: () => _openLocationPicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.mapPin,
                          size: 13, color: theme.colorScheme.primary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          location.cityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(LucideIcons.chevronDown,
                          size: 12, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceCard : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(
                color: isDark ? AppColors.outline : AppColors.lightOutline,
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.search, size: 18, color: theme.colorScheme.onSurface),
                    onPressed: () => _handleSearch(context),
                    tooltip: 'بحث عالمي',
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.moreHorizontal, size: 18, color: theme.colorScheme.onSurface),
                    onPressed: () => onMore?.call(),
                    tooltip: 'قائمة سريعة',
                  ),
                  IconButton(
                    icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 18, color: theme.colorScheme.onSurface),
                    onPressed: () => context.read<ThemeController>().toggleTheme(),
                    tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.bell, size: 18, color: theme.colorScheme.onSurface),
                    onPressed: () => context.push('/notifications'),
                    tooltip: 'الإشعارات',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}