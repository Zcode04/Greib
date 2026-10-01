import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/mock_data/mock_data.dart';

/// شريط تبويبات الـ 14 قسم، يظهر في الرئيسية بين "رائج" و"الأحدث".
/// التصميم مطابق لتبويبات صفحة تفاصيل الخدمة (`service_details_page.dart`):
/// مؤشر سفلي بلون التمييز، خط عريض، وحد فاصل أسفل الشريط.
class HomeCategoriesTabBar extends StatefulWidget {
  const HomeCategoriesTabBar({super.key});

  @override
  State<HomeCategoriesTabBar> createState() => _HomeCategoriesTabBarState();
}

class _HomeCategoriesTabBarState extends State<HomeCategoriesTabBar>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  final List<Map<String, String>> _categories = MockData.productCategories;

  /// ★ الشريط مطويّ افتراضياً: يعرض القسم المختار فقط.
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accentFor(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadii.full),
            // ★ الصف ينزلق إلى الزاوية المقابلة (نهاية السطر) مع عكس ترتيب
            // عناصره ليبقى العنوان محصوراً بين الأيقونة والسهم.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ★ سهم يوضّح الحالة: مطوي ⇩ / مفتوح ⇧.
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Container(
padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: accent.withValues(alpha: 0.04),
                  ),
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 21,
                    color: accent,
                  ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // ★ يعرض القسم المختار فقط ويتحدث فور اختيار تبويب.
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Text(
                    _categories[_controller.index]['label']!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // ★ أيقونة بلا خلفية (نفس ستايل عناوين الرئيسية).
                Icon(LucideIcons.chartNoAxesGantt, size: 18, color: accent),
              ],
            ),
          ),
        ),
        // ★ التبويبات تظهر وتختفي بارتفاع متحرك.
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Container(
                  height: 46,
                  color: isDark
                      ? AppColors.backgroundPrimary
                      : AppColors.lightBackground,
                  child: TabBar(
                    controller: _controller,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: accent,
                    labelColor: accent,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w700),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    tabs: [
                      for (final cat in _categories)
                        Tab(text: cat['label']),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}
