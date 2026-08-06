import 'package:flutter/material.dart';
import '../../core/notifications/notification_manager.dart';
import '../../shared_widgets/app_button.dart';

// شاشة الإشعارات
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الإشعارات الوهمية
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
        padding: const EdgeInsets.all(16),
        children: [
          if (notifManager.notifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('لا توجد إشعارات', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            )
          else
            ...notifManager.notifications.map((notif) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.body),
                      const SizedBox(height: 4),
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
                            color: Colors.blue,
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
            }).toList(),
          const SizedBox(height: 16),
          if (notifManager.notifications.isNotEmpty)
            AppButton(
              label: 'مسح الكل',
              icon: Icons.delete_sweep,
              isOutlined: true,
              color: theme.colorScheme.error,
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
        return Icons.receipt_long;
      case 'order_update':
        return Icons.update;
      case 'chat':
        return Icons.chat_bubble;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }
}