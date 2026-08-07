import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class CourierScreen extends StatelessWidget {
  const CourierScreen({super.key});

  static const List<Map<String, String>> courierOptions = [
    {
      'name': 'توصيل سريع',
      'desc': 'توصيل خلال ساعة واحدة',
      'price': '25 درهم',
      'time': '60 دقيقة',
      'weight': 'حتى 5 كجم',
      'icon': '⚡',
    },
    {
      'name': 'توصيل قياسي',
      'desc': 'توصيل خلال 4 ساعات',
      'price': '15 درهم',
      'time': '240 دقيقة',
      'weight': 'حتى 5 كجم',
      'icon': '🚚',
    },
    {
      'name': 'طرود كبيرة',
      'desc': 'أثاث ومعدات كبيرة',
      'price': 'يُحدد لاحقاً',
      'time': '24 ساعة',
      'weight': 'أكثر من 20 كجم',
      'icon': '📦',
    },
    {
      'name': 'مستندات رسمية',
      'desc': 'توصيل آمن للمستندات',
      'price': '20 درهم',
      'time': '30 دقيقة',
      'weight': 'خفيف',
      'icon': '📄',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقل الطرود'),
        backgroundColor: AppColors.serviceCourier,
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
                  colors: [AppColors.serviceCourier, Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوصل أي شيء لأي مكان',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'من المستندات للأثاث الكبير',
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

            AppButton(
              label: 'إنشاء طلب شحن جديد',
              icon: LucideIcons.packagePlus,
              color: AppColors.serviceCourier,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => _buildNewShipmentSheet(context, theme),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'خيارات التوصيل',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            ...courierOptions.map((option) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.serviceCourier.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Center(
                      child: Text(
                        option['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    option['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      Text(option['desc']!),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text(option['time']!),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(LucideIcons.scale, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text(option['weight']!),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        option['price']!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.serviceCourier,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'اختر',
                        style: TextStyle(
                          color: AppColors.serviceCourier,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تتبع طردك',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'رقم التتبع',
                        hintText: 'أدخل رقم التتبع...',
                        prefixIcon: Icon(LucideIcons.search),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'تتبع الآن',
                      icon: LucideIcons.locateFixed,
                      color: AppColors.serviceCourier,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جارٍ البحث عن طردك... 🔍'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewShipmentSheet(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'طلب شحن جديد',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            decoration: const InputDecoration(
              labelText: 'وصف الطرد',
              hintText: 'مثال: صندوق ملابس',
              prefixIcon: Icon(LucideIcons.box),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            decoration: const InputDecoration(
              labelText: 'موقع الاستلام',
              prefixIcon: Icon(LucideIcons.mapPin),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            decoration: const InputDecoration(
              labelText: 'موقع التوصيل',
              prefixIcon: Icon(LucideIcons.mapPin),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'إرسال الطلب',
            icon: LucideIcons.send,
            color: AppColors.serviceCourier,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب الشحن بنجاح ✅'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
