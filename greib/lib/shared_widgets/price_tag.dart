import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double? oldPrice;
  final String currency;
  final TextStyle? style;
  final TextStyle? oldPriceStyle;

  const PriceTag({
    super.key,
    required this.price,
    this.oldPrice,
    this.currency = 'د.إ',
    this.style,
    this.oldPriceStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price.toStringAsFixed(0),
          style: style ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          currency,
          style: style?.copyWith(fontSize: (style?.fontSize ?? 16) * 0.7) ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
        ),
        if (oldPrice != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${oldPrice!.toStringAsFixed(0)} $currency',
            style: oldPriceStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
          ),
        ],
      ],
    );
  }
}
