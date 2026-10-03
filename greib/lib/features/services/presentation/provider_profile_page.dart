import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/service_model.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/post_sheets.dart';
import '../../../shared_widgets/service_post_card.dart';
import '../../../shared_widgets/smart_image.dart';
import '../data/provider_repository.dart';
import '../data/services_repository.dart';
import '../../../shared_widgets/share_arrow_icon.dart';

/// ============================================================================
///  ProviderProfilePage — صفحة مقدم الخدمة.
///
///  المسار: /provider/:id   (المعرّف = معرّف الخدمة + "_p" + الفهرس)
///
///  الهيكل (نفس صفحة الخدمة تماماً):
///   1) صورة غلاف + بروفايل مقدم الخدمة متداخل + زر الرجوع
///   2) الاسم + التقييم + سطرBio
///   3) زر «تواصل» وزر «متابعة»
///   4) تبويبات المنشورات: الأحدث | الكل | الأكثر تفاعلاً
/// ============================================================================
class ProviderProfilePage extends StatefulWidget {
  final String providerId;

  const ProviderProfilePage({super.key, required this.providerId});

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  /// ★ نفس نواة الأوراق المشتركة ⇒ نفس سلوك التفاعل/المفضلة/التعليقات.
  PostSheetsController? _sheets;

  /// حالة المتابعة (محلية للصفحة — mock).
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

    final provider = ProviderRepository.instance.byId(widget.providerId);
    final serviceId = widget.providerId.split('_p').first;
    final service = ServicesRepository.instance.byId(serviceId);
    if (provider == null || service == null) return const _ProviderNotFound();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          backgroundColor: bg,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: _ProviderHeader(
                  provider: provider,
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
                delegate: _ProviderTabBarDelegate(
                  backgroundColor: bg,
                  accent: service.color,
                  isDark: isDark,
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _ProviderPostsTab(
                  providerId: provider.id,
                  service: service,
                  mode: _ProviderFeedMode.latest,
                  sheets: _sheets!,
                ),
                _ProviderPostsTab(
                  providerId: provider.id,
                  service: service,
                  mode: _ProviderFeedMode.all,
                  sheets: _sheets!,
                ),
                _ProviderPostsTab(
                  providerId: provider.id,
                  service: service,
                  mode: _ProviderFeedMode.topEngaged,
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
class _ProviderHeader extends StatelessWidget {
  final ServiceProvider provider;
  final ServiceCategory service;
  final bool isDark;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  const _ProviderHeader({
    required this.provider,
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
    final hasCover = service.imageUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: _coverHeight,
              width: double.infinity,
              child: hasCover
                  ? SmartImage(
                      src: service.imageUrls.first,
                      placeholder: _ProviderCoverFallback(color: service.color),
                    )
                  : _ProviderCoverFallback(color: service.color),
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

            // بروفايل مقدم الخدمة (أيقونة الشخص) متداخل فوق الغلاف.
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
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        LucideIcons.userRound,
                        size: 42,
                        color: service.color,
                      ),
                    ),
                    // علامة توثيق beside الاسم، وعليها صح داخل البروفايل.
                    PositionedDirectional(
                      bottom: 6,
                      start: 6,
                      child: const Icon(
                        LucideIcons.checkCircle,
                        size: 18,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
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
              Row(
                children: [
                  Flexible(
                    child: Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    LucideIcons.star,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'مقدّم خدمة «${service.title}»',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: service.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                provider.bio,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // زر «تواصل» وزر «متابعة».
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: LucideIcons.messageCircle,
                      label: 'تواصل',
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
}

/// زر إجراء واحد (تواصل / متابعة) — حدود موحّدة في الوضعين.
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? color
          : color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled ? Colors.white : color,
              ),
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

class _ProviderCoverFallback extends StatelessWidget {
  final Color color;
  const _ProviderCoverFallback({required this.color});

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
class _ProviderTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Color accent;
  final bool isDark;

  _ProviderTabBarDelegate({
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
  bool shouldRebuild(covariant _ProviderTabBarDelegate old) =>
      old.backgroundColor != backgroundColor ||
      old.accent != accent ||
      old.isDark != isDark;
}

// ============================ محتوى التبويبات ============================
enum _ProviderFeedMode { latest, all, topEngaged }

/// نفس بطاقة المنشورات ونفس أوراق التفاعل، والفرق الوحيد أن المصدر هنا
/// ProviderRepository (منشورات مقدم الخدمة) بدل ServicesRepository.
class _ProviderPostsTab extends StatelessWidget {
  final String providerId;
  final ServiceCategory service;
  final _ProviderFeedMode mode;
  final PostSheetsController sheets;

  const _ProviderPostsTab({
    required this.providerId,
    required this.service,
    required this.mode,
    required this.sheets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;
    final source = ProviderRepository.instance.postsFor(providerId);

    final List<ServicePost> posts;
    switch (mode) {
      case _ProviderFeedMode.latest:
        posts = source.reversed.toList();
      case _ProviderFeedMode.all:
        posts = List<ServicePost>.of(source);
      case _ProviderFeedMode.topEngaged:
        posts = List<ServicePost>.of(source)
          ..sort((a, b) => b.text.hashCode.compareTo(a.text.hashCode));
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
      key: PageStorageKey('provider_feed_${mode.name}'),
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      // ★ بلا فاصل بين المنشورات — المسافة العمودية من البطاقة نفسها.
      separatorBuilder: (_, _) => const SizedBox.shrink(),
      itemBuilder: (context, i) {
        final post = posts[i];
        // ★ معرّف المنشور خاص بالمقدم ⇒ تفاعله مستقل عن صفحة الخدمة.
        final postId = '${providerId}_post_$i';

        return ListenableBuilder(
          listenable: sheets,
          builder: (context, _) => ServicePostCard(
            service: service,
            text: post.text,
            imageUrls: post.imageUrls,
            isDark: isDark,
            backgroundColor: bg,
            countSeed: post.text,
            reaction: sheets.reactionOf(postId),
            isSaved: sheets.isFavorite(postId),
            onSaveChanged: (value) => sheets.setFavorite(postId, value),
            onReaction: () =>
                sheets.showReaction(context, postId: postId, service: service),
            onComment: () =>
                sheets.showComments(context, postId: postId, service: service),
            onRequest: () => sheets.openServiceChat(context, service: service),
            onShare: () => sheets.showAction(
              context,
              iconWidget: const ShareArrowIcon(size: 18),
              title: 'إعادة النشر',
              hint: 'نشر رابط منشور «${service.title}» على صفحتك.',
            ),
            onImageTap: () => sheets.openImagePreview(
              context,
              images: post.imageUrls.isNotEmpty
                  ? post.imageUrls
                  : (service.coverImage != null
                        ? [service.coverImage!]
                        : const <String>[]),
              service: service,
            ),
          ),
        );
      },
    );
  }
}

// ============================ مقدم غير موجود ============================
class _ProviderNotFound extends StatelessWidget {
  const _ProviderNotFound();

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
                  'مقدم الخدمة غير موجود',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
