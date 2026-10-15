import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../notifications/notification_manager.dart';
import '../extensions/context_extensions.dart';
import '../theme/design_tokens.dart';
import '../../shared_widgets/quick_settings_sheet.dart';
import 'user_avatar.dart';
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
        final iconSize = collapsed ? 15.0 : 18.0;
        final btnBox = collapsed ? 28.0 : 32.0;


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
                            // ★ زر البروفايل: يعرض صورة المستخدم من UserData (ملف المستخدم
                            //   المركزي) ويفتح صفحة الحساب (/profile). التصميم متسق مع
                            //   _HeaderIconBtn: نفس الحجم (btnBox) ونفس الإطار.
                            //   (زر «+» وورقته UpcomingServicesSheet محفوظان — أعد
                            //   الاستيراد والاستدعاء من الأسفل إن أردت إرجاعهما.)
                            SizedBox(
                              width: btnBox,
                              child: _HeaderAvatarBtn(
                                box: btnBox,
                                iconSize: iconSize,
                                onTap:
                                    onAccount ?? () => context.push('/profile'),
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

/// زر بروفايل الهيدر: دائرة بنفس قياس أزرار الهيدر.
/// يعرض صورة المستخدم من ملف المستخدم المركزي (UserData) ويُحدَّث فور
/// تغييرها؛ بلا صورة ⇒ أيقونة مستخدم هادئة.
class _HeaderAvatarBtn extends StatelessWidget {
  final double box;
  final double iconSize;
  final VoidCallback onTap;
  const _HeaderAvatarBtn({
    required this.box,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ★ الاستماع داخل UserAvatar — أي تغيير يُعاد بناء الزر وحده (أداء عالٍ).
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: box, minHeight: box),
      tooltip: 'حسابي',
      onPressed: onTap,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: UserAvatar(
          size: iconSize + 14,
          iconSize: iconSize,
        ),
      ),
    );
  }
}