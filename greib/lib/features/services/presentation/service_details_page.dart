import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/mock_data/mock_data.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/smart_image.dart';
import '../../../shared_widgets/service_post_card.dart';
import '../data/services_repository.dart';

/// ============================================================================
///  ServiceDetailsPage — صفحة الخدمة بتصميم "بروفايل".
///
///  المسار:  /service/:id
///
///  الهيكل:
///   1) صورة غلاف
///   2) بروفايل (أيقونة الخدمة) متداخل فوق الغلاف
///   3) اسم الخدمة
///   4) الوصف
///   5) تبويبات: الأحدث | الكل | الأكثر تفاعلاً
/// ============================================================================
class ServiceDetailsPage extends StatelessWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final service = ServicesRepository.instance.byId(serviceId);
    if (service == null) return const _ServiceNotFound();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        // نجعل "الكل" هو التبويب الافتراضي (الأوسط).
        initialIndex: 1,
        child: Scaffold(
          backgroundColor: bg,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: _ProfileHeader(service: service, isDark: isDark),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  backgroundColor: bg,
                  accent: service.color,
                  isDark: isDark,
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _PostsTab(service: service, mode: _FeedMode.latest),
                _PostsTab(service: service, mode: _FeedMode.all),
                _PostsTab(service: service, mode: _FeedMode.topEngaged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ الترويسة ============================
// غلاف + بروفايل + اسم + وصف
class _ProfileHeader extends StatelessWidget {
  final ServiceCategory service;
  final bool isDark;

  const _ProfileHeader({required this.service, required this.isDark});

  static const double _coverHeight = 200;
  static const double _avatarSize = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;
    final hasCover = service.imageUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- الغلاف + البروفايل المتداخل ----------
        Stack(
          clipBehavior: Clip.none,
          children: [
            // صورة الغلاف (أول صورة للخدمة، أو تدرّج بلون الخدمة).
            SizedBox(
              height: _coverHeight,
              width: double.infinity,
              child: hasCover
                  ? SmartImage(
                      src: service.imageUrls.first,
                      placeholder: _CoverFallback(color: service.color),
                    )
                  : _CoverFallback(color: service.color),
            ),

            // زر الرجوع
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

            // البروفايل — نصفه فوق الغلاف ونصفه تحته
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
                  // حلقة بلون الخلفية لتبدو "مقتطعة" من الغلاف
                  border: Border.all(color: bg, width: 4),
                  boxShadow: AppShadows.brandGlow,
                ),
                child: Icon(
                  MockData.getIconByName(service.iconName),
                  size: 44,
                  color: service.color,
                ),
              ),
            ),
          ],
        ),

        // مساحة تعوّض نصف ارتفاع البروفايل المتدلّي
        const SizedBox(height: _avatarSize / 2 + AppSpacing.md),

        // ---------- اسم الخدمة ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            service.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // ---------- الوصف ----------
        if (service.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              service.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

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
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Color accent;
  final bool isDark;

  _TabBarDelegate({
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
  bool shouldRebuild(covariant _TabBarDelegate old) =>
      old.backgroundColor != backgroundColor ||
      old.accent != accent ||
      old.isDark != isDark;
}

// ============================ محتوى التبويبات ============================
enum _FeedMode { latest, all, topEngaged }

/// كل تبويب يجلب منشورات الخدمة من المصدر الواحد (services.json ⟵ posts)
/// ويعرضها **بنفس تصميم المنشورات** المستخدم في الـ Spotlight Carousel،
/// مع اختلاف الترتيب فقط بين التبويبات.
class _PostsTab extends StatelessWidget {
  final ServiceCategory service;
  final _FeedMode mode;

  const _PostsTab({required this.service, required this.mode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundPrimary : AppColors.lightBackground;
    final source = ServicesRepository.instance.postsFor(service.id);

    // ترتيب مختلف لكل تبويب (Sorting) — البيانات نفسها، العرض يختلف.
    final List<ServicePost> posts;
    switch (mode) {
      case _FeedMode.latest:
        posts = source.reversed.toList();
      case _FeedMode.all:
        posts = List<ServicePost>.of(source);
      case _FeedMode.topEngaged:
        // تفاعل ثابت مشتق من نص المنشور (mock) ⇒ لا عشوائية تتغيّر كل إطار.
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

    final line = isDark ? AppColors.outline : AppColors.lightOutline;

    return ListView.separated(
      key: PageStorageKey('feed_${mode.name}'),
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      // ★ فاصل رفيع (لا فجوة) ⇒ نفسه تصميم المنشورات.
      separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: line),
      itemBuilder: (context, i) => ServicePostCard(
        // ★ نفس بطاقة المنشورات في الصفحة الرئيسية (ServicePostCard).
        service: service,
        text: posts[i].text,
        timeAgo: posts[i].timeAgo,
        imageUrls: posts[i].imageUrls,
        isDark: isDark,
        backgroundColor: bg,
        countSeed: posts[i].text,
      ),
    );
  }
}

// ============================ خدمة غير موجودة ============================
class _ServiceNotFound extends StatelessWidget {
  const _ServiceNotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
                'الخدمة غير موجودة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'ربما تم تغيير الرابط أو حذف الخدمة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
