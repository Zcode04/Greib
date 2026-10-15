// ============================================================================
//  Avatar Picker Sheet — شيت اختيار صورة البروفايل:
//    • التقاط صورة (الكاميرا).
//    • إرفاق صورة (المعرض).
//  يعيد XFile? للمتصل (يُعرض في الأفاتار فوراً)، null عند الإلغاء.
// ============================================================================
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';

/// يعرض شيت اختيار صورة البروفايل ويعيد الصورة المختارة، أو null عند الإلغاء.
Future<XFile?> showAvatarPickerSheet(BuildContext context) {
  return showModalBottomSheet<XFile?>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.backgroundColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AvatarPickerSheet(),
  );
}

class _AvatarPickerSheet extends StatefulWidget {
  const _AvatarPickerSheet();
  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  bool _busy = false;

  Future<void> _pick(ImageSource source, String from) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (file == null) return;
      // ★ نغلق الشيت ونعيد الصورة — العرض والحفظ مسؤولية المتصل.
      Navigator.of(context).pop(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            from == 'camera'
                ? 'تعذّر فتح الكاميرا — تحقق من الأذونات'
                : 'تعذّر فتح المعرض — حاول مجدداً',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final textColor = context.textColors.primary;
    final secondary = context.textColors.secondary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(LucideIcons.camera, size: 22, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صورة البروفايل',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'التقط صورة جديدة أو اختر واحدة من المعرض',
                        style: TextStyle(fontSize: 12, color: secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _opt(
              context,
              icon: LucideIcons.camera,
              title: 'التقاط صورة',
              sub: 'كاميرا الهاتف الفعلية',
              hl: true,
              tap: () => _pick(ImageSource.camera, 'camera'),
            ),
            _opt(
              context,
              icon: LucideIcons.imagePlus,
              title: 'إرفاق صورة',
              sub: 'اختر صورة من المعرض',
              hl: false,
              tap: () => _pick(ImageSource.gallery, 'gallery'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opt(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String sub,
    required bool hl,
    required VoidCallback tap,
  }) {
    final accent = context.accentColor;
    final textColor = context.textColors.primary;
    return ListTile(
      enabled: !_busy,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hl
              ? accent.withValues(alpha: 0.15)
              : context.backgroundColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: hl ? accent : textColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      ),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: tap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
