import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  ReportIssueScreen — صفحة «الإبلاغ عن مشكلة» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): عنوان المشكلة + التفاصيل + المكان/الرابط (اختياري).
///  ◆ للتطوير لاحقاً: نوع المشكلة، إرفاق صورة، ومتابعة حالة البلاغ.
/// ============================================================================
class ReportIssueScreen extends AgFormPage {
  const ReportIssueScreen({super.key})
      : super(
          title: 'الإبلاغ عن مشكلة',
          subtitle: 'أخبرنا بالمشكلة التي واجهتها وسنعمل على حلها.',
          successMessage: 'تم إرسال البلاغ، شكراً لك',
          fields: const [
            (
              label: 'عنوان المشكلة',
              hint: 'اكتب عنواناً مختصراً للمشكلة',
              icon: LucideIcons.triangleAlert,
            ),
            (
              label: 'تفاصيل المشكلة',
              hint: 'اشرح المشكلة بالتفصيل',
              icon: LucideIcons.fileText,
            ),
            (
              label: 'المكان أو الرابط (اختياري)',
              hint: 'اسم المكان أو رابط الصفحة',
              icon: LucideIcons.link,
            ),
          ],
        );
}
