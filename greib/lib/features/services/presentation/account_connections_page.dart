import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/account_model.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/account_repository.dart';
import '../data/services_repository.dart';

/// ============================================================================
///  AccountConnectionsPage — صفحة relations الحساب.
///
///  المسار:  /account/:id/connections
///  يفتحها: الضغط على سطر «متابع · يتابع · منشور» في صفحة الحساب.
///
///  ★ الهيكل: ترويسة مصغّرة (غلاف + بروفايل متداخل + زر رجوع) ثم تبويب واحد
///    بثلاث صفحات داخلية: المتابِعون | يتابع | متابِعون مشتركون.
///    أسفل كل تبويب: «المتابِعون (1234)» و«يتابع (567)» — كلٌّ منها يفتح نفس
///    الصفحة على التبويب المطلوب (navigation عبر query param).
///
///  ★ البيانات: AccountRepository.{followersOf, followingOf, mutualOf}
///    — قوائم ثابتة مشتقّة من المعرّف (mock)، وتضم حسابات حقيقية من كل
///    الخدمات ⇒ الضغط على أي صف ينقل إلى صفحته (/account/:id).
/// ============================================================================
class AccountConnectionsPage extends StatefulWidget {
  final String accountId;

  /// التبويب الافتتاحي (0=متابعون، 1=يتابع، 2=مشتركون).
  final int initialTab;

  const AccountConnectionsPage({
    super.key,
    required this.accountId,
    this.initialTab = 0,
  });

  @override
  State<AccountConnectionsPage> createState() =>
      _AccountConnectionsPageState();
}

class _AccountConnectionsPageState extends State<AccountConnectionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 3,
    vsync: this,
    initialIndex: widget.initialTab.clamp(0, 2),
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    final account = AccountRepository.instance.byId(widget.accountId);
    final service = account == null
        ? null
        : ServicesRepository.instance.byId(account.serviceId);
    if (account == null || service == null) return const _NotFound();

    final repo = AccountRepository.instance;
    // ★ القوائم الثلاث تُحسب مرة واحدة ⇒ نفس البيانات في التبويبات الثلاثة.
    final followers = repo.followersOf(account.id);
    final following = repo.followingOf(account.id);
    final mutual = repo.mutualOf(account.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: _MiniHeader(account: account, service: service, isDark: isDark),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsDelegate(
                backgroundColor: bg,
                accent: service.color,
                isDark: isDark,
                controller: _tabs,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [
              _RelationList(
                accounts: followers,
                isDark: isDark,
                emptyLabel: 'لا يوجد متابِعون بعد',
                serviceColor: service.color,
              ),
              _RelationList(
                accounts: following,
                isDark: isDark,
                emptyLabel: 'لا يتابع أحداً بعد',
                serviceColor: service.color,
              ),
              _RelationList(
                accounts: mutual,
                isDark: isDark,
                emptyLabel: 'لا يوجد متابِعون مشتركون',
                serviceColor: service.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ الترويسة المصغّرة ============================
/// نفس غلاف/بروفايل صفحة الحساب لكن بارتفاع أصغر (الهدف هنا هو القوائم).
class _MiniHeader extends StatelessWidget {
  final AccountProfile account;
  final ServiceCategory service;
  final bool isDark;

  const _MiniHeader({
    required this.account,
    required this.service,
    required this.isDark,
  });

  static const double _coverHeight = 120;
  static const double _avatarSize = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: _coverHeight,
              width: double.infinity,
              child: account.coverUrl != null
                  ? Image.network(
                      account.coverUrl!,
                      fit: BoxFit.cover,
                      // ★ فشل الشبكة ⇒ لا استثناء (يبقى التدرّج خلفها).
                      errorBuilder: (_, _, _) => _CoverFallback(color: service.color),
                    )
                  : _CoverFallback(color: service.color),
            ),
            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              start: AppSpacing.md,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      (isDark ? AppColors.surfaceCard : AppColors.lightSurface)
                          .withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                ),
              ),
            ),
            PositionedDirectional(
              start: AppSpacing.xl,
              bottom: -_avatarSize / 2,
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.surfaceCard
                      : AppColors.lightSurface,
                  border: Border.all(color: bg, width: 4),
                  boxShadow: AppShadows.brandGlow,
                  image: account.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(account.avatarUrl!),
                          fit: BoxFit.cover,
                          onError: (_, _) {},
                        )
                      : null,
                ),
                child: account.avatarUrl == null
                    ? Icon(
                        LucideIcons.userRound,
                        size: 34,
                        color: service.color,
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: _avatarSize / 2 + AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            account.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ============================ شريط التبويبات ============================
class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Color accent;
  final bool isDark;
  final TabController controller;

  _TabsDelegate({
    required this.backgroundColor,
    required this.accent,
    required this.isDark,
    required this.controller,
  });

  static const double _height = 46;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: backgroundColor,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: isDark ? AppColors.outline : AppColors.lightOutline,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'المتابِعون'),
          Tab(text: 'يتابع'),
          Tab(text: 'متابِعون مشتركون'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsDelegate old) =>
      old.backgroundColor != backgroundColor ||
      old.accent != accent ||
      old.isDark != isDark ||
      old.controller != controller;
}

