import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_controller.dart';
import '../core/localization/app_localizations.dart';
import '../core/permissions/permissions.dart';
import '../features/auth/mock_auth.dart';

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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: AppColors.accentPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
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
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
            )
          : null,
      actions: [
        if (showDarkModeToggle)
          Container(
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
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeController>().toggleTheme();
              },
              tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
            ),
          ),
        if (showDarkModeToggle)
          Container(
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
              icon: const Icon(Icons.language, size: 20),
              onPressed: () {
                context.read<LanguageProvider>().toggleLanguage();
              },
              tooltip: 'تبديل اللغة',
            ),
          ),
        if (showNotifications)
          Container(
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
              icon: const Icon(Icons.notifications_outlined, size: 20),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              tooltip: 'الإشعارات',
            ),
          ),
        ...?actions,
        Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceCard : AppColors.lightSurfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.outline : AppColors.lightOutline,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.person_outline, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'البروفايل',
          ),
        ),
      ],
    );
  }
}

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
        : AppColors.accentPrimary;

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: roleColor,
      foregroundColor: Colors.black,
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