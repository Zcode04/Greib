import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/location/location_controller.dart';
import 'core/notifications/notification_manager.dart';
import 'core/storage/app_prefs.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/color_palette_controller.dart';
import 'core/theme/theme_controller.dart';
import 'core/user/user_data.dart';
import 'core/router/app_router.dart';
import 'core/widgets/location_gate.dart';
import 'features/auth/auth_service.dart';
import 'features/services/data/account_repository.dart';
import 'features/services/data/services_repository.dart';


Future<void> main() async {
  // نُهيّئ القنوات الأصلية + التخزين المحلي قبل بناء الواجهة،
  // حتى يبدأ التطبيق بالوضع الليلي/التبويب اللذين اختارهما المستخدم سابقاً.
  WidgetsFlutterBinding.ensureInitialized();
  await AppPrefs.init();

  // ★ تحميل صورة البروفايل المحفوظة (تبقى بعد الخروج والعودة).
  UserData.instance.load();

  // ★ ميزة «التحكم في الألوان» معطّلة حالياً (زر «غير متاح في منطقتك»)
  //   ⇒ نضمن اعتماد التطبيق على اللوحة الافتراضية وحده: نحذف أي تخصيص
  //   محفوظ سابقاً حتى لا يعود مع تفعيل الكود لاحقاً.
  await AppPrefs.clearPaletteOverrides(isDark: true);
  await AppPrefs.clearPaletteOverrides(isDark: false);

  // نحمّل ملفات البيانات (المصدر الوحيد للحقيقة) قبل بناء الواجهة،
  // فتكون كل الصفحات جاهزة فوراً بلا شاشة تحميل وبلا وميض.
  await ServicesRepository.instance.load();
  await AccountRepository.instance.load();

  runApp(buildGreibMenkApp());
}

/// يبني التطبيق مع كل المتحكمات المشتركة (Singleton + ChangeNotifier).
/// مفصولة عن `main()` لكي تُستخدم في الاختبارات دون تشغيل التطبيق كاملاً.
Widget buildGreibMenkApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      // ★ اللوحة الافتراضية فقط (ميزة تخصيص الألوان معطّلة حالياً).
      ChangeNotifierProvider(create: (_) => ColorPaletteController()),
      ChangeNotifierProvider<AuthService>.value(value: AuthService.instance),
      // ★ ملف بيانات المستخدم المركزي (صورة البروفايل).
      ChangeNotifierProvider<UserData>.value(value: UserData.instance),
      ChangeNotifierProvider<NotificationManager>.value(
        value: NotificationManager.instance,
      ),
      ChangeNotifierProvider<LocationController>.value(
        value: LocationController(),
      ),
    ],
    child: const GreibMenkApp(),
  );
}

class GreibMenkApp extends StatelessWidget {
  const GreibMenkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    // ★ نستمع لمتحكم الألوان لسريان أي تغيير في اللوحة فوراً على كل التطبيق.
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
      routerConfig: AppRouter.router,
      // ★ بوابة إذن الموقع الدقيق عند أول فتح — داخل MaterialApp
      // حتى تتوفر Directionality وTheme لشاشة الإذن.
      builder: (context, child) =>
          LocationGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
