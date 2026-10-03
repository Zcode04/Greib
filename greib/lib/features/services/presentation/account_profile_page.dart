import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'account_connections_page.dart';
import '../../../core/mock_data/mock_data.dart';
import '../../../core/models/account_model.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/post_sheets.dart';
import '../../../shared_widgets/service_post_card.dart';
import '../../../shared_widgets/smart_image.dart';
import '../data/account_repository.dart';
import '../data/services_repository.dart';
import '../../../shared_widgets/share_arrow_icon.dart';

/// ============================================================================
///  AccountProfilePage — صفحة حساب المستخدم/المتجر (بروفايل مستقل).
///
///  المسار:  /account/:id   (المعرّف = serviceId + "::" + بذرة الحساب)
///  يفتحها: الضغط على أي صورة بروفايل في شريط «الحسابات» أسفل صفحة الخدمة.
///
///  ★ الهيكل (بنفس بنية صفحة تفاصيل الخدمة تماماً):
///    1) صورة غلاف + صورة بروفايل متداخلة + زر الرجوع
///    2) اسم الحساب + التقييم + الموقع + عدد المتابعين
///    3) الوصف (Bio)
///    4) زرّان: «مراسلة» و«متابعة»  ← مباشرة بعد الوصف
///    5) تبويبات: الأحدث | الكل | الأكثر تفاعلاً
///
///  ★ أهم فرق عن صفحة الخدمة: التبويبات هنا تجلب **منشورات هذا الحساب وحده**
///    من AccountRepository، لا منشورات مشتركة بين متاجر مختلفة.
/// ============================================================================
class AccountProfilePage extends StatefulWidget {
  final String accountId;

  const AccountProfilePage({super.key, required this.accountId});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  /// ★ نفس نواة الأوراق المشتركة ⇒ نفس سلوك التفاعل/المفضلة/التعليقات.
  PostSheetsController? _sheets;

