import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/service_model.dart';

import '../../core/widgets/draggable_sheet_body.dart';

/// ============================================================================
///  PostOptionsSheet — ورقة خيارات المنشور (زر ⋯):
///  حفظ، عرض المزيد، عرض الشرائح، اهتمام، إخفاء، إبلاغ.
///
///  ★ نفس تصميم ورقة صور المنشور (_showPostImagesSheet):
///    بلا عنوان علوي، فقط الأزرار — InkWell + padding vertical 16،
///    أيقونة 24 + مسافة 16 + نص 16 w600 بلون onSurface،
///    داخل DraggableSheetBody قابل للسحب.
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
    return DraggableSheetBody(
      initialExtent: 0.45,
      snapSizes: const [0.35, 0.45, 0.6, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                // ★ عرض المزيد: فتح صفحة الخدمة.
                _tile(
                  context,
                  icon: LucideIcons.arrowUpDown,
                  label: 'عرض المزيد',
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    context.push('/service/${service.id}');
                  },
                ),
                // ★ عرض الشرائح — معطّل مؤقتاً (غير ضروري حالياً).
                //   محفوظ للمستقبل: أعد تفعيله بحذف التعليق أدناه.
                // _tile(
                //   context,
                //   icon: LucideIcons.galleryHorizontal,
                //   label: 'عرض الشرائح',
                //   onTap: () {
                //     Navigator.of(context, rootNavigator: true).pop();
                //     (onShowSlides ?? () => _showLater(context))();
                //   },
                // ),
                _tile(
                  context,
                  icon: LucideIcons.image,
                  label: 'عرض الصورة',
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _showLater(context);
                  },
                ),
                _tile(
                  context,
                  icon: LucideIcons.shoppingBag,
                  label: 'طلب الآن',
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _showLater(context);
                  },
                ),
                _tile(
                  context,
                  icon: LucideIcons.user,
                  label: 'عرض الملف الشخصي',
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _showLater(context);
                  },
                ),
                _tile(
                  context,
                  icon: isSaved
                      ? LucideIcons.bookmarkCheck
                      : LucideIcons.bookmark,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// عنصر قائمة — نفس ستايل ورقة صور المنشور:
  /// InkWell + padding vertical 16، أيقونة 24 + مسافة 16 + نص 16 w600.
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final sheetText = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: sheetText),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: sheetText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
///  PostReadSheet — ورقة خيارات القراءة (زر 🔊 volume2):
///  قراءة المنشور، تلخيص، توضيح.
///
///  ★ نفس تصميم ورقة صور المنشور (_showPostImagesSheet):
///    بلا عنوان علوي، فقط الأزرار — InkWell + padding vertical 16،
///    أيقونة 24 + مسافة 16 + نص 16 w600 بلون onSurface،
///    داخل DraggableSheetBody قابل للسحب.
/// ============================================================================
class PostReadSheet extends StatelessWidget {
  const PostReadSheet({super.key, required this.service});

  final ServiceCategory service;

  @override
  Widget build(BuildContext context) {
    return DraggableSheetBody(
      initialExtent: 0.45,
      snapSizes: const [0.35, 0.45, 0.6, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// عنصر قائمة — نفس ستايل ورقة صور المنشور:
  /// InkWell + padding vertical 16، أيقونة 24 + مسافة 16 + نص 16 w600.
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: sheetText),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: sheetText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
