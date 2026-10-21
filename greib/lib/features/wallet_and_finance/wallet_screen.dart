import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared_widgets/app_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // رأس الصفحة
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                // ★ أُزيل جرس الإشعارات من هنا: كان زراً مكرراً مع جرس الهيدر
                // (Shell) وغير تفاعلي أصلاً — الهيدر يتكفّل بالإشعارات.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محفظتي',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.textColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'إدارة رصيدك ونقاطك',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.textColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // بطاقة الرصيد
            SliverToBoxAdapter(
              child: _buildBalanceCard(context, theme),
            ),

            // تبويبات
            SliverToBoxAdapter(
              child: _buildTabBar(context, theme),
            ),

            // محتوى التبويب — تبديل ناعم (تلاشٍ قصير) بدل القفزة المباشرة.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey<int>(_selectedTab),
                    child: _buildTabContent(context, theme),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  بطاقة الرصيد — أسلوب بطاقة بنكية
  // ---------------------------------------------------------------------------
  Widget _buildBalanceCard(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
          colors: [context.accentColor, context.accentColor, context.backgroundColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: [
          BoxShadow(
            color: context.accentColor.withValues(alpha: 0.4),
            blurRadius: 28,
            spreadRadius: 2.8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // زخرفة دائرية خلفية (أسلوب البطاقات البنكية)
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الرصيد المتاح',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '1,250 نقطة',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '250.00',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'AED',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _cardActionButton(
                          context,
                          icon: LucideIcons.plus,
                          label: 'شحن',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _cardActionButton(
                          context,
                          icon: LucideIcons.send,
                          label: 'تحويل',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _cardActionButton(
                          context,
                          icon: LucideIcons.arrowDownToLine,
                          label: 'سحب',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  شريط التبويبات
  // ---------------------------------------------------------------------------
  Widget _buildTabBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
          color: context.backgroundColors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildTab(context, 'الرصيد', 0, _selectedTab == 0),
          _buildTab(context, 'النقاط', 1, _selectedTab == 1),
          _buildTab(context, 'الاستبدال', 2, _selectedTab == 2),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index, bool isSelected) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? context.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.full),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.accentColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? Colors.white
                  : context.textColors.secondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  محتوى التبويبات
  // ---------------------------------------------------------------------------
  Widget _buildTabContent(BuildContext context, ThemeData theme) {
    switch (_selectedTab) {
      case 0:
        return _buildBalanceTab(theme);
      case 1:
        return _buildPointsTab(context, theme);
      case 2:
        return _buildRedeemTab(context, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBalanceTab(ThemeData theme) {
    final transactions = [
      {
        'title': 'طلب توصيل طعام',
        'subtitle': 'اليوم',
        'amount': '-45.00 درهم',
        'type': 'debit',
        'icon': LucideIcons.utensilsCrossed,
        'color': context.accentColor,
      },
      {
        'title': 'شحن المحفظة',
        'subtitle': 'أمس',
        'amount': '+200.00 درهم',
        'type': 'credit',
        'icon': LucideIcons.wallet,
        'color': context.accentColor,
      },
      {
        'title': 'طلب صيدلية',
        'subtitle': 'منذ يومين',
        'amount': '-32.00 درهم',
        'type': 'debit',
        'icon': LucideIcons.pill,
        'color': context.accentColor,
      },
      {
        'title': 'مكافأة ولاء',
        'subtitle': 'منذ ٣ أيام',
        'amount': '+25.00 درهم',
        'type': 'credit',
        'icon': LucideIcons.gift,
        'color': context.accentColor,
      },
    ];

    return Column(
      children: [
        for (final tx in transactions)
          _TransactionTile(
            title: tx['title'] as String,
            subtitle: tx['subtitle'] as String,
            amount: tx['amount'] as String,
            isCredit: tx['type'] == 'credit',
            icon: tx['icon'] as IconData,
            iconColor: tx['color'] as Color,
          ),
      ],
    );
  }

  Widget _buildPointsTab(BuildContext context, ThemeData theme) {
    final pointsHistory = [
      {'title': 'طلب توصيل طعام', 'points': '+125', 'time': 'اليوم'},
      {'title': 'طلب صيدلية', 'points': '+80', 'time': 'منذ يومين'},
      {'title': 'تقييم طلب', 'points': '+50', 'time': 'منذ ٣ أيام'},
      {'title': 'استبدال نقاط', 'points': '-200', 'time': 'منذ أسبوع'},
    ];

    return Column(
      children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.accentColor.withValues(alpha: 0.18),
                  context.accentColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: context.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: context.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    LucideIcons.sparkles,
                    color: context.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نقاطك الحالية',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.textColors.secondary,
                        ),
                      ),
                      Text(
                        '1,250 نقطة',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: context.accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.iconColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        color: context.iconColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '+255',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: context.iconColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...pointsHistory.map((item) {
            final isPositive = (item['points'] as String).startsWith('+');
            return _PointsTile(
              title: item['title'] as String,
              time: item['time'] as String,
              points: item['points'] as String,
              isPositive: isPositive,
            );
          }),
      ],
    );
  }

  Widget _buildRedeemTab(BuildContext context, ThemeData theme) {
    final rewards = [
      {'title': 'خصم 10%', 'points': '500', 'icon': LucideIcons.percent},
      {'title': 'توصيل مجاني', 'points': '300', 'icon': LucideIcons.truck},
      {'title': 'خصم 25 درهم', 'points': '800', 'icon': LucideIcons.gift},
      {'title': 'عضوية ذهبية', 'points': '2000', 'icon': LucideIcons.crown},
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _RewardCard(
          title: reward['title'] as String,
          points: reward['points'] as String,
          icon: reward['icon'] as IconData,
          onRedeem: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم استبدال المكافأة بنجاح ✅'),
                backgroundColor: context.iconColors.success,
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================================
//  عناصر فرعية (Widgets)
// ============================================================================

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final IconData icon;
  final Color iconColor;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: context.backgroundColors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.textColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isCredit ? context.iconColors.success : context.textColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsTile extends StatelessWidget {
  final String title;
  final String time;
  final String points;
  final bool isPositive;

  const _PointsTile({
    required this.title,
    required this.time,
    required this.points,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: context.backgroundColors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (isPositive ? context.iconColors.success : context.iconColors.error)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              isPositive ? LucideIcons.plus : LucideIcons.minus,
              color: isPositive ? context.iconColors.success : context.iconColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.textColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isPositive ? context.iconColors.success : context.iconColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final String points;
  final IconData icon;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.title,
    required this.points,
    required this.icon,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: context.backgroundColors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.accentColor.withValues(alpha: 0.2),
                  context.accentColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              icon,
              color: context.accentColor,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.textColors.primary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              '$points نقطة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'استبدل',
            type: ButtonType.primary,
            isFullWidth: true,
            onPressed: onRedeem,
          ),
        ],
      ),
    );
  }
}
