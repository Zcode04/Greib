import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/loading_states.dart';
import '../tracking/tracking_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const List<Map<String, String>> favoriteRestaurants = [
    {
      'name': 'مطعم المندي الملكي',
      'cuisine': 'مندي، برياني، كبسة',
      'rating': '4.8',
      'emoji': '🍛',
    },
    {
      'name': 'شاورما العربي الأصيل',
      'cuisine': 'شاورما، مشاوي',
      'rating': '4.6',
      'emoji': '🌯',
    },
    {
      'name': 'بيتزا نابولي',
      'cuisine': 'بيتزا، معكرونة',
      'rating': '4.4',
      'emoji': '🍕',
    },
  ];

  static const List<Map<String, String>> recentOrders = [
    {
      'id': 'ord1',
      'title': 'طلب برياني دجاج',
      'restaurant': 'مطعم المندي الملكي',
      'price': '45 درهم',
      'status': 'assigned',
      'date': 'اليوم',
    },
    {
      'id': 'ord2',
      'title': 'أدوية',
      'restaurant': 'صيدلية أستر',
      'price': '32.5 درهم',
      'status': 'in_transit',
      'date': 'أمس',
    },
    {
      'id': 'ord3',
      'title': 'توصيل طرد',
      'restaurant': 'نقل طرود',
      'price': '25 درهم',
      'status': 'delivered',
      'date': 'منذ ٣ أيام',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة والسجل'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المفضلة'),
              Tab(text: 'طلباتي السابقة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoritesTab(context, theme),
            _buildHistoryTab(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, ThemeData theme) {
    if (favoriteRestaurants.isEmpty) {
      return EmptyState(
        icon: LucideIcons.heart,
        title: 'لا توجد مفضلات',
        description: 'أضف مطاعم ومتاجر إلى المفضلة',
        actionLabel: 'استكشف الخدمات',
        onAction: () => Navigator.pop(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: favoriteRestaurants.length,
      itemBuilder: (context, index) {
        final item = favoriteRestaurants[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Center(
                child: Text(
                  item['emoji']!,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            title: Text(item['name']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['cuisine']!),
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Text(item['rating']!),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(LucideIcons.heart, color: AppColors.error),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, ThemeData theme) {
    if (recentOrders.isEmpty) {
      return EmptyState(
        icon: LucideIcons.history,
        title: 'لا توجد طلبات سابقة',
        description: 'ستظهر طلباتك السابقة هنا',
        actionLabel: 'تصفح الخدمات',
        onAction: () => Navigator.pop(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: recentOrders.length,
      itemBuilder: (context, index) {
        final order = recentOrders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                LucideIcons.receipt,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            title: Text(order['title']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order['restaurant']!),
                Text(order['date']!),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order['price']!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _buildStatusBadge(context, theme, order['status']!),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackingScreen(orderId: order['id']!),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme, String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'قيد الانتظار';
      case 'assigned':
        color = AppColors.info;
        label = 'تم التعيين';
      case 'in_transit':
        color = AppColors.success;
        label = 'في الطريق';
      case 'delivered':
        color = AppColors.neutral400;
        label = 'تم التسليم';
      default:
        color = AppColors.neutral400;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
