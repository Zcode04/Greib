import 'package:flutter/material.dart';
import '../core/mock_data/mock_data.dart';
import '../core/theme/app_colors.dart';

/// شريط تبويبات المتجر (14 تبويب) — يعرض مباشرة بعد قسم الأحدث.
/// الأول (الكل) مفعّل افتراضيا. يبث التغيير عبر ValueNotifier مشترك.
class StoreSelectedCategory {
  static final ValueNotifier<String> notifier = ValueNotifier<String>('all');
}

/// نسخة مدمجة دائرية للشريط اللاصق — نفس المصدر (notifier) بدون تكرار حالة.
class StoreCategoryTabsCompact extends StatelessWidget {
  const StoreCategoryTabsCompact({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
    return ValueListenableBuilder<String>(
      valueListenable: StoreSelectedCategory.notifier,
      builder: (context, selected, _) {
        return SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.productCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = MockData.productCategories[i];
              final id = cat['id']!;
              final label = cat['label']!;
              final isSelected = id == selected;
              return GestureDetector(
                onTap: () => StoreSelectedCategory.notifier.value = id,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : (isDark ? AppColors.surfaceCard : AppColors.lightSurfaceVariant),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: isSelected ? Colors.transparent : (isDark ? AppColors.outline : AppColors.lightOutline), width: 1),
                  ),
                  child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary))),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class StoreCategoryTabs extends StatelessWidget {
  const StoreCategoryTabs({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
    return ValueListenableBuilder<String>(
      valueListenable: StoreSelectedCategory.notifier,
      builder: (context, selected, _) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.productCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final cat = MockData.productCategories[i];
              final id = cat['id']!;
              final label = cat['label']!;
              final isSelected = id == selected;
              return GestureDetector(
                onTap: () => StoreSelectedCategory.notifier.value = id,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : (isDark ? AppColors.surfaceCard : AppColors.lightSurfaceVariant),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.transparent : (isDark ? AppColors.outline : AppColors.lightOutline), width: 1),
                    boxShadow: isSelected ? [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))] : null,
                  ),
                  child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary))),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