  /// حالة المتابعة (محلية للصفحة — mock، تُستبدل لاحقاً بطلب حقيقي).
  bool _isFollowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_sheets == null || _sheets!.isDark != isDark) {
      _sheets?.dispose();
      _sheets = PostSheetsController(isDark: isDark);
    }
  }

  @override
  void dispose() {
    _sheets?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    // ★ المصدر الوحيد للحساب = AccountRepository.
    final account = AccountRepository.instance.byId(widget.accountId);
    final service = account == null
        ? null
        : ServicesRepository.instance.byId(account.serviceId);
    if (account == null || service == null) return const _AccountNotFound();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        // نبقي «الكل» التبويب الافتراضي (الأوسط) مثل صفحة الخدمة.
        initialIndex: 1,
        child: Scaffold(
          backgroundColor: bg,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: _AccountHeader(
                  account: account,
                  service: service,
                  isDark: isDark,
                  isFollowing: _isFollowing,
                  onFollow: () =>
                      setState(() => _isFollowing = !_isFollowing),
                  onMessage: () => _sheets!.openServiceChat(
                    context,
                    service: service,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _AccountTabBarDelegate(
                  backgroundColor: bg,
                  accent: service.color,
                  isDark: isDark,
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _AccountPostsTab(
                  accountId: account.id,
                  account: account,
                  service: service,
                  mode: _AccountFeedMode.latest,
                  sheets: _sheets!,
                ),
                _AccountPostsTab(
                  accountId: account.id,
                  account: account,
                  service: service,
                  mode: _AccountFeedMode.all,
                  sheets: _sheets!,
                ),
                _AccountPostsTab(
                  accountId: account.id,
                  account: account,
                  service: service,
                  mode: _AccountFeedMode.topEngaged,
                  sheets: _sheets!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ الترويسة ============================
// غلاف + بروفايل + اسم + إحصائيات + وصف + زرّان (مراسلة / متابعة)
class _AccountHeader extends StatelessWidget {
  final AccountProfile account;
  final ServiceCategory service;
  final bool isDark;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  const _AccountHeader({
    required this.account,
    required this.service,
    required this.isDark,
    required this.isFollowing,
    required this.onFollow,
    required this.onMessage,
  });

  static const double _coverHeight = 180;
  static const double _avatarSize = 92;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- الغلاف + البروفايل المتداخل + زر الرجوع ----------
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: _coverHeight,
              width: double.infinity,
              // ★ غلاف الحساب نفسه (وليس غلاف الخدمة).
              child: account.coverUrl != null
                  ? SmartImage(
                      src: account.coverUrl,
                      placeholder: _CoverFallback(color: service.color),
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

            // ---------- بروفايل الحساب (صورة حقيقية) فوق الغلاف ----------
            PositionedDirectional(
              start: AppSpacing.xl,
              bottom: -_avatarSize / 2,
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceCard
                      : AppColors.lightSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: bg, width: 4),
                  boxShadow: AppShadows.brandGlow,
                  image: account.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(account.avatarUrl!),
                          fit: BoxFit.cover,
                          // ★ فشل التحميل (انقطاع شبكة) ⇒ نُبقي دائرة بلون
                          //   السطح بدل رمي استثناء.
                          onError: (_, _) {},
                        )
                      : null,
                ),
                // ★ أيقونة بديلة فقط عند غياب الصورة.
                child: account.avatarUrl == null
                    ? Icon(
                        LucideIcons.userRound,
                        size: 42,
                        color: service.color,
                      )
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: _avatarSize / 2 + AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- الاسم + التوثيق + التقييم ----------
              Row(
                children: [
                  Flexible(
                    child: Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (account.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.badgeCheck,
                      size: 18,
                      color: AppColors.info,
                    ),
                  ],
                  const SizedBox(width: AppSpacing.sm),
                  Icon(LucideIcons.star, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    account.rating.toStringAsFixed(1),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // ---------- آخر ظهور / حالة الاتصال (تحت الاسم مباشرة) ----------
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: account.isOnline
                          ? AppColors.success
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    account.presenceLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // ---------- إحصائيات المتابعين (اضغط ⇒ صفحة العلاقات) ----------
              Row(
                children: [
                  // ★ المتابعون ⇒ تبويب 0 داخل Bottom Sheet (لا صفحة).
                  _StatLink(
                    label: '${_format(account.followers)} متابع',
                    onTap: () => showAccountConnectionsSheet(
                      context,
                      accountId: account.id,
                      initialTab: 0,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // ★ يتابع ⇒ تبويب 1 داخل Bottom Sheet.
                  _StatLink(
                    label: '${_format(account.following)} يتابع',
                    onTap: () => showAccountConnectionsSheet(
                      context,
                      accountId: account.id,
                      initialTab: 1,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${account.postsCount} منشور',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ---------- الفئة (أيقونة) + الموقع (أيقونة) ----------
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _MetaChip(
                    icon: MockData.getIconByName(service.iconName),
                    label: service.title,
                    color: service.color,
                  ),
                  _MetaChip(
                    icon: LucideIcons.mapPin,
                    label: account.location,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ---------- الوصف (Bio) ----------
              Text(
                account.bio,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ---------- زرّان: مراسلة + متابعة (مباشرة بعد الوصف) ----------
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: LucideIcons.messageCircle,
                      label: 'مراسلة',
                      filled: true,
                      color: service.color,
                      onTap: onMessage,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ActionButton(
                      icon: isFollowing
                          ? LucideIcons.check
                          : LucideIcons.userPlus,
                      label: isFollowing ? 'متابَع' : 'متابعة',
                      filled: false,
                      color: service.color,
                      onTap: onFollow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  /// 12500 ⇒ «12.5 ألف» (رقم مختصر للقراءة السريعة).
  static String _format(int value) {
    if (value < 1000) return '$value';
    return '${(value / 1000).toStringAsFixed(1)} ألف';
  }
}

/// ★ عنصر إحصائي قابل للضغط (متابع / يتابع) ⇒ يفتح صفحة العلاقات على التبويب
///   المقابل. نميّزه بلون العلامة ليعرف المستخدم أنه رابط.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// ★ عنصر إحصائي قابل للضغط (متابع / يتابع) ⇒ يفتح صفحة العلاقات على التبويب
///   المقابل. نميّزه بلون العلامة ليعرف المستخدم أنه رابط.
class _StatLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StatLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.5),
            decorationThickness: 1,
          ),
        ),
      ),
    );
  }
}

// ============================ زر إجراء ============================
// زر «مراسلة» / «متابعة» — حدود موحّدة في الوضعين.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  /// ★ حواف دائرية بالكامل (rounded-full) = نصف الارتفاع ⇒ كبطاقة «عرض المزيد».
  static BorderRadius get _radius => BorderRadius.circular(999);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : color.withValues(alpha: 0.12),
      borderRadius: _radius,
      child: InkWell(
        borderRadius: _radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: filled ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : color,
                ),
              ),
            ],
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
      child: Center(child: Icon(LucideIcons.image, color: color, size: 32)),
    );
  }
}

// ============================ شريط التبويبات ============================
// ★ نفس تبويبات صفحة تفاصيل الخدمة تماماً: الأحدث | الكل | الأكثر تفاعلاً.
class _AccountTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Color accent;
  final bool isDark;

  _AccountTabBarDelegate({
    required this.backgroundColor,
    required this.accent,
    required this.isDark,
  });

  static const double _height = 48;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: backgroundColor,
      child: TabBar(
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: isDark ? AppColors.outline : AppColors.lightOutline,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'الأحدث'),
          Tab(text: 'الكل'),
          Tab(text: 'الأكثر تفاعلاً'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AccountTabBarDelegate old) =>
      old.backgroundColor != backgroundColor ||
      old.accent != accent ||
      old.isDark != isDark;
}

// ============================ محتوى التبويبات ============================
enum _AccountFeedMode { latest, all, topEngaged }

/// ★ كل تبويب يجلب **منشورات هذا الحساب وحده** من AccountRepository
/// (وليس منشورات الخدمة المشتركة بين عدة متاجر) ويعرضها بنفس تصميم
/// المنشورات الموحّد (ServicePostCard) ونفس أوراق التفاعل، ويختلف الترتيب.
class _AccountPostsTab extends StatelessWidget {
  final String accountId;
  final AccountProfile account;
  final ServiceCategory service;
  final _AccountFeedMode mode;
  final PostSheetsController sheets;

  const _AccountPostsTab({
    required this.accountId,
    required this.account,
    required this.service,
    required this.mode,
    required this.sheets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    // ★ المصدر = AccountRepository.postsFor ⇒ منشورات الحساب المحدد فقط.
    final source = AccountRepository.instance.postsFor(accountId);

    // ترتيب مختلف لكل تبويب — نفس البيانات، عرض يختلف.
    final List<AccountPost> posts;
    switch (mode) {
      case _AccountFeedMode.latest:
        // الأحدث: آخر منشور في مصدره أولاً.
        posts = source.reversed.toList();
      case _AccountFeedMode.all:
        posts = List<AccountPost>.of(source);
      case _AccountFeedMode.topEngaged:
        // ★ ترتيب حقيقي بأرقام التفاعل المخزّنة (لا عشوائية بنص المنشور).
        posts = List<AccountPost>.of(source)
          ..sort((a, b) => b.engagement.compareTo(a.engagement));
    }

    if (posts.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد محتوى بعد',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey('account_feed_${mode.name}'),
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      // ★ بلا فاصل بين المنشورات — المسافة العمودية من البطاقة نفسها.
      separatorBuilder: (_, _) => const SizedBox.shrink(),
      itemBuilder: (context, i) {
        final post = posts[i];
        // ★ المعرّف نفسه في كل التبويبات ⇒ تفاعل واحد للمنشور أياً كان التبويب.
        final postId = post.id;

        return ListenableBuilder(
          listenable: sheets,
          builder: (context, _) => ServicePostCard(
            service: service,
            // ★ رأس المنشور يعرض الحساب (اسمه + صورته) بدل الخدمة.
            authorName: account.name,
            authorAvatarUrl: account.avatarUrl,
            // ★ تحت الاسم: الفئة + حالة الاتصال (بدل توقيت النشر).
            authorSubtitle: service.title,
            authorIsOnline: account.isOnline,
            authorPresence: account.presenceLabel,
            text: post.text,
            imageUrls: post.imageUrls,
            isDark: isDark,
            backgroundColor: bg,
            countSeed: postId,
            // ★ أرقام التفاعل الحقيقية من بيانات الحساب.
            likeCount: '${post.likes}',
            commentCount: '${post.comments}',
            shareCount: '${post.shares}',
            // الحالة من النواة المشتركة (لا محلية) ⇒ متسقة بين الشاشات.
            reaction: sheets.reactionOf(postId),
            isSaved: sheets.isFavorite(postId),
            onSaveChanged: (value) => sheets.setFavorite(postId, value),
            onReaction: () => sheets.showReaction(
              context,
              postId: postId,
              service: service,
            ),
            onComment: () => sheets.showComments(
              context,
              postId: postId,
              service: service,
            ),
            onRequest: () => sheets.openServiceChat(context, service: service),
            onShare: () => sheets.showAction(
              context,
              iconWidget: const ShareArrowIcon(size: 18),
              title: 'إعادة النشر',
              hint: 'نشر رابط منشور «${account.name}» على صفحتك.',
            ),
            onImageTap: () => sheets.openImagePreview(
              context,
              images: post.imageUrls.isNotEmpty
                  ? post.imageUrls
                  : (account.coverUrl != null
                        ? [account.coverUrl!]
                        : const <String>[]),
              service: service,
            ),
          ),
        );
      },
    );
  }
}

// ============================ حساب غير موجود ============================
class _AccountNotFound extends StatelessWidget {
  const _AccountNotFound();

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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.searchX,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'الحساب غير موجود',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'ربما تم تغيير الرابط أو حذف الحساب.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




