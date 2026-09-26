import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/location_picker.dart';
import '../../../shared_widgets/store_category_tabs.dart';

/// الشريط اللاصق: زر الموقع + تبويبات المتجر بشكل دائري قابل للتمرير.
/// يظهر فقط بعد تمرير المستخدم حتى موضع الـ 14 تبويب.
class StickyTabsBar extends StatelessWidget {
  final bool visible;
  const StickyTabsBar({super.key, required this.visible});
  void _openLocation(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Theme.of(context).colorScheme.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl))), builder: (_) => const LocationPickerSheet());
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = context.watch<LocationController>().cityName;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      offset: visible ? Offset.zero : const Offset(0, -1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !visible,
          child: SafeArea(
            bottom: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(AppRadii.full), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.18)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Row(children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  onTap: () => _openLocation(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(LucideIcons.mapPin, size: 16, color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700))),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: theme.dividerColor.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                const Expanded(flex: 3, child: StoreCategoryTabsCompact()),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
