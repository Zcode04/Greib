import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../features/home/home_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../shared_widgets/profile_widget.dart';
import '../shared_widgets/floating_bottom_nav.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 2;

  final List<Widget> _screens = const [
    WalletScreen(),
    ChatListScreen(),
    HomeScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          FloatingNavItem(
            icon: LucideIcons.wallet,
            label: 'المحفظة',
          ),
          FloatingNavItem(
            icon: LucideIcons.messageCircle,
            label: 'المحادثات',
          ),
          FloatingNavItem(
            icon: LucideIcons.home,
            label: 'الرئيسية',
          ),
          FloatingNavItem(
            icon: LucideIcons.heart,
            label: 'المفضلة',
          ),
          FloatingNavItem(
            icon: LucideIcons.user,
            label: 'البروفايل',
          ),
        ],
      ),
    );
  }
}
