import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/extensions/context_extensions.dart';
import '../core/mock_data/mock_data.dart';
import '../core/models/user_model.dart';
import '../core/theme/design_tokens.dart';
import '../features/auth/auth_service.dart';
import '../features/wallet_and_finance/wallet_screen.dart';
import '../shared_widgets/app_button.dart';
import 'profile_widget.dart';

// ============================================================================
//  ★ المحفظة مفعّلة: تُستدعى صفحة المحفظة الأصلية (WalletScreen) كما هي.
//    لتعطيلها لاحقاً: احذف الاستيراد + Tab + WalletScreen، واجعل length = 1.
// ============================================================================

/// ============================================================================
///  AccountTabsPage — صفحة الحساب (صفحة واحدة متماسكة بروح Super-App).
///
///  تُفتح من أيقونة الحساب (المسار /profile) وتُعرض كـ body داخل Scaffold
///  فيه SuperHeader (في الراوتر) ⇒ لا Scaffold داخلي هنا، فقط عمود واحد:
///    [شريط تبويبات underline ملاصق للهيدر] + [محتوى التبويب].
///
///  ★ التصميم: تبويبات «underline» أنحف وأكثر احترافية — شفافة تندمج مع
///    خلفية الصفحة، حدّ سفلي شعري يفصلها عن المحتوى، ومؤشر رقيق بلون الـ
///    accent. التبديل سلس عبر TabBarView.
///
///  ★ التبويبان: «الملف الشخصي» (بطاقة البيانات) و«المحفظة» (WalletScreen).
///    `initialTab` يفتح تبويب المحفظة مباشرة (مثلاً من /profile?tab=wallet).
/// ============================================================================
class AccountTabsPage extends StatelessWidget {
  /// التبويب المفتوح افتراضياً: 0 = الملف الشخصي، 1 = المحفظة (معطّلة حالياً).
  final int initialTab;

  const AccountTabsPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final profile = MockData.demoProfiles.firstWhere(
      (p) => p.email == user?.email || p.phone == user?.phone,
      orElse: () => MockData.demoProfiles.first,
    );

    // ★ صفحة واحدة متماسكة: بلا Scaffold داخلي (نحن أصلاً داخل body)، وبلا
    //   فراغات علوية/سفلية حول شريط التبويب — ملاصق للهيدر وفاصل شعري عن المحتوى.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        // ★ تبويبان: «الملف الشخصي» و«المحفظة» (WalletScreen).
        length: 2,
        initialIndex: initialTab.clamp(0, 1),
        child: Column(
          children: [
            const _AccountTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _ProfileTab(profile: profile),
                  const WalletScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط التبويبات بنمط «underline» الأنيق: شفاف، حدّ سفلي شعري، مؤشر رقيق.
class _AccountTabBar extends StatelessWidget {
  const _AccountTabBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.55);
    final hairline = onSurface.withValues(alpha: 0.10);

    return Container(
      // ★ شفاف (يندمج مع خلفية الصفحة) + حدّ شعري سفلي يفصل التبويب عن المحتوى.
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: hairline)),
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        // ★ مؤشر رقيق (underline) بلون الـ accent بدل الحبة الملوّنة الكاملة.
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: accent, width: 2.5),
          insets: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        labelColor: accent,
        unselectedLabelColor: muted,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'الملف الشخصي'),
          Tab(text: 'المحفظة'),
        ],
      ),
    );
  }
}

/// محتوى تبويب الملف الشخصي: زر إنشاء منشور + بطاقة البيانات + زر تسجيل الخروج.
class _ProfileTab extends StatelessWidget {
  final AppUserProfile profile;

  const _ProfileTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        children: [
          // ★ أيقونة «إنشاء منشور» — تفتح صفحة التحرير (نص + صورة + فيديو).
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: AppButton(
              label: 'إنشاء منشور',
              icon: LucideIcons.squarePen,
              type: ButtonType.secondary,
              color: context.accentColor.withValues(alpha: 0.12),
              textColor: context.accentColor,
              onPressed: () => context.push('/create-post'),
            ),
          ),
          ProfileWidget(profile: profile, includeTopInset: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppButton(
              label: 'تسجيل الخروج',
              icon: LucideIcons.logOut,
              color: AppColors.error,
              onPressed: () => context.go('/login'),
            ),
          ),
        ],
      ),
    );
  }
}

