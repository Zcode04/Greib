import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  AddRoadScreen — صفحة «إضافة طريق» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): اسم الطريق + الموقع + الإحداثيات (اختياري).
///  ◆ للتطوير لاحقاً: تحديد مسار الطريق على الخريطة، نقطة البداية والنهاية،
///    طول الطريق، حالة الطريق، صور، ثم الإرسال للخادم.
/// ============================================================================
class AddRoadScreen extends AgFormPage {
  const AddRoadScreen({super.key})
      : super(
          title: 'إضافة طريق',
          subtitle: 'أضف بيانات الطريق حتى يظهر للمستخدمين على الخريطة.',
          successMessage: 'تم إرسال بيانات الطريق، شكراً لك',
          fields: const [
            (
              label: 'اسم الطريق',
              hint: 'اكتب اسم الطريق',
              icon: LucideIcons.route,
            ),
            (
              label: 'الموقع',
              hint: 'المدينة، الحي، المنطقة',
              icon: LucideIcons.mapPin,
            ),
            (
              label: 'الإحداثيات (اختياري)',
              hint: 'مثال: 18.0735, -15.9582',
              icon: LucideIcons.crosshair,
            ),
          ],
        );
}
