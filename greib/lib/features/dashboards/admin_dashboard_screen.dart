import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../features/auth/auth_service.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/header.dart';

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
        appBar: Header(title: 'لوحة المشرفين'),
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
                      color: context.iconColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      size: 32,
                      color: context.iconColors.error,
                    ),
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
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: Header(
        title: 'لوحة المشرفين',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () {
              AuthService.instance.logout();
              context.go('/login');
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _buildBody(context, theme),
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

  Widget _buildBody(BuildContext context, ThemeData theme) {
    switch (_selectedTab) {
      case 0:
        return _buildDashboard(context, theme);
      case 1:
        return _buildOrdersTab(context, theme);
      case 2:
        return _buildUsersTab(context, theme);
      case 3:
        return _buildGroupsTab(context, theme);
      default:
        return _buildDashboard(context, theme);
    }
  }

  Widget _buildDashboard(BuildContext context, ThemeData theme) {
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
              _buildStatCard(context, theme, 'الطلبات', '12', LucideIcons.receipt, context.iconColors.info),
              _buildStatCard(context, theme, 'المستخدمين', '1,234', LucideIcons.users, context.iconColors.success),
              _buildStatCard(context, theme, 'الوكلاء', '18', LucideIcons.bike, context.textColors.tertiary),
              _buildStatCard(context, theme, 'الإيرادات', '45,600', LucideIcons.coins, context.iconColors.info),
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
                        ? context.iconColors.warning.withValues(alpha: 0.1)
                        : context.iconColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    order.status == 'pending' ? 'قيد الانتظار' : 'قيد التنفيذ',
                    style: TextStyle(
                      fontSize: 12,
                      color: order.status == 'pending' ? context.iconColors.warning : context.iconColors.success,
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

  Widget _buildStatCard(BuildContext context, ThemeData theme, String title, String value, IconData icon, Color color) {
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

  Widget _buildOrdersTab(BuildContext context, ThemeData theme) {
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
                color: context.iconColors.info,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'تعيين وكيل',
                icon: LucideIcons.userPlus,
                color: context.iconColors.info,
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
                color: context.iconColors.info,
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
                              color: context.iconColors.info,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: 'إلغاء',
                              icon: LucideIcons.xCircle,
                              type: ButtonType.secondary,
                              color: context.iconColors.error,
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

  Widget _buildUsersTab(BuildContext context, ThemeData theme) {
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
                    : context.textColors.tertiary.withValues(alpha: 0.15),
                child: Icon(
                  roleEnum != null ? PermissionService.roleIcon(roleEnum) : LucideIcons.user,
                  color: roleEnum != null ? PermissionService.roleColor(roleEnum) : context.textColors.tertiary,
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: roleEnum != null
                      ? PermissionService.roleColor(roleEnum).withValues(alpha: 0.1)
                      : context.textColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  roleEnum != null ? PermissionService.roleLabel(roleEnum) : user.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: roleEnum != null ? PermissionService.roleColor(roleEnum) : context.textColors.tertiary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGroupsTab(BuildContext context, ThemeData theme) {
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
              color: context.iconColors.error,
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
                color: context.iconColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(LucideIcons.users, color: context.iconColors.info),
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
                color: context.iconColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(LucideIcons.users, color: context.iconColors.success),
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
                color: context.textColors.tertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(LucideIcons.users, color: context.accentColor),
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
