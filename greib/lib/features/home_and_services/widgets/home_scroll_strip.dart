import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/design_tokens.dart';

/// شريط قابل للتمرير: "رائج الآن" فقط — يختفي عند التمرير.
/// (زر الموقع صار ثابتاً أعلى الشاشة — انظر StickyLocationButton)
class HomeScrollStrip extends StatelessWidget {
  const HomeScrollStrip({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFFF6B35).withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(LucideIcons.flame, color: Color(0xFFFF6B35), size: 18)),
      const SizedBox(width: AppSpacing.sm),
      Text('رائج الآن', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimary : AppColors.lightText)),
    ]);
  }
}
