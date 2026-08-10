import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/theme_controller.dart';

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

    // ★ تجاوب: نحسب عرض الشاشة لتصغير الأيقونات/الهوامش على الشاشات الضيقة
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;

    final double circleSize = isCompact ? 34 : 40;
    final double iconSize = isCompact ? 18 : 20;
    final double actionMargin = isCompact ? 2 : 4;

    return AppBar(
      titleSpacing: 0,
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
              LucideIcons.rocket,
              color: AppColors.accentPrimary,
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
                onPressed: () => Navigator.maybePop(context),
              ),
            )
          : null,
      actions: [
        // ★ تجاوب: كل أزرار الإجراءات (المدمجة + الخارجية) توضع الآن داخل
        // شريط قابل للتمرير أفقياً، بحيث لا يحدث Overflow أبداً مهما كان
        // عدد الأزرار أو ضيق الشاشة — بدل الفيض الأفقي (الخطوط الصفراء/السوداء).
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: actionMargin,
                  vertical: AppSpacing.sm,
                ),
                width: circleSize,
                height: circleSize,
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
                  padding: EdgeInsets.zero,
                  icon: Icon(LucideIcons.search, size: iconSize),
                  onPressed: () {
                    // TODO: Implement search functionality
                  },
                  tooltip: 'البحث',
                ),
              ),
              if (showDarkModeToggle)
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: actionMargin,
                    vertical: AppSpacing.sm,
                  ),
                  width: circleSize,
                  height: circleSize,
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
                    padding: EdgeInsets.zero,
                    icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon,
                        size: iconSize),
                    onPressed: () {
                      context.read<ThemeController>().toggleTheme();
                    },
                    tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                  ),
                ),
              if (showNotifications)
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: actionMargin,
                    vertical: AppSpacing.sm,
                  ),
                  width: circleSize,
                  height: circleSize,
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
                    padding: EdgeInsets.zero,
                    icon: Icon(LucideIcons.bell, size: iconSize),
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    tooltip: 'الإشعارات',
                  ),
                ),
              ...?actions,
              const SizedBox(width: AppSpacing.xs),
            ],
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