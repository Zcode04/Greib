import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../notifications/notification_manager.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';
import 'header_collapse_state.dart';

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

    // ★ انكماش الهيدر عند التمرير: حجم كامل أول دخول → مصغّر مرتفع.
    return ValueListenableBuilder<bool>(
      valueListenable: HeaderCollapseState.collapsed,
      builder: (context, collapsed, _) {
        final toolbarH = collapsed ? 48.0 : 64.0;
        final logoSize = collapsed ? 18.0 : 24.0;
        final iconSize = collapsed ? 15.0 : 18.0;
        final btnBox = collapsed ? 28.0 : 32.0;
        // ★ نفس فكرة الشريط السفلي: المحتوى يمر خلف الهيدر مع بلور.
        // طبقة زجاجية (لون الخلفية + blur) خلف محتوى الهيدر فقط —
        // الحجم والشكل والأزرار لم تُمس.
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    color: (isDark
                            ? AppColors.background
                            : AppColors.lightBackground)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: AppBar(
            toolbarHeight: toolbarH,
            // ★ هيدر بدون خلفية: شفاف تماماً.
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: showBackButton ? 0 : AppSpacing.md,
            automaticallyImplyLeading: showBackButton,
            leading: showBackButton ? const BackButton() : null,
            centerTitle: false,
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: logoSize,
                color:
                    isDark ? AppColors.textPrimary : AppColors.lightText,
              ),
              child: const Text('گريب منك'),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: collapsed ? 10 : 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceCard
                        : AppColors.lightSurfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      color: isDark
                          ? AppColors.outline
                          : AppColors.lightOutline,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HeaderIconBtn(
                          box: btnBox,
                          iconSize: iconSize,
                          icon: LucideIcons.search,
                          color: theme.colorScheme.onSurface,
                          onPressed: () =>
                              _handleSearch(context),
                          tooltip: 'بحث عالمي',
                        ),
                        _HeaderIconBtn(
                          box: btnBox,
                          iconSize: iconSize,
                          icon: isDark
                              ? LucideIcons.sun
                              : LucideIcons.moon,
                          color: theme.colorScheme.onSurface,
                          onPressed: () => context
                              .read<ThemeController>()
                              .toggleTheme(),
                          tooltip: isDark
                              ? 'الوضع النهاري'
                              : 'الوضع الليلي',
                        ),
                        _HeaderIconBtn(
                          box: btnBox,
                          iconSize: iconSize,
                          icon: LucideIcons.bell,
                          badge: unreadNotifications > 9
                              ? '+9'
                              : '$unreadNotifications',
                          showBadge: unreadNotifications > 0,
                          color: theme.colorScheme.onSurface,
                          onPressed: () =>
                              context.push('/notifications'),
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
          ),
            ),
          ],
        );
      },
    );
  }
}

/// زر أيقونة هيدر بقياس متحرك (عالي الأداء: بدون إعادة بناء الصفحة).
class _HeaderIconBtn extends StatelessWidget {
  final double box;
  final double iconSize;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;
  final String badge;
  final bool showBadge;
  const _HeaderIconBtn({
    required this.box,
    required this.iconSize,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.badge = '',
    this.showBadge = false,
  });
  @override
  Widget build(BuildContext context) {
    final btn = IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
          minWidth: box, minHeight: box),
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: Icon(icon, size: iconSize, color: color),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
    if (!showBadge) return btn;
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
          minWidth: box, minHeight: box),
      icon: Badge(
        isLabelVisible: true,
        label: Text(badge),
        child:
            Icon(icon, size: iconSize, color: color),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}