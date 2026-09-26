import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/location_picker.dart';

/// زر الموقع الثابت — يبقى ظاهرا أعلى الشاشة أثناء التمرير.
class StickyLocationButton extends StatelessWidget {
  const StickyLocationButton({super.key});
  void _open(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Theme.of(context).colorScheme.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl))), builder: (_) => const LocationPickerSheet());
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = context.watch<LocationController>().cityName;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.full),
              onTap: () => _open(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(AppRadii.full), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.mapPin, size: 14, color: theme.colorScheme.primary), const SizedBox(width: 4), Flexible(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700))), const SizedBox(width: 4), Icon(LucideIcons.chevronDown, size: 14, color: theme.colorScheme.primary)]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
