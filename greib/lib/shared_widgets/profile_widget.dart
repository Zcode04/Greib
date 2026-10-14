import 'package:flutter/material.dart';
import '../core/extensions/context_extensions.dart';
import '../core/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/section_header.dart';
import '../../shared_widgets/smart_image.dart';
import '../../features/home_and_services/widgets/orders_list.dart';

/// ============================================================================
///  ProfileWidget — الملف الشخصي بروح KIMI: هادئ، خفيف، راقٍ.
///
///  القواعد:
///    - أسطح مستوية (flat) بلا تدرجات، حدود شعرية 1px، ظلال شبه معدومة.
///    - الألوان من نظام التطبيق (surface / outline / muted) — لا ألوان صارخة.
///    - الأفاتار صغير (72) بجانب الاسم — لا غلاف ملوّن ولا توهج.
///    - الإحصائيات صف نصي هادئ بفواصل رفيعة.
/// ============================================================================
class ProfileWidget extends StatefulWidget {
  final AppUserProfile profile;
  final bool isEditable;

  /// ★ يُطفأ عند تضمين البطاقة داخل صفحة فيها تبويبات علوية
  ///   (مثل AccountTabsPage) لأن المسافة العلوية تُدار هناك.
  final bool includeTopInset;

  const ProfileWidget({
    super.key,
    required this.profile,
    this.isEditable = true,
    this.includeTopInset = true,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _emailController = TextEditingController(text: widget.profile.email);
    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// إعادة الحقول لقيم البروفايل (زر «إلغاء»).
  void _resetFields() {
    _nameController.text = widget.profile.name;
    _phoneController.text = widget.profile.phone;
    _emailController.text = widget.profile.email;
    _addressController.text = widget.profile.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final topInset = widget.includeTopInset
        ? MediaQuery.paddingOf(context).top + 64
        : 0.0;

    final content = Column(
      children: [
        _IdentityCard(
          profile: widget.profile,
          nameController: _nameController,
          isEditingName: _isEditing,
          isEditable: widget.isEditable,
        ),
        _ContactCard(
          profile: widget.profile,
          isEditing: _isEditing,
          phoneController: _phoneController,
          emailController: _emailController,
          addressController: _addressController,
          onEdit: () => setState(() => _isEditing = true),
          onSave: () => setState(() => _isEditing = false),
          onCancel: () => setState(() {
            _resetFields();
            _isEditing = false;
          }),
          isEditable: widget.isEditable,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'طلباتك الحالية',
                icon: LucideIcons.package,
                iconColor: AppColors.warning,
                actionTitle: 'كل الطلبات',
                onActionTap: () => context.push('/orders'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: OrdersList(
                  isDark: theme.brightness == Brightness.dark,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!widget.includeTopInset) return content;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: topInset, bottom: 110),
      child: content,
    );
  }
}

/// ============================================================================
///  _IdentityCard — بطاقة الهوية بروح KIMI.
///
///  أفاتار صغير يسار الاسم، شارة دور نصية خافتة، وصف إحصائيات نصي بفواصل.
///  بلا غلاف ملوّن، بلا توهج، بلا تدرجات — سطح مستوٍ وحدّ شعري فقط.
/// ============================================================================
class _IdentityCard extends StatelessWidget {
  final AppUserProfile profile;
  final TextEditingController nameController;
  final bool isEditingName;
  final bool isEditable;

  const _IdentityCard({
    required this.profile,
    required this.nameController,
    required this.isEditingName,
    this.isEditable = true,
  });

  String get _tierLabel {
    switch (profile.membershipTier) {
      case 'gold':
        return 'ذهبية';
      case 'silver':
        return 'فضية';
      case 'platinum':
        return 'بلاتينية';
      default:
        return 'أساسية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleEnum = PermissionService.roleFromString(profile.role);
    final accent = context.accentColor;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.55);
    final hairline = onSurface.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: hairline, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: SmartImage(
                        src: profile.avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: _AvatarInitials(
                          name: profile.name,
                          accent: accent,
                          textColor: muted,
                        ),
                      ),
                    ),
                  ),
                  if (isEditable)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          border: Border.all(color: surface, width: 2),
                        ),
                        child: const Icon(
                          LucideIcons.camera,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEditingName)
                      TextField(
                        controller: nameController,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: hairline),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: accent),
                          ),
                        ),
                      )
                    else
                      Text(
                        nameController.text.isEmpty
                            ? profile.name
                            : nameController.text,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          roleEnum != null
                              ? PermissionService.roleLabel(roleEnum)
                              : profile.role,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: muted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'عضوية $_tierLabel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _QuickPill(
                  icon: LucideIcons.settings,
                  label: 'الإعدادات',
                  onTap: () => context.push('/settings'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickPill(
                  icon: LucideIcons.bell,
                  label: 'الإشعارات',
                  onTap: () => context.push('/notifications'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickPill(
                  icon: LucideIcons.headphones,
                  label: 'الدعم',
                  onTap: () => context.push('/support'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickPill(
                  icon: LucideIcons.package,
                  label: 'طلباتي',
                  onTap: () => context.push('/orders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: hairline)),
            ),
            child: Row(
              children: [
                _Stat(value: '${profile.loyaltyPoints}', label: 'نقطة'),
                _StatDivider(),
                _Stat(value: '${MockData.demoOrders.length}', label: 'طلبات'),
                _StatDivider(),
                const _Stat(value: '4.8', label: 'التقييم'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  _AvatarInitials — بديل الأفاتار: أحرف الاسم الأولى بخلفية ملوّنة خفيفة
///  (طراز عالمي كما في Gmail/Google)، مع سقوط آمن لأيقونة عند غياب الاسم.
/// ============================================================================
class _AvatarInitials extends StatelessWidget {
  final String name;
  final Color accent;
  final Color textColor;

  const _AvatarInitials({
    required this.name,
    required this.accent,
    required this.textColor,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first;
    return parts.first.characters.first + parts.last.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials;
    return Container(
      color: accent.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: initials.isEmpty
          ? Icon(LucideIcons.user, size: 30, color: textColor)
          : Text(
              initials,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
    );
  }
}


class _QuickPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final hairline = onSurface.withValues(alpha: 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: hairline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: onSurface.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// خلية إحصائية نصية هادئة (قيمة + تسمية خافتة).
class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: 1,
      height: 28,
      color: onSurface.withValues(alpha: 0.1),
    );
  }
}

/// ============================================================================
///  _ContactCard — بطاقة معلومات التواصل بروح KIMI.
///
///  صفوف مفصولة بفواصل شعرية، أيقونات أحادية هادئة، ووضع تحرير سلس
///  (حقول + زرّا «حفظ» و«إلغاء»). الأسطح مستوية والظلال شبه معدومة.
/// ============================================================================
class _ContactCard extends StatelessWidget {
  final AppUserProfile profile;
  final bool isEditing;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isEditable;

  const _ContactCard({
    required this.profile,
    required this.isEditing,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.55);
    final hairline = onSurface.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'معلومات التواصل',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const Spacer(),
              if (isEditable && !isEditing)
                _SmallIconBtn(
                  icon: LucideIcons.pencil,
                  tooltip: 'تعديل البيانات',
                  onTap: onEdit,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isEditing) ...[
            _EditField(
              controller: phoneController,
              label: 'رقم الهاتف',
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
              forceLtr: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _EditField(
              controller: emailController,
              label: 'البريد الإلكتروني',
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              forceLtr: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _EditField(
              controller: addressController,
              label: 'العنوان',
              icon: LucideIcons.mapPin,
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'حفظ',
                    icon: LucideIcons.check,
                    onPressed: onSave,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'إلغاء',
                    icon: LucideIcons.x,
                    type: ButtonType.ghost,
                    onPressed: onCancel,
                  ),
                ),
              ],
            ),
          ] else ...[
            _InfoRow(
              icon: LucideIcons.phone,
              value: phoneController.text.isEmpty
                  ? profile.phone
                  : phoneController.text,
              iconColor: muted,
              forceLtr: true,
            ),
            _InfoDivider(),
            _InfoRow(
              icon: LucideIcons.mail,
              value: emailController.text.isEmpty
                  ? profile.email
                  : emailController.text,
              iconColor: muted,
              forceLtr: true,
            ),
            _InfoDivider(),
            _InfoRow(
              icon: LucideIcons.mapPin,
              value: addressController.text.isEmpty
                  ? (profile.address ?? 'غير محدد')
                  : addressController.text,
              iconColor: muted,
              isLast: true,
            ),
            if (isEditable) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'تعديل البيانات',
                icon: LucideIcons.pencil,
                type: ButtonType.secondary,
                onPressed: onEdit,
                color: accent.withValues(alpha: 0.12),
                textColor: accent,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// فاصل شعري رفيع بين صفوف المعلومات.
class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Divider(
      height: 1,
      thickness: 1,
      color: onSurface.withValues(alpha: 0.08),
    );
  }
}

/// صف معلومة واحد: أيقونة أحادية هادئة + القيمة.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color iconColor;
  final bool isLast;

  /// تثبيت اتجاه النص LTR (للأرقام/البريد) حتى لا يقلب محرك BiDi العلامات.
  final bool forceLtr;

  const _InfoRow({
    required this.icon,
    required this.value,
    required this.iconColor,
    this.isLast = false,
    this.forceLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final text = Text(
      value,
      // LTR فقط لتصحيح ترتيب العلامات (BiDi) — المحاذاة تبقى start
      // أي ملاصقة للأيقونة في RTL دون فجوة بصرية.
      textDirection: forceLtr ? TextDirection.ltr : null,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: onSurface.withValues(alpha: 0.85),
        fontWeight: FontWeight.w500,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: text),
        ],
      ),
    );
  }
}

/// حقل تحرير واحد بتصميم البطاقة الهادئ (حدود شعرية).
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  /// تثبيت اتجاه الإدخال LTR (للأرقام/البريد) لتفادي قلب محرك BiDi.
  final bool forceLtr;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.keyboardType,
    this.forceLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final onSurface = theme.colorScheme.onSurface;
    final hairline = onSurface.withValues(alpha: 0.12);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: forceLtr ? TextDirection.ltr : null,
      textAlign: forceLtr ? TextAlign.left : TextAlign.start,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon:
            Icon(icon, size: 18, color: onSurface.withValues(alpha: 0.45)),
        isDense: true,
        filled: true,
        fillColor: onSurface.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}

/// زر أيقونة دائري صغير (تحرير سريع) — هادئ بحدّ شعري.
class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.08),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
///  ProfileScreen — صفحة مستقلة للملف الشخصي (تُستخدم عند الحاجة).
/// ============================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockData.demoProfiles.first;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileWidget(profile: profile),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppButton(
                label: 'تسجيل الخروج',
                icon: LucideIcons.logOut,
                type: ButtonType.ghost,
                color: AppColors.error,
                onPressed: () => context.go('/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
