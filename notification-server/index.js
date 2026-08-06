const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// مخزن الإشعارات في الذاكرة
const notifications = [];

// ==================== API Routes ====================

// اختبار الاتصال
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'سيرفر إشعارات گريب منك يعمل بنجاح 🚀',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// إرسال إشعار
app.post('/api/notifications/send', (req, res) => {
  const { title, body, type, userId, route } = req.body;

  if (!title || !body) {
    return res.status(400).json({
      success: false,
      error: 'العنوان والنص مطلوبان',
    });
  }

  const notification = {
    id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    title,
    body,
    type: type || 'system',
    userId: userId || 'all',
    route: route || '/home',
    timestamp: new Date().toISOString(),
    isRead: false,
  };

  notifications.push(notification);
  console.log('📨 إشعار جديد:', notification);

  // حذف الإشعارات القديمة (احتفاظ بآخر 50)
  if (notifications.length > 50) {
    notifications.splice(0, notifications.length - 50);
  }

  res.json({
    success: true,
    message: 'تم إرسال الإشعار بنجاح ✅',
    notification,
  });
});

// الحصول على إشعارات مستخدم
app.get('/api/notifications/:userId', (req, res) => {
  const { userId } = req.params;

  const userNotifications = notifications.filter(
    (n) => n.userId === userId || n.userId === 'all'
  );

  res.json({
    success: true,
    count: userNotifications.length,
    notifications: userNotifications,
  });
});

// تحديد إشعار كمقروء
app.put('/api/notifications/:id/read', (req, res) => {
  const { id } = req.params;
  const notification = notifications.find((n) => n.id === id);

  if (!notification) {
    return res.status(404).json({
      success: false,
      error: 'الإشعار غير موجود',
    });
  }

  notification.isRead = true;
  res.json({
    success: true,
    message: 'تم تحديد الإشعار كمقروء ✅',
    notification,
  });
});

// إرسال إشعار تجريبي
app.post('/api/notifications/test', (req, res) => {
  const testNotification = {
    id: `test_${Date.now()}`,
    title: 'إشعار تجريبي',
    body: 'هذا إشعار تجريبي من سيرفر گريب منك 🚀',
    type: 'system',
    userId: 'all',
    route: '/home',
    timestamp: new Date().toISOString(),
    isRead: false,
  };

  notifications.push(testNotification);
  console.log('🧪 تم إرسال إشعار تجريبي');

  res.json({
    success: true,
    message: 'تم إرسال الإشعار التجريبي بنجاح ✅',
    notification: testNotification,
  });
});

// الحصول على كل الإشعارات
app.get('/api/notifications', (req, res) => {
  res.json({
    success: true,
    count: notifications.length,
    notifications,
  });
});

// مسح كل الإشعارات
app.delete('/api/notifications', (req, res) => {
  notifications.length = 0;
  res.json({
    success: true,
    message: 'تم مسح كل الإشعارات 🗑️',
  });
});

// ==================== تشغيل السيرفر ====================
app.listen(PORT, () => {
  console.log(`\n═══════════════════════════════════════`);
  console.log(`  🚀 سيرفر إشعارات گريب منك`);
  console.log(`  📡 يعمل على المنفذ: ${PORT}`);
  console.log(`  🌐 http://localhost:${PORT}`);
  console.log(`  📝 API: http://localhost:${PORT}/api/notifications`);
  console.log(`═══════════════════════════════════════\n`);
});