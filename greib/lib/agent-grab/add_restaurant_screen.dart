import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  AddRestaurantScreen — صفحة «إضافة مطعم» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): اسم المطعم + الموقع + الإحداثيات (اختياري).
///  ◆ للتطوير لاحقاً: نوع المطبخ، قائمة الأطباق، أوقات العمل، صور، والتقييمات.
/// ============================================================================
class AddRestaurantScreen extends AgFormPage {
  const AddRestaurantScreen({super.key})
      : super(
          title: 'إضافة مطعم',
          subtitle: 'أضف بيانات المطعم حتى يظهر للمستخدمين في نتائج البحث.',
          successMessage: 'تم إرسال بيانات المطعم، شكراً لك',
          fields: const [
            (
              label: 'اسم المطعم',
              hint: 'اكتب اسم المطعم',
              icon: LucideIcons.utensilsCrossed,
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
