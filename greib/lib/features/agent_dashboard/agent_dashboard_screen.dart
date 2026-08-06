import 'package:flutter/material.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/app_button.dart';

// لوحة الوكلاء
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

    // التحقق من الصلاحية
    if (role != UserRole.agent && role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة الوكلاء')),
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
        title: const Text('لوحة الوكلاء'),
        backgroundColor: Colors.blue,
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

  // المهام الحالية
  Widget _buildTasksTab(ThemeData theme) {
    final tasks = MockData.demoOrders.where((o) => o.agentId == AuthService.instance.currentUser?.id || o.status == 'pending').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('المهام الحالية', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'لديك ${tasks.length} مهام',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        if (tasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  Text('لا توجد مهام حالية', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          )
        else
          ...tasks.map((task) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    MockData.getIconByName(task.serviceType),
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: Text(task.description, style: theme.textTheme.titleSmall),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('من: ${task.pickupLocation}'),
                    Text('إلى: ${task.deliveryLocation}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'قبول',
                            icon: Icons.check,
                            color: Colors.green,
                            isFullWidth: false,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم قبول المهمة ✅'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            label: 'تحديث الحالة',
                            icon: Icons.update,
                            color: Colors.blue,
                            isFullWidth: false,
                            isOutlined: true,
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
          }).toList(),
      ],
    );
  }

  // المهام المنجزة
  Widget _buildCompletedTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('المهام المنجزة', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),

        // أمثلة لمهام منجزة
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ),
            title: const Text('توصيل طلب طعام'),
            subtitle: const Text('تم التسليم - ٢٠٢٤/١٢/١'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'مكتمل',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
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
              child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ),
            title: const Text('توصيل أدوية'),
            subtitle: const Text('تم التسليم - ٢٠٢٤/١١/٣٠'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'مكتمل',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // شات الوكيل
  Widget _buildAgentChatTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('محادثات العمل', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),

        // قائمة محادثات العمل
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.blue),
            ),
            title: const Text('الإدارة'),
            subtitle: const Text('التقرير اليومي جاهز'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'شاهد',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, '/chat'),
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
            title: const Text('فريق التوصيل'),
            subtitle: const Text('تم تسليم طلب الممزر ✅'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'شاهد',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, '/chat'),
          ),
        ),
      ],
    );
  }

  // نافذة تحديث الحالة
  Widget _buildStatusUpdateSheet(BuildContext context, ThemeData theme, Order task) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تحديث حالة الطلب',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'قيد التوصيل',
            icon: Icons.delivery_dining,
            color: Colors.blue,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث الحالة إلى: قيد التوصيل 🚚')),
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'تم التسليم',
            icon: Icons.check_circle,
            color: Colors.green,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد التسليم ✅')),
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'تأخير',
            icon: Icons.warning,
            color: Colors.orange,
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