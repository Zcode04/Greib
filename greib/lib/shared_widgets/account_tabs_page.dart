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

/// ============================================================================
///  AccountTabsPage — صفحة الحساب (الملف الشخصي + المحفظة).
///
///  تُفتح من أيقونة المستخدم في شريط الصفحة الرئيسية (المسار /profile).
///  تحتوي على تبويبين ثابتين أسفل الهيدر:
///    1) «الملف الشخصي» — بطاقة البيانات (ProfileWidget) + طلباتك الحالية.
///    2) «المحفظة»       — نفس صفحة المحفظة الأصلية (WalletScreen) بلا أي تعديل.
///
///  ★ الملاحظات:
///    - الـ RTL: اتجاه التبويبات من اليمين (الملف الشخصي أولاً).
///    - زر «تسجيل الخروج» داخل تبويب الملف الشخصي فقط.
///    - المحفظة تُبنى عند أول فتح لتبويبها (TabBarView يبني كسولاً) ⇒ لا تكلفة
///      عند فتح الصفحة على التبويب الأول.
///    - `initialTab`: لفتح الصفحة مباشرة على تبويب المحفظة (مثلاً من زر
///      «المحفظة» في الصفحة الرئيسية): AccountTabsPage(initialTab: 1).
/// ============================================================================
class AccountTabsPage extends StatelessWidget {
  /// التبويب المفتوح افتراضياً: 0 = الملف الشخصي، 1 = المحفظة.
  final int initialTab;

  const AccountTabsPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final profile = MockData.demoProfiles.firstWhere(
      (p) => p.email == user?.email || p.phone == user?.phone,
      orElse: () => MockData.demoProfiles.first,
    );

    // ★ مسافة علوية = شريط الحالة + ارتفاع الهيدر (نفس منطق ProfileWidget).
    final topInset = MediaQuery.paddingOf(context).top + 64;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        initialIndex: initialTab.clamp(0, 1),
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.background
              : AppColors.lightBackground,
          body: Column(
            children: [
              SizedBox(height: topInset),
              _AccountTabBar(),
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
      ),
    );
  }
}

/// شريط التبويبين (الملف الشخصي | المحفظة) بنفس هوية التطبيق.
class _AccountTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.accentColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, accent.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.7,
        ),
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(icon: Icon(LucideIcons.user, size: 18), text: 'الملف الشخصي'),
          Tab(icon: Icon(LucideIcons.wallet, size: 18), text: 'المحفظة'),
        ],
      ),
    );
  }
}

/// محتوى تبويب الملف الشخصي: بطاقة البيانات + زر تسجيل الخروج.
class _ProfileTab extends StatelessWidget {
  final AppUserProfile profile;

  const _ProfileTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        children: [
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
