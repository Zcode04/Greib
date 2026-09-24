import 'package:flutter/material.dart';

import '../core/theme/design_tokens.dart';

/// ============================================================================
///  OrderStatusBadge — شارة حالة الطلب الموحّدة (مصدر واحد للتسمية واللون).
///  كانت منطقياً مكرَّراً داخل orders_list.dart ومليئاً بـ switch بلا break.
///  الاستخدام:
///    OrderStatusBadge(status: order.status, isDark: isDark)
/// ============================================================================
class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const OrderStatusBadge({
    super.key,
    required this.status,
    required this.isDark,
  });

  /// التسمية العربية لكل حالة طلب.
  static String labelFor(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'assigned':
        return 'تم التعيين';
      case 'in_transit':
        return 'في الطريق';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  /// لون الحالة (يتبع الوضع الليلي/النهاري).
  static Color colorFor(String status, bool isDark) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'assigned':
        return AppColors.info;
      case 'in_transit':
        return isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return isDark ? AppColors.textMuted : AppColors.lightTextTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.sm + 2),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        labelFor(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
