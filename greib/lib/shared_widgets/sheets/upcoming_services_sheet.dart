import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_sheet.dart';

/// ============================================================================
///  UpcomingServicesSheet — ورقة «خدمات قادمة» (زر + في الهيدر):
///  قائمة الخدمات التي ستُطوَّر لاحقاً — حالياً عرض فقط (أيقونة + نص).
///  الضغط على أي بند يغلق الورقة ويعرض تنبيه «ستتوفر قريباً»،
///  باستثناء البنود المفعّلة (مثل «إنشاء منشور» و«الانضمام كمزود خدمة»)
///  التي توجّه إلى صفحاتها.
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

  /// بنود الخدمات القادمة — لكل بند أيقونته الخاصة الدالة عليه.
  static const List<({String label, IconData icon})> items = [
    (label: 'إنشاء منشور', icon: LucideIcons.squarePen),
    (label: 'الانضمام إلينا كمزود خدمة', icon: LucideIcons.handshake),
    (label: 'إضافة محل', icon: LucideIcons.store),
    (label: 'إضافة طريق', icon: LucideIcons.route),
    (label: 'إضافة مطعم', icon: LucideIcons.utensilsCrossed),
    (label: 'إضافة فئة', icon: LucideIcons.shapes),
    (label: 'اقتراح تعديل', icon: LucideIcons.filePen),
    (label: 'الإبلاغ عن مشكلة', icon: LucideIcons.triangleAlert),
    (label: 'مساهم في الخرائط', icon: LucideIcons.handHeart),
    (label: 'أضف مكان', icon: LucideIcons.mapPinPlus),
    (label: 'أضف تفاصيل خريطة مفقودة', icon: LucideIcons.mapPinPen),
  ];

  /// البنود المفعّلة فعلياً: نص البند ← مسار الصفحة المقصودة.
  static const Map<String, String> activeRoutes = {
    'إنشاء منشور': '/create-post',
    'الانضمام إلينا كمزود خدمة': '/join-provider',
    'إضافة محل': '/add-store',
    'إضافة طريق': '/add-road',
  };

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
            for (final item in items)
              _tile(context, item: item),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required ({String label, IconData icon}) item,
  }) {
    final sheetText = Theme.of(context).colorScheme.onSurface;
    // ★ البنود المفعّلة (مثل «إنشاء منشور») توجّه لصفحتها، والبقية «قريباً».
    final route = activeRoutes[item.label];
    return InkWell(
      onTap: () {
        // نحفظ الراوتر قبل إغلاق الورقة لضمان تنقّل سليم بعد الإغلاق.
        final router = GoRouter.of(context);
        Navigator.of(context, rootNavigator: true).pop();

        if (route != null) {
          router.push(route);
          return;
        }

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
            Icon(item.icon, size: 22, color: sheetText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(color: sheetText, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
