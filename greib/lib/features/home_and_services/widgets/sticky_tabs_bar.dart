import 'package:flutter/material.dart';
import '../../../core/mock_data/mock_data.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/store_category_tabs.dart';

/// كبسولة التبويبات فقط (b) — تظهر بجوار زر الموقع (a) الذي بقي في مكانه كما هو.
/// قابلة للتمرير الأفقي — خلفية واحدة فقط بلا خلفيات منفصلة.
/// تظهر فقط بعد تمرير المستخدم حتى موضع الـ 14 تبويب.
class StickyTabsBar extends StatelessWidget {
  final bool visible;
  const StickyTabsBar({super.key, required this.visible});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const double itemH = 34.0;
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
              margin: const EdgeInsets.fromLTRB(126, 8, 10, 0),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
              decoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(AppRadii.full), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.18)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 12, offset: const Offset(0, 4))]),
              child: SizedBox(
                height: itemH,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ValueListenableBuilder<String>(
                    valueListenable: StoreSelectedCategory.notifier,
                    builder: (context, selected, _) {
                      final accent = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
                      return Row(children: [
                        for (int i = 0; i < MockData.productCategories.length; i++)
                          Padding(
                            padding: EdgeInsets.only(right: i == MockData.productCategories.length - 1 ? 0 : 0),
                            child: GestureDetector(
                              onTap: () => StoreSelectedCategory.notifier.value = MockData.productCategories[i]['id']!,
                              child: Container(
                                height: itemH,
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: MockData.productCategories[i]['id'] == selected ? accent : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.full)),
                                child: Text(MockData.productCategories[i]['label']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MockData.productCategories[i]['id'] == selected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary))),
                              ),
                            ),
                          ),
                      ]);
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
