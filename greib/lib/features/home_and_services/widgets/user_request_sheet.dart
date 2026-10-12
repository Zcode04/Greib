import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';

// ─────────────────────────────────────────────
//  شيت خيارات بطاقة المستخدم (Bottom Sheet)
//  يظهر عند الضغط على UserRequestStoryCard
//  ★ نسخة أولية — كل خيار يعرض رسالة "قريباً" وسنطوّرها لاحقاً
// ─────────────────────────────────────────────

/// عنصر واحد في الشيت
class _SheetOption {
  final String title;
  final IconData icon;
  const _SheetOption({required this.title, required this.icon});
}

const _kOptions = [
  _SheetOption(title: 'طلب خدمة', icon: LucideIcons.clipboardList),
  _SheetOption(title: 'من المتصل الآن', icon: LucideIcons.phoneCall),
  _SheetOption(title: 'من الأقرب إلي', icon: LucideIcons.mapPin),
  _SheetOption(title: 'ماهو اقرب طريق لوجهتي', icon: LucideIcons.route),
  _SheetOption(title: 'لانتقال لبراوى', icon: LucideIcons.car),
  _SheetOption(title: 'لانتقال للحاذك', icon: LucideIcons.store),
];

/// عرض الشيت — تُستدعى عند الضغط على بطاقة المستخدم
Future<void> showUserRequestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.backgroundColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _UserRequestSheet(),
  );
}

class _UserRequestSheet extends StatelessWidget {
  const _UserRequestSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // مقبض السحب
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: context.backgroundColors.outline,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ماذا تريد أن تطلب؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'اختر نوع الخدمة — سنطوّر كل خيار لاحقاً',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // الخيارات الستة
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in _kOptions)
                      _SheetTile(option: option),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final _SheetOption option;
  const _SheetTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.backgroundColors.secondary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).maybePop();
            context.showSnackBar('«${option.title}» — قريباً');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.accentColor.withValues(alpha: 0.14),
                  ),
                  child: Icon(option.icon, color: context.accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.title,
                    style: TextStyle(
                      color: context.textColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronLeft,
                  color: context.textColors.tertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
