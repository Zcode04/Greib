import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/header.dart';
import '../../shared_widgets/loading_states.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _openTickets = [
    {
      'id': 't1',
      'subject': 'تأخير في التوصيل',
      'description': 'الطلب تأخر أكثر من الوقت المتوقع',
      'status': 'open',
      'time': 'منذ ساعتين',
      'type': 'complaint',
    },
    {
      'id': 't2',
      'subject': 'سؤال عن الفاتورة',
      'description': 'أريد توضيح بنود الفاتورة',
      'status': 'open',
      'time': 'منذ يوم',
      'type': 'inquiry',
    },
  ];

  final List<Map<String, dynamic>> _closedTickets = [
    {
      'id': 't3',
      'subject': 'مشكلة في الدفع',
      'description': 'تم حلها عبر الدعم',
      'status': 'closed',
      'time': 'منذ أسبوع',
      'type': 'payment',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: Header(
        title: 'تذاكر الدعم',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle),
            onPressed: () => _showCreateTicketDialog(context),
            tooltip: 'إنشاء تذكرة',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                _buildTab(context, 'مفتوحة (${_openTickets.length})', 0),
                _buildTab(context, 'مغلقة (${_closedTickets.length})', 1),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildTicketsList(context, _openTickets, isOpen: true)
                : _buildTicketsList(context, _closedTickets, isOpen: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: isSelected ? AppShadows.xs : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList(
    BuildContext context,
    List<Map<String, dynamic>> tickets, {
    required bool isOpen,
  }) {
    final theme = Theme.of(context);

    if (tickets.isEmpty) {
      return EmptyState(
        icon: isOpen ? LucideIcons.headphones : LucideIcons.history,
        title: isOpen ? 'لا توجد تذاكر مفتوحة' : 'لا توجد تذاكر مغلقة',
        description: isOpen
            ? 'أنشئ تذكرة دعم جديدة وسيتم الرد عليك قريباً'
            : 'التذاكر المغلقة ستظهر هنا',
        actionLabel: isOpen ? 'إنشاء تذكرة' : null,
        onAction: isOpen ? () => _showCreateTicketDialog(context) : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isOpen ? context.accentColor : context.textColors.tertiary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                isOpen ? LucideIcons.headphones : LucideIcons.checkCircle,
                color: isOpen ? context.accentColor : context.textColors.tertiary,
                size: 24,
              ),
            ),
            title: Text(
              ticket['subject'] as String,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket['description'] as String),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ticket['time'] as String,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isOpen
                    ? context.iconColors.success.withValues(alpha: 0.1)
                    : context.textColors.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                isOpen ? 'مفتوحة' : 'مغلقة',
                style: TextStyle(
                  color: isOpen ? context.iconColors.success : context.textColors.tertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              if (isOpen) {
                _showTicketDetail(context, ticket);
              }
            },
          ),
        );
      },
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء تذكرة دعم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'موضوع التذكرة',
                hintText: 'مثال: مشكلة في التوصيل',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف المشكلة',
                hintText: 'اشرح مشكلتك بالتفصيل...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
          AppButton(
            label: 'إرسال',
            isFullWidth: false,
            onPressed: () {
              if (subjectController.text.isEmpty) return;

              setState(() {
                _openTickets.add({
                  'id': 't${DateTime.now().millisecondsSinceEpoch}',
                  'subject': subjectController.text,
                  'description': descController.text,
                  'status': 'open',
                  'time': 'الآن',
                  'type': 'inquiry',
                });
              });

              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم إنشاء تذكرة الدعم بنجاح ✅'),
                  backgroundColor: context.iconColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTicketDetail(BuildContext context, Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket['subject'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket['description'] as String),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.iconColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.headphones, color: context.iconColors.success, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'فريق الدعم يرد خلال ٢٤ ساعة',
                      style: TextStyle(color: context.iconColors.success, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
