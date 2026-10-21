import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/chat_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/header.dart';

/// ============================================================================
///  ContactProfileScreen — بروفايل جهة الاتصال/الحساب داخل المحادثة.
/// ============================================================================
///  ◆ تُفتح بالضغط على اسم الشخص أو صورته في هيدر صفحة الدردشة.
///  ◆ الترتيب المعروض:
///     ① صورة البروفايل + الاسم (مع شارة توثيق للحسابات الرسمية)
///     ② الرقم مقنّعاً: الرقم الأول + نجوم + الرقم الأخير
///     ③ تنبيه: «رقم خاص لا يمكن تبادله مع الأشخاص»
///     ④ الهوية: اسم الشخص أو اسم مقدّم الخدمة مع أيقونة
///     ⑤ آخر ظهور
///     ⑥ مدخل «مشاهدة منشورات أو الخدمات» — غير مفعّل (يُطوَّر لاحقاً)
///  ◆ بصري فقط — بلا منطق بيانات (Mock-first مثل باقي التطبيق).
/// ============================================================================
class ContactProfileScreen extends StatelessWidget {
  /// اسم الحساب كما يظهر في المحادثة.
  final String name;

  /// إيموجي صورة البروفايل (بنفس نوع أفاتار الدردشة).
  final String avatar;

  /// رقم الحساب الحقيقي — يُعرض مقنّعاً فقط.
  final String phone;

  /// آخر ظهور / الحالة (مثال: «آخر ظهور اليوم 9:15 ص»).
  final String activity;

  final bool online;

  /// مجموعة (تغيير الأيقونة والوصف فقط).
  final bool isGroup;

  const ContactProfileScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.phone,
    required this.activity,
    this.online = false,
    this.isGroup = false,
  });

  /// ★ تقنيع الرقم: الرقم الأول + نجوم + الرقم الأخير فقط — لا يُكشف
  ///   الرقم كاملاً. يعيد null للأرقام غير الرقمية (حسابات الخدمات/المجموعات).
  static String? _maskPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 3) return null;
    final stars = '*' * (digits.length - 2);
    return '${digits[0]}$stars${digits[digits.length - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final maskedPhone = _maskPhone(phone);
    // «آخر ظهور اليوم 9:15 ص» ⇒ «اليوم 9:15 ص» (بلا تكرار كلمة آخر ظهور).
    final lastSeen = online
        ? 'متصل الآن'
        : activity.replaceFirst('آخر ظهور', '').trim();

    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: const Header(
        title: 'معلومات الحساب',
        showBackButton: true,
        showNotifications: false,
        showDarkModeToggle: false,
        showSearchButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            // ── ① صورة البروفايل + الاسم ──────────────────────────────
            Center(
              child: Container(
                width: 112,
                height: 112,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: context.brandGlow,
                ),
                child: Text(avatar, style: const TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.textColors.primary,
                    ),
                  ),
                ),
                if (!isGroup) ...[
                  const SizedBox(width: 6),
                  Icon(
                    LucideIcons.badgeCheck,
                    size: 18,
                    color: context.iconColors.info,
                  ),
                ],
              ],
            ),

            // ── ②③ الرقم المقنّع + تنبيه الخصوصية ─────────────────────
            if (maskedPhone != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                maskedPhone,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.textColors.primary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.lock,
                    size: 13,
                    color: context.textColors.tertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'رقم خاص لا يمكن تبادله مع الأشخاص',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.textColors.tertiary,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // ── ④ الهوية: الاسم / اسم مقدّم الخدمة ────────────────────
            _ProfileTile(
              icon: isGroup ? LucideIcons.users : LucideIcons.badgeCheck,
              title: name,
              subtitle: isGroup ? 'مجموعة' : 'اسم مقدم الخدمة',
            ),
            const SizedBox(height: AppSpacing.md),

            // ── ⑤ آخر ظهور ───────────────────────────────────────────
            _ProfileTile(
              icon: LucideIcons.clock,
              iconColor: online ? context.chatColors.onlineDot : accent,
              title: 'آخر ظهور',
              subtitle: lastSeen,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── ⑥ المنشورات والخدمات — غير مفعّل حالياً (يُطوَّر لاحقاً) ──
            _ProfileTile(
              icon: LucideIcons.newspaper,
              title: 'منشورات وخدمات الحساب',
              subtitle:
                  'يمكن من هنا مشاهدة منشورات أو الخدمات التي يقدمها الحساب',
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة صف واحدة: أيقونة ملوّنة + عنوان + وصف (بلا أي إجراء عند الضغط).
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = iconColor ?? context.accentColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
