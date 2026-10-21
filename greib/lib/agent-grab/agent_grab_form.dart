import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extensions/context_extensions.dart';
import '../core/theme/design_tokens.dart';
import '../core/widgets/super_header.dart';
import '../shared_widgets/app_button.dart';

/// ============================================================================
///  agent_grab_form.dart — المكوّنات المشتركة لصفحات مجلد agent-grab:
///  هيكل موحّد (عنوان + وصف + حقول إدخال + زر إرسال) لتجنّب تكرار الكود.
///
///  الاستخدام:
///    AgFormPage(
///      title: 'إضافة محل',
///      subtitle: '...',
///      fields: [(label: 'اسم المحل', hint: '...', icon: LucideIcons.store)],
///      successMessage: '...',
///    )
/// ============================================================================

/// مواصفة حقل إدخال: العنوان + التلميح + الأيقونة.
typedef AgFieldSpec = ({String label, String hint, IconData icon});

/// صفحة نموذج موحّدة (Mock): تعرض الحقول وترسل رسالة نجاح ثم ترجع.
class AgFormPage extends StatefulWidget {
  const AgFormPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.successMessage,
    this.submitLabel = 'إرسال',
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<AgFieldSpec> fields;
  final String successMessage;
  final String submitLabel;

  /// محتوى إضافي يظهر أسفل الحقول (مثل حبوب اختيار الخدمة).
  final Widget? footer;

  @override
  State<AgFormPage> createState() => _AgFormPageState();
}

class _AgFormPageState extends State<AgFormPage> {
  late final List<TextEditingController> _controllers = List.generate(
    widget.fields.length,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    // ★ محاكاة الإرسال — يُستبدل لاحقاً بطلب فعلي للخادم.
    context.showSnackBar(widget.successMessage);
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: const SuperHeader(showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          // ---- مقدّمة الصفحة ----
          Text(
            widget.title,
            style: AppTypography.headlineMedium.copyWith(
              color: context.textColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- الحقول ----
          for (int i = 0; i < widget.fields.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            AgField(
              label: widget.fields[i].label,
              hint: widget.fields[i].hint,
              icon: widget.fields[i].icon,
              controller: _controllers[i],
              textInputAction: i == widget.fields.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
            ),
          ],

          if (widget.footer != null) ...[
            const SizedBox(height: AppSpacing.xl),
            widget.footer!,
          ],

          const SizedBox(height: AppSpacing.xxl),

          // ---- زر الإرسال (Pill) ----
          AppButton(label: widget.submitLabel, onPressed: _submit),
        ],
      ),
    );
  }
}

/// حقل إدخال موحّد: عنوان + بطاقة إدخال بأيقونة.
class AgField extends StatelessWidget {
  const AgField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AgFieldLabel(label),
        const SizedBox(height: AppSpacing.sm),
        AgInputCard(
          child: TextField(
            controller: controller,
            textInputAction: textInputAction,
            style: AppTypography.bodyLarge.copyWith(
              color: context.textColors.primary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: context.textColors.tertiary,
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: context.textColors.tertiary,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// عنوان حقل داخل الصفحة.
class AgFieldLabel extends StatelessWidget {
  const AgFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelLarge.copyWith(
        color: context.textColors.secondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// غلاف موحّد لحقول الإدخال (سطح + حدود دقيقة).
class AgInputCard extends StatelessWidget {
  const AgInputCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      child: child,
    );
  }
}
