import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:greib_menk/core/location/location_controller.dart';
import 'package:greib_menk/core/notifications/notification_manager.dart';
import 'package:greib_menk/core/permissions/permissions.dart';
import 'package:greib_menk/core/router/app_router.dart';
import 'package:greib_menk/core/storage/app_prefs.dart';
import 'package:greib_menk/core/theme/theme_controller.dart';
import 'package:greib_menk/features/auth/mock_auth.dart';

/// يُغلّف راوتراً بالتطبيق والمتحكمات المشتركة (نفس ترتيب main.dart)
/// لكي تعمل الشاشات التي تقرأ Providers (الهيدر/الشريط السفلي/الإعدادات).
Widget appWithProviders(GoRouter router) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider<AuthService>.value(value: AuthService.instance),
      ChangeNotifierProvider<NotificationManager>.value(
        value: NotificationManager.instance,
      ),
      ChangeNotifierProvider<LocationController>.value(
        value: LocationController(),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// ============================================================================
///  اختبارات شاشة البداية وتسجيل الدخول (Flow حقيقي لا صورة ثابتة).
/// ============================================================================
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.init();
    AuthService.instance.logout();
  });

  tearDown(() => AuthService.instance.logout());

  testWidgets('شاشة البداية تعرض الهوية ثم تنقل إلى شاشة التعريف أول مرة',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.createRouter()),
    );
    await tester.pump();

    expect(find.text('گريب منك'), findsWidgets);
    expect(find.text('كل خدماتك في مكان واحد'), findsOneWidget);

    // نُنهي مؤقّت الـ Splash (2500ms) ونمرّر انتقالات الراوتر.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    // مستخدم جديد لم يشاهد شاشة التعريف → Onboarding.
    expect(find.text('تخطي'), findsOneWidget);
  });

  testWidgets('شاشة البداية تتخطى التعريف إذا شاهده المستخدم سابقاً',
      (tester) async {
    SharedPreferences.setMockInitialValues({'is_first_time': true});
    await AppPrefs.init();

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.createRouter()),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('تسجيل الدخول أو إنشاء حساب'), findsOneWidget);
  });

  testWidgets('الوضع الليلي الافتراضي قابل للتبديل ويُحفظ في التفضيلات',
      (tester) async {
    final controller = ThemeController();
    expect(controller.isDarkMode, isTrue); // الوضع الداكن افتراضي

    controller.setDarkMode(false);
    await tester.pumpAndSettle();

    expect(controller.isDarkMode, isFalse);
    expect(AppPrefs.isDarkMode, isFalse);
  });

  testWidgets('شاشة الدخول تُظهر خطأً واضحاً لصيغة بريد غير صحيحة',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('تسجيل الدخول أو إنشاء حساب'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();

    expect(find.textContaining('صيغة غير صحيحة'), findsOneWidget);
  });

  testWidgets('شاشة الدخول ترفض كلمة مرور خاطئة وتقبل الصحيحة', (tester) async {
    final router = AppRouter.createRouter(initialLocation: '/login');

    await tester.pumpWidget(appWithProviders(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تسجيل الدخول أو إنشاء حساب'));
    await tester.pumpAndSettle();

    // بيانات صحيحة الشكل + كلمة مرور خاطئة → رسالة رفض.
    await tester.enterText(find.byType(TextField).first, 'user@greib.com');
    await tester.enterText(find.byType(TextField).last, 'wrong-pass');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('بيانات الدخول غير صحيحة'), findsOneWidget);

    // كلمة المرور التجريبية الصحيحة → الانتقال إلى الرئيسية.
    await tester.enterText(find.byType(TextField).last, demoPassword);
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 600));

    expect(AuthService.instance.isLoggedIn, isTrue);
    expect(AuthService.instance.currentRole, UserRole.user);
    // انتقلنا فعلاً من شاشة الدخول إلى الهيكل الرئيسي.
    expect(router.state.matchedLocation, '/home');
  });

  testWidgets('الدخول السريع كمشرف يمنح دور المشرف', (tester) async {
    // راوتر مصغّر: نتحقق من منح الدور فقط دون بناء الرئيسية الكاملة.
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('HOME_STUB')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('تسجيل الدخول أو إنشاء حساب'));
    await tester.pumpAndSettle();

    final adminChip = find.text('مشرف');
    await tester.ensureVisible(adminChip);
    await tester.pumpAndSettle();
    await tester.tap(adminChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(AuthService.instance.currentRole, UserRole.admin);
    expect(AuthService.instance.currentUser?.email, 'admin@greib.com');
  });

  testWidgets('حماية المسارات: لوحة المشرفين غير متاحة لمستخدم عادي',
      (tester) async {
    // runAsync: ننفّذ تأخير تسجيل الدخول التجريبي على الزمن الحقيقي
    // (داخل اختبار الواجهة يكون الزمن وهمياً فلا يكتمل Future.delayed).
    await tester.runAsync(() => AuthService.instance.quickLogin(UserRole.user));

    final router = AppRouter.createRouter(initialLocation: '/admin_dashboard');
    await tester.pumpWidget(appWithProviders(router));
    await tester.pump(const Duration(milliseconds: 900));

    // إعادة التوجيه حدثت فعلاً: مستخدم عادي لا يستطيع فتح لوحة المشرفين.
    expect(router.state.matchedLocation, '/home');
  });

  testWidgets('حماية المسارات: الزائر غير المسجّل يُعاد إلى شاشة الدخول',
      (tester) async {
    AuthService.instance.logout();

    final router = AppRouter.createRouter(initialLocation: '/wallet');
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(router.state.matchedLocation, '/login');
  });
}