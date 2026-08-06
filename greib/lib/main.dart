import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/mock_auth.dart';
import 'features/home/home_screen.dart';
import 'features/food_delivery/food_delivery_screen.dart';
import 'features/pharmacy/pharmacy_screen.dart';
import 'features/courier/courier_screen.dart';
import 'features/ride/ride_screen.dart';
import 'features/shopping/shopping_screen.dart';
import 'features/tourism_events/tourism_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/agent_dashboard/agent_dashboard_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'shared_widgets/profile_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const GreibMenkApp(),
    ),
  );
}

// التطبيق الرئيسي
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
      initialRoute: '/login',
      routes: {
        // شاشة تسجيل الدخول
        '/login': (context) => const LoginScreen(),

        // الصفحة الرئيسية
        '/home': (context) => const HomeScreen(),

        // صفحات الخدمات الست
        '/food': (context) => const FoodDeliveryScreen(),
        '/pharmacy': (context) => const PharmacyScreen(),
        '/courier': (context) => const CourierScreen(),
        '/ride': (context) => const RideScreen(),
        '/shopping': (context) => const ShoppingScreen(),
        '/tourism': (context) => const TourismScreen(),

        // نظام الشات
        '/chat': (context) => const ChatListScreen(),

        // لوحات التحكم
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/agent_dashboard': (context) => const AgentDashboardScreen(),

        // الإشعارات
        '/notifications': (context) => const NotificationsScreen(),

        // البروفايل
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}