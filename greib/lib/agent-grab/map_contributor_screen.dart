import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'agent_grab_form.dart';

/// ============================================================================
///  MapContributorScreen — صفحة «مساهم في الخرائط» — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock): الاسم + المدينة/المنطقة + نبذة (اختياري).
///  ◆ للتطوير لاحقاً: رفع الهوية، مجالات الاهتمام، ومكافآت المساهمين.
/// ============================================================================
class MapContributorScreen extends AgFormPage {
  const MapContributorScreen({super.key})
      : super(
          title: 'مساهم في الخرائط',
          subtitle: 'شارك في تحسين الخرائط والمعلومات مع فريقنا.',
          successMessage: 'تم إرسال طلبك، سنتواصل معك قريباً',
          fields: const [
            (
              label: 'الاسم',
              hint: 'اكتب اسمك',
              icon: LucideIcons.userRound,
            ),
            (
              label: 'المدينة أو المنطقة',
              hint: 'المدينة أو المنطقة التي تعرفها جيداً',
              icon: LucideIcons.mapPin,
            ),
            (
              label: 'نبذة عنك (اختياري)',
              hint: 'اشرح خبرتك في المنطقة',
              icon: LucideIcons.fileText,
            ),
          ],
        );
}
