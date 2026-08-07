import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

class FoodDeliveryScreen extends StatelessWidget {
  const FoodDeliveryScreen({super.key});

  static const List<Map<String, String>> restaurants = [
    {
      'name': 'مطعم المندي الملكي',
      'cuisine': 'مندي، برياني, كبسة',
      'rating': '4.8',
      'time': '25 دقيقة',
      'deliveryFee': '5 درهم',
      'image': '🍛',
    },
    {
      'name': 'شاورما العربي الأصيل',
      'cuisine': 'شاورما، مشاوي',
      'rating': '4.6',
      'time': '15 دقيقة',
      'deliveryFee': '3 درهم',
      'image': '🌯',
    },
    {
      'name': 'بيتزا نابولي',
      'cuisine': 'بيتزا، معكرونة',
      'rating': '4.4',
      'time': '30 دقيقة',
      'deliveryFee': '6 درهم',
      'image': '🍕',
    },
    {
      'name': 'برجر جامبو',
      'cuisine': 'برجر، بطاطا مقلية',
      'rating': '4.7',
      'time': '20 دقيقة',
      'deliveryFee': '4 درهم',
      'image': '🍔',
    },
    {
      'name': 'مأكولات بحرية الخليج',
      'cuisine': 'أسماك، روبيان',
      'rating': '4.9',
      'time': '35 دقيقة',
      'deliveryFee': '7 درهم',
      'image': '🦐',
    },
    {
      'name': 'حلويات الشرق',
      'cuisine': 'حلويات عربية',
      'rating': '4.5',
      'time': '15 دقيقة',
      'deliveryFee': '3 درهم',
      'image': '🍮',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('توصيل طعام'),
        backgroundColor: const Color(0xFFFF9800),
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
                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  const Text('🍽️', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جوعان؟ خلنا نوصل لك!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'أكثر من ٥٠٠ مطعم حولك',
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
              'أشهر المطاعم',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return _buildRestaurantCard(context, theme, restaurant);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    BuildContext context,
    ThemeData theme,
    Map<String, String> restaurant,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.lg),
              ),
            ),
            child: Center(
              child: Text(
                restaurant['image']!,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['name']!,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  restaurant['cuisine']!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      restaurant['rating']!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      restaurant['time']!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'توصيل: ${restaurant['deliveryFee']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
