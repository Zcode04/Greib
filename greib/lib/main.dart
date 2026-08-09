import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/mock_auth.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/agent_dashboard/agent_dashboard_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/tracking/tracking_screen.dart';
import 'features/promo/promo_codes_screen.dart';
import 'features/reviews/reviews_screen.dart';
import 'features/membership/membership_screen.dart';
import 'features/support/support_tickets_screen.dart';
import 'features/doctors/doctors_list_screen.dart';
import 'features/doctors/doctor_profile_screen.dart';
import 'shared_widgets/main_shell_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: const GreibMenkApp(),
    ),
  );
}

class GreibMenkApp extends StatelessWidget {
  const GreibMenkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShellScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/agent_dashboard': (context) => const AgentDashboardScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/promo': (context) => const PromoCodesScreen(),
        '/reviews': (context) => const ReviewsScreen(),
        '/membership': (context) => const MembershipScreen(),
        '/support': (context) => const SupportTicketsScreen(),
        '/doctors': (context) => const DoctorsListScreen(),
        '/doctor_profile': (context) => const DoctorProfileScreen(),
      },
    );
  }
}