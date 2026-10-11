import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:greib_menk/core/location/location_controller.dart';
import 'package:greib_menk/core/notifications/notification_manager.dart';
import 'package:greib_menk/core/permissions/permissions.dart';
import 'package:greib_menk/core/router/app_router.dart';
import 'package:greib_menk/core/storage/app_prefs.dart';
import 'package:greib_menk/core/theme/app_color_palette.dart';
import 'package:greib_menk/core/theme/app_theme.dart';
import 'package:greib_menk/core/theme/color_palette_controller.dart';
import 'package:greib_menk/core/theme/theme_controller.dart';
import 'package:greib_menk/features/auth/auth_service.dart';

/// ============================================================================
///  اختبار «التحكم في الألوان» (الميزة معطّلة حالياً — التفعيل لاحقاً):
///   1) بند الإعدادات السريعة معطّل: زر «غير متاح في منطقتك» ولا يستجيب للنقر.
///   2) الصفحة نفسها وسريان الألوان الفوري + الحفظ في AppPrefs + الاستعادة
///      (تبقى مُختبَرة كما هي لأنها ستُفعَّل لاحقاً دون تغيير).
///   3) الألوان المختارة للوضع النهاري منفصلة عن الليلي.
/// ============================================================================
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.init();
    AuthService.instance.logout();
  });

  tearDown(() => AuthService.instance.logout());

  /// يبني التطبيق بنفس ربط main.dart (الوضع + الثيم الديناميكي من اللوحة).
  Future<(GoRouter, ThemeController, ColorPaletteController)> pumpApp(
    WidgetTester tester, {
    String initialLocation = '/home',
  }) async {
    await tester.runAsync(() => AuthService.instance.quickLogin(UserRole.user));
    final router = AppRouter.createRouter(initialLocation: initialLocation);
    final themeController = ThemeController();
    final paletteController = ColorPaletteController.withStored();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeController),
          ChangeNotifierProvider.value(value: paletteController),
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
        child: _ThemedApp(themeController: themeController, router: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return (router, themeController, paletteController);
  }

  testWidgets('بند «التحكم في الألوان» معطّل: زر «غير متاح في منطقتك» ولا يستجيب للنقر', (
    tester,
  ) async {
    final (router, _, _) = await pumpApp(tester);

    // فتح ورقة الإعدادات السريعة من أيقونة «المزيد» في الهيدر.
    await tester.tap(find.byTooltip('المزيد'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // البند موجود أسفل الوضع الليلي مباشرة.
    expect(find.text('التحكم في الألوان'), findsOneWidget);
    final darkY = tester.getTopLeft(find.text('الوضع الليلي')).dy;
    final colorsY = tester.getTopLeft(find.text('التحكم في الألوان')).dy;
    expect(colorsY, greaterThan(darkY));

    // ★ زر «غير متاح في منطقتك» ظاهر ومعطّل (onPressed: null).
    final unavailableButton = find.widgetWithText(OutlinedButton, 'غير متاح في منطقتك');
    expect(unavailableButton, findsOneWidget);
    final outlined = tester.widget<OutlinedButton>(unavailableButton);
    expect(outlined.onPressed, isNull);

    // ★ نقر البند لا ينقل لأي صفحة (يبقى في الرئيسية والورقة مفتوحة).
    await tester.tap(find.text('التحكم في الألوان'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(router.state.matchedLocation, '/home');
    expect(find.text('الإعدادات السريعة'), findsOneWidget);

    // ★ نقر الزر المعطّل لا يفعل شيئاً أيضاً.
    await tester.tap(unavailableButton, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(router.state.matchedLocation, '/home');
  });

  testWidgets('اختيار لون يسري فوراً على اللوحة ويُحفظ في AppPrefs ثم يُستعاد', (
    tester,
  ) async {
    final (_, _, controller) = await pumpApp(
      tester,
      initialLocation: '/color-settings',
    );

    // الوضع الافتراضي داكن ⇒ خلفية الشاشة slate-900.
    expect(
      controller.darkPalette.background.primary,
      const Color(0xFF0F172A),
    );

    // لا مؤشر «غير محفوظ» قبل أي تغيير.
    expect(find.textContaining('غير محفوظ'), findsNothing);

    // اختيار «أبيض» من صف «خلفية الشاشة» (أول صفوف الخلفية).
    final whiteSwatch = find.byTooltip('أبيض').first;
    await tester.ensureVisible(whiteSwatch);
    await tester.tap(whiteSwatch);
    await tester.pump();

    // ★ يسري فوراً على اللوحة (دون إعادة تشغيل).
    expect(
      controller.darkPalette.background.primary,
      const Color(0xFFFFFFFF),
    );

    // شارة «غير محفوظ» تظهر بعد الرجوع لأعلى القائمة.
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, 400),
    );
    await tester.pump();
    expect(find.textContaining('غير محفوظ'), findsOneWidget);

    // حفظ التغييرات ⇒ تُثبَّت في AppPrefs.
    final saveButton = find.textContaining('حفظ التغييرات');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    final overrides = AppPrefs.paletteOverrides(isDark: true);
    expect(overrides[PaletteFieldKeys.backgroundPrimary], 0xFFFFFFFF);
    expect(controller.darkPalette.background.primary, const Color(0xFFFFFFFF));

    // استعادة الافتراضي تُرجع اللوحة الأصلية وتحذف التخصيص.
    await tester.ensureVisible(find.text('استعادة الألوان الافتراضية'));
    await tester.tap(find.text('استعادة الألوان الافتراضية'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(controller.darkPalette.background.primary, const Color(0xFF0F172A));
    expect(AppPrefs.paletteOverrides(isDark: true), isEmpty);

    // إزالة أي SnackBar معلّق قبل انتهاء الاختبار.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('اختيار لون أيقونة نشطة يسري على لوحة الأيقونات', (tester) async {
    final (_, _, controller) = await pumpApp(
      tester,
      initialLocation: '/color-settings',
    );

    // التمرير إلى عنوان صف «أيقونة نشطة» ثم اختيار أول لون أسفل العنوان
    // (يضمن استهداف صف «نشطة» وليس صف «أساسية» الذي يعلوه).
    await tester.scrollUntilVisible(
      find.text('أيقونة نشطة'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    final labelY = tester.getTopLeft(find.text('أيقونة نشطة')).dy;
    final cyanElement = find
        .byTooltip('سماوي')
        .evaluate()
        .firstWhere((e) =>
            tester.getRect(find.byWidget(e.widget)).top >= labelY - 1);
    await tester.tap(find.byWidget(cyanElement.widget));
    await tester.pump();

    expect(controller.darkPalette.icon.active, const Color(0xFF06B6D4));
    expect(controller.darkPalette.icon.primary, const Color(0xFF3B82F6));
    expect(find.byIcon(LucideIcons.check), findsWidgets);
  });

  testWidgets('تخصيص الوضع النهاري منفصل عن الليلي', (tester) async {
    final (_, themeController, controller) = await pumpApp(
      tester,
      initialLocation: '/color-settings',
    );

    // تبديل إلى الوضع النهاري من داخل الصفحة نفسها.
    themeController.setDarkMode(false);
    await tester.pumpAndSettle();
    expect(find.text('يتم تعديل ألوان الوضع النهاري'), findsOneWidget);

    final lightBefore = controller.lightPalette.background.primary;
    expect(lightBefore, const Color(0xFFF1F5F9));
    expect(
      controller.darkPalette.background.primary,
      const Color(0xFF0F172A),
    );

    final whiteSwatch = find.byTooltip('أبيض').first;
    await tester.ensureVisible(whiteSwatch);
    await tester.tap(whiteSwatch);
    await tester.pump();

    // يسري على الوضع النهاري فقط.
    expect(
      controller.lightPalette.background.primary,
      const Color(0xFFFFFFFF),
    );
    expect(
      controller.darkPalette.background.primary,
      const Color(0xFF0F172A),
    );
  });
}

/// MaterialApp بربط main.dart نفسه (الثيم يتبع اللوحة المركزية والوضع).
class _ThemedApp extends StatelessWidget {
  final ThemeController themeController;
  final GoRouter router;

  const _ThemedApp({required this.themeController, required this.router});

  @override
  Widget build(BuildContext context) {
    // ★ نفس ربط main.dart: مراقبة الوضع (لتغيير النمط) واللوحة (لتغيير الألوان).
    context.watch<ThemeController>();
    final paletteController = context.watch<ColorPaletteController>();
    return MaterialApp.router(
      title: 'گريب منك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(paletteController.lightPalette),
      darkTheme: AppTheme.darkTheme(paletteController.darkPalette),
      themeMode: themeController.themeMode,
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
