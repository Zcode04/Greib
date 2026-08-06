import 'package:flutter/material.dart';

// أدوار المستخدمين
enum UserRole { admin, agent, user }

class PermissionService {
  // التحقق من أن المستخدم يملك صلاحية الوصول لشاشة معينة
  static bool canAccess(UserRole? role, String route) {
    if (role == null) return false;

    switch (route) {
      // الصفحة الرئيسية متاحة للجميع
      case '/home':
        return true;

      // صفحات الخدمات متاحة للجميع
      case '/food':
      case '/pharmacy':
      case '/courier':
      case '/ride':
      case '/shopping':
      case '/tourism':
        return true;

      // الشات متاح للجميع
      case '/chat':
        return true;

      // لوحة المشرفين - للمشرف فقط
      case '/admin_dashboard':
        return role == UserRole.admin;

      // لوحة الوكلاء - للوكيل والمشرف
      case '/agent_dashboard':
        return role == UserRole.agent || role == UserRole.admin;

      // إدارة المستخدمين - للمشرف فقط
      case '/admin_users':
      case '/admin_orders':
      case '/admin_agents':
      case '/admin_groups':
        return role == UserRole.admin;

      // البروفايل - للجميع
      case '/profile':
        return true;

      // الإشعارات - للجميع
      case '/notifications':
        return true;

      default:
        return false;
    }
  }

  // التحقق من صلاحية تنفيذ إجراء (Action)
  static bool canPerform(UserRole? role, String action) {
    if (role == null) return false;

    switch (action) {
      case 'create_order':
        return true; // الجميع يمكنهم إنشاء طلب

      case 'assign_agent':
        return role == UserRole.admin;

      case 'update_order_status':
        return role == UserRole.agent || role == UserRole.admin;

      case 'create_dynamic_group':
        return role == UserRole.admin;

      case 'manage_users':
        return role == UserRole.admin;

      case 'manage_agents':
        return role == UserRole.admin;

      case 'view_all_orders':
        return role == UserRole.admin;

      case 'view_assigned_orders':
        return role == UserRole.agent || role == UserRole.admin;

      case 'send_notifications':
        return role == UserRole.admin;

      default:
        return false;
    }
  }

  // تحويل النص إلى دور
  static UserRole? roleFromString(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'agent':
        return UserRole.agent;
      case 'user':
        return UserRole.user;
      default:
        return null;
    }
  }

  // تحويل الدور إلى نص
  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.agent:
        return 'agent';
      case UserRole.user:
        return 'user';
    }
  }

  // تسمية الدور بالعربية
  static String roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مشرف';
      case UserRole.agent:
        return 'وكيل';
      case UserRole.user:
        return 'مستخدم';
    }
  }

  // لون الدور
  static Color roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.agent:
        return Colors.blue;
      case UserRole.user:
        return Colors.green;
    }
  }

  // أيقونة الدور
  static IconData roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.shield;
      case UserRole.agent:
        return Icons.delivery_dining;
      case UserRole.user:
        return Icons.person;
    }
  }

  // شاشة البداية لكل دور بعد تسجيل الدخول
  static String homeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/home'; // المشرف يذهب للوحة التحكم أو الرئيسية
      case UserRole.agent:
        return '/home';
      case UserRole.user:
        return '/home';
    }
  }
}