import 'package:flutter/material.dart';

import '../core/extensions/context_extensions.dart';
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

  /// لون الحالة (مشتق من اللوحة المركزية — يتحدّث فوراً مع الوضع والتخصيص).
  static Color colorFor(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return context.iconColors.warning;
      case 'assigned':
        return context.iconColors.info;
      case 'in_transit':
        return context.isDarkMode ? context.accentColor : context.accentDarkColor;
      case 'delivered':
        return context.iconColors.success;
      case 'cancelled':
        return context.iconColors.error;
      default:
        return context.textColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(context, status);

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
