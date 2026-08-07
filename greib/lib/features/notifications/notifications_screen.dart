import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/notifications/notification_manager.dart';
import '../../shared_widgets/app_button.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () {
              notifManager.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد الكل كمقروء ✅')),
              );
            },
            child: const Text('تحديد الكل مقروء'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.body),
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
                      Navigator.pushNamed(context, route);
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
