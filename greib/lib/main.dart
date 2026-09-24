import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/location/location_controller.dart';
import 'core/notifications/notification_manager.dart';
import 'core/storage/app_prefs.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/router/app_router.dart';
import 'features/auth/auth_service.dart';

Future<void> main() async {
  // نُهيّئ القنوات الأصلية + التخزين المحلي قبل بناء الواجهة،
  // حتى يبدأ التطبيق بالوضع الليلي/التبويب اللذين اختارهما المستخدم سابقاً.
  WidgetsFlutterBinding.ensureInitialized();
  await AppPrefs.init();

  runApp(buildGreibMenkApp());
}

/// يبني التطبيق مع كل المتحكمات المشتركة (Singleton + ChangeNotifier).
/// مفصولة عن `main()` لكي تُستخدم في الاختبارات دون تشغيل التطبيق كاملاً.
Widget buildGreibMenkApp() {
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
    child: const GreibMenkApp(),
  );
}

class GreibMenkApp extends StatelessWidget {
  const GreibMenkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp.router(
      title: 'گريب منك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}