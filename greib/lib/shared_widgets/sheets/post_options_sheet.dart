import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/service_model.dart';

/// ============================================================================
///  PostOptionsSheet — ورقة خيارات المنشور (زر ⋯):
///  حفظ، عرض المزيد، عرض الشرائح، اهتمام، إخفاء، إبلاغ.
///
///  الاستخدام:
///    await showAppSheet(context, builder: (_) => PostOptionsSheet(...));
/// ============================================================================
class PostOptionsSheet extends StatelessWidget {
  const PostOptionsSheet({
    super.key,
    required this.service,
    required this.isSaved,
    required this.onSaveToggle,
    this.onShowSlides,
  });

  final ServiceCategory service;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final VoidCallback? onShowSlides;

  @override
  Widget build(BuildContext context) {
    final sheetText = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Text(
                  'خيارات المنشور',
                  style: TextStyle(
                    color: sheetText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // ★ عرض المزيد: فتح صفحة الخدمة.
          _tile(
            context,
            icon: LucideIcons.arrowUpDown,
            label: 'عرض المزيد',
            trailingChevron: true,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              context.push('/service/${service.id}');
            },
          ),
          // ★ عرض الشرائح.
          _tile(
            context,
            icon: LucideIcons.galleryHorizontal,
            label: 'عرض الشرائح',
            trailingChevron: true,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              (onShowSlides ?? () => _showLater(context))();
            },
          ),
          _tile(
            context,
            icon: isSaved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
            label: isSaved ? 'إلغاء حفظ المنشور' : 'حفظ المنشور',
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              onSaveToggle();
            },
          ),
          _tile(
            context,
            icon: LucideIcons.thumbsUp,
            label: 'مهتم',
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              _showLater(context);
            },
          ),
          _tile(
            context,
            icon: LucideIcons.thumbsDown,
            label: 'غير مهتم',
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              _showLater(context);
            },
          ),
          _tile(
            context,
            icon: LucideIcons.eyeOff,
            label: 'إخفاء المنشور',
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              _showLater(context);
            },
          ),
          _tile(
            context,
            icon: LucideIcons.eyeOff,
            label: 'إخفاء جميع منشورات نشاط هذا التاجر',
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              _showLater(context);
            },
          ),
          _tile(
            context,
            icon: LucideIcons.flag,
            label: 'الإبلاغ عن المنشور',
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              _showLater(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// عنصر قائمة: أيقونة + نص + سهم اختياري.
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool trailingChevron = false,
  }) {
    final sheetText = Theme.of(context).colorScheme.onSurface;
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

  void _showLater(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة ستتوفر قريباً بإذن الله'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }
}

/// ============================================================================
///  PostReadSheet — ورقة خيارات القراءة (زر 📢):
///  قراءة المنشور، تلخيص، توضيح.
/// ============================================================================
class PostReadSheet extends StatelessWidget {
  const PostReadSheet({super.key, required this.service});

  final ServiceCategory service;

  @override
  Widget build(BuildContext context) {
    final sheetText = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Icon(
                  LucideIcons.volume2,
                  size: 18,
                  color: sheetText.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'قراءة المنشور',
                  style: TextStyle(
                    color: sheetText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _tile(
            context,
            icon: LucideIcons.bookOpen,
            label: 'قراءة المنشور',
          ),
          _tile(
            context,
            icon: LucideIcons.textQuote,
            label: 'تلخيص',
          ),
          _tile(
            context,
            icon: LucideIcons.lightbulb,
            label: 'توضيح',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final sheetText = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذه الميزة ستتوفر قريباً بإذن الله'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 900),
          ),
        );
      },
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
          ],
        ),
      ),
    );
  }
}
