import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  const Text('🚗', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
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
                        const SizedBox(height: AppSpacing.xs),
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
            const SizedBox(height: AppSpacing.xl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'موقع الانطلاق',
                        prefixIcon: Icon(Icons.trip_origin),
                        hintText: 'موقعك الحالي',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.xl),

            Text(
              'اختر سيارتك',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            ...rideOptions.map((ride) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.md),
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
                      const SizedBox(height: AppSpacing.xs),
                      Text(ride['desc']!),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.xs),
                          Text(ride['rating']!),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text('يصل خلال ${ride['time']}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    ride['price']!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF9C27B0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'اطلب سيارة الآن',
              icon: Icons.local_taxi,
              color: const Color(0xFF9C27B0),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جارٍ البحث عن سائق قريب منك... 🚗'),
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
