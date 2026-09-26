import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/mock_data/mock_data.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/location_picker.dart';
import '../../../shared_widgets/store_category_tabs.dart';

/// كبسولة جامعة واحدة: زر الموقع + الـ 14 تبويب بجواره بنفس الحجم.
/// الكبسولة كلها قابلة للتمرير الأفقي — خلفية واحدة فقط بلا خلفيات منفصلة.
/// تظهر فقط بعد تمرير المستخدم حتى موضع الـ 14 تبويب.
class StickyTabsBar extends StatelessWidget {
  final bool visible;
  const StickyTabsBar({super.key, required this.visible});
  void _openLocation(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Theme.of(context).colorScheme.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl))), builder: (_) => const LocationPickerSheet());
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final city = context.watch<LocationController>().cityName;
    const double itemH = 36.0;
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(AppRadii.full), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.18)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 12, offset: const Offset(0, 4))]),
              child: SizedBox(
                height: itemH,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      onTap: () => _openLocation(context),
                      child: Container(
                        height: itemH,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.mapPin, size: 14, color: theme.colorScheme.primary), const SizedBox(width: 4), Text(city, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)), const SizedBox(width: 2), Icon(LucideIcons.chevronDown, size: 13, color: theme.colorScheme.primary)]),
                      ),
                    ),
                    Container(width: 1, height: 22, margin: const EdgeInsets.symmetric(horizontal: 4), color: theme.dividerColor.withValues(alpha: 0.5)),
                    ValueListenableBuilder<String>(
                      valueListenable: StoreSelectedCategory.notifier,
                      builder: (context, selected, _) {
                        final accent = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
                        return Row(children: [
                          for (int i = 0; i < MockData.productCategories.length; i++)
                            Padding(
                              padding: EdgeInsets.only(right: i == MockData.productCategories.length - 1 ? 2 : 6),
                              child: GestureDetector(
                                onTap: () => StoreSelectedCategory.notifier.value = MockData.productCategories[i]['id']!,
                                child: Container(
                                  height: itemH,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: MockData.productCategories[i]['id'] == selected ? accent : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.full)),
                                  child: Text(MockData.productCategories[i]['label']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: MockData.productCategories[i]['id'] == selected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary))),
                                ),
                              ),
                            ),
                        ]);
                      },
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
