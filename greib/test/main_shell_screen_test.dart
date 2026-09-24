import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:greib_menk/core/location/location_controller.dart';
import 'package:greib_menk/core/notifications/notification_manager.dart';
import 'package:greib_menk/core/permissions/permissions.dart';
import 'package:greib_menk/core/router/app_router.dart';
import 'package:greib_menk/core/storage/app_prefs.dart';
import 'package:greib_menk/core/theme/theme_controller.dart';
import 'package:greib_menk/features/auth/auth_service.dart';

/// ============================================================================
///  اختبار الهيكل الرئيسي (الشاشة التي نتنقّل منها بين الصفحات عبر الشريط
///  السفلي): الهيدر يجب أن يحتوي زر إشعارات واحداً وزر بحث واحداً فقط،
///  لأن `Header` يضيفهما مدمجَين — فتزويده بأزرار مشابهة في `actions`
///  كان يُنتج أزراراً مكررة أعلى كل صفحة.
/// ============================================================================
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.init();
    AuthService.instance.logout();
  });

  tearDown(() => AuthService.instance.logout());

  testWidgets('هيدر الهيكل الرئيسي لا يكرّر زر الإشعارات وزر البحث', (
    tester,
  ) async {
    // runAsync: تأخير تسجيل الدخول التجريبي يحتاج زمناً حقيقياً.
    await tester.runAsync(() => AuthService.instance.quickLogin(UserRole.user));

    final router = AppRouter.createRouter(initialLocation: '/home');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),
          ChangeNotifierProvider<AuthService>.value(
            value: AuthService.instance,
          ),
          ChangeNotifierProvider<NotificationManager>.value(
            value: NotificationManager.instance,
          ),
          ChangeNotifierProvider<LocationController>.value(
            value: LocationController(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // نبضات قصيرة بدل pumpAndSettle (خلفية الرئيسية متحركة بلا توقف).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // نتحقق أننا فعلاً داخل الهيكل الرئيسي (وليس مُعاداً لشاشة الدخول).
    expect(router.state.matchedLocation, '/home');

    expect(find.byTooltip('الإشعارات'), findsOneWidget);
    expect(find.byTooltip('البحث'), findsOneWidget);

    // الضغط على أيقونة البحث ينقل إلى شاشة البحث الفعلية بدل crashing.
    await tester.tap(find.byTooltip('البحث'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(router.state.matchedLocation, '/search');
    expect(find.text('مرحباً بك في البحث'), findsOneWidget);

    // العودة للرئيسية قبل اختبار تبويب المحفظة.
    router.go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // ★ الانتقال إلى تبويب المحفظة: لا يظهر جرس إشعارات ثانٍ داخل الصفحة
    // (كان محفظة الشاشة تحتوي جرساً مكرراً غير تفاعلي).
    await tester.tap(find.text('المحفظة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(LucideIcons.bell), findsOneWidget);
    expect(find.byTooltip('الإشعارات'), findsOneWidget);
  });
}
