import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  AddPlaceScreen — صفحة «أضف مكان» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): اسم المكان + الموقع + الإحداثيات (اختياري).
///  ◆ للتطوير لاحقاً: تحديد الموقع على الخريطة، نوع المكان، صور، والوصف.
/// ============================================================================
class AddPlaceScreen extends AgFormPage {
  const AddPlaceScreen({super.key})
      : super(
          title: 'أضف مكان',
          subtitle: 'أضف مكاناً جديداً ليظهر للمستخدمين على الخريطة.',
          successMessage: 'تم إرسال المكان، شكراً لك',
          fields: const [
            (
              label: 'اسم المكان',
              hint: 'اكتب اسم المكان',
              icon: LucideIcons.mapPinPlus,
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
