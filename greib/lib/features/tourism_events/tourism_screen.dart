import 'package:flutter/material.dart';
import '../../shared_widgets/app_button.dart';

// صفحة السياحة والفعاليات
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
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF80DEEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('✈️', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استكشف الإمارات',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
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
            const SizedBox(height: 24),
            Text('فعاليات قادمة', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            ...events.map((event) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                          const Icon(Icons.calendar_month, size: 14),
                          const SizedBox(width: 4),
                          Text(event['date']!, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Text('احجز', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            Text('أماكن سياحية', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
                          color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Center(child: Text(place['icon']!, style: const TextStyle(fontSize: 44))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place['name']!, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(place['desc']!, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(place['rating']!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(place['price']!, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 2),
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
            const SizedBox(height: 24),
            AppButton(
              label: 'أضف فعالية جديدة',
              icon: Icons.add_circle_outline,
              color: const Color(0xFF00BCD4),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم إضافة الفعالية قريباً 📅'), backgroundColor: Colors.cyan),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}