import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/account_model.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/post_sheets.dart';
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

class _AccountConnectionsPageState extends State<AccountConnectionsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    final account = AccountRepository.instance.byId(widget.accountId);
    final service = account == null
        ? null
        : ServicesRepository.instance.byId(account.serviceId);
    if (account == null || service == null) return const _NotFound();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: AccountConnectionsView(
          accountId: widget.accountId,
          initialTab: widget.initialTab,
        ),
      ),
    );
  }
}

/// ★ يفتح شبكة علاقات الحساب في **Bottom Sheet بأسلوب ورقة التعليقات**:
///   لا تملأ الشاشة عند الفتح (٤٥٪ فقط)، وتتكامل ديناميكياً: السحب للأعلى
///   يكبّرها حتى ٩٢٪، والسحب لأسفل يصغّرها ثم يغلقها، مع Snap عند مواضع
///   محدّدة (نفس تجربة `DraggableSheetBody` في ورقة التعليقات).
Future<void> showAccountConnectionsSheet(
  BuildContext context, {
  required String accountId,
  int initialTab = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (sheetContext) {
      final isDark =
          Theme.of(sheetContext).brightness == Brightness.dark;
      final bg = isDark
          ? AppColors.backgroundPrimary
          : AppColors.lightBackground;
      return Directionality(
        textDirection: TextDirection.rtl,
        // ★ نفس ورقة التعليقات: تبدأ صغيرة، تتوسّع بالسحب، وتُغلق بالسحب لأسفل.
        child: DraggableSheetBody(
          initialExtent: _sheetInitialExtent,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AccountConnectionsView(
              accountId: accountId,
              initialTab: initialTab,
              scrollController: scrollController,
              inSheet: true,
            ),
          ),
        ),
      );
    },
  );
}

/// ★ الارتفاع الافتتاحي: نصف الشاشة تقريباً (ورقة تعليقات، لا صفحة كاملة).
const double _sheetInitialExtent = 0.45;

/// ★ نواة العرض المشتركة بين الصفحة والـ Bottom Sheet: ترويسة مصغّرة (غلاف +
/// بروفايل متداخل + زر إغلاق) ثم شريط التبويبات (نفس تصميم صفحة الخدمة)
/// ثم قوائم الحسابات بالتحميل التدريجي.
class AccountConnectionsView extends StatefulWidget {
  final String accountId;
  final int initialTab;

  /// تمرير قابل للسحب (يعطيه DraggableScrollableSheet في حالة الـ Sheet).
  final ScrollController? scrollController;

  /// ★ في الـ Sheet: زر إغلاق (×) بدل زر الرجوع، والترويسة قابلة للسحب.
  final bool inSheet;

  /// ★ متحكّم الورقة (DraggableScrollableController) لتمرير السحب لأسفل.
  const AccountConnectionsView({
    super.key,
    required this.accountId,
    this.initialTab = 0,
    this.scrollController,
    this.inSheet = false,
  });

  @override
  State<AccountConnectionsView> createState() => _AccountConnectionsViewState();
}

class _AccountConnectionsViewState extends State<AccountConnectionsView>
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

    return Column(
      children: [
        // ---------- الترويسة المصغّرة ----------
        // ★ ListenableBuilder ⇒ العنوان المختصر يتحدّث فور تبديل التبويب.
        ListenableBuilder(
          listenable: _tabs,
          builder: (context, _) => _MiniHeader(
            account: account,
            service: service,
            isDark: isDark,
            inSheet: widget.inSheet,
            dragController: widget.scrollController,
            tabIndex: _tabs.index,
            counts: [
              account.followers,
              account.following,
              repo.mutualOf(account.id).length,
            ],
          ),
        ),
        // ---------- شريط التبويبات (نفس تصميم صفحة الخدمة) ----------
        _TabsStrip(
          backgroundColor: bg,
          accent: service.color,
          isDark: isDark,
          controller: _tabs,
        ),
        // ---------- محتوى التبويبات ----------
        Expanded(
          // ★ ListenableBuilder ⇒ نمرّر متحكّم الورقة للقائمة **الshowing فقط**
          //   (التحكّم الواحد لا يتّصل بقائمتين وإلا再一次 assertion من Flutter).
          child: ListenableBuilder(
            listenable: _tabs,
            builder: (context, _) => TabBarView(
              controller: _tabs,
              children: [
                _RelationList(
                  accounts: followers,
                  isDark: isDark,
                  emptyLabel: 'لا يوجد متابِعون بعد',
                  serviceColor: service.color,
                  scrollController: _tabs.index == 0
                      ? widget.scrollController
                      : null,
                ),
                _RelationList(
                  accounts: following,
                  isDark: isDark,
                  emptyLabel: 'لا يتابع أحداً بعد',
                  serviceColor: service.color,
                  scrollController: _tabs.index == 1
                      ? widget.scrollController
                      : null,
                ),
                _RelationList(
                  accounts: mutual,
                  isDark: isDark,
                  emptyLabel: 'لا يوجد متابِعون مشتركون',
                  serviceColor: service.color,
                  scrollController: _tabs.index == 2
                      ? widget.scrollController
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================ الترويسة المصغّرة ============================
/// نفس غلاف/بروفايل صفحة الحساب لكن بارتفاع أصغر (الهدف هنا هو القوائم).
class _MiniHeader extends StatelessWidget {
  final AccountProfile account;
  final ServiceCategory service;
  final bool isDark;

  /// ★ في الـ Sheet: زر إغلاق (×) بدل زر الرجوع + منطقة سحب الورقة.
  final bool inSheet;

  /// ★ متحكّم تمرير الورقة ⇒ منطقة السحب في الرأس تُكبّر/تصغّر الورقة.
  final ScrollController? dragController;

  /// ★ فهرس التبويب الحالي ⇒ يتبدّل العنوان المختصر مع تبديل التبويب.
  final int tabIndex;

  /// ★ أرقام التبويبات الثلاثة: [متابعون، يتابع، مشتركون].
  final List<int> counts;

  const _MiniHeader({
    required this.account,
    required this.service,
    required this.isDark,
    this.inSheet = false,
    this.dragController,
    this.tabIndex = 0,
    this.counts = const [],
  });

  static const double _coverHeight = 110;
  static const double _avatarSize = 68;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    // ★★ في الـ Sheet: بلا غلاف ولا بروفايل ولا اسم — شريط عنوان صغير فقط
    //    (مقبض السحب + عنوان التبويب + زر إغلاق) ثم التبويبات مباشرة،
    //    فتظهر بلا تمرير أو انتقال غير ضروري.
    if (inSheet) {
      // ★ العدد المعروض = عدد التبويب النشط (متابعون / يتابع / مشتركون).
      final activeCount = counts.isEmpty
          ? account.followers
          : counts[tabIndex.clamp(0, 2)];
      final titleBar = _SheetTitleBar(
        title: tabLabels[tabIndex.clamp(0, 2)],
        count: activeCount,
        accent: service.color,
        onClose: () => Navigator.of(context).maybePop(),
      );
      // ★ منطقة السحب على الرأس = تكبير/تصغير/إغلاق الورقة ديناميكياً.
      return dragController == null
          ? titleBar
          : SheetDragArea(controller: dragController!, child: titleBar);
    }

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ★ مقبض السحب (يظهر في الـ Sheet فقط) — إشارة بصرية أن الورقة قابلة
        //   للسحب لأسفل للإغلاق.
        if (inSheet)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
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
            // ★ زر إغلاق/رجوع واضح: دائرة ممتلئة + حدّ بلون الخدمة + ظلّ.
            PositionedDirectional(
              top: inSheet ? AppSpacing.sm : MediaQuery.of(context).padding.top + AppSpacing.sm,
              start: AppSpacing.md,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceCard
                      : AppColors.lightSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: service.color.withValues(alpha: 0.45),
                  ),
                  boxShadow: AppShadows.brandGlow,
                ),
                child: IconButton(
                  icon: Icon(
                    inSheet ? LucideIcons.x : LucideIcons.arrowRight,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    if (inSheet) {
                      Navigator.of(context).maybePop();
                    } else if (context.canPop()) {
                      context.pop();
                    }
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
                        size: 32,
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
          child: Row(
            children: [
              Flexible(
                child: Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· ${tabLabels[tabIndex.clamp(0, 2)]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: service.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );

    // (الورقة تستخدم الشريط المصغّر أعلاه ⇒ لا حاجة لتغليف هنا).
    return header;
  }

  /// ★ عنوان مختصر: «المتابِعون»/«يتابع»/«المشتركون» — يتبدّل مع التبويب
  ///   الحالي فيظهر للمستخدم سياق ما يعرضه.
  static const List<String> tabLabels = [
    'المتابِعون',
    'يتابع',
    'المشتركون',
  ];
}

// ============================ شريط عنوان الورقة ============================
/// ★ الورقة (Bottom Sheet) لا تعرض غلافاً ولا بروفايلاً ولا اسم الحساب —
///    فقط: مقبض السحب + عنوان التبويب الحالي + زر إغلاق. التبويبات تظهر
///    مباشرة تحته بلا أي تمرير أو انتقال غير ضروري.
class _SheetTitleBar extends StatelessWidget {
  final String title;
  final int count;
  final Color accent;
  final VoidCallback onClose;

  const _SheetTitleBar({
    required this.title,
    required this.count,
    required this.accent,
    required this.onClose,
  });

  /// ★ تنسيق مختصر للرقم (12.5 ألف).
  static String format(int value) {
    if (value < 1000) return '$value';
    return '${(value / 1000).toStringAsFixed(1)} ألف';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      child: Column(
        children: [
          // مقبض السحب (Drag handle).
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              // ★ العنوان = التبويب النشط + عدده.
              Expanded(
                child: Text(
                  '$title (${format(count)})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              // ★ زر إغلاق واضح.
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    LucideIcons.x,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ============================ شريط التبويبات ============================
/// ★ نفس شريط تبويبات صفحة الخدمة تماماً: ثلاثة تبويبات بعرض متساوٍ،
///   مؤشر تحت النص (indicatorSize: tab) بلا تمرير أفقي.
class _TabsStrip extends StatelessWidget {
  final Color backgroundColor;
  final Color accent;
  final bool isDark;
  final TabController controller;

  const _TabsStrip({
    required this.backgroundColor,
    required this.accent,
    required this.isDark,
    required this.controller,
  });

  static const double height = 46;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: backgroundColor,
      child: TabBar(
        controller: controller,
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: isDark ? AppColors.outline : AppColors.lightOutline,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'المتابِعون'),
          Tab(text: 'يتابع'),
          Tab(text: 'مشتركون'),
        ],
      ),
    );
  }
}

// ============================ قائمة الحسابات ============================
/// ★ صف واحد لكل حساب: بروفايل + اسم + خدمة + زر متابعة دائري الحواف.
///
/// ★ التحميل **تدريجي**: نعرض [pageSize] حساباً أولياً، وزر «عرض المزيد» في
///   القاع يجلب الدفعة التالية فقط (لا تحميل كامل دفعة واحدة).
class _RelationList extends StatefulWidget {
  final List<AccountProfile> accounts;
  final bool isDark;
  final String emptyLabel;
  final Color serviceColor;

  /// ★ متحكّم التمرير (في الورقة) ⇒ السحب داخل القائمة يحرّك الورقة نفسها.
  final ScrollController? scrollController;

  const _RelationList({
    required this.accounts,
    required this.isDark,
    required this.emptyLabel,
    required this.serviceColor,
    this.scrollController,
  });

  @override
  State<_RelationList> createState() => _RelationListState();
}

class _RelationListState extends State<_RelationList> {
  /// ★ أول دفعة عند الفتح (٥ حسابات ⇒ تخطيط مريح على كل الشاشات).
  static const int initialCount = 5;

  /// ★ كل ضغطة على «عرض المزيد» تضيف حسابين فقط ⇒ تمرير تدريجي ناعم.
  static const int stepCount = 2;

  late int _visible = initialCount;

  bool get _hasMore => _visible < widget.accounts.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = widget.isDark ? AppColors.outline : AppColors.lightOutline;
    final visible = widget.accounts.take(_visible).toList();

    if (widget.accounts.isEmpty) {
      return Center(
        child: Text(
          widget.emptyLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // ★ +1 عنصر أخير = زر «عرض المزيد».
    final itemCount = visible.length + (_hasMore ? 1 : 0);

    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        color: line,
        indent: 76,
      ),
      itemBuilder: (context, i) {
        if (i == visible.length) {
          return _LoadMoreButton(
            remaining: widget.accounts.length - _visible,
            accent: widget.serviceColor,
            onTap: () => setState(() => _visible += stepCount),
          );
        }
        return _RelationRow(
          account: visible[i],
          isDark: widget.isDark,
          accent: widget.serviceColor,
        );
      },
    );
  }
}

/// زر «عرض المزيد» — بحواف دائرية، يعرض كم بقي.
class _LoadMoreButton extends StatelessWidget {
  final int remaining;
  final Color accent;
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.remaining,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
      child: Center(
        child: Material(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.chevronDown, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    'عرض المزيد ($remaining)',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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