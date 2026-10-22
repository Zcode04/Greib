import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/super_header.dart';
import 'search_history_store.dart';

/// ============================================================================
///  صفحة «سجل البحث» — تحتفظ بكل ما بحث عنه المستخدم.
///
///  تُفتح من أيقونة الساعة بجوار أيقونات الكاميرا/الصور في شاشة البحث.
///  ★ واجهة قابلة للتطوير لاحقاً (بحث داخلي، تجميع بالتاريخ، مسح فردي...).
/// ============================================================================
class SearchHistoryScreen extends StatelessWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final store = SearchHistoryStore.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // ★ خلفية من اللوحة المركزية (تتبع الثيم والوضع والتخصيص).
        backgroundColor: context.backgroundColors.primary,
        appBar: const SuperHeader(title: 'سجل البحث', showBackButton: true),
        body: SafeArea(
          child: ValueListenableBuilder<List<String>>(
            valueListenable: store.entries,
            builder: (context, entries, _) {
              if (entries.isEmpty) {
                return _EmptyHistory(theme: theme, isDark: isDark);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس الصفحة: العنوان + زر مسح الكل.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.clock3,
                          size: 20,
                          color: isDark
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'عمليات البحث السابقة',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تابع من حيث توقفت',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: store.clear,
                          icon: const Icon(LucideIcons.trash2, size: 16),
                          label: const Text('مسح الكل'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final query = entries[index];
                        return _HistoryTile(
                          query: query,
                          isDark: isDark,
                          // إعادة البحث: نُرجع الاستعلام لشاشة البحث ثم نغلق.
                          onTap: () => Navigator.of(context).pop(query),
                          onDelete: () => store.remove(query),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// عنصر واحد في سجل البحث: الأيقونة + النص + زر حذف فردي.
class _HistoryTile extends StatelessWidget {
  final String query;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.query,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = isDark ? Colors.white : theme.colorScheme.onSurface;
    return ListTile(
      onTap: onTap,
      leading: Icon(LucideIcons.history, size: 20, color: fg),
      title: Text(
        query,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: IconButton(
        tooltip: 'حذف',
        icon: Icon(
          LucideIcons.x,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: onDelete,
      ),
    );
  }
}

/// حالة فارغة عندما لا توجد عمليات بحث.
class _EmptyHistory extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;

  const _EmptyHistory({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'لا توجد عمليات بحث بعد',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ستظهر هنا كل ما تبحث عنه لتتمكن من العودة إليه بسرعة.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

