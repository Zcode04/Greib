import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/notifications/notification_manager.dart';
import '../../shared_widgets/app_button.dart';
import '../../core/widgets/super_header.dart';
import '../../shared_widgets/loading_states.dart';

/// ★ ترتيب تبويبات صفحة الإشعارات من اليمين: الكل ← كربي ← بنكي ← براوى.
/// [source] = null يعني «الكل».
const List<({String label, NotificationSource? source})> _kNotificationTabs = [
  (label: 'الكل', source: null),
  (label: 'إشعارات كربي', source: NotificationSource.greib),
  (label: 'إشعارات بنكي', source: NotificationSource.bank),
  (label: 'إشعارات براوى', source: NotificationSource.barawi),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    NotificationManager.instance.loadMockNotifications();
    // إعادة البناء عند تغيير التبويب لتحديث زر «مسح الكل» أسفل الصفحة.
    _tabController = TabController(length: _kNotificationTabs.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// مسح إشعارات التبويب المعروض فقط (null = مسح الكل).
  void _clearTab(NotificationSource? source) {
    final notifManager = NotificationManager.instance;
    if (source == null) {
      notifManager.clearAll();
    } else {
      notifManager.clearBySource(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifManager = NotificationManager.instance;

    return Scaffold(
      appBar: const SuperHeader(
        title: 'الإشعارات',
        showBackButton: true,
        // ★ جرس الهيدر يظهر بنسخته الممتلئة داخل هذه الصفحة (مفعّل).
        notificationsActive: true,
      ),
      body: ListenableBuilder(
        listenable: notifManager,
        builder: (context, _) {
          // ★ التبويب المعروض حالياً: يحدّد القائمة وزر «مسح الكل».
          final currentTab = _kNotificationTabs[_tabController.index];
          final currentNotifications = currentTab.source == null
              ? notifManager.notifications
              : notifManager.notificationsBySource(currentTab.source!);

          // ★ تجاوب: حدّ أقصى لعرض المحتوى (700) حتى لا تتمدد الكروت بشكل
          // غير مقروء على الشاشات الكبيرة (تابلت/الشاشات العريضة).
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxContentWidth =
                  constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    children: [
                      // ★ شريط التبويبات بنفس نمط (الملف الشخصي | المحفظة).
                      _NotificationsTabBar(controller: _tabController),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // مولّدة من نفس مصدر ترتيب التبويبات لضمان التطابق.
                            for (final tab in _kNotificationTabs)
                              _NotificationsList(
                                notifications: tab.source == null
                                    ? notifManager.notifications
                                    : notifManager
                                        .notificationsBySource(tab.source!),
                                source: tab.source,
                              ),
                          ],
                        ),
                      ),
                      // ★ زر «مسح الكل» ثابت في أسفل الصفحة — يمسح إشعارات
                      //   التبويب المعروض فقط (الكل / كربي / بنكي / براوى).
                      if (currentNotifications.isNotEmpty)
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.lg,
                            ),
                            child: AppButton(
                              label: 'مسح الكل',
                              icon: LucideIcons.trash2,
                              isOutlined: true,
                              color: context.iconColors.error,
                              onPressed: () => _clearTab(currentTab.source),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// شريط التبويبات بنمط «underline» — مطابق لنمط صفحة الحساب
/// (الملف الشخصي | المحفظة) لاتساق التصميم في كامل التطبيق.
class _NotificationsTabBar extends StatelessWidget {
  final TabController controller;
  const _NotificationsTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.55);
    final hairline = onSurface.withValues(alpha: 0.10);

    return Container(
      // شفاف يندمج مع خلفية الصفحة + حدّ شعري سفلي يفصله عن المحتوى.
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: hairline)),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: accent, width: 2.5),
          insets: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        labelColor: accent,
        unselectedLabelColor: muted,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          for (final tab in _kNotificationTabs) Tab(text: tab.label),
        ],
      ),
    );
  }
}

/// قائمة إشعارات فئة واحدة مع زر «تحديد الكل مقروء».
/// [source] = null ⇒ «الكل»، وإلا ⇒ كربي / بنكي / براوى.
class _NotificationsList extends StatelessWidget {
  final List<AppNotification> notifications;
  final NotificationSource? source;

  const _NotificationsList({
    required this.notifications,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return EmptyState(
        icon: LucideIcons.bellOff,
        title: 'لا توجد إشعارات',
        description: 'ستظهر الإشعارات هنا عند وصولها',
      );
    }

    // ★ تجاوب: نحدد إذا كانت الشاشة ضيقة لتقصير نص الزر.
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              // يُحدّد إشعارات هذه الفئة فقط كمقروءة (null = الكل).
              NotificationManager.instance.markAllAsRead(source: source);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد الكل كمقروء ✅')),
              );
            },
            icon: const Icon(LucideIcons.checkCheck, size: 16),
            label: Text(isCompact ? 'تحديد الكل' : 'تحديد الكل مقروء'),
          ),
        ),
        ...notifications.map((notif) => _NotificationCard(notif: notif)),
      ],
    );
  }
}

/// بطاقة إشعار واحدة.
class _NotificationCard extends StatelessWidget {
  final AppNotification notif;
  const _NotificationCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifManager = NotificationManager.instance;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notif.isRead
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(
            _iconForType(notif.type),
            color: notif.isRead
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          notif.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notif.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              notif.timestamp.toString().substring(0, 16),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: notif.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          notifManager.markAsRead(notif.id);
          final route = notifManager.getRouteForNotification(notif);
          if (route != '/home') {
            context.push(route);
          }
        },
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'order':
      return LucideIcons.receipt;
    case 'order_update':
      return LucideIcons.refreshCw;
    case 'chat':
      return LucideIcons.messagesSquare;
    case 'system':
      return LucideIcons.settings;
    case 'bank':
      return LucideIcons.creditCard;
    case 'barawi':
      return LucideIcons.store;
    default:
      return LucideIcons.bell;
  }
}
