import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_sheet.dart';

/// ============================================================================
///  UpcomingServicesSheet — ورقة «خدمات قادمة» (زر + في الهيدر):
///  قائمة الخدمات التي ستُطوَّر لاحقاً — حالياً عرض فقط (أيقونة + نص).
///  الضغط على أي بند يغلق الورقة ويعرض تنبيه «ستتوفر قريباً».
///
///  الاستخدام:
///    await UpcomingServicesSheet.show(context);
/// ============================================================================
class UpcomingServicesSheet extends StatelessWidget {
  const UpcomingServicesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppSheet(
      context,
      builder: (_) => const UpcomingServicesSheet(),
    );
  }

  /// البنود المطلوبة — كلها بأيقونة plus حالياً، تُخصَّص لاحقاً.
  static const List<String> items = [
    'إنشاء منشور',
    'الانضمام إلينا كمزود خدمة',
    'إضافة محل',
    'إضافة طريق',
    'إضافة مطعم',
    'إضافة فئة',
    'اقتراح تعديل',
    'الإبلاغ عن مشكلة',
    'مساهم في الخرائط',
    'أضف مكان',
    'أضف تفاصيل خريطة مفقودة',
  ];

  @override
  Widget build(BuildContext context) {
    final sheetText = Theme.of(context).colorScheme.onSurface;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circlePlus,
                    size: 18,
                    color: sheetText.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'خدمات قادمة',
                    style: TextStyle(
                      color: sheetText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            for (final label in items)
              _tile(context, label: label),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, {required String label}) {
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
            Icon(LucideIcons.circlePlus, size: 22, color: sheetText),
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
