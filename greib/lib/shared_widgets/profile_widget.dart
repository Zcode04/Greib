import 'package:flutter/material.dart';
import '../core/extensions/context_extensions.dart';
import '../core/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/smart_image.dart';

/// ============================================================================
///  ProfileWidget — الملف الشخصي بطراز فيسبوك (Facebook-like Profile).
///
///  التكوين من الأعلى للأسفل:
///    ① غلاف (Cover) بعرض كامل + أفاتار دائري متداخل + اسم المستخدم.
///    ② معلومات التواصل: الهاتف، البريد الإلكتروني، الموقع.
///    ③ الأزرار: إنشاء منشور | تعديل البيانات | تسجيل الدخول.
///
///  ★ بلا تبويبات سريعة (إعدادات/إشعارات/دعم/طلبات)، وبلا إحصائيات أو تقييم،
///    وبلا فواصل بين صفوف المعلومات — أسطح مستوية وحدّ شعري واحد فقط.
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
    final topInset = widget.includeTopInset
        ? MediaQuery.paddingOf(context).top + 64
        : 0.0;

    final content = Column(
      children: [
        _ProfileHeaderCard(
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
          onSave: () => setState(() => _isEditing = false),
          onCancel: () => setState(() {
            _resetFields();
            _isEditing = false;
          }),
        ),
        _ProfileActions(
          isEditing: _isEditing,
          isEditable: widget.isEditable,
          onEdit: () => setState(() => _isEditing = true),
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
///  _ProfileHeaderCard — ترويسة البروفايل بطراز فيسبوك.
///
///  غلاف (Cover) بتدرّج لون التمييز يعلو البطاقة، وأفاتار دائري متداخل مع
///  حدّه السفلي، ثم الاسم وشارة الدور/العضوية. بلا تبويبات سريعة وبلا إحصائيات.
/// ============================================================================
class _ProfileHeaderCard extends StatelessWidget {
  final AppUserProfile profile;
  final TextEditingController nameController;
  final bool isEditingName;
  final bool isEditable;

  const _ProfileHeaderCard({
    required this.profile,
    required this.nameController,
    required this.isEditingName,
    this.isEditable = true,
  });

  /// ارتفاع الغلاف، ونصف قطر الأفاتار (يتداخل نصفه مع الغلاف).
  static const double _coverHeight = 132;
  static const double _avatarSize = 96;

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
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ① الغلاف + الأفاتار المتداخل معه.
          SizedBox(
            height: _coverHeight + _avatarSize / 2,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: _coverHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            accent.withValues(alpha: 0.85),
                            accent.withValues(alpha: 0.30),
                          ],
                        ),
                      ),
                      // لمسة ضوئية ناعمة تعطي الغلاف عمقاً بلا صور ولا أيقونات.
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.7, -0.9),
                            radius: 1.4,
                            colors: [
                              Colors.white.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  top: _coverHeight - _avatarSize / 2,
                  child: Stack(
                    children: [
                      Container(
                        width: _avatarSize,
                        height: _avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: surface,
                          border: Border.all(color: surface, width: 4),
                        ),
                        padding: const EdgeInsets.all(2),
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
                            width: 28,
                            height: 28,
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
                ),
              ],
            ),
          ),
          // ② الاسم + الدور والعضوية.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
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
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
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
    );
  }
}

/// ============================================================================
///  _ProfileActions — أزرار أسفل معلومات التواصل:
///  «إنشاء منشور» و«تعديل البيانات» في صف واحد، و«تسجيل الدخول» بعرض كامل.
/// ============================================================================
class _ProfileActions extends StatelessWidget {
  final bool isEditing;
  final bool isEditable;
  final VoidCallback onEdit;

  const _ProfileActions({
    required this.isEditing,
    required this.isEditable,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final canEdit = isEditable && !isEditing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'إنشاء منشور',
                  icon: LucideIcons.squarePen,
                  onPressed: () => context.push('/create-post'),
                ),
              ),
              if (canEdit) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'تعديل البيانات',
                    icon: LucideIcons.pencil,
                    type: ButtonType.secondary,
                    color: accent.withValues(alpha: 0.12),
                    textColor: accent,
                    onPressed: onEdit,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'تسجيل الدخول',
            icon: LucideIcons.logIn,
            type: ButtonType.secondary,
            isOutlined: true,
            color: accent,
            onPressed: () => context.go('/login'),
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


/// ============================================================================
///  _ContactCard — بطاقة معلومات التواصل بطراز فيسبوك.
///
///  ثلاث معلومات: الهاتف، البريد الإلكتروني، الموقع — كل واحدة بأيقونة داخل
///  قرص ملوّن خفيف، بلا فواصل، مع وضع تحرير سلس (حقول + زرّا «حفظ» و«إلغاء»).
/// ============================================================================
class _ContactCard extends StatelessWidget {
  final AppUserProfile profile;
  final bool isEditing;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ContactCard({
    required this.profile,
    required this.isEditing,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
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
          Text(
            'معلومات التواصل',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
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
              forceLtr: true,
            ),
            _InfoRow(
              icon: LucideIcons.mail,
              value: emailController.text.isEmpty
                  ? profile.email
                  : emailController.text,
              forceLtr: true,
            ),
            _InfoRow(
              icon: LucideIcons.mapPin,
              value: addressController.text.isEmpty
                  ? (profile.address ?? 'غير محدد')
                  : addressController.text,
            ),
          ],
        ],
      ),
    );
  }
}

/// صف معلومة واحد: أيقونة داخل قرص بلون التمييز + القيمة.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  /// تثبيت اتجاه النص LTR (للأرقام/البريد) حتى لا يقلب محرك BiDi العلامات.
  final bool forceLtr;

  const _InfoRow({
    required this.icon,
    required this.value,
    this.forceLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.10),
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              // LTR فقط لتصحيح ترتيب العلامات (BiDi) — المحاذاة تبقى start
              // أي ملاصقة للأيقونة في RTL دون فجوة بصرية.
              textDirection: forceLtr ? TextDirection.ltr : null,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                color: context.iconColors.error,
                onPressed: () => context.go('/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

