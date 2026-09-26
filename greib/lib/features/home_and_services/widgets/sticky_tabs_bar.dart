import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/mock_data/mock_data.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/location_picker.dart';
import '../../../shared_widgets/store_category_tabs.dart';

/// كبسولة لاصقة واحدة تجمع زر الموقع + الـ 14 تبويب بنفس الحجم.
/// تظهر عند التمرير حتى موضع التبويبات مع أنيميشن دمج احترافي.
/// تختفي عند الصعود ويعود زر الموقع المنفرد.
class StickyTabsBar extends StatefulWidget {
  final bool visible;
  const StickyTabsBar({super.key, required this.visible});
  @override
  State<StickyTabsBar> createState() => _StickyTabsBarState();
}

class _StickyTabsBarState extends State<StickyTabsBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _merge;
  late final Animation<double> _grow;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _merge = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _grow = CurvedAnimation(
        parent: _merge,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack));
    _pulse = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.18, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
        parent: _merge,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut)));
    if (widget.visible) _merge.value = 1.0;
  }

  @override
  void didUpdateWidget(StickyTabsBar old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) {
      _merge.forward(from: 0.0);
    } else if (!widget.visible && old.visible) {
      _merge.reverse();
    }
  }

  @override
  void dispose() {
    _merge.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = context.watch<LocationController>().cityName;
    // نفس أبعاد زر الموقع الأصلي تماماً + عرض متجاوب مع الشاشة.
    final screenW = MediaQuery.of(context).size.width;
    const double itemH = 34.0;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      offset: widget.visible ? Offset.zero : const Offset(0, -1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: widget.visible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !widget.visible,
          child: SafeArea(
            bottom: false,
            // ★ Directionality ثابت LTR حتى تبقى topLeft فيزيائية
            // (في RTL كانت تنعكس لليمين).
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
              // ★ نفس زاوية زر الموقع الأصلي تماماً (topLeft + left 20)
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8, left: 20),
                child: AnimatedBuilder(
                  animation: _merge,
                  builder: (context, _) {
                    return ConstrainedBox(
                      // ★ عرض متجاوب: لا يتجاوز الشاشة أبداً
                      constraints: BoxConstraints(
                        maxWidth: screenW - 40,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          // ★ نفس ستايل زر الموقع الأصلي حرفياً
                          color: theme.colorScheme.surface
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(
                              AppRadii.full),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: itemH,
                          child: _MergedRow(
                            merge: _merge,
                            grow: _grow,
                            pulse: _pulse,
                            city: city,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// الصف الداخلي: زر الموقع + التبويبات بنفس الحجم داخل كبسولة واحدة.
class _MergedRow extends StatelessWidget {
  final AnimationController merge;
  final Animation<double> grow;
  final Animation<double> pulse;
  final String city;
  const _MergedRow({
    required this.merge,
    required this.grow,
    required this.pulse,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const double itemH = 34.0;
    // ★ عرض التبويبات متجاوب: يأخذ المتبقي من عرض الشاشة بعد زر الموقع.
    final screenW = MediaQuery.of(context).size.width;
    final tabsW = (screenW - 40 - 130).clamp(120.0, 420.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: pulse,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.full),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor:
                    Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadii.xxl)),
                ),
                builder: (_) => const LocationPickerSheet(),
              );
            },
            child: Container(
              height: itemH,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.12 * merge.value),
                borderRadius:
                    BorderRadius.circular(AppRadii.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.mapPin,
                      size: 14,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    city,
                    style:
                        theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(LucideIcons.chevronDown,
                      size: 13,
                      color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: grow,
          axis: Axis.horizontal,
          axisAlignment: -1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 1,
                height: 20,
                margin:
                    const EdgeInsets.symmetric(horizontal: 6),
                color: theme.dividerColor
                    .withValues(alpha: 0.5 * merge.value),
              ),
              SizedBox(
                width: tabsW,
                child: ValueListenableBuilder<String>(
                  valueListenable:
                      StoreSelectedCategory.notifier,
                  builder: (context, selected, _) {
                    final accent = isDark
                        ? AppColors.accentPrimary
                        : AppColors.accentPrimaryDark;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0;
                              i <
                                  MockData
                                      .productCategories.length;
                              i++)
                            GestureDetector(
                              onTap: () =>
                                  StoreSelectedCategory
                                          .notifier.value =
                                      MockData
                                              .productCategories[
                                          i]['id']!,
                              child: Container(
                                height: itemH,
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: MockData
                                              .productCategories[
                                          i]['id'] ==
                                          selected
                                      ? accent
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(
                                          AppRadii.full),
                                ),
                                child: Text(
                                  MockData.productCategories[i]
                                      ['label']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: MockData
                                                .productCategories[
                                            i]['id'] ==
                                            selected
                                        ? (isDark
                                            ? Colors.black
                                            : Colors.white)
                                        : (isDark
                                            ? AppColors
                                                .textSecondary
                                            : AppColors
                                                .lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}