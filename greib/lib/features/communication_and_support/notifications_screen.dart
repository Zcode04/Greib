import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/notifications/notification_manager.dart';
import '../../shared_widgets/app_button.dart';
import '../../core/widgets/super_header.dart';
import '../../shared_widgets/loading_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationManager.instance.loadMockNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifManager = NotificationManager.instance;

    // ★ تجاوب: نحدد إذا كانت الشاشة ضيقة لتقصير نص الزر
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;

    return Scaffold(
      appBar: const SuperHeader(
        title: 'الإشعارات',
        showBackButton: true,
      ),
      // ★ تجاوب: LayoutBuilder يحسب المساحة المتاحة فعليًا، ونحدد حداً أقصى
      // لعرض المحتوى (700) حتى لا تتمدد الكروت بشكل غير مقروء على
      // الشاشات الكبيرة (تابلت/الشاشات العريضة)، مع توسيطها أفقياً.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth =
              constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // ★ نُقل هنا من الـ Header ليبقى الهيدر عاماً وخفيفاً
                  if (notifManager.notifications.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          notifManager.markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديد الكل كمقروء ✅')),
                          );
                        },
                        icon: const Icon(LucideIcons.checkCheck, size: 16),
                        label: Text(isCompact ? 'تحديد الكل' : 'تحديد الكل مقروء'),
                      ),
                    ),
                  if (notifManager.notifications.isEmpty)
                    EmptyState(
                      icon: LucideIcons.bellOff,
                      title: 'لا توجد إشعارات',
                      description: 'ستظهر الإشعارات هنا عند وصولها',
                    )
                  else
                    ...notifManager.notifications.map((notif) {
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
                              _getIconForType(notif.type),
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
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
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
                    }),
                  const SizedBox(height: AppSpacing.lg),
                  if (notifManager.notifications.isNotEmpty)
                    AppButton(
                      label: 'مسح الكل',
                      icon: LucideIcons.trash2,
                      isOutlined: true,
                      color: AppColors.error,
                      onPressed: () {
                        notifManager.clearAll();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order':
        return LucideIcons.receipt;
      case 'order_update':
        return LucideIcons.refreshCw;
      case 'chat':
        return LucideIcons.messagesSquare;
      case 'system':
        return LucideIcons.settings;
      default:
        return LucideIcons.bell;
    }
  }
}