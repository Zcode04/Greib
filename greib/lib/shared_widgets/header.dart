import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/permissions/permissions.dart';
import '../features/auth/mock_auth.dart';

// هيدر موحد يُعاد استخدامه في كل الشاشات
class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showNotifications;
  final bool showDarkModeToggle;
  final List<Widget>? actions;

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showNotifications = true,
    this.showDarkModeToggle = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.rocket_launch,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      actions: [
        if (showDarkModeToggle)
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeController>().toggleTheme();
            },
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          ),
        if (showNotifications)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            tooltip: 'الإشعارات',
          ),
        if (actions != null) ...actions!,
        // زر البروفايل
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          tooltip: 'البروفايل',
        ),
      ],
    );
  }
}

// هيدر مخصص للوحات التحكم
class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String role;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.role,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final roleEnum = PermissionService.roleFromString(role);
    final roleColor = roleEnum != null
        ? PermissionService.roleColor(roleEnum)
        : AppColors.primary;

    return AppBar(
      title: Text(title),
      backgroundColor: roleColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            AuthService.instance.logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }
}