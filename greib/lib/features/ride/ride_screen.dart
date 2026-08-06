import 'package:flutter/material.dart';
import '../../shared_widgets/app_button.dart';

// صفحة المواصلات والتنقل
class RideScreen extends StatelessWidget {
  const RideScreen({super.key});

  static const List<Map<String, String>> rideOptions = [
    {
      'name': 'سيارة اقتصادية',
      'desc': 'حتى 3 ركاب',
      'price': '25 درهم',
      'time': '3 دقائق',
      'rating': '4.5',
      'icon': '🚗',
    },
    {
      'name': 'سيارة عائلية',
      'desc': 'حتى 6 ركاب',
      'price': '40 درهم',
      'time': '5 دقائق',
      'rating': '4.8',
      'icon': '🚙',
    },
    {
      'name': 'فخامة',
      'desc': 'سيارة راقية',
      'price': '75 درهم',
      'time': '10 دقائق',
      'rating': '4.9',
      'icon': '🚘',
    },
    {
      'name': 'دراجة نارية',
      'desc': 'للمسافات القصيرة',
      'price': '15 درهم',
      'time': '2 دقيقة',
      'rating': '4.4',
      'icon': '🏍️',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المواصلات'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة ترحيبية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🚗', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وين تبا تروح؟',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سائقين متاحين حولك الآن',
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
            const SizedBox(height: 24),

            // حقول الموقع
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'موقع الانطلاق',
                        prefixIcon: Icon(Icons.trip_origin),
                        hintText: 'موقعك الحالي',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'وجهتك',
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'أين تريد الذهاب؟',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // خيارات السيارة
            Text(
              'اختر سيارتك',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            // قائمة الخيارات
            ...rideOptions.map((ride) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        ride['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    ride['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(ride['desc']!),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(ride['rating']!),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text('يصل خلال ${ride['time']}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    ride['price']!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF9C27B0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // زر طلب سيارة
            AppButton(
              label: 'اطلب سيارة الآن',
              icon: Icons.local_taxi,
              color: const Color(0xFF9C27B0),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جارٍ البحث عن سائق قريب منك... 🚗'),
                    backgroundColor: Colors.purple,
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