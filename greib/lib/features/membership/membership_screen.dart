import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  String _currentTier = 'regular';

  final List<Map<String, dynamic>> _tiers = [
    {
      'id': 'regular',
      'name': 'عادية',
      'nameEn': 'Regular',
      'color': AppColors.neutral500,
      'benefits': [
        'توصيل عادي',
        'دعم عملاء',
        'نقاط ولاء أساسية',
      ],
      'price': 'مجاني',
    },
    {
      'id': 'gold',
      'name': 'ذهبية',
      'nameEn': 'Gold',
      'color': AppColors.secondary,
      'benefits': [
        'توصيل أولوية',
        'دعم VIP',
        'نقاط ولاء مضاعفة',
        'خصومات حصرية',
        'توصيل مجاني شهرياً',
      ],
      'price': '29 درهم/شهر',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTierData = _tiers.firstWhere((t) => t['id'] == _currentTier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العضوية'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العضوية الحالية
            Card(
              color: _currentTier == 'gold'
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentTierData['color'] as Color,
                            (currentTierData['color'] as Color).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        boxShadow: AppShadows.md,
                      ),
                      child: Icon(
                        _currentTier == 'gold'
                            ? Icons.workspace_premium
                            : Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'العضوية ${currentTierData['name']}',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: (currentTierData['color'] as Color)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Text(
                        currentTierData['price'] as String,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: currentTierData['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...(currentTierData['benefits'] as List<String>).map((benefit) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(benefit),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'باقات العضوية',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),

            ..._tiers.map((tier) {
              final isCurrent = tier['id'] == _currentTier;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: (tier['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Icon(
                          tier['id'] == 'gold'
                              ? Icons.workspace_premium
                              : Icons.person,
                          color: tier['color'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier['name'] as String,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              tier['price'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Text(
                            'الحالية',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        AppButton(
                          label: 'ترقية',
                          type: ButtonType.secondary,
                          color: tier['color'] as Color,
                          isFullWidth: false,
                          onPressed: () {
                            setState(() => _currentTier = tier['id'] as String);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم الترقية إلى عضوية ${tier['name']}'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