// ============================ قائمة الحسابات ============================
/// ★ صف واحد لكل حساب: بروفايل + اسم + خدمة + زر متابعة دائري الحواف.
class _RelationList extends StatelessWidget {
  final List<AccountProfile> accounts;
  final bool isDark;
  final String emptyLabel;
  final Color serviceColor;

  const _RelationList({
    required this.accounts,
    required this.isDark,
    required this.emptyLabel,
    required this.serviceColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = isDark ? AppColors.outline : AppColors.lightOutline;

    if (accounts.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: accounts.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        color: line,
        indent: 76,
      ),
      itemBuilder: (context, i) => _RelationRow(
        account: accounts[i],
        isDark: isDark,
        accent: serviceColor,
      ),
    );
  }
}

class _RelationRow extends StatefulWidget {
  final AccountProfile account;
  final bool isDark;
  final Color accent;

  const _RelationRow({
    required this.account,
    required this.isDark,
    required this.accent,
  });

  @override
  State<_RelationRow> createState() => _RelationRowState();
}

class _RelationRowState extends State<_RelationRow> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final account = widget.account;

    return ListTile(
      onTap: () => context.push('/account/${account.id}'),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.accent.withValues(alpha: 0.15),
          image: account.avatarUrl != null
              ? DecorationImage(
                  image: NetworkImage(account.avatarUrl!),
                  fit: BoxFit.cover,
                  onError: (_, _) {},
                )
              : null,
        ),
        child: account.avatarUrl == null
            ? Icon(
                LucideIcons.userRound,
                size: 20,
                color: widget.accent,
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              account.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (account.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(
              LucideIcons.badgeCheck,
              size: 14,
              color: AppColors.info,
            ),
          ],
        ],
      ),
      subtitle: Text(
        account.location,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: _FollowPill(
        isFollowing: _isFollowing,
        color: widget.accent,
        onTap: () => setState(() => _isFollowing = !_isFollowing),
      ),
    );
  }
}

/// زر متابعة صغير بحواف دائرية كاملة (rounded-full).
class _FollowPill extends StatelessWidget {
  final bool isFollowing;
  final Color color;
  final VoidCallback onTap;

  const _FollowPill({
    required this.isFollowing,
    required this.color,
    required this.onTap,
  });

  static BorderRadius get _radius => BorderRadius.circular(999);

  @override
  Widget build(BuildContext context) {
    final fg = isFollowing ? color : Colors.white;
    return Material(
      color: isFollowing ? color.withValues(alpha: 0.12) : color,
      borderRadius: _radius,
      child: InkWell(
        borderRadius: _radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          child: Text(
            isFollowing ? 'متابَع' : 'متابعة',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ غلاف بديل ============================
class _CoverFallback extends StatelessWidget {
  final Color color;
  const _CoverFallback({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.35),
            color.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(child: Icon(LucideIcons.image, color: color, size: 28)),
    );
  }
}

// ============================ غير موجود ============================
class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundPrimary
            : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColors.backgroundPrimary
              : AppColors.lightBackground,
        ),
        body: Center(
          child: Text(
            'الحساب غير موجود',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}