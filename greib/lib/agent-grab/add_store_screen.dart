import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  AddStoreScreen — صفحة «إضافة محل» (Add Store) — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): اسم المحل + الموقع + الإحداثيات (اختياري).
///  ◆ للتطوير لاحقاً: التقاط الموقع تلقائياً، خريطة لتحديد النقطة، صور المحل،
///    أوقات العمل، التواصل، ثم الإرسال للخادم.
/// ============================================================================
class AddStoreScreen extends AgFormPage {
  const AddStoreScreen({super.key})
      : super(
          title: 'إضافة محل',
          subtitle: 'أضف بيانات المحل حتى يظهر للمستخدمين على الخريطة وقوائم البحث.',
          successMessage: 'تم إرسال بيانات المحل، شكراً لك',
          fields: const [
            (
              label: 'اسم المحل',
              hint: 'اكتب اسم المحل',
              icon: LucideIcons.store,
            ),
            (
              label: 'الموقع',
              hint: 'المدينة، الحي، اسم الشارع',
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
