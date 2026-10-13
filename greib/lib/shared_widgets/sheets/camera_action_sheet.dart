// shared_widgets/sheets/camera_action_sheet.dart
//
// ورقة خيارات الكاميرا — تُفتح من زر «الكاميرا» في الشريط السفلي.
// النسخة الحالية: التقاط/اختيار حقيقي عبر image_picker + رسالة
// «قريباً: النشر» — ومسار التطوير اللاحق (نشر ريل/ستوري/منشور)
// يُبنى فوق هذه الورقة دون تغيير الشريط السفلي.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';

/// يعرض ورقة خيارات الكاميرا (BottomSheet).
Future<void> showCameraActionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.backgroundColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CameraActionSheet(),
  );
}

class _CameraActionSheet extends StatelessWidget {
  const _CameraActionSheet();

  Future<void> _pick(
    BuildContext context, {
    required ImageSource source,
    bool video = false,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? file = video
          ? await picker.pickVideo(source: source)
          : await picker.pickImage(source: source, imageQuality: 85);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      if (file == null) return;
      // ★ لاحقاً: توجيه الملف إلى شاشة «إنشاء ريل/منشور».
      // حالياً: تأكيد الالتقاط فقط.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            video
                ? 'تم اختيار الفيديو ✅ (النشر قريباً)'
                : 'تم اختيار الصورة ✅ (النشر قريباً)',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر فتح الكاميرا — تحقق من الأذونات'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final textColor = context.textColors.primary;

    Widget option({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      bool highlight = false,
    }) {
      return ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: highlight
                ? accent.withValues(alpha: 0.15)
                : context.backgroundColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: highlight ? accent : textColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الكاميرا',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'صوّر أو ارفع — والنشر الكامل سنضيفه لاحقاً',
              style: TextStyle(
                fontSize: 12,
                color: context.textColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            option(
              icon: LucideIcons.camera,
              title: 'التقاط صورة',
              subtitle: 'افتح كاميرا الهاتف الآن',
              highlight: true,
              onTap: () => _pick(context, source: ImageSource.camera),
            ),
            option(
              icon: LucideIcons.clapperboard,
              title: 'تسجيل فيديو / ريل',
              subtitle: 'سجّل مقطعاً قصيراً',
              onTap: () =>
                  _pick(context, source: ImageSource.camera, video: true),
            ),
            option(
              icon: LucideIcons.image,
              title: 'اختيار من المعرض',
              subtitle: 'صورة أو فيديو من جهازك',
              onTap: () => _pick(context, source: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
