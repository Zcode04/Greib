import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../features/home/home_screen.dart';
import '../features/food_delivery/food_delivery_screen.dart';
import '../features/pharmacy/pharmacy_screen.dart';
import '../features/courier/courier_screen.dart';
import '../features/ride/ride_screen.dart';
import '../features/shopping/shopping_screen.dart';
import '../features/tourism_events/tourism_screen.dart';
import '../features/services/service_detail_screen.dart';
import '../core/mock_data/mock_data.dart';
import '../features/chat/chat_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/doctors/doctors_list_screen.dart';
import '../features/doctors/doctor_profile_screen.dart';
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



  static final Map<String, WidgetBuilder> _mainRouteBuilders = {
    '/home': (_) => HomeScreen(),
    '/food': (_) => FoodDeliveryScreen(),
    '/pharmacy': (_) => PharmacyScreen(),
    '/courier': (_) => CourierScreen(),
    '/ride': (_) => RideScreen(),
    '/shopping': (_) => ShoppingScreen(),
    '/tourism': (_) => TourismScreen(),
    '/chat': (_) => ChatListScreen(),
    // ===== المسارات الجديدة (١٨ خدمة) — شاشة مخصّصة لكل خدمة =====
    ..._buildNewServiceRoutes(),
    '/wallet': (_) => WalletScreen(),
    '/favorites': (_) => FavoritesScreen(),
    '/doctors': (_) => const DoctorsListScreen(),
    '/doctor_profile': (_) => const DoctorProfileScreen(),
    '/profile': (_) => ProfileScreen(),
  };

  int _currentNavIndex = 2;

  void _handleRouteChanged(String routeName) {
    // No-op since we don't update title anymore
  }

  // بناء مسارات الخدمات الجديدة ديناميكياً من قائمة MockData.services
  static Map<String, WidgetBuilder> _buildNewServiceRoutes() {
    final newServiceIds = {
      'moving', 'taxi', 'electricity', 'water', 'laundry', 'clothes',
      'phones', 'devices', 'appliances', 'office', 'delivery', 'estore',
      'travel', 'tourism_extra', 'medicine', 'pharmacy_extra', 'consult', 'freight',
    };
    final routes = <String, WidgetBuilder>{};
    for (final service in MockData.services) {
      if (newServiceIds.contains(service.id)) {
        routes[service.route] = (_) => ServiceDetailScreen(service: service);
      }
    }
    return routes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'گريب منك'),
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
