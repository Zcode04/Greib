import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/app_colors.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      extendBody: true, // يسمح للـ navbar بالطفو فوق المحتوى مثل الصورة
      appBar: _buildAppBar(context, user, isDark),
      drawer: _buildDrawer(context, user, role, isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(user, isDark),
            const SizedBox(height: 28),

            _sectionTitle('الخدمة المميزة', isDark),
            const SizedBox(height: 12),
            _buildSpotlightCard(isDark),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('خدماتنا', isDark),
                Text('تصفح الكل',
                    style: TextStyle(color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 14),
            _buildServicesRow(isDark),
            const SizedBox(height: 28),

            _sectionTitle('طلباتك الحالية', isDark),
            const SizedBox(height: 14),
            ..._buildOrdersList(isDark),

            if (role == UserRole.admin || role == UserRole.agent) ...[
              const SizedBox(height: 28),
              _sectionTitle('صفحات سريعة', isDark),
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
          const routes = ['/wallet', '/chat', '/home', '/favorites', '/profile'];
          if (i < routes.length) Navigator.pushNamed(context, routes[i]);
        },
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

  // ---------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context, user, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
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
                  color: isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant,
                ),
                child: Icon(LucideIcons.user,
                    color: isDark ? Colors.white70 : AppColors.lightTextSecondary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أهلاً بعودتك',
                    style: TextStyle(
                        color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary,
                        fontSize: 11)),
                Text(
                  user?.name ?? 'گريب منك',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.lightText,
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
          icon: LucideIcons.search,
          onTap: () {},
          isDark: isDark,
        ),
        _circleIconButton(
          icon: LucideIcons.bell,
          onTap: () => Navigator.pushNamed(context, '/notifications'),
          isDark: isDark,
        ),
        _circleIconButton(
          icon: isDark ? LucideIcons.sun : LucideIcons.moon,
          onTap: () => context.read<ThemeController>().toggleTheme(),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon,
              size: 18, color: isDark ? Colors.white70 : AppColors.lightTextSecondary),
          onPressed: onTap,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Hero Banner ("Explore new collection")
  // ---------------------------------------------------------------------
  Widget _buildHeroBanner(user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? AppColors.heroGradient
              : const [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
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
                Text(
                  'اكتشف خدماتنا\nالجديدة',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : AppColors.accentPrimaryDark,
                    foregroundColor: isDark ? Colors.black : Colors.white,
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
            child: Icon(LucideIcons.truck,
                color: isDark ? AppColors.neon : AppColors.accentPrimaryDark, size: 72),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Spotlight card (البطاقة المميزة الكبيرة)
  // ---------------------------------------------------------------------
  Widget _buildSpotlightCard(bool isDark) {
    final service = MockData.services.isNotEmpty ? MockData.services.first : null;
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? AppColors.neonGlow(blur: 30, alpha: 0.12)
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: neonColor.withValues(alpha: isDark ? 0.12 : 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              service != null
                  ? MockData.getIconByName(service.iconName)
                  : LucideIcons.truck,
              color: neonColor,
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
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.lightText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'متاح الآن بالقرب منك',
                  style: TextStyle(
                      color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary,
                      fontSize: 12),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonColor,
                ),
                child: Icon(LucideIcons.chevronRight,
                    size: 16,
                    color: isDark ? Colors.black : Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Services row (مثل صف "Stores" الدائري في الصورة)
  // ---------------------------------------------------------------------
  Widget _buildServicesRow(bool isDark) {
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
                    color: isDark ? AppColors.surfaceVariant : AppColors.lightSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark ? Colors.white10 : AppColors.lightOutline),
                  ),
                  child: Icon(MockData.getIconByName(s.iconName),
                      color: isDark ? AppColors.textPrimary : AppColors.lightText,
                      size: 22),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    s.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        fontSize: 11),
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
  List<Widget> _buildOrdersList(bool isDark) {
    final orders = MockData.demoOrders;
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;

    if (orders.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text('لا توجد طلبات حالية',
                style: TextStyle(
                    color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary)),
          ),
        ),
      ];
    }

    return orders.take(3).map((order) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.white10 : AppColors.lightOutline),
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
                  color: neonColor.withValues(alpha: isDark ? 0.1 : 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(MockData.getIconByName(order.serviceType),
                    color: neonColor),
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
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.pickupLocation} → ${order.deliveryLocation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary,
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(order.status, isDark),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'قيد الانتظار';
      case 'assigned':
        color = AppColors.info;
        label = 'تم التعيين';
      case 'in_transit':
        color = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
        label = 'في الطريق';
      case 'delivered':
        color = isDark ? AppColors.textMuted : AppColors.lightTextTertiary;
        label = 'تم التسليم';
      case 'cancelled':
        color = AppColors.error;
        label = 'ملغي';
      default:
        color = isDark ? AppColors.textMuted : AppColors.lightTextTertiary;
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
          _chip(LucideIcons.shieldCheck, 'لوحة المشرفين', AppColors.error,
              () => Navigator.pushNamed(context, '/admin_dashboard')),
        if (role == UserRole.agent || role == UserRole.admin)
          _chip(LucideIcons.bike, 'لوحة الوكلاء', AppColors.info,
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

  Widget _sectionTitle(String text, bool isDark) {
    return Text(text,
        style: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.lightText,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ));
  }

  // ---------------------------------------------------------------------
  // Drawer
  // ---------------------------------------------------------------------
  Widget _buildDrawer(BuildContext context, user, role, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
                color: isDark ? AppColors.background : AppColors.lightBackground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant,
                  ),
                  child: Icon(LucideIcons.user,
                      color: isDark ? AppColors.neon : AppColors.accentPrimaryDark,
                      size: 28),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'زائر',
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightText,
                        fontWeight: FontWeight.w700)),
                Text(
                  role != null ? PermissionService.roleLabel(role) : 'غير مسجل',
                  style: TextStyle(
                      color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          _drawerItem(LucideIcons.home, 'الرئيسية', context, selected: true,
              isDark: isDark,
              onTap: () => Navigator.pop(context)),
          _drawerItem(LucideIcons.wallet, 'المحفظة', context,
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/wallet')),
          _drawerItem(LucideIcons.heart, 'المفضلة', context,
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/favorites')),
          _drawerItem(LucideIcons.messageCircle, 'المحادثات', context,
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/chat')),
          _drawerItem(LucideIcons.user, 'البروفايل', context,
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/profile')),
          _drawerItem(LucideIcons.moon, 'المظهر', context,
              isDark: isDark,
              onTap: () => context.read<ThemeController>().toggleTheme()),
          Divider(color: isDark ? Colors.white10 : AppColors.lightOutline),
          _drawerItem(LucideIcons.logOut, 'تسجيل الخروج', context,
              isDark: isDark,
              iconColor: AppColors.error,
              onTap: () {
                AuthService.instance.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, BuildContext context,
      {bool selected = false, Color? iconColor, required VoidCallback onTap, required bool isDark}) {
    final accentColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final color = iconColor ?? (selected ? accentColor : (isDark ? Colors.white70 : AppColors.lightTextSecondary));
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: isDark ? 0.12 : 0.1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title,
          style: TextStyle(
              color: selected
                  ? accentColor
                  : (isDark ? Colors.white : AppColors.lightText),
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
      onTap: onTap,
    );
  }
}