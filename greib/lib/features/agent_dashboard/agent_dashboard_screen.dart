import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/loading_states.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = AuthService.instance.currentRole;

    if (role != UserRole.agent && role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة الوكلاء')),
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
                  child: const Icon(Icons.lock, size: 32, color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'ليس لديك صلاحية الوصول',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'العودة للرئيسية',
                  icon: Icons.home,
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
        title: const Text('لوحة الوكلاء'),
        backgroundColor: AppColors.info,
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
          NavigationDestination(icon: Icon(Icons.assignment), label: 'المهام'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'منجز'),
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: 'الشات'),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_selectedTab) {
      case 0:
        return _buildTasksTab(theme);
      case 1:
        return _buildCompletedTab(theme);
      case 2:
        return _buildAgentChatTab(theme);
      default:
        return _buildTasksTab(theme);
    }
  }

  Widget _buildTasksTab(ThemeData theme) {
    final tasks = MockData.demoOrders.where((o) => o.agentId == AuthService.instance.currentUser?.id || o.status == 'pending').toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('المهام الحالية', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'لديك ${tasks.length} مهام',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),

        if (tasks.isEmpty)
          EmptyState(
            icon: Icons.check_circle,
            title: 'لا توجد مهام حالية',
            description: 'ستظهر المهام الجديدة هنا',
          )
        else
          ...tasks.map((task) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    MockData.getIconByName(task.serviceType),
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                title: Text(task.description, style: theme.textTheme.titleSmall),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    Text('من: ${task.pickupLocation}'),
                    Text('إلى: ${task.deliveryLocation}'),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'قبول',
                            icon: Icons.check,
                            color: AppColors.success,
                            isFullWidth: false,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم قبول المهمة ✅'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: 'تحديث الحالة',
                            icon: Icons.update,
                            color: AppColors.info,
                            isFullWidth: false,
                            type: ButtonType.secondary,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (ctx) => _buildStatusUpdateSheet(ctx, theme, task),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCompletedTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('المهام المنجزة', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.lg),

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
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            title: const Text('توصيل طلب طعام'),
            subtitle: const Text('تم التسليم - ٢٠٢٤/١٢/١'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Text(
                'مكتمل',
                style: TextStyle(color: AppColors.success, fontSize: 12),
              ),
            ),
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
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            title: const Text('توصيل أدوية'),
            subtitle: const Text('تم التسليم - ٢٠٢٤/١١/٣٠'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Text(
                'مكتمل',
                style: TextStyle(color: AppColors.success, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentChatTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('محادثات العمل', style: theme.textTheme.headlineMedium),
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
              child: const Icon(Icons.admin_panel_settings, color: AppColors.info),
            ),
            title: const Text('الإدارة'),
            subtitle: const Text('التقرير اليومي جاهز'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Text(
                'شاهد',
                style: TextStyle(color: AppColors.info, fontSize: 12),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, '/chat'),
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
              child: const Icon(Icons.group, color: AppColors.success),
            ),
            title: const Text('فريق التوصيل'),
            subtitle: const Text('تم تسليم طلب الممزر ✅'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Text(
                'شاهد',
                style: TextStyle(color: AppColors.success, fontSize: 12),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, '/chat'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusUpdateSheet(BuildContext context, ThemeData theme, Order task) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تحديث حالة الطلب',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'قيد التوصيل',
            icon: Icons.delivery_dining,
            color: AppColors.info,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث الحالة إلى: قيد التوصيل 🚚')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'تم التسليم',
            icon: Icons.check_circle,
            color: AppColors.success,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد التسليم ✅')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'تأخير',
            icon: Icons.warning,
            color: AppColors.warning,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم الإبلاغ عن تأخير ⏰')),
              );
            },
          ),
        ],
      ),
    );
  }
}
