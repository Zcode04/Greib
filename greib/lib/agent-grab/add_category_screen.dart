import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  AddCategoryScreen — صفحة «إضافة فئة» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): اسم الفئة + الوصف + الفئة الرئيسية (اختياري).
///  ◆ للتطوير لاحقاً: اختيار الأيقونة واللون، وربط الفئة بالخدمات.
/// ============================================================================
class AddCategoryScreen extends AgFormPage {
  const AddCategoryScreen({super.key})
      : super(
          title: 'إضافة فئة',
          subtitle: 'اقترح فئة جديدة لتصنيف المحلات والخدمات.',
          successMessage: 'تم إرسال الفئة، شكراً لك',
          fields: const [
            (
              label: 'اسم الفئة',
              hint: 'اكتب اسم الفئة',
              icon: LucideIcons.shapes,
            ),
            (
              label: 'الوصف',
              hint: 'وصف مختصر للفئة',
              icon: LucideIcons.fileText,
            ),
            (
              label: 'الفئة الرئيسية (اختياري)',
              hint: 'مثال: مطاعم، متاجر، خدمات',
              icon: LucideIcons.listTree,
            ),
          ],
        );
}
