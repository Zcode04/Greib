import 'package:flutter/material.dart';

/// ★ مصدر الإشعار — يحدّد التبويب الذي يظهر فيه في صفحة الإشعارات.
enum NotificationSource {
  greib, // إشعارات كربي
  bank, // إشعارات بنكي
  barawi, // إشعارات براوى
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // order / chat / order_update / system / bank / barawi
  final DateTime timestamp;
  final bool isRead;
  final String? route; // وجهة الإشعار

  /// مصدر الإشعار (كربي / بنكي / براوى) — يُستخدم لفصله في تبويبات الإشعارات.
  final NotificationSource source;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.route,
    this.source = NotificationSource.greib,
  });
}

// إدارة الإشعارات داخل التطبيق
class NotificationManager extends ChangeNotifier {
  static final NotificationManager instance = NotificationManager._();
  NotificationManager._();

  final List<AppNotification> _notifications = [];
  final List<AppNotification> _incomingQueue = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// إشعارات كربي — تبويب «إشعارات كربي».
  List<AppNotification> get greibNotifications =>
      notificationsBySource(NotificationSource.greib);

  /// إشعارات بنكي — تبويب «إشعارات بنكي».
  List<AppNotification> get bankNotifications =>
      notificationsBySource(NotificationSource.bank);

  /// إشعارات براوى — تبويب «إشعارات براوى».
  List<AppNotification> get barawiNotifications =>
      notificationsBySource(NotificationSource.barawi);

  /// إشعارات مصدر واحد (كربي / بنكي / براوى).
  List<AppNotification> notificationsBySource(NotificationSource source) =>
      _notifications.where((n) => n.source == source).toList();

  // استقبال إشعار جديد من السيرفر (Next.js)
  void receiveNotification(AppNotification notification) {
    _incomingQueue.add(notification);
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // توجيه الإشعار إلى الشاشة المناسبة بناءً على نوعه
  String getRouteForNotification(AppNotification notification) {
    if (notification.route != null) return notification.route!;

    switch (notification.type) {
      case 'order':
        // طلب جديد → توجيه لوحة الوكلاء
        return '/agent_dashboard';
      case 'order_update':
        // تحديث طلب → توجيه الصفحة الرئيسية
        return '/home';
      case 'chat':
        // رسالة جديدة → توجيه الشات
        return '/chat';
      default:
        return '/home';
    }
  }

  // تحديد إشعار كمقروء
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final updated = AppNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        route: _notifications[index].route,
        source: _notifications[index].source,
      );
      _notifications[index] = updated;
      notifyListeners();
    }
  }

  // تحديد كل الإشعارات كمقروءة — يمكن قصره على فئة واحدة (كربي / بنكي / براوى)
  void markAllAsRead({NotificationSource? source}) {
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if (source != null && n.source != source) continue;
      _notifications[i] = AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        timestamp: n.timestamp,
        isRead: true,
        route: n.route,
        source: n.source,
      );
    }
    notifyListeners();
  }

  // إزالة إشعار
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // مسح كل الإشعارات
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // مسح إشعارات فئة واحدة فقط (كربي / بنكي / براوى) — يخدم زر «مسح الكل» لكل تبويب
  void clearBySource(NotificationSource source) {
    _notifications.removeWhere((n) => n.source == source);
    notifyListeners();
  }

  // إرسال إشعار تجريبي (يستخدم في التطبيق للعرض)
  void sendTestNotification() {
    receiveNotification(AppNotification(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'إشعار تجريبي',
      body: 'هذا إشعار تجريبي من سيرفر الإشعارات 🚀',
      type: 'system',
      timestamp: DateTime.now(),
      route: '/home',
    ));
  }

  // تحويل الإشعارات الوهمية إلى AppNotification
  void loadMockNotifications() {
    _notifications.clear();
    // ★ ثلاث فئات: كربي (greib) / بنكي (bank) / براوى (barawi).
    final List<Map<String, dynamic>> mockList = [
      {
        'id': 'n1',
        'title': 'طلب جديد',
        'body': 'لديك طلب جديد من أحمد محمد - توصيل طعام',
        'type': 'order',
        'route': '/agent_dashboard',
      },
      {
        'id': 'n2',
        'title': 'رسالة جديدة',
        'body': 'رسالة جديدة من سالم راشد في مجموعة فريق التوصيل',
        'type': 'chat',
        'route': '/chat',
      },
      {
        'id': 'n3',
        'title': 'تحديث الطلب',
        'body': 'تم تعيين وكيل لطلبك رقم ord1',
        'type': 'order_update',
        'route': '/home',
      },
      // ── إشعارات بنكي ──
      {
        'id': 'b1',
        'title': 'عملية شراء',
        'body': 'تم خصم 250 ر.س من بطاقتك · متجر المدينة',
        'type': 'bank',
        'route': '/wallet',
        'source': NotificationSource.bank,
      },
      {
        'id': 'b2',
        'title': 'إيداع راتب',
        'body': 'تم إيداع راتب الشهر في حسابك البنكي',
        'type': 'bank',
        'route': '/wallet',
        'source': NotificationSource.bank,
      },
      {
        'id': 'b3',
        'title': 'تحويل وارد',
        'body': 'استلمت تحويلاً بمبلغ 1,200 ر.س من محمد',
        'type': 'bank',
        'route': '/wallet',
        'source': NotificationSource.bank,
      },
      // ── إشعارات براوى ──
      {
        'id': 'r1',
        'title': 'تحديث جديد',
        'body': 'لديك تحديث جديد من براوى',
        'type': 'barawi',
        'route': '/home',
        'source': NotificationSource.barawi,
      },
      {
        'id': 'r2',
        'title': 'عرض خاص',
        'body': 'خصم 20% على خدمات براوى لفترة محدودة',
        'type': 'barawi',
        'route': '/home',
        'source': NotificationSource.barawi,
      },
      {
        'id': 'r3',
        'title': 'تم التأكيد',
        'body': 'تم تأكيد طلبك من براوى بنجاح',
        'type': 'barawi',
        'route': '/home',
        'source': NotificationSource.barawi,
      },
    ];

    for (final mock in mockList) {
      _notifications.add(AppNotification(
        id: mock['id']!,
        title: mock['title']!,
        body: mock['body']!,
        type: mock['type']!,
        timestamp: DateTime.now(),
        isRead: false,
        route: mock['route'],
        source: mock['source'] as NotificationSource? ?? NotificationSource.greib,
      ));
    }
    notifyListeners();
  }
}