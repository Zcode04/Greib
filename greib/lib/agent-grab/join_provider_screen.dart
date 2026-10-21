import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/extensions/context_extensions.dart';
import '../core/theme/design_tokens.dart';
import '../core/widgets/super_header.dart';
import '../shared_widgets/app_button.dart';

/// ============================================================================
///  JoinProviderScreen — صفحة «الانضمام إلينا كمزود خدمة» (مجلد agent-grab).
///
///  ★ نسخة تجريبية (Mock) — مكوّنات أولية فقط:
///      • حقل كتابة الاسم / اسم النشاط.
///      • اختيار نوع الخدمة التي يقدّمها (Pill chips).
///      • زر إرسال الطلب (محاكاة فقط).
///  ◆ للتطوير لاحقاً: بيانات النشاط، الموقع، المستندات، رفع الهوية،
///    التحقق من الحساب، ومتابعة حالة الطلب.
/// ============================================================================
class JoinProviderScreen extends StatefulWidget {
  const JoinProviderScreen({super.key});

  @override
  State<JoinProviderScreen> createState() => _JoinProviderScreenState();
}

class _JoinProviderScreenState extends State<JoinProviderScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedService = -1;

  /// أنواع الخدمات المتاحة لمزود الخدمة (بيانات تجريبية).
  static const List<({String label, IconData icon})> services = [
    (label: 'مطعم / مأكولات', icon: LucideIcons.utensilsCrossed),
    (label: 'متجر / محل تجاري', icon: LucideIcons.store),
    (label: 'صيدلية', icon: LucideIcons.pill),
    (label: 'عيادة / طبيب', icon: LucideIcons.stethoscope),
    (label: 'توصيل', icon: LucideIcons.bike),
    (label: 'فندق / إقامة', icon: LucideIcons.hotel),
    (label: 'خدمات سيارات', icon: LucideIcons.car),
    (label: 'أخرى', icon: LucideIcons.ellipsis),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    // ★ محاكاة الإرسال — يُستبدل لاحقاً بطلب فعلي للخادم.
    context.showSnackBar('تم إرسال طلبك، سنتواصل معك قريباً بإذن الله');
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
            'انضم إلينا كمزود خدمة',
            style: AppTypography.headlineMedium.copyWith(
              color: context.textColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'سجّل اسمك واختر الخدمة التي تقدّمها، وسيتواصل معك فريقنا لتفعيل حسابك.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- حقل الاسم ----
          const _FieldLabel('الاسم'),
          const SizedBox(height: AppSpacing.sm),
          _InputCard(
            child: TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب اسمك أو اسم النشاط',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textColors.tertiary,
                ),
                prefixIcon: Icon(
                  LucideIcons.userRound,
                  size: 20,
                  color: context.textColors.tertiary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- اختيار الخدمة المقدَّمة ----
          const _FieldLabel('الخدمة التي تقدّمها'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (int i = 0; i < services.length; i++)
                _ServiceChip(
                  icon: services[i].icon,
                  label: services[i].label,
                  isSelected: _selectedService == i,
                  onTap: () => setState(() => _selectedService = i),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ---- زر الإرسال (Pill) ----
          AppButton(
            label: 'إرسال الطلب',
            icon: LucideIcons.send,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// عنوان حقل داخل الصفحة.
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

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
class _InputCard extends StatelessWidget {
  final Widget child;

  const _InputCard({required this.child});

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

/// حبة اختيار الخدمة (Pill) — تتلوّن باللون الرسمي عند الاختيار.
class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final labelColor = isSelected
        ? context.textColors.onAccent
        : context.textColors.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected ? accent : context.backgroundColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(
              color: isSelected ? accent : context.backgroundColors.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? context.textColors.onAccent
                    : context.textColors.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: labelColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
