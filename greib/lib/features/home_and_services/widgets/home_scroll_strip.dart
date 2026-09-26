import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/location_picker.dart';

/// شريط قابل للتمرير: "رائج الآن" + زر الموقع — يختفي عند التمرير.
class HomeScrollStrip extends StatelessWidget {
  const HomeScrollStrip({super.key});
  void _openLocation(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Theme.of(context).colorScheme.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl))), builder: (_) => const LocationPickerSheet());
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final city = context.watch<LocationController>().cityName;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFFF6B35).withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(LucideIcons.flame, color: Color(0xFFFF6B35), size: 18)),
        const SizedBox(width: AppSpacing.sm),
        Text('رائج الآن', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimary : AppColors.lightText)),
      ]),
      InkWell(borderRadius: BorderRadius.circular(AppRadii.full), onTap: () => _openLocation(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadii.full)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.mapPin, size: 14, color: theme.colorScheme.primary), const SizedBox(width: 4), Flexible(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700))), const SizedBox(width: 4), Icon(LucideIcons.chevronDown, size: 14, color: theme.colorScheme.primary)]))),
    ]);
  }
}
