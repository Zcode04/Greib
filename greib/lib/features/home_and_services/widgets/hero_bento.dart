import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/mock_data/mock_data.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/mock_auth.dart';

/// ============================================================================
///  HeroBento — البانر الرئيسي للرئيسية (UX 2026):
///   تحية ترحيبية + شارة العضوية + بطاقتا Bento (المحفظة / الطلب النشط).
/// ============================================================================
class HeroBento extends StatelessWidget {
  const HeroBento({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.currentUser;
    final profile = MockData.demoProfiles.first;
    final isGold = profile.membershipTier == 'gold';
    final name = user?.name ?? profile.name;
    final firstName = name.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentPrimary, AppColors.accentPrimaryLight],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xxl + 4),
        boxShadow: AppColors.violetGlow(blur: 28, alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting()، $firstName',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ماذا تخطط له اليوم؟',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (isGold)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.gift,
                        size: 13,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ذهبي',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _BentoTile(
                  icon: LucideIcons.wallet,
                  label: 'المحفظة',
                  value: '850 ر.ع',
                  caption: '1,250 نقطة ولاء',
                  onTap: () => context.push('/wallet'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _BentoTile(
                  icon: LucideIcons.package,
                  label: 'طلب نشط',
                  value: '×1',
                  caption: 'متابعة التوصيل',
                  onTap: () => context.push('/orders'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // >>> BENTO_TILE_MARKER
}

/// بطاقة Bento داخل البانر — زجاجية على التدرج البنفسجي.
class _BentoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final VoidCallback onTap;

  const _BentoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                caption,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}