import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  static const List<Map<String, String>> pharmacies = [
    {
      'name': 'صيدلية أستر',
      'desc': 'أدوية ومستلزمات طبية',
      'rating': '4.9',
      'time': '20 دقيقة',
      'image': '💊',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية دبي',
      'desc': 'أدوية ووصفات طبية',
      'rating': '4.7',
      'time': '15 دقيقة',
      'image': '⚕️',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية الحياة',
      'desc': 'فيتامينات ومكملات غذائية',
      'rating': '4.5',
      'time': '25 دقيقة',
      'image': '🌿',
      'available': 'مفتوحة 24/7',
    },
    {
      'name': 'صيدلية النور',
      'desc': 'مستحضرات تجميل طبية',
      'rating': '4.6',
      'time': '30 دقيقة',
      'image': '🧴',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية المدينة',
      'desc': 'معدات طبية وقياس السكر',
      'rating': '4.3',
      'time': '25 دقيقة',
      'image': '🩺',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية الشفاء',
      'desc': 'أدوية الأطفال والعناية',
      'rating': '4.8',
      'time': '18 دقيقة',
      'image': '👶',
      'available': 'مفتوحة 24/7',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصيدلية'),
        backgroundColor: AppColors.servicePharmacy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.servicePharmacy, Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  const Text('💊', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صحتك أولوية',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'الصيدليات قريبة منك ونوصل للأدوية لحد باب البيت',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عندك وصفة طبية؟',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'ارفع صورة الوصفة',
                      icon: LucideIcons.upload,
                      color: AppColors.servicePharmacy,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم استلام الوصفة، سنراجعها ونواصل معك قريباً ✅'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'أقرب الصيدليات',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            ...pharmacies.map((pharmacy) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.servicePharmacy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Center(
                      child: Text(
                        pharmacy['image']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    pharmacy['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      Text(pharmacy['desc']!),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.xs),
                          Text(pharmacy['rating']!),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(LucideIcons.clock, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text(pharmacy['time']!),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          pharmacy['available']!,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'اطلب الآن',
                        style: TextStyle(
                          color: AppColors.servicePharmacy,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
