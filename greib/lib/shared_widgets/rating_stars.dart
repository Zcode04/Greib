import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/design_tokens.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int count;
  final double size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.count = 5,
    this.size = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.amber;
    final inactiveColor = Colors.grey.withValues(alpha: 0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        ...List.generate(count, (index) {
          if (index < rating.floor()) {
            return Icon(LucideIcons.star, size: size, color: activeColor);
          } else if (index == rating.floor() && rating % 1 != 0) {
            return Icon(LucideIcons.starHalf, size: size, color: activeColor);
          } else {
            return Icon(LucideIcons.star, size: size, color: inactiveColor);
          }
        }),
      ],
    );
  }
}
