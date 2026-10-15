import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../notifications/notification_manager.dart';
import '../extensions/context_extensions.dart';
import '../theme/design_tokens.dart';
import '../../shared_widgets/quick_settings_sheet.dart';
import '../../shared_widgets/sheets/upcoming_services_sheet.dart';
import 'header_collapse_state.dart';

/// ============================================================================
///  SuperHeader — هيدر التطبيق الموحّد (Super-App 2026):
///   شعار + بحث + إشعارات + ليلي + قائمة نقطية (البحث متاح هنا وفي الشريط السفلي).
///  الاستخدام داخل الـ Shell: appBar: SuperHeader(onMore:)
/// ============================================================================
class SuperHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onMore;
  final List<Widget>? extraActions;
  final bool showBackButton;

  /// نقر أيقونة «+» في الهيدر.
  /// null = السلوك الافتراضي (فتح ورقة «خدمات قادمة»).
  final VoidCallback? onAccount;

  /// الأدوات المعروضة داخل الورقة (فارغة = الافتراضي).
  final List<QuickSettingsItem> settingsItems;

  const SuperHeader({super.key, this.title, this.onMore, this.extraActions, this.showBackButton = false, this.settingsItems = const [], this.onAccount});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final unreadNotifications = context.select<NotificationManager, int>(
      (manager) => manager.unreadCount,
    );

    // ★ انكماش الهيدر عند التمرير: حجم كامل أول دخول → مصغّر مرتفع.
    return ValueListenableBuilder<bool>(
      valueListenable: HeaderCollapseState.collapsed,
      builder: (context, collapsed, _) {
        final toolbarH = collapsed ? 48.0 : 64.0;
        final logoSize = collapsed ? 18.0 : 24.0;
        // ★ أيقونات أكبر وأوضح: 18→21 (كامل) و 15→17 (مصغّر)،
        //   مع صندوق أكبر ليبقى التباعد مريحاً.
        final iconSize = collapsed ? 17.0 : 21.0;
        final btnBox = collapsed ? 32.0 : 38.0;


        // ★ تأثير زجاجي (Glassmorphism):
        // شفافية أعلى لرؤية تأثير الضبابي بوضوح، مع ظل ناعم حقيقي للأسفل
        // ★ الحاوية الخارجية مسؤولة عن رسم الظل (حتى لا يتم قصه)
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AppBar(
                  toolbarHeight: toolbarH,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  titleSpacing: showBackButton ? 0 : AppSpacing.md,
                  automaticallyImplyLeading: showBackButton,
                  // ★ زر الرجوع يعيد دائماً إلى «الرئيسية» (/home) بدل الخروج العشوائي
                  //   من مكدّس التنقل — تجربة Super-App متوقّعة وثابتة.
                  leading: showBackButton
                      ? IconButton(
                          icon: const Icon(LucideIcons.chevronRight),
                          color: theme.colorScheme.onSurface,
                          tooltip: 'رجوع',
                          onPressed: () => context.go('/home'),
                        )
                      : null,
                  centerTitle: false,
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: logoSize,
                      color: context.textColors.primary,
                    ),
                    child: const Text('گريب منك'),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: collapsed ? 10 : 14),
                      child: Container(
                        decoration: const BoxDecoration(
                          // ★ نفس خلفية التطبيق: شفاف بدون إطار (stroke)
                          color: Colors.transparent,
                        ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ★ عرض ثابت لكل زر => مسافات أفقية متساوية بين الأيقونات
                            //   زر البحث نُقل إلى ورقة «⋯» (QuickSettingsSheet) مثل الوضع الليلي.
                            //   نسخة من أيقونة «حسابي» (نفس أيقونة الشريط السفلي) في الهيدر.
                            // ★ زر (+) بدل أيقونة «حسابي» — يفتح ورقة «خدمات قادمة»
                            //   (عرض فقط حالياً، تُطوَّر لاحقاً). صفحة الحساب
                            //   ما زالت متاحة من /profile.
                            SizedBox(
                              width: btnBox,
                              child: _HeaderIconBtn(
                                box: btnBox,
                                iconSize: iconSize,
                                icon: LucideIcons.circlePlus,
                                color: theme.colorScheme.onSurface,
                                onPressed: onAccount ??
                                    () => UpcomingServicesSheet.show(context),
                                tooltip: 'إضافة',
                              ),
                            ),
                            SizedBox(
                              width: btnBox,
                              child: _HeaderIconBtn(
                                box: btnBox,
                                iconSize: iconSize,
                                icon: LucideIcons.bell,
                                badge: unreadNotifications > 9 ? '+9' : '$unreadNotifications',
                                showBadge: unreadNotifications > 0,
                                color: theme.colorScheme.onSurface,
                                onPressed: () => context.push('/notifications'),
                                tooltip: 'الإشعارات',
                              ),
                            ),
                            // ★ زر الوضع الليلي/النهاري نُقل إلى ورقة «⋯»
                            //   (QuickSettingsSheet) ليقلّ عدد أيقونات الهيدر.
                            SizedBox(
                              width: btnBox,
                              child: _HeaderIconBtn(
                                box: btnBox,
                                iconSize: iconSize,
                                icon: LucideIcons.ellipsisVertical,
                                color: theme.colorScheme.onSurface,
                                onPressed: onMore ?? () => QuickSettingsSheet.show(context, items: settingsItems),
                                tooltip: 'المزيد',
                              ),
                            ),
                            ...?extraActions,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: null,
          ),
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
      constraints: BoxConstraints(minWidth: box, minHeight: box),
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
      constraints: BoxConstraints(minWidth: box, minHeight: box),
      icon: Badge(
        isLabelVisible: true,
        label: Text(badge),
        child: Icon(icon, size: iconSize, color: color),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}