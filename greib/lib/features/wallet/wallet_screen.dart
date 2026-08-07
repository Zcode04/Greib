import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة ونقاط الولاء'),
      ),
      body: Column(
        children: [
          // بطاقة الرصيد
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: AppShadows.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرصيد الحالي',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      'AED 250.00',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: AppColors.secondaryLight, size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '1,250 نقطة',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // تبويبات
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                _buildTab(context, 'الرصيد', 0, _selectedTab == 0),
                _buildTab(context, 'النقاط', 1, _selectedTab == 1),
                _buildTab(context, 'الاستبدال', 2, _selectedTab == 2),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // محتوى التبويب
          Expanded(
            child: _buildTabContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index, bool isSelected) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: isSelected
                ? AppShadows.xs
                : null,
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

  Widget _buildTabContent(BuildContext context, ThemeData theme) {
    switch (_selectedTab) {
      case 0:
        return _buildBalanceTab(context, theme);
      case 1:
        return _buildPointsTab(context, theme);
      case 2:
        return _buildRedeemTab(context, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBalanceTab(BuildContext context, ThemeData theme) {
    final transactions = [
      {'title': 'طلب توصيل طعام', 'amount': '-45 درهم', 'type': 'debit', 'time': 'اليوم'},
      {'title': 'شحن المحفظة', 'amount': '+200 درهم', 'type': 'credit', 'time': 'أمس'},
      {'title': 'طلب صيدلية', 'amount': '-32 درهم', 'type': 'debit', 'time': 'منذ يومين'},
      {'title': 'مكافأة ولاء', 'amount': '+25 درهم', 'type': 'credit', 'time': 'منذ ٣ أيام'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isCredit = tx['type'] == 'credit';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isCredit ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ),
            title: Text(tx['title'] as String),
            subtitle: Text(tx['time'] as String),
            trailing: Text(
              tx['amount'] as String,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isCredit ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsTab(BuildContext context, ThemeData theme) {
    final pointsHistory = [
      {'title': 'طلب توصيل طعام', 'points': '+125', 'time': 'اليوم'},
      {'title': 'طلب صيدلية', 'points': '+80', 'time': 'منذ يومين'},
      {'title': 'تقييم طلب', 'points': '+50', 'time': 'منذ ٣ أيام'},
      {'title': 'استبدال نقاط', 'points': '-200', 'time': 'منذ أسبوع'},
    ];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.1),
                AppColors.secondaryLight.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars, color: AppColors.secondary, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نقاطك الحالية', style: theme.textTheme.bodyMedium),
                    Text(
                      '1,250 نقطة',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: pointsHistory.length,
            itemBuilder: (context, index) {
              final item = pointsHistory[index];
              final isPositive = (item['points'] as String).startsWith('+');
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  title: Text(item['title'] as String),
                  subtitle: Text(item['time'] as String),
                  trailing: Text(
                    item['points'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRedeemTab(BuildContext context, ThemeData theme) {
    final rewards = [
      {'title': 'خصم 10%', 'points': '500', 'icon': Icons.percent},
      {'title': 'توصيل مجاني', 'points': '300', 'icon': Icons.local_shipping},
      {'title': 'خصم 25 درهم', 'points': '800', 'icon': Icons.card_giftcard},
      {'title': 'عضوية ذهبية', 'points': '2000', 'icon': Icons.workspace_premium},
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    reward['icon'] as IconData,
                    color: AppColors.secondaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  reward['title'] as String,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${reward['points']} نقطة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'استبدل',
                  type: ButtonType.secondary,
                  color: AppColors.secondary,
                  isFullWidth: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم استبدال المكافأة بنجاح ✅'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
