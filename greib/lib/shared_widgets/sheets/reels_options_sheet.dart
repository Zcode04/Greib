// shared_widgets/sheets/reels_options_sheet.dart
//
// ورقة خيارات الريل (زر ⋯ في صفحة الريلز).
//
// ★ نفس التصميم المستخدم في ورقة خيارات المنشور (`PostOptionsSheet`):
//   عنوان + صفوف (أيقونة + نص + سهم اختياري).
// ★ نفس البيانات المشتركة (حفظ/مهتم/إخفاء/إبلاغ) + عناصر خاصة بالريل
//   (تنزيل، نسخ الرابط، الصوت، تعديل إن كان صاحب الريل…).
//
// الاستخدام:
//    await showAppSheet(context, builder: (_) =>
//        ReelsOptionsSheet(reel: reel, isSaved: ..., onSaveToggle: ...));

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';

/// ============================================================================
///  ReelsOptionsSheet — ورقة خيارات الريل (زر ⋯).
/// ============================================================================
class ReelsOptionsSheet extends StatelessWidget {
  const ReelsOptionsSheet({
    super.key,
    required this.reelTitle,
    required this.authorName,
    required this.isSaved,
    required this.onSaveToggle,
    this.isOwner = false,
    this.onAction,
  });

  /// نص يميّز الريل في العنوان (مقتطف من الوصف أو اسم الحساب).
  final String reelTitle;

  final String authorName;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  /// صاحب الريل الحالي ⇒ نضيف «تعديل/حذف» كما في إنستقرام.
  final bool isOwner;

  /// إجراء موحّد لكل الخيارات غير المحفوظة (نفس أسلوب ورقة البوست).
  final void Function(String label)? onAction;

  void _run(BuildContext context, String label) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context, rootNavigator: true).pop();
    final action = onAction;
    if (action != null) {
      action(label);
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text('$label — هذه الميزة ستتوفر قريباً بإذن الله'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).colorScheme.onSurface;
    final secondary = text.withValues(alpha: 0.6);

    return SafeArea(
      top: false,
      // ★ ارتفاع مرن: القائمة أطول من ورقة البوست، فلا نستخدم Column
      //   mainAxisSize.min (قد يطفح على الشاشات الصغيرة).
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خيارات الريل',
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ★ سطر تعريف: يفرّق الورقة عن ورقة المنشور ويوضّح أي ريل.
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clapperboard,
                        size: 13,
                        color: context.textColors.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$authorName · $reelTitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: secondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ═══════ إجراءات الريل ═══════
            _tile(
              context,
              icon: LucideIcons.download,
              label: 'تنزيل الريل',
              onTap: () => _run(context, 'تنزيل الريل'),
            ),
            _tile(
              context,
              icon: LucideIcons.link,
              label: 'نسخ رابط الريل',
              onTap: () => _run(context, 'نسخ الرابط'),
            ),
            _tile(
              context,
              icon: LucideIcons.music2,
              label: 'عرض الصوت المستخدم',
              trailingChevron: true,
              onTap: () => _run(context, 'الصوت'),
            ),
            _tile(
              context,
              icon: LucideIcons.user,
              label: 'عرض الملف الشخصي',
              trailingChevron: true,
              onTap: () => _run(context, 'الملف الشخصي'),
            ),
            if (isOwner) ...[
              const Divider(height: 1),
              _tile(
                context,
                icon: LucideIcons.pencil,
                label: 'تعديل الريل',
                onTap: () => _run(context, 'تعديل الريل'),
              ),
              _tile(
                context,
                icon: LucideIcons.trash2,
                label: 'حذف الريل',
                destructive: true,
                onTap: () => _run(context, 'حذف الريل'),
              ),
            ],
            const Divider(height: 1),
            // ═══════ نفس خيارات ورقة المنشور ═══════
            _tile(
              context,
              icon: isSaved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
              label: isSaved ? 'إلغاء حفظ الريل' : 'حفظ الريل',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                onSaveToggle();
              },
            ),
            _tile(
              context,
              icon: LucideIcons.thumbsUp,
              label: 'مهتم',
              onTap: () => _run(context, 'مهتم'),
            ),
            _tile(
              context,
              icon: LucideIcons.thumbsDown,
              label: 'غير مهتم',
              onTap: () => _run(context, 'غير مهتم'),
            ),
            _tile(
              context,
              icon: LucideIcons.eyeOff,
              label: 'إخفاء الريل',
              onTap: () => _run(context, 'إخفاء الريل'),
            ),
            _tile(
              context,
              icon: LucideIcons.eyeOff,
              label: 'إخفاء جميع ريلز $authorName',
              onTap: () => _run(context, 'إخفاء جميع الريلز'),
            ),
            _tile(
              context,
              icon: LucideIcons.flag,
              label: 'الإبلاغ عن الريل',
              onTap: () => _run(context, 'الإبلاغ'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// عنصر قائمة: أيقونة + نص + سهم اختياري (نفس نمط ورقة البوست).
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool trailingChevron = false,
    bool destructive = false,
  }) {
    final sheetText = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: sheetText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: sheetText, fontSize: 15),
              ),
            ),
            if (trailingChevron)
              Icon(
                LucideIcons.chevronDown,
                size: 20,
                color: sheetText.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}