import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  static const List<Map<String, String>> stores = [
    {
      'name': 'كارفور',
      'desc': 'سوبر ماركت - كل المقاضي',
      'rating': '4.7',
      'time': '30 دقيقة',
      'icon': '🛒',
      'categories': 'مواد غذائية، مشروبات، خضار',
    },
    {
      'name': 'لولو هايبر ماركت',
      'desc': 'سوبر ماركت - أسعار مميزة',
      'rating': '4.6',
      'time': '25 دقيقة',
      'icon': '🏪',
      'categories': 'كل احتياجات البيت',
    },
    {
      'name': 'ميني مول',
      'desc': 'مقاضي سريعة',
      'rating': '4.4',
      'time': '15 دقيقة',
      'icon': '🛍️',
      'categories': 'أساسيات، خضار وفواكه',
    },
    {
      'name': 'خضار وفواكه الطازج',
      'desc': 'خضار وفواكه يومية',
      'rating': '4.8',
      'time': '20 دقيقة',
      'icon': '🥬',
      'categories': 'فواكه وخضار طازجة',
    },
    {
      'name': 'المخبز العربي',
      'desc': 'خبز وحلويات',
      'rating': '4.5',
      'time': '15 دقيقة',
      'icon': '🥖',
      'categories': 'خبز، كعك، حلويات',
    },
    {
      'name': 'بقالة 24 ساعة',
      'desc': 'مفتوح طوال اليوم',
      'rating': '4.3',
      'time': '10 دقائق',
      'icon': '🏠',
      'categories': 'أساسيات ومستلزمات يومية',
    },
  ];

  static const List<Map<String, String>> categories = [
    {'name': 'خضار وفواكه', 'icon': '🥦', 'color': '#4CAF50'},
    {'name': 'مشروبات', 'icon': '🥤', 'color': '#2196F3'},
    {'name': 'منظفات', 'icon': '🧴', 'color': '#FF9800'},
    {'name': 'مخبوزات', 'icon': '🥐', 'color': '#795548'},
    {'name': 'ألبان', 'icon': '🥛', 'color': '#03A9F4'},
    {'name': 'مواد غذائية', 'icon': '🍚', 'color': '#E91E63'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التسوق والمقاضي'),
        backgroundColor: AppColors.serviceShopping,
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
                  colors: [AppColors.serviceShopping, Color(0xFFF06292)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كل مقاضيك توصل لباب البيت',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'أكثر من 100 متجر متاح',
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

            Text(
              'تصنيفات سريعة',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تصفح ${category['name']} 🛍️'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category['icon']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          category['name']!,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'أقرب المتاجر',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            ...stores.map((store) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.serviceShopping.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Center(
                      child: Text(
                        store['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    store['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      Text(store['desc']!),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        store['categories']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.serviceShopping,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.xs),
                          Text(store['rating']!),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        store['time']!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'أنشئ قائمة مشترياتك',
              icon: LucideIcons.listPlus,
              color: AppColors.serviceShopping,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء قائمة المشتريات 🛒'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
