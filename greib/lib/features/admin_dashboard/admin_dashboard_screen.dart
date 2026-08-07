import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/app_button.dart';

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

    if (role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة المشرفين')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: const Icon(LucideIcons.lock, size: 32, color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'ليس لديك صلاحية الوصول',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'العودة للرئيسية',
                  icon: LucideIcons.home,
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المشرفين'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
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
          NavigationDestination(icon: Icon(LucideIcons.layoutDashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(LucideIcons.receipt), label: 'الطلبات'),
          NavigationDestination(icon: Icon(LucideIcons.users), label: 'المستخدمين'),
          NavigationDestination(icon: Icon(LucideIcons.userPlus), label: 'المجموعات'),
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

  Widget _buildDashboard(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نظرة عامة', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(theme, 'الطلبات', '12', LucideIcons.receipt, AppColors.info),
              _buildStatCard(theme, 'المستخدمين', '1,234', LucideIcons.users, AppColors.success),
              _buildStatCard(theme, 'الوكلاء', '18', LucideIcons.bike, AppColors.secondary),
              _buildStatCard(theme, 'الإيرادات', '45,600', LucideIcons.coins, AppColors.info),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('آخر الطلبات', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          ...MockData.demoOrders.map((order) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                title: Text(order.description),
                subtitle: Text('${order.pickupLocation} → ${order.deliveryLocation}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: order.status == 'pending'
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    order.status == 'pending' ? 'قيد الانتظار' : 'قيد التنفيذ',
                    style: TextStyle(
                      fontSize: 12,
                      color: order.status == 'pending' ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
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

  Widget _buildOrdersTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('إدارة الطلبات', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.lg),

        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'كل الطلبات',
                icon: LucideIcons.list,
                type: ButtonType.secondary,
                color: AppColors.info,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'تعيين وكيل',
                icon: LucideIcons.userPlus,
                color: AppColors.info,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تعيين وكيل للطلبات المحددة ✅')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        ...MockData.demoOrders.map((order) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ExpansionTile(
              leading: Icon(
                MockData.getIconByName(order.serviceType),
                color: AppColors.info,
              ),
              title: Text(order.description),
              subtitle: Text('حالة: ${order.status}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الاستلام: ${order.pickupLocation}'),
                      Text('التوصيل: ${order.deliveryLocation}'),
                      Text('السعر: ${order.price} درهم'),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'تعيين وكيل',
                              icon: LucideIcons.userCog,
                              type: ButtonType.secondary,
                              color: AppColors.info,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: 'إلغاء',
                              icon: LucideIcons.xCircle,
                              type: ButtonType.secondary,
                              color: AppColors.error,
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
        }),
      ],
    );
  }

  Widget _buildUsersTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('إدارة المستخدمين', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.lg),

        ...MockData.demoAccounts.map((user) {
          final roleEnum = PermissionService.roleFromString(user.role);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: CircleAvatar(
                backgroundColor: roleEnum != null
                    ? PermissionService.roleColor(roleEnum).withValues(alpha: 0.15)
                    : AppColors.neutral300.withValues(alpha: 0.15),
                child: Icon(
                  roleEnum != null ? PermissionService.roleIcon(roleEnum) : LucideIcons.user,
                  color: roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.neutral500,
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: roleEnum != null
                      ? PermissionService.roleColor(roleEnum).withValues(alpha: 0.1)
                      : AppColors.neutral300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  roleEnum != null ? PermissionService.roleLabel(roleEnum) : user.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.neutral500,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGroupsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('المجموعات', style: theme.textTheme.headlineMedium),
            AppButton(
              label: 'مجموعة جديدة',
              icon: LucideIcons.plus,
              color: AppColors.error,
              isFullWidth: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم فتح إنشاء مجموعة جديدة...')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Icon(LucideIcons.users, color: AppColors.info),
            ),
            title: const Text('فريق التوصيل - دبي'),
            subtitle: const Text('٣ أعضاء'),
            trailing: const Icon(LucideIcons.chevronLeft, size: 16),
          ),
        ),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Icon(LucideIcons.users, color: AppColors.success),
            ),
            title: const Text('خدمة العملاء'),
            subtitle: const Text('٥ أعضاء'),
            trailing: const Icon(LucideIcons.chevronLeft, size: 16),
          ),
        ),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(LucideIcons.users, color: AppColors.secondaryDark),
            ),
            title: const Text('الإدارة العليا'),
            subtitle: const Text('٢ أعضاء'),
            trailing: const Icon(LucideIcons.chevronLeft, size: 16),
          ),
        ),
      ],
    );
  }
}
