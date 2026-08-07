import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/dark_palette.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/floating_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final role = AuthService.instance.currentRole;

    return Scaffold(
      backgroundColor: DarkPalette.background,
      extendBody: true, // يسمح للـ navbar بالطفو فوق المحتوى مثل الصورة
      appBar: _buildAppBar(context, user),
      drawer: _buildDrawer(context, user, role),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(user),
            const SizedBox(height: 28),

            _sectionTitle('الخدمة المميزة'),
            const SizedBox(height: 12),
            _buildSpotlightCard(),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('خدماتنا'),
                Text('تصفح الكل',
                    style: TextStyle(color: DarkPalette.textMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 14),
            _buildServicesRow(),
            const SizedBox(height: 28),

            _sectionTitle('طلباتك الحالية'),
            const SizedBox(height: 14),
            ..._buildOrdersList(),

            if (role == UserRole.admin || role == UserRole.agent) ...[
              const SizedBox(height: 28),
              _sectionTitle('صفحات سريعة'),
              const SizedBox(height: 14),
              _buildQuickActions(context, role),
            ],
          ],
        ),
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          const routes = ['/wallet', '/chat', '/favorites', '/profile'];
          if (i < routes.length) Navigator.pushNamed(context, routes[i]);
        },
        centerIcon: Icons.home_rounded,
        isCenterActive: true,
        onCenterTap: () {}, // بالفعل في الرئيسية
        items: const [
          FloatingNavItem(
            icon: Icons.wallet_outlined,
            activeIcon: Icons.wallet,
            label: 'المحفظة',
          ),
          FloatingNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'المحادثات',
          ),
          FloatingNavItem(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: 'المفضلة',
          ),
          FloatingNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'البروفايل',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context, user) {
    return AppBar(
      backgroundColor: DarkPalette.background,
      elevation: 0,
      titleSpacing: 20,
      title: Builder(
        builder: (ctx) => Row(
          children: [
            GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DarkPalette.surfaceVariant,
                ),
                child: const Icon(Icons.person, color: Colors.white70, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أهلاً بعودتك',
                    style: TextStyle(color: DarkPalette.textMuted, fontSize: 11)),
                Text(
                  user?.name ?? 'گريب منك',
                  style: const TextStyle(
                    color: DarkPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        _circleIconButton(
          icon: Icons.search,
          onTap: () {},
        ),
        _circleIconButton(
          icon: Icons.notifications_outlined,
          onTap: () => Navigator.pushNamed(context, '/notifications'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: DarkPalette.surfaceVariant,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 18, color: Colors.white70),
          onPressed: onTap,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Hero Banner ("Explore new collection")
  // ---------------------------------------------------------------------
  Widget _buildHeroBanner(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: DarkPalette.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اكتشف خدماتنا\nالجديدة',
                  style: TextStyle(
                    color: DarkPalette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('استكشف الآن',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Icon(Icons.local_shipping_rounded,
                color: DarkPalette.neon, size: 72),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Spotlight card (البطاقة المميزة الكبيرة)
  // ---------------------------------------------------------------------
  Widget _buildSpotlightCard() {
    final service = MockData.services.isNotEmpty ? MockData.services.first : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkPalette.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [DarkPalette.neonGlow(blur: 30, alpha: 0.12)],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DarkPalette.neon.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              service != null
                  ? MockData.getIconByName(service.iconName)
                  : Icons.local_shipping,
              color: DarkPalette.neon,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service?.title ?? 'توصيل سريع',
                  style: const TextStyle(
                    color: DarkPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'متاح الآن بالقرب منك',
                  style: TextStyle(color: DarkPalette.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (service != null)
            InkWell(
              onTap: () => Navigator.pushNamed(context, service.route),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: DarkPalette.neon,
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Services row (مثل صف "Stores" الدائري في الصورة)
  // ---------------------------------------------------------------------
  Widget _buildServicesRow() {
    final services = MockData.services;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final s = services[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, s.route),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: DarkPalette.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Icon(MockData.getIconByName(s.iconName),
                      color: DarkPalette.textPrimary, size: 22),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    s.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: DarkPalette.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Orders list (بطاقات بنفس شكل بطاقة المنتج في الصورة)
  // ---------------------------------------------------------------------
  List<Widget> _buildOrdersList() {
    final orders = MockData.demoOrders;

    if (orders.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DarkPalette.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text('لا توجد طلبات حالية',
                style: TextStyle(color: DarkPalette.textMuted)),
          ),
        ),
      ];
    }

    return orders.take(3).map((order) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DarkPalette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, '/tracking'),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DarkPalette.neon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(MockData.getIconByName(order.serviceType),
                    color: DarkPalette.neon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DarkPalette.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.pickupLocation} → ${order.deliveryLocation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: DarkPalette.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = DarkPalette.warning;
        label = 'قيد الانتظار';
      case 'assigned':
        color = DarkPalette.info;
        label = 'تم التعيين';
      case 'in_transit':
        color = DarkPalette.neon;
        label = 'في الطريق';
      case 'delivered':
        color = DarkPalette.textMuted;
        label = 'تم التسليم';
      case 'cancelled':
        color = DarkPalette.error;
        label = 'ملغي';
      default:
        color = DarkPalette.textMuted;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  // ---------------------------------------------------------------------
  // Quick actions (تظهر فقط للأدوار الإدارية، بقية الوصول أصبح عبر الـ navbar)
  // ---------------------------------------------------------------------
  Widget _buildQuickActions(BuildContext context, UserRole? role) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (role == UserRole.admin)
          _chip(Icons.admin_panel_settings, 'لوحة المشرفين', DarkPalette.error,
              () => Navigator.pushNamed(context, '/admin_dashboard')),
        if (role == UserRole.agent || role == UserRole.admin)
          _chip(Icons.delivery_dining, 'لوحة الوكلاء', DarkPalette.info,
              () => Navigator.pushNamed(context, '/agent_dashboard')),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
          color: DarkPalette.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ));
  }

  // ---------------------------------------------------------------------
  // Drawer
  // ---------------------------------------------------------------------
  Widget _buildDrawer(BuildContext context, user, role) {
    return Drawer(
      backgroundColor: DarkPalette.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(color: DarkPalette.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DarkPalette.surfaceVariant,
                  ),
                  child: const Icon(Icons.person, color: DarkPalette.neon, size: 28),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'زائر',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                Text(
                  role != null ? PermissionService.roleLabel(role) : 'غير مسجل',
                  style: TextStyle(color: DarkPalette.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, 'الرئيسية', context, selected: true, onTap: () => Navigator.pop(context)),
          _drawerItem(Icons.wallet, 'المحفظة', context, onTap: () => Navigator.pushNamed(context, '/wallet')),
          _drawerItem(Icons.favorite, 'المفضلة', context, onTap: () => Navigator.pushNamed(context, '/favorites')),
          _drawerItem(Icons.chat_bubble, 'المحادثات', context, onTap: () => Navigator.pushNamed(context, '/chat')),
          _drawerItem(Icons.person, 'البروفايل', context, onTap: () => Navigator.pushNamed(context, '/profile')),
          _drawerItem(Icons.dark_mode, 'المظهر', context,
              onTap: () => context.read<ThemeController>().toggleTheme()),
          const Divider(color: Colors.white10),
          _drawerItem(Icons.logout, 'تسجيل الخروج', context, iconColor: DarkPalette.error, onTap: () {
            AuthService.instance.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, BuildContext context,
      {bool selected = false, Color? iconColor, required VoidCallback onTap}) {
    final color = iconColor ?? (selected ? DarkPalette.neon : Colors.white70);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(
              color: selected ? DarkPalette.neon : Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
      onTap: onTap,
    );
  }
}