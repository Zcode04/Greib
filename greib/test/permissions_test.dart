import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/core/permissions/permissions.dart';

/// ============================================================================
///  اختبارات حماية الصلاحيات — المنطق الذي كان مكتوباً وغير مُستدعى إطلاقاً.
///  الآن يمرّ عليه كل تنقّل في AppRouter عبر `_guard`.
/// ============================================================================
void main() {
  group('PermissionService.canAccess', () {
    test('زائر غير مسجّل لا يملك صلاحية أي مسار', () {
      expect(PermissionService.canAccess(null, '/home'), isFalse);
      expect(PermissionService.canAccess(null, '/admin_dashboard'), isFalse);
    });

    test('لوحة المشرفين للمشرف فقط', () {
      expect(PermissionService.canAccess(UserRole.admin, '/admin_dashboard'),
          isTrue);
      expect(PermissionService.canAccess(UserRole.agent, '/admin_dashboard'),
          isFalse);
      expect(PermissionService.canAccess(UserRole.user, '/admin_dashboard'),
          isFalse);
    });

    test('لوحة الوكلاء للوكيل والمشرف', () {
      expect(PermissionService.canAccess(UserRole.agent, '/agent_dashboard'),
          isTrue);
      expect(PermissionService.canAccess(UserRole.admin, '/agent_dashboard'),
          isTrue);
      expect(PermissionService.canAccess(UserRole.user, '/agent_dashboard'),
          isFalse);
    });

    test('المستخدم العادي يصل للخدمات والشاشات المشتركة', () {
      for (final route in ['/home', '/food', '/orders', '/search', '/wallet']) {
        expect(
          PermissionService.canAccess(UserRole.user, route),
          isTrue,
          reason: 'المسار $route يجب أن يكون متاحاً للمستخدم',
        );
      }
    });

    test('كل مسار خدمة من الخدمات الـ27 متاح للجميع', () {
      expect(PermissionService.serviceRoutes.length, 27);
      for (final route in PermissionService.serviceRoutes) {
        expect(PermissionService.canAccess(UserRole.user, route), isTrue);
      }
    });

    test('مسار غير معروف مرفوض', () {
      expect(PermissionService.canAccess(UserRole.admin, '/not-a-route'),
          isFalse);
    });
  });

  group('PermissionService.canPerform', () {
    test('الجميع يستطيع إنشاء طلب', () {
      expect(PermissionService.canPerform(UserRole.user, 'create_order'),
          isTrue);
    });

    test('إسناد الوكيل وإرسال الإشعارات للمشرف فقط', () {
      expect(PermissionService.canPerform(UserRole.user, 'assign_agent'),
          isFalse);
      expect(PermissionService.canPerform(UserRole.agent, 'assign_agent'),
          isFalse);
      expect(PermissionService.canPerform(UserRole.admin, 'assign_agent'),
          isTrue);
      expect(
          PermissionService.canPerform(
              UserRole.agent, 'send_notifications'),
          isFalse);
    });

    test('تحديث حالة الطلب للوكيل والمشرف', () {
      expect(
          PermissionService.canPerform(UserRole.agent, 'update_order_status'),
          isTrue);
      expect(
          PermissionService.canPerform(UserRole.user, 'update_order_status'),
          isFalse);
    });
  });

  group('تسميات الأدوار', () {
    test('تحويل الدور نصياً في الاتجاهين', () {
      for (final role in UserRole.values) {
        final asString = PermissionService.roleToString(role);
        expect(PermissionService.roleFromString(asString), role);
      }
      expect(PermissionService.roleFromString('unknown'), isNull);
      expect(PermissionService.roleLabel(UserRole.admin), 'مشرف');
      expect(PermissionService.roleLabel(UserRole.agent), 'وكيل');
      expect(PermissionService.roleLabel(UserRole.user), 'مستخدم');
    });
  });
}