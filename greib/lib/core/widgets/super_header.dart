import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../notifications/notification_manager.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';

/// ============================================================================
///  SuperHeader — هيدر التطبيق الموحّد (Super-App 2026):
///   شعار + المدينة المختارة + بحث + قائمة سريعة + ليلي + إشعارات.
///  الاستخدام داخل الـ Shell: appBar: SuperHeader(onSearch:, onMore:)
/// ============================================================================
class SuperHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onSearch;
  final VoidCallback? onMore;
  final List<Widget>? extraActions;
  final bool showBackButton;

  const SuperHeader({super.key, this.title, this.onSearch, this.onMore, this.extraActions, this.showBackButton = false});

  @override
  Size get preferredSize => const Size.fromHeight(64);

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

    final unreadNotifications = context.select<NotificationManager, int>(
      (manager) => manager.unreadCount,
    );

    return AppBar(
      toolbarHeight: 64,
      titleSpacing: showBackButton ? 0 : AppSpacing.md,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton ? const BackButton() : null,
      centerTitle: false,
      title: Text(
        'گريب منك',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 24,
          color: isDark ? AppColors.textPrimary : AppColors.lightText,
        ),
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
                    icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 18, color: theme.colorScheme.onSurface),
                    onPressed: () => context.read<ThemeController>().toggleTheme(),
                    tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                  ),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: unreadNotifications > 0,
                      label: Text(
                        unreadNotifications > 9 ? '+9' : '$unreadNotifications',
                      ),
                      child: Icon(LucideIcons.bell, size: 18, color: theme.colorScheme.onSurface),
                    ),
                    onPressed: () => context.push('/notifications'),
                    tooltip: 'الإشعارات',
                  ),
                  ...?extraActions,
                ],
              ),
            ),
          ),
        ),
      ],
      // ★ الهيدر الثابت فقط: الشعار + الأيقونات.
      // أي شيء آخر (رائج / الموقع) يعيش داخل المحتوى القابل للتمرير.
      bottom: null,
    );
  }
}