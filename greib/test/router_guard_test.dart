import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/core/permissions/permissions.dart';
import 'package:greib_menk/core/router/app_router.dart';
import 'package:greib_menk/features/auth/mock_auth.dart';

/// ============================================================================
///  اختبارات حماية التنقّل (Route Guard) — منطق `AppRouter.resolveRedirect`.
///  هذا هو نفس المنطق الذي يمنع فتح لوحة المشرفين بصلاحيات غير كافية.
/// ============================================================================
void main() {
  tearDown(() => AuthService.instance.logout());

  test('الزائر غير المسجّل يُعاد إلى شاشة الدخول', () {
    AuthService.instance.logout();

    expect(AppRouter.resolveRedirect('/home'), '/login');
    expect(AppRouter.resolveRedirect('/wallet'), '/login');
    expect(AppRouter.resolveRedirect('/admin_dashboard'), '/login');
    expect(AppRouter.resolveRedirect('/food'), '/login');
  });

  test('المسارات العامة متاحة قبل تسجيل الدخول', () {
    AuthService.instance.logout();

    expect(AppRouter.resolveRedirect('/splash'), isNull);
    expect(AppRouter.resolveRedirect('/login'), isNull);
    expect(AppRouter.resolveRedirect('/onboarding'), isNull);
  });

  test('المستخدم العادي: الخدمات مسموحة ولوحة المشرفين ممنوعة', () async {
    await AuthService.instance.quickLogin(UserRole.user);

    expect(AppRouter.resolveRedirect('/food'), isNull);
    expect(AppRouter.resolveRedirect('/orders'), isNull);
    expect(AppRouter.resolveRedirect('/search'), isNull);
    expect(AppRouter.resolveRedirect('/wallet'), isNull);
    expect(AppRouter.resolveRedirect('/agent_dashboard'), '/home');
    expect(AppRouter.resolveRedirect('/admin_dashboard'), '/home');
  });

  test('الوكيل يصل للوحة الوكلاء ولا يصل للوحة المشرفين', () async {
    await AuthService.instance.quickLogin(UserRole.agent);

    expect(AppRouter.resolveRedirect('/agent_dashboard'), isNull);
    expect(AppRouter.resolveRedirect('/admin_dashboard'), '/home');
  });

  test('المشرف يصل إلى لوحتي المشرفين والوكلاء', () async {
    await AuthService.instance.quickLogin(UserRole.admin);

    expect(AppRouter.resolveRedirect('/admin_dashboard'), isNull);
    expect(AppRouter.resolveRedirect('/agent_dashboard'), isNull);
  });

  test('مسار غير معروف يُعاد إلى الرئيسية للمستخدمين المسجّلين', () async {
    await AuthService.instance.quickLogin(UserRole.user);

    expect(AppRouter.resolveRedirect('/not-a-real-route'), '/home');
    expect(AppRouter.resolveRedirect('/merchant_dashboard'), '/home');
  });
}