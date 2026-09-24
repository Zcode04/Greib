import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../shared_widgets/order_status_badge.dart';

class OrdersList extends StatelessWidget {
  final bool isDark;

  const OrdersList({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final orders = MockData.demoOrders;
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;

    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text('لا توجد طلبات حالية',
              style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary)),
        ),
      );
    }

    return Column(
      children: orders.take(3).map((order) {
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(20),
          opacity: isDark ? 0.05 : 0.08,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/tracking'),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: neonColor.withValues(alpha: isDark ? 0.1 : 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(MockData.getIconByName(order.serviceType),
                      color: neonColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimary : AppColors.lightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.pickupLocation} → ${order.deliveryLocation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.status, isDark: isDark),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
