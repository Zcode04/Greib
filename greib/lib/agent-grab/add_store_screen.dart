import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/extensions/context_extensions.dart';
import '../core/theme/design_tokens.dart';
import '../core/widgets/super_header.dart';
import '../shared_widgets/app_button.dart';

/// ============================================================================
///  AddStoreScreen — صفحة «إضافة محل» (Add Store) — مجلد agent-grab.
///
///  ★ نسخة تجريبية (Mock) — مكوّنات أولية فقط:
///      • اسم المحل (مطلوب).
///      • موقع المحل (مطلوب).
///      • الإحداثيات (اختياري).
///  ◆ للتطوير لاحقاً: التقاط الموقع تلقائياً، خريطة لتحديد الموقع،
///    صور المحل، أوقات العمل، التواصل، ثم الإرسال للخادم.
/// ============================================================================
class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({super.key});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _coordsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _coordsController.dispose();
    super.dispose();
  }

  void _submit() {
    // ★ محاكاة الإرسال — يُستبدل لاحقاً بطلب فعلي للخادم.
    context.showSnackBar('تم إرسال بيانات المحل، شكراً لك');
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
            'إضافة محل',
            style: AppTypography.headlineMedium.copyWith(
              color: context.textColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'أضف بيانات المحل حتى يظهر للمستخدمين على الخريطة وقوائم البحث.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textColors.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ---- اسم المحل ----
          const _FieldLabel('اسم المحل'),
          const SizedBox(height: AppSpacing.sm),
          _InputCard(
            child: TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب اسم المحل',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textColors.tertiary,
                ),
                prefixIcon: Icon(
                  LucideIcons.store,
                  size: 20,
                  color: context.textColors.tertiary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- موقع المحل ----
          const _FieldLabel('الموقع'),
          const SizedBox(height: AppSpacing.sm),
          _InputCard(
            child: TextField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'المدينة، الحي، اسم الشارع',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textColors.tertiary,
                ),
                prefixIcon: Icon(
                  LucideIcons.mapPin,
                  size: 20,
                  color: context.textColors.tertiary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- الإحداثيات (اختياري) ----
          const _FieldLabel('الإحداثيات (اختياري)'),
          const SizedBox(height: AppSpacing.sm),
          _InputCard(
            child: TextField(
              controller: _coordsController,
              textInputAction: TextInputAction.done,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'مثال: 18.0735, -15.9582',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textColors.tertiary,
                ),
                prefixIcon: Icon(
                  LucideIcons.crosshair,
                  size: 20,
                  color: context.textColors.tertiary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ---- زر الإرسال (Pill) ----
          AppButton(
            label: 'إرسال',
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
