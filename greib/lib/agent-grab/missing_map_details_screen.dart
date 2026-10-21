import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  MissingMapDetailsScreen — صفحة «أضف تفاصيل خريطة مفقودة» — agent-grab.
///
///  ★ نسخة تجريبية (Mock): اسم المكان + التفاصيل المفقودة + الإحداثيات.
///  ◆ للتطوير لاحقاً: تحديد الموقع على الخريطة، إرفاق مستندات، وحالة الطلب.
/// ============================================================================
class MissingMapDetailsScreen extends AgFormPage {
  const MissingMapDetailsScreen({super.key})
      : super(
          title: 'أضف تفاصيل خريطة مفقودة',
          subtitle: 'أخبرنا بالتفاصيل المفقودة في الخريطة وسنضيفها.',
          successMessage: 'تم إرسال التفاصيل، شكراً لك',
          fields: const [
            (
              label: 'اسم المكان',
              hint: 'اكتب اسم المكان الناقص',
              icon: LucideIcons.mapPinPen,
            ),
            (
              label: 'التفاصيل المفقودة',
              hint: 'ما المعلومة أو التفصيل الناقص؟',
              icon: LucideIcons.fileText,
            ),
            (
              label: 'الإحداثيات (اختياري)',
              hint: 'مثال: 18.0735, -15.9582',
              icon: LucideIcons.crosshair,
            ),
          ],
        );
}
