import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  SuggestEditScreen — صفحة «اقتراح تعديل» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): المكان/الخدمة + التعديل المقترح + تفاصيل إضافية.
///  ◆ للتطوير لاحقاً: إرفاق صور، وربط الاقتراح بسجل المكان الفعلي.
/// ============================================================================
class SuggestEditScreen extends AgFormPage {
  const SuggestEditScreen({super.key})
      : super(
          title: 'اقتراح تعديل',
          subtitle: 'ساعدنا في تصحيح بيانات أي مكان أو خدمة.',
          successMessage: 'تم إرسال اقتراحك، شكراً لك',
          fields: const [
            (
              label: 'المكان أو الخدمة',
              hint: 'اكتب اسم المكان أو الخدمة',
              icon: LucideIcons.mapPin,
            ),
            (
              label: 'التعديل المقترح',
              hint: 'ما الذي يجب تعديله؟',
              icon: LucideIcons.squarePen,
            ),
            (
              label: 'تفاصيل إضافية (اختياري)',
              hint: 'اكتب أي تفاصيل تساعدنا',
              icon: LucideIcons.fileText,
            ),
          ],
        );
}
