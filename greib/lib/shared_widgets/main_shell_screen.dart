import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../features/home/home_screen.dart';
import '../features/food_delivery/food_delivery_screen.dart';
import '../features/pharmacy/pharmacy_screen.dart';
import '../features/courier/courier_screen.dart';
import '../features/ride/ride_screen.dart';
import '../features/shopping/shopping_screen.dart';
import '../features/tourism_events/tourism_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../shared_widgets/profile_widget.dart';
import '../shared_widgets/floating_bottom_nav.dart';
import '../shared_widgets/header.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final GlobalKey<NavigatorState> innerNavigatorKey =
      GlobalKey<NavigatorState>();

  static const Map<String, String> _mainRouteTitles = {
    '/home': 'الرئيسية',
    '/food': 'توصيل الطعام',
    '/pharmacy': 'صيدلية',
    '/courier': 'شحن وتوصيل',
    '/ride': 'المشاوير',
    '/shopping': 'التسوق',
    '/tourism': 'السياحة',
    '/chat': 'المحادثات',
    '/wallet': 'المحفظة',
    '/favorites': 'المفضلة',
    '/profile': 'البروفايل',
  };

  static final Map<String, WidgetBuilder> _mainRouteBuilders = {
    '/home': (_) => HomeScreen(),
    '/food': (_) => FoodDeliveryScreen(),
    '/pharmacy': (_) => PharmacyScreen(),
    '/courier': (_) => CourierScreen(),
    '/ride': (_) => RideScreen(),
    '/shopping': (_) => ShoppingScreen(),
    '/tourism': (_) => TourismScreen(),
    '/chat': (_) => ChatListScreen(),
    '/wallet': (_) => WalletScreen(),
    '/favorites': (_) => FavoritesScreen(),
    '/profile': (_) => ProfileScreen(),
  };

  String _currentTitle = 'الرئيسية';
  int _currentNavIndex = 2;

  void _handleRouteChanged(String routeName) {
    final title = _mainRouteTitles[routeName];
    if (title != null && title != _currentTitle) {
      setState(() => _currentTitle = title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: _currentTitle),
      extendBody: true,
      body: Navigator(
        key: innerNavigatorKey,
        initialRoute: '/home',
        observers: [_ShellRouteObserver(onRouteChanged: _handleRouteChanged)],
        onGenerateRoute: (settings) {
          final builder = _mainRouteBuilders[settings.name];
          if (builder == null) return null;
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (i) {
          const tabRoutes = [
            '/wallet',
            '/chat',
            '/home',
            '/favorites',
            '/profile',
          ];
          setState(() => _currentNavIndex = i);
          innerNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            tabRoutes[i],
            (route) => false,
          );
        },
        items: const [
          FloatingNavItem(icon: LucideIcons.wallet, label: 'المحفظة'),
          FloatingNavItem(icon: LucideIcons.messageCircle, label: 'المحادثات'),
          FloatingNavItem(icon: LucideIcons.home, label: 'الرئيسية'),
          FloatingNavItem(icon: LucideIcons.heart, label: 'المفضلة'),
          FloatingNavItem(icon: LucideIcons.user, label: 'البروفايل'),
        ],
      ),
    );
  }
}

class _ShellRouteObserver extends NavigatorObserver {
  final void Function(String routeName) onRouteChanged;

  _ShellRouteObserver({required this.onRouteChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) onRouteChanged(name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = previousRoute?.settings.name;
    if (name != null) onRouteChanged(name);
  }
}
