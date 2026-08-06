import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/theme_controller.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/central_service_card.dart';
import '../../shared_widgets/app_button.dart';

// الصفحة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.currentUser;
    final role = AuthService.instance.currentRole;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rocket_launch,
              color: isDark ? theme.colorScheme.primary : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('گريب منك'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              // التبديل بين الوضع الليلي والنهاري
              context.read<ThemeController>().toggleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isDark ? 'تم التبديل للوضع النهاري ☀️' : 'تم التبديل للوضع الليلي 🌙',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: isDark ? 'التبديل للوضع النهاري' : 'التبديل للوضع الليلي',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            tooltip: 'الإشعارات',
          ),
        ],
      ),
      drawer: _buildDrawer(context, theme, user, role),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترحيب
            _buildWelcomeSection(theme, user, role),
            const SizedBox(height: 24),

            // قسم الخدمات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'خدماتنا',
                  style: theme.textTheme.headlineMedium,
                ),
                if (role == UserRole.admin)
                  Text(
                    'إدارة الخدمات',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // شبكة الخدمات الست
            ServicesGrid(services: MockData.services),

            const SizedBox(height: 24),

            // قسم الطلبات الحالية
            Text(
              'طلباتك الحالية',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // عرض الطلبات الوهمية
            ..._buildOrdersSection(theme),

            const SizedBox(height: 24),

            // روابط سريعة حسب الدور
            _buildRoleQuickActions(theme, role),
          ],
        ),
      ),
    );
  }

  // قسم الترحيب
  Widget _buildWelcomeSection(ThemeData theme, user, role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أهلاً ${user?.name ?? 'بك'} 👋',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role != null ? 'أنت الآن بصفة ${PermissionService.roleLabel(role)}' : 'كل خدماتك في مكان واحد',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          // شارة الترحيب
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'الخدمات الست متاحة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قائمة الطلبات الوهمية
  List<Widget> _buildOrdersSection(ThemeData theme) {
    final orders = MockData.demoOrders;

    if (orders.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'لا توجد طلبات حالية',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ];
    }

    return orders.take(2).map((order) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              MockData.getIconByName(order.serviceType),
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(order.description),
          subtitle: Text(
            '${order.pickupLocation} → ${order.deliveryLocation}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildStatusBadge(theme, order.status),
          onTap: () => Navigator.pushNamed(context, '/order_details_${order.id}'),
        ),
      );
    }).toList();
  }

  // شارة الحالة
  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'قيد الانتظار';
      case 'assigned':
        color = Colors.blue;
        label = 'تم التعيين';
      case 'in_transit':
        color = Colors.teal;
        label = 'في الطريق';
      case 'delivered':
        color = Colors.green;
        label = 'تم التسليم';
      case 'cancelled':
        color = Colors.red;
        label = 'ملغي';
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // روابط سريعة حسب الدور
  Widget _buildRoleQuickActions(ThemeData theme, UserRole? role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صفحات سريعة',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),

        // لوحة التحكم للمشرف
        if (role == UserRole.admin)
          AppButton(
            label: 'لوحة المشرفين',
            icon: Icons.admin_panel_settings,
            color: Colors.red,
            onPressed: () => Navigator.pushNamed(context, '/admin_dashboard'),
          ),

        // لوحة الوكلاء
        if (role == UserRole.agent || role == UserRole.admin) ...[
          if (role == UserRole.admin) const SizedBox(height: 12),
          AppButton(
            label: 'لوحة الوكلاء',
            icon: Icons.delivery_dining,
            color: Colors.blue,
            onPressed: () => Navigator.pushNamed(context, '/agent_dashboard'),
          ),
        ],
        const SizedBox(height: 12),

        // الشات
        AppButton(
          label: 'المحادثات',
          icon: Icons.chat_bubble,
          color: Colors.green,
          onPressed: () => Navigator.pushNamed(context, '/chat'),
        ),
        const SizedBox(height: 12),

        // البروفايل
        AppButton(
          label: 'البروفايل',
          icon: Icons.person,
          color: theme.colorScheme.primary,
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  // القائمة الجانبية
  Widget _buildDrawer(BuildContext context, ThemeData theme, user, role) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? 'زائر',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  role != null ? PermissionService.roleLabel(role) : 'غير مسجل',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble),
            title: const Text('المحادثات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/chat');
            },
          ),
          if (role == UserRole.admin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
              title: const Text('لوحة المشرفين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_dashboard');
              },
            ),
          if (role == UserRole.agent || role == UserRole.admin)
            ListTile(
              leading: const Icon(Icons.delivery_dining, color: Colors.blue),
              title: const Text('لوحة الوكلاء'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agent_dashboard');
              },
            ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('البروفايل'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('الإشعارات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              AuthService.instance.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}