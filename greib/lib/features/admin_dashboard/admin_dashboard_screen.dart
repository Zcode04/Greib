import 'package:flutter/material.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/app_button.dart';

// لوحة المشرفين
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = AuthService.instance.currentRole;

    // التحقق من الصلاحية
    if (role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة المشرفين')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'ليس لديك صلاحية الوصول',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'العودة للرئيسية',
                icon: Icons.home,
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المشرفين'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.instance.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _buildBody(theme),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.people), label: 'المستخدمين'),
          NavigationDestination(icon: Icon(Icons.group), label: 'المجموعات'),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_selectedTab) {
      case 0:
        return _buildDashboard(theme);
      case 1:
        return _buildOrdersTab(theme);
      case 2:
        return _buildUsersTab(theme);
      case 3:
        return _buildGroupsTab(theme);
      default:
        return _buildDashboard(theme);
    }
  }

  // لوحة الإحصائيات
  Widget _buildDashboard(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نظرة عامة', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),

          // بطاقات الإحصائيات
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(theme, 'الطلبات', '12', Icons.receipt_long, Colors.blue),
              _buildStatCard(theme, 'المستخدمين', '1,234', Icons.people, Colors.green),
              _buildStatCard(theme, 'الوكلاء', '18', Icons.delivery_dining, Colors.orange),
              _buildStatCard(theme, 'الإيرادات', '45,600', Icons.monetization_on, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),

          // آخر الطلبات
          Text('آخر الطلبات', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),

          ...MockData.demoOrders.map((order) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(order.description),
                subtitle: Text('${order.pickupLocation} → ${order.deliveryLocation}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status == 'pending'
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status == 'pending' ? 'قيد الانتظار' : 'قيد التنفيذ',
                    style: TextStyle(
                      fontSize: 12,
                      color: order.status == 'pending' ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(value, style: theme.textTheme.headlineMedium),
            Text(title, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  // تبويب إدارة الطلبات
  Widget _buildOrdersTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('إدارة الطلبات', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),

        // أزرار الإجراءات
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'كل الطلبات',
                icon: Icons.list,
                isOutlined: true,
                color: Colors.blue,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: 'تعيين وكيل',
                icon: Icons.person_add,
                color: Colors.blue,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تعيين وكيل للطلبات المحددة ✅')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // قائمة الطلبات
        ...MockData.demoOrders.map((order) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              leading: Icon(
                MockData.getIconByName(order.serviceType),
                color: Colors.blue,
              ),
              title: Text(order.description),
              subtitle: Text('حالة: ${order.status}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الاستلام: ${order.pickupLocation}'),
                      Text('التوصيل: ${order.deliveryLocation}'),
                      Text('السعر: ${order.price} درهم'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'تعيين وكيل',
                              icon: Icons.person_pin,
                              isOutlined: true,
                              color: Colors.blue,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              label: 'إلغاء',
                              icon: Icons.cancel,
                              isOutlined: true,
                              color: Colors.red,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // تبويب إدارة المستخدمين
  Widget _buildUsersTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('إدارة المستخدمين', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),

        // قائمة المستخدمين
        ...MockData.demoAccounts.map((user) {
          final roleEnum = PermissionService.roleFromString(user.role);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: roleEnum != null
                    ? PermissionService.roleColor(roleEnum).withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                child: Icon(
                  roleEnum != null ? PermissionService.roleIcon(roleEnum) : Icons.person,
                  color: roleEnum != null ? PermissionService.roleColor(roleEnum) : Colors.grey,
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleEnum != null
                      ? PermissionService.roleColor(roleEnum).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  roleEnum != null ? PermissionService.roleLabel(roleEnum) : user.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: roleEnum != null ? PermissionService.roleColor(roleEnum) : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // تبويب إدارة المجموعات
  Widget _buildGroupsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('المجموعات', style: theme.textTheme.headlineMedium),
            AppButton(
              label: 'مجموعة جديدة',
              icon: Icons.add,
              color: Colors.red,
              isFullWidth: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم فتح إنشاء مجموعة جديدة...')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // المجموعات
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group, color: Colors.blue),
            ),
            title: const Text('فريق التوصيل - دبي'),
            subtitle: const Text('٣ أعضاء'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group, color: Colors.green),
            ),
            title: const Text('خدمة العملاء'),
            subtitle: const Text('٥ أعضاء'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group, color: Colors.purple),
            ),
            title: const Text('الإدارة العليا'),
            subtitle: const Text('٢ أعضاء'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ],
    );
  }
}