import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_controller.dart';

import '../core/permissions/permissions.dart';
import '../core/notifications/notification_manager.dart';
import '../features/auth/mock_auth.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showNotifications;
  final bool showDarkModeToggle;
  final bool showSearchButton;

  /// زر فتح القائمة الجانبية (Drawer) — يُستخدم في الهيكل الرئيسي فقط.
  final bool showMenuButton;
  final List<Widget>? actions;

  bool get hasActions =>
      showSearchButton ||
      showDarkModeToggle ||
      showNotifications ||
      (actions?.isNotEmpty ?? false);

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showNotifications = true,
    this.showDarkModeToggle = true,
    this.showSearchButton = true,
    this.showMenuButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ★ تجاوب: نحسب عرض الشاشة لتصغير الأيقونات/الهوامش على الشاشات الضيقة
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;

    final double iconSize = isCompact ? 18 : 20;

    // عدد الإشعارات غير المقروءة لعرضه كشارة على الجرس.
    final unreadNotifications = context.select<NotificationManager, int>(
      (manager) => manager.unreadCount,
    );

    return AppBar(
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentFor(isDark).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
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
          const SizedBox(width: AppSpacing.sm),
          // ★ تجاوب: العنوان الآن Flexible مع ellipsis بدل نص ثابت قد يفيض
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      leading: showBackButton
          ? Container(
              margin: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceCard
                    : AppColors.lightSurfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.outline : AppColors.lightOutline,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  LucideIcons.chevronLeft,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
              ),
            )
          : showMenuButton
          ? IconButton(
              icon: Icon(
                LucideIcons.menu,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
              tooltip: 'القائمة',
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          : null,
      actions: [
        // ★ تصميم حديث: تجميع الأيقونات في كبسولة (Pill) واحدة بدلاً من دوائر متكررة.
        if (hasActions)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceCard
                    : AppColors.lightSurfaceVariant,
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
                    if (showSearchButton)
                      IconButton(
                        icon: Icon(LucideIcons.search, size: iconSize),
                        onPressed: () => context.push('/search'),
                        tooltip: 'البحث',
                      ),
                    if (showDarkModeToggle)
                      IconButton(
                        icon: Icon(
                          isDark ? LucideIcons.sun : LucideIcons.moon,
                          size: iconSize,
                        ),
                        onPressed: () {
                          context.read<ThemeController>().toggleTheme();
                        },
                        tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                      ),
                    if (showNotifications)
                      IconButton(
                        icon: Badge(
                          isLabelVisible: unreadNotifications > 0,
                          label: Text(
                            unreadNotifications > 9
                                ? '+9'
                                : '$unreadNotifications',
                          ),
                          child: Icon(LucideIcons.bell, size: iconSize),
                        ),
                        onPressed: () => context.push('/notifications'),
                        tooltip: 'الإشعارات',
                      ),
                    ...?actions,
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String role;

  const DashboardHeader({super.key, required this.title, required this.role});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final roleEnum = PermissionService.roleFromString(role);
    final roleColor = roleEnum != null
        ? PermissionService.roleColor(roleEnum)
        : AppColors.accentPrimary;

    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: roleColor,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.logOut),
          onPressed: () {
            AuthService.instance.logout();
            context.go('/login');
          },
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }
}
