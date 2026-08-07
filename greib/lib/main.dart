import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations.dart' as loc;
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
import 'features/splash/splash_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/tracking/tracking_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/promo/promo_codes_screen.dart';
import 'features/reviews/reviews_screen.dart';
import 'features/membership/membership_screen.dart';
import 'features/support/support_tickets_screen.dart';
import 'shared_widgets/profile_widget.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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
    final langProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      title: loc.AppLocalizations(const Locale('ar')).get('app_name'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      locale: langProvider.locale,
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/food': (context) => const FoodDeliveryScreen(),
        '/pharmacy': (context) => const PharmacyScreen(),
        '/courier': (context) => const CourierScreen(),
        '/ride': (context) => const RideScreen(),
        '/shopping': (context) => const ShoppingScreen(),
        '/tourism': (context) => const TourismScreen(),
        '/chat': (context) => const ChatListScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/agent_dashboard': (context) => const AgentDashboardScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/promo': (context) => const PromoCodesScreen(),
        '/reviews': (context) => const ReviewsScreen(),
        '/membership': (context) => const MembershipScreen(),
        '/support': (context) => const SupportTicketsScreen(),
      },
    );
  }
}