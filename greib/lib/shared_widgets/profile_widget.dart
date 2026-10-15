import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/extensions/context_extensions.dart';
import '../core/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/user/user_data.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/smart_image.dart';
import 'sheets/avatar_picker_sheet.dart';

/// ============================================================================
///  ProfileWidget — الملف الشخصي بروح KIMI: هادئ، خفيف، راقٍ.
///
///  يعرض فقط:
///    - الاسم + الأفاتار (بطاقة الهوية).
///    - أيقونات معلومات التواصل: الهاتف، الواتساب، البريد، الموقع.
///  بلا تحرير، بلا إحصائيات، بلا اختصارات — أسطح مستوية وحدود شعرية فقط.
/// ============================================================================
class ProfileWidget extends StatelessWidget {
  final AppUserProfile profile;

  /// ★ يُطفأ عند تضمين البطاقة داخل صفحة فيها تبويبات علوية
  ///   (مثل AccountTabsPage) لأن المسافة العلوية تُدار هناك.
  final bool includeTopInset;

  const ProfileWidget({
    super.key,
    required this.profile,
    this.includeTopInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = includeTopInset
        ? MediaQuery.paddingOf(context).top + 64
        : 0.0;

    final content = Column(
      children: [
        _IdentityCard(profile: profile),
        _ContactCard(profile: profile),
      ],
    );

    if (!includeTopInset) return content;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: topInset, bottom: 110),
      child: content,
    );
  }
}

/// ============================================================================
///  _IdentityCard — بطاقة الهوية بروح KIMI.
///
///  الأفاتار في المنتصف، الاسم تحته، وأيقونة كاميرا عائمة تفتح شيت
///  (التقاط/إرفاق) — الصورة المختارة تُحفظ في UserData (ملف المستخدم
///  المركزي) فتظهر فوراً وتبقى بعد الخروج والعودة وإعادة التشغيل.
/// ============================================================================
class _IdentityCard extends StatelessWidget {
  final AppUserProfile profile;

  const _IdentityCard({required this.profile});

  Future<void> _changeAvatar(BuildContext context) async {
    final file = await showAvatarPickerSheet(context);
    if (file == null) return;
    // ★ تُحفظ في ملف المستخدم المركزي (UserData) — تبقى بعد الخروج والعودة.
    await UserData.instance.setAvatarPath(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.55);
    final hairline = onSurface.withValues(alpha: 0.1);

    // ★ الصورة من ملف المستخدم المركزي — أي تغيير يُعاد بناء كل الواجهات.
    final avatarPath = context.select<UserData, String?>((u) => u.avatarPath);

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: hairline, width: 1.5),
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: avatarPath != null
                      ? Image.file(
                          File(avatarPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _AvatarInitials(
                            name: profile.name,
                            accent: accent,
                            textColor: muted,
                          ),
                        )
                      : SmartImage(
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
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    onTap: () => _changeAvatar(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        border: Border.all(color: surface, width: 2.5),
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: onSurface,
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


/// ============================================================================
///  _ContactCard — معلومات التواصل بروح KIMI.
///
///  صفوف مفصولة بفواصل شعرية: الهاتف، الواتساب، البريد، الموقع.
///  أسطح مستوية، أيقونات أحادية هادئة، بلا تحرير.
/// ============================================================================
class _ContactCard extends StatelessWidget {
  final AppUserProfile profile;

  const _ContactCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          _InfoRow(
            icon: LucideIcons.phone,
            value: profile.phone,
            iconColor: muted,
            forceLtr: true,
          ),
          _InfoDivider(),
          _InfoRow(
            icon: LucideIcons.messageCircle,
            value: profile.phone,
            iconColor: muted,
            forceLtr: true,
          ),
          _InfoDivider(),
          _InfoRow(
            icon: LucideIcons.mail,
            value: profile.email,
            iconColor: muted,
            forceLtr: true,
          ),
          _InfoDivider(),
          _InfoRow(
            icon: LucideIcons.mapPin,
            value: profile.address ?? 'غير محدد',
            iconColor: muted,
            isLast: true,
          ),
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
