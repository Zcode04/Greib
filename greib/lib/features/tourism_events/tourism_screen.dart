import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  static const List<Map<String, String>> places = [
    {
      'name': 'برج خليفة',
      'desc': 'أعلى برج في العالم',
      'price': '150 درهم',
      'time': 'ساعتان',
      'rating': '4.9',
      'icon': '🏙️',
      'location': 'وسط مدينة دبي',
    },
    {
      'name': 'سفاري الصحراء',
      'desc': 'مغامرة في الكثبان الرملية',
      'price': '200 درهم',
      'time': '4 ساعات',
      'rating': '4.8',
      'icon': '🏜️',
      'location': 'الصحراء - دبي',
    },
    {
      'name': 'متحف المستقبل',
      'desc': 'تجربة مستقبلية فريدة',
      'price': '120 درهم',
      'time': '3 ساعات',
      'rating': '4.7',
      'icon': '🌐',
      'location': 'الخيل - دبي',
    },
    {
      'name': 'دبي مول',
      'desc': 'أكبر مركز تسوق في العالم',
      'price': 'مجاناً',
      'time': 'مفتوح يومياً',
      'rating': '4.6',
      'icon': '🛍️',
      'location': 'وسط مدينة دبي',
    },
    {
      'name': 'قناة دبي المائية',
      'desc': 'جولة بالقارب',
      'price': '85 درهم',
      'time': 'ساعة',
      'rating': '4.5',
      'icon': '⛵',
      'location': 'القناة، دبي',
    },
    {
      'name': 'المسجد الكبير',
      'desc': 'تحفة معمارية إسلامية',
      'price': 'مجاناً',
      'time': 'ساعتان',
      'rating': '4.9',
      'icon': '🕌',
      'location': 'أبوظبي',
    },
  ];

  static const List<Map<String, String>> events = [
    {
      'title': 'مهرجان دبي للتسوق',
      'date': 'من 15 ديسمبر',
      'desc': 'تخفيضات وفعاليات',
      'icon': '🎉',
    },
    {
      'title': 'معرض إكسبو الدولي',
      'date': 'من 1 أكتوبر',
      'desc': 'معرض عالمي',
      'icon': '🌍',
    },
    {
      'title': 'المهرجان الوطني',
      'date': 'من 2 ديسمبر',
      'desc': 'احتفالات العيد الوطني',
      'icon': '🇦🇪',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('السياحة والفعاليات'),
        backgroundColor: AppColors.serviceTourism,
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
                  colors: [AppColors.serviceTourism, Color(0xFF80DEEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  const Text('✈️', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استكشف الإمارات',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'أماكن سياحية وفعاليات قريبة منك',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('فعاليات قادمة', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            ...events.map((event) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.serviceTourism.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Center(child: Text(event['icon']!, style: const TextStyle(fontSize: 24))),
                  ),
                  title: Text(event['title']!, style: theme.textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['desc']!),
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text(event['date']!, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('احجز', style: TextStyle(color: AppColors.serviceTourism, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xl),
            Text('أماكن سياحية', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.serviceTourism.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
                        ),
                        child: Center(child: Text(place['icon']!, style: const TextStyle(fontSize: 44))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place['name']!, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(place['desc']!, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                                const SizedBox(width: AppSpacing.xs),
                                Text(place['rating']!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(place['price']!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.serviceTourism, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(child: Text(place['location']!, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'أضف فعالية جديدة',
              icon: LucideIcons.plusCircle,
              color: AppColors.serviceTourism,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم إضافة الفعالية قريباً 📅'), backgroundColor: AppColors.info),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
