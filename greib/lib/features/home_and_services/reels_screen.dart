// features/home_and_services/reels_screen.dart
//
// صفحة Reels — نسخة وهمية (واجهة فقط، بدون مشغّل فيديو).
//
// التصميم يحاكي تجربة Reels في TikTok / Facebook:
// • تمرير عمودي بفيديو واحد لكل صفحة (PageView عمودي، ملء الشاشة)
// • طبقة محتوى فوق الفيديو: اسم الحساب، الوصف، الموسيقى، الإحصاءات
// • عمود تفاعل على اليمين (إعجاب/تعليق/مشاركة/حفظ/صورة)
// • قلب(double-tap) مع قلوب متطايرة، وكتم الصوت، وشريط تقدّم زمني متحرك
//
// البيانات كلها محلية داخل هذا الملف (Mock)، فاستبدالها لاحقاً بواجهة
// برمجية يتم في `_ReelsPage.demo` فقط دون المساس ببناء الواجهة.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/service_model.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../shared_widgets/sheets/reels_options_sheet.dart';
import '../../shared_widgets/post_reaction.dart';
import '../../shared_widgets/share_arrow_icon.dart';
import '../../shared_widgets/post_sheets.dart' show PostComment, PostCommentsSheet;

/// ============================================================================
///  نموذج الريل — بيانات وهمية لريل واحد.
/// ============================================================================
class ReelItem {
  final String id;
  final String authorName;
  final String authorHandle;
  final String avatarUrl;
  final bool verified;
  final String caption;
  final String audioTitle;
  final String coverUrl;
  final List<String> tags;

  final int likes;
  final int comments;
  final int shares;
  final int saves;

  const ReelItem({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.avatarUrl,
    this.verified = false,
    required this.caption,
    required this.audioTitle,
    required this.coverUrl,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
  });
}

/// ============================================================================
///  ReelsScreen — صفحة الريلز (المسار /reels).
/// ============================================================================
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late final PageController _pageController;

  int _currentIndex = 0;
  bool _muted = true;

  /// حالات الإعجاب/الحفظ — مفتاحها معرّف الريل.
  final Set<String> _liked = {};
  final Set<String> _saved = {};

  /// الريل الذي يتطاير فوقه قلب واحد (عند الضغط المزدوج).
  String? _burstReelId;

  /// ★ تعليقات كل ريل — تُملأ مرة واحدة وتبقى محفوظة أثناء التنقّل بين الريلات.
  final Map<String, List<PostComment>> _comments = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _burstReelId = _demo.first.id;
    for (final reel in _demo) {
      _comments[reel.id] = _mockComments(reel);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLike(String id) {
    setState(() => _liked.contains(id) ? _liked.remove(id) : _liked.add(id));
  }

  void _toggleSave(String id) {
    setState(() => _saved.contains(id) ? _saved.remove(id) : _saved.add(id));
  }

  void _toggleMute() => setState(() => _muted = !_muted);

  void _handleDoubleTap(ReelItem reel) {
    setState(() {
      if (!_liked.contains(reel.id)) _liked.add(reel.id);
      _burstReelId = reel.id;
    });
  }

  void _openSheet(String message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MockSheet(message: message),
    );
  }

  /// ★ ورقة التعليقات: نفس `PostCommentsSheet` المستخدمة في بطاقة البوست
  ///   (نفس التصميم والحقول والردود)، وتعمل على بيانات وهمية لكل ريل.
  void _openComments(ReelItem reel) {
    final list = _comments.putIfAbsent(reel.id, () => _mockComments(reel));
    showAppSheet<void>(
      context,
      builder: (_) => PostCommentsSheet(
        service: _reelServiceStub(reel),
        isDark: Theme.of(context).brightness == Brightness.dark,
        comments: list,
      ),
    ).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  /// ★ خدمة وهمية قصيرة العمر: ورقة التعليقات تقرأ منها اللون فقط،
  ///   فتبقى صالحة دون تغيير بنية `PostCommentsSheet` (تُشترك مع البوست).
  ServiceCategory _reelServiceStub(ReelItem reel) {
    return ServiceCategory(
      id: 'reel_${reel.id}',
      title: reel.authorName,
      subtitle: reel.audioTitle,
      description: reel.caption,
      iconName: 'play',
      color: context.accentColor,
      colorHex: '3B82F6',
    );
  }

  /// ★ ورقة خيارات الريل (⋯) — نفس ورقة خيارات المنشور مع عناصر خاصة بالريل.
  void _openOptions(ReelItem reel) {
    showAppSheet<void>(
      context,
      builder: (_) => ReelsOptionsSheet(
        reelTitle: reel.caption,
        authorName: reel.authorName,
        isSaved: _saved.contains(reel.id),
        onSaveToggle: () => _toggleSave(reel.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reels = _demo;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundColors.mediaScrim,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: reels.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final reel = reels[index];
                return _ReelPage(
                  key: ValueKey(reel.id),
                  reel: reel,
                  isActive: index == _currentIndex,
                  isMuted: _muted,
                  liked: _liked.contains(reel.id),
                  saved: _saved.contains(reel.id),
                  commentCount: (_comments[reel.id]?.length ?? 0) > reel.comments
                      ? (_comments[reel.id]?.length ?? 0)
                      : reel.comments,
                  showBurst: _burstReelId == reel.id,
                  onTap: _toggleMute,
                  onDoubleTap: () => _handleDoubleTap(reel),
                  onBurstFinished: () {
                    if (_burstReelId == reel.id) {
                      setState(() => _burstReelId = null);
                    }
                  },
                  onLike: () => _toggleLike(reel.id),
                  onSave: () => _toggleSave(reel.id),
                  onComment: () => _openComments(reel),
                  onShare: () => _openSheet('مشاركة الريل'),
                  onMore: () => _openOptions(reel),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildTopBar(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            tooltip: 'رجوع',
            icon: Icon(
              LucideIcons.chevronRight,
              color: context.textColors.onMedia,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Expanded(
            child: Center(child: _TopTitle(label: 'الريلز')),
          ),
          IconButton(
            onPressed: _toggleMute,
            tooltip: _muted ? 'تشغيل الصوت' : 'كتم الصوت',
            icon: Icon(
              _muted ? LucideIcons.volumeX : LucideIcons.volume2,
              color: context.textColors.onMedia,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  _ReelPage — صفحة واحدة = ريل واحد بملء الشاشة وطبقات التفاعل.
/// ============================================================================
class _ReelPage extends StatelessWidget {
  final ReelItem reel;
  final bool isActive;
  final bool isMuted;
  final bool liked;
  final bool saved;
  final bool showBurst;
  final int commentCount;

  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onBurstFinished;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMore;

  const _ReelPage({
    super.key,
    required this.reel,
    required this.isActive,
    required this.isMuted,
    required this.liked,
    required this.saved,
    required this.showBurst,
    required this.commentCount,
    required this.onTap,
    required this.onDoubleTap,
    required this.onBurstFinished,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onShare,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) خلفية الفيديو (محاكاة: صورة متحركة + تدرّج).
        _VideoBackdrop(reel: reel, isActive: isActive),

        // 2) تدرّجات لقراءة المحتوى فوق الفيديو.
        const _EdgeScrim(top: true),
        const _EdgeScrim(top: false),

        // 3) طبقة اللمسات: نقرة = كتم، ضغط مزدوج = قلب.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: const SizedBox.expand(),
          ),
        ),

        // 4) قلوب الضغط المزدوج.
        if (showBurst)
          Positioned.fill(
            child: _HeartBurst(onFinished: onBurstFinished),
          ),

        // 5) زر تشغيل/كتم وسط الشاشة عند الكتم.
        if (isMuted)
          Center(
            child: AnimatedOpacity(
              opacity: isActive ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                LucideIcons.volumeX,
                color: context.textColors.onMedia.withValues(alpha: 0.54),
                size: 56,
              ),
            ),
          ),

        // 6) محتوى الريل + عمود التفاعل + شريط التقدّم.
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _ReelMeta(reel: reel, liked: liked),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _ActionRail(
                        reel: reel,
                        liked: liked,
                        saved: saved,
                        commentCount: commentCount,
                        isActive: isActive,
                        onLike: onLike,
                        onSave: onSave,
                        onComment: onComment,
                        onShare: onShare,
                        onMore: onMore,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressBar(isActive: isActive),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
///  _VideoBackdrop — محاكاة الفيديو: صورة بحركة بطيئة + حركة تكبير خفيفة.
///  (يُستبدل لاحقاً بمشغّل فيديو حقيقي دون تغيير بقية الواجهة).
/// ============================================================================
class _VideoBackdrop extends StatefulWidget {
  final ReelItem reel;
  final bool isActive;

  const _VideoBackdrop({required this.reel, required this.isActive});

  @override
  State<_VideoBackdrop> createState() => _VideoBackdropState();
}

class _VideoBackdropState extends State<_VideoBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant _VideoBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) _syncPlayback();
  }

  /// التوقف عند مغادرة الريل_CURRENT يقلّل استهلاك الإطارات في الشاشة الخلفية.
  void _syncPlayback() {
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Transform.scale(
          scale: 1.06 + 0.06 * t,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.reel.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) =>
                    ColoredBox(color: context.backgroundColors.mediaScrim),
              ),
              // توهج متحرك أسفل الصفحة يحاكي إضاءة الفيديو.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      context.accentColor.withValues(
                        alpha: 0.10 + 0.10 * t,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================================================================
///  _EdgeScrim — تدرّج أسود عند الحافة العليا أو السفلية لزيادة وضوح النص.
/// ============================================================================
class _EdgeScrim extends StatelessWidget {
  final bool top;

  const _EdgeScrim({required this.top});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              context.backgroundColors.mediaScrim.withValues(alpha: 0.55),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
///  _HeartBurst — قلب كبير يظهر عند الضغط المزدوج ويختفي تلقائياً.
///
class _HeartBurst extends StatefulWidget {
  final VoidCallback onFinished;

  const _HeartBurst({required this.onFinished});

  @override
  State<_HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<_HeartBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 0.3, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    final fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1, curve: Curves.easeIn),
      ),
    );
    final drift = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -18),
    ).animate(_controller);

    return Center(
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: drift,
          child: ScaleTransition(
            scale: scale,
            child: Icon(
              LucideIcons.thumbsUp,
              color: _likeColor(context),
              size: 116,
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
///  _ReelMeta — اسم صاحب الريل، الوصف، الموسيقى، الأزرار (متابعة/تسجيل صوتي).
/// ============================================================================
class _ReelMeta extends StatelessWidget {
  final ReelItem reel;
  final bool liked;

  const _ReelMeta({required this.reel, required this.liked});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                reel.avatarUrl,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => CircleAvatar(
                  radius: 17,
                  backgroundColor: context.backgroundColors.surface,
                  child: Icon(
                    LucideIcons.user,
                    size: 18,
                    color: context.textColors.onMedia.withValues(alpha: 0.70),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      reel.authorHandle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textColors.onMedia,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (reel.verified) ...[
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 15,
                      color: context.accentColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const _FollowPill(),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          reel.caption,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.textColors.onMedia, fontSize: 13.5, height: 1.5),
        ),
        if (reel.tags.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            reel.tags.map((tag) => '#$tag').join('  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textColors.onMedia.withValues(alpha: 0.75),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              LucideIcons.music2,
              size: 14,
              color: context.textColors.onMedia,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                reel.audioTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.textColors.onMedia, fontSize: 12.5),
              ),
            ),
          ],
        ),
        if (liked) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: context.textColors.onMedia.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.thumbsUp, size: 12, color: _likeColor(context)),
                const SizedBox(width: 4),
                Text(
                  'أعجبك الريل',
                  style: TextStyle(
                    color: context.textColors.onMedia,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FollowPill extends StatelessWidget {
  const _FollowPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: context.textColors.onMedia.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
          color: context.textColors.onMedia.withValues(alpha: 0.38),
        ),
      ),
      child: Text(
        'متابعة',
        style: TextStyle(
          color: context.textColors.onMedia,
          fontSize: 11.5,
          height: 1.3,
        ),
      ),
    );
  }
}

/// ============================================================================
///  _ActionRail — عمود التفاعل على يمين الشاشة (إعجاب، تعليق، مشاركة، حفظ).
/// ============================================================================
class _ActionRail extends StatelessWidget {
  final ReelItem reel;
  final bool liked;
  final bool saved;
  final int commentCount;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMore;

  const _ActionRail({
    required this.reel,
    required this.liked,
    required this.saved,
    required this.commentCount,
    required this.isActive,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onShare,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ★ توحيد المكوّنات مع بطاقة البوست:
        //   إعجاب = thumbsUp، مشاركة = ShareArrowIcon (سهم إعادة النشر).
        _RailButton(
          icon: LucideIcons.thumbsUp,
          iconColor: liked ? _likeColor(context) : context.textColors.onMedia,
          filled: liked,
          count: reel.likes + (liked ? 1 : 0),
          tooltip: 'إعجاب',
          onTap: onLike,
        ),
        _RailButton(
          icon: LucideIcons.messageSquare,
          count: commentCount,
          tooltip: 'تعليق',
          onTap: onComment,
        ),
        _RailButton(
          icon: LucideIcons.bookmark,
          iconColor:
              saved ? context.iconColors.warning : context.textColors.onMedia,
          filled: saved,
          count: reel.saves + (saved ? 1 : 0),
          tooltip: 'حفظ',
          onTap: onSave,
        ),
        _RailButton(
          iconWidget: ShareArrowIcon(
            size: 26,
            color: context.textColors.onMedia,
          ),
          count: reel.shares,
          tooltip: 'مشاركة',
          onTap: onShare,
        ),
        // ★ زر «المزيد» — نقطتان فقط بلا عدّاد (نفس لغة الأزرار الأخرى).
        _RailButton(
          icon: LucideIcons.ellipsis,
          tooltip: 'المزيد',
          onTap: onMore,
        ),
        _AvatarStackButton(isActive: isActive),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  /// أيقونة Lucide (تُرسم بـ Icon). تُتجاهل إذا مُرّر [iconWidget].
  final IconData? icon;

  /// أيقونة SVG جاهزة (مثل سهم المشاركة) — لها الأولوية على [icon].
  final Widget? iconWidget;

  final Color? iconColor;
  final bool filled;

  /// العدّاد أسفل الأيقونة — null يعني زر بلا عدّاد (مثل «المزيد»).
  final int? count;

  final String tooltip;
  final VoidCallback onTap;

  const _RailButton({
    required this.tooltip,
    required this.onTap,
    this.count,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Semantics(
        label: tooltip,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            children: [
              AnimatedScale(
                scale: filled ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: iconWidget ??
                    Icon(
                      icon ?? LucideIcons.circle,
                      size: 30,
                      color: iconColor ?? context.textColors.onMedia,
                    ),
              ),
              const SizedBox(height: 3),
              if (count != null)
                Text(
                  _format(count!),
                  style: TextStyle(
                    color: context.textColors.onMedia,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                const SizedBox(height: 14.5),
            ],
          ),
        ),
      ),
    );
  }
}

/// صورة الملف الشخصي داخل عمود التفاعل + علامة «+» (إضافة ستوري).
class _AvatarStackButton extends StatelessWidget {
  final bool isActive;

  const _AvatarStackButton({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.textColors.onMedia,
                width: 1.6,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                _demo.last.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => CircleAvatar(
                  backgroundColor: context.backgroundColors.surface,
                  child: Icon(
                    LucideIcons.user,
                    color: context.textColors.onMedia.withValues(alpha: 0.70),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: context.accentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.backgroundColors.mediaScrim,
                  width: 1.6,
                ),
              ),
              child: isActive
                  ? Icon(
                      LucideIcons.plus,
                      size: 13,
                      color: context.textColors.onAccent,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  _ProgressBar — شريط تقدّم زمني متحرك أسفل الريل (بديل شريط المشغّل).
/// ============================================================================
class _ProgressBar extends StatefulWidget {
  final bool isActive;

  const _ProgressBar({required this.isActive});

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant _ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) _sync();
  }

  void _sync() {
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: SizedBox(
        height: 3,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: context.textColors.onMedia.withValues(alpha: 0.24),
            valueColor: AlwaysStoppedAnimation<Color>(
              context.textColors.onMedia,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopTitle extends StatefulWidget {
  final String label;

  const _TopTitle({required this.label});

  @override
  State<_TopTitle> createState() => _TopTitleState();
}

class _TopTitleState extends State<_TopTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(_controller),
      child: Text(
        widget.label,
        style: TextStyle(
          color: context.textColors.onMedia,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// ============================================================================
///  _MockSheet — ورقة منبثقة وهمية (تعليقات/مشاركة) بدل ربط API.
/// ============================================================================
class _MockSheet extends StatelessWidget {
  final String message;

  const _MockSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.backgroundColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'هذه الشاشة تجريبية حالياً، وسيتم ربطها بالبيانات لاحقاً.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ★ لون «الإعجاب» — مأخوذ من تفاعل البوست نفسه (لون أيقونة المعلومات) حتى
///   يبقى الزران متطابقين بين الريلز وبطاقة المنشور.
Color _likeColor(BuildContext context) =>
    PostReaction.byValue(1)?.color ?? context.iconColors.info;

/// اختصار الأعداد (12.4K / 3.1M) بنفس أسلوب المنصات الاجتماعية.
String _format(int value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
  }
  return '$value';
}

/// ============================================================================
/// تعليقات وهمية لكل ريل (مطابقة لنموذج `PostComment` المستخدم في البوست).
List<PostComment> _mockComments(ReelItem reel) {
  return [
    PostComment(
      'سارة',
      'المونتاج خفيف والفكرة واضحة 👏',
      replies: [
        PostComment(reel.authorName, 'شكراً سارة ❤️', seq: 1),
        PostComment('ريم', 'نفس الرابط، ستجده في البايو', seq: 2),
      ],
    ),
    PostComment(
      'محمد',
      'وين أقدر ألقى الشي نفسه؟ أحد يعرف الاسم؟',
      replies: [PostComment('خالد', 'موجود عند المحل الثاني في القائمة', seq: 3)],
    ),
    PostComment('ريم', 'أجمل ريل اليوم بلا منافس 🔥'),
    PostComment(
      'خالد',
      'التفاصيل المهمة في آخر عشر ثوانٍ: نفّذت بالضبط نفس الخطوات التي '
      'شرحتها في الحساب، ونجحت من أول مرة دون أي تعديل أو إضافة، وهذا يبين '
      'أن الكلام موثوق ومبني على تجربة حقيقية.',
      replies: [
        PostComment('ريم', 'الحين أقدر أبدأ بثقة', seq: 4),
        PostComment('نور', 'نفس النتيجة عندي تماماً', seq: 5),
        PostComment('يوسف', 'محتوى يستاهل المتابعة 👏', seq: 6),
      ],
    ),
  ];
}

/// بيانات وهمية — تُستبدل لاحقاً بمصدر بيانات حقيقي.
/// ============================================================================
const List<ReelItem> _demo = [
  ReelItem(
    id: 'r1',
    authorName: 'ليان الحربي',
    authorHandle: '@layan.coffee',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    verified: true,
    caption: 'جرّبنا قهوة مختصة من محصول العندي الطازج ☕️ morning routine',
    audioTitle: 'الصوت الأصلي — ليان الحربي',
    coverUrl: 'https://picsum.photos/seed/reel1/900/1600',
    tags: ['قهوة', 'مorning'],
    likes: 12400,
    comments: 412,
    shares: 890,
    saves: 2300,
  ),
  ReelItem(
    id: 'r2',
    authorName: 'متجر غريب',
    authorHandle: '@greib.store',
    avatarUrl: 'https://i.pravatar.cc/150?img=7',
    verified: true,
    caption: 'وصل حديثاً: سماعات لاسلكية بخصم 40% لفترة محدودة 🎧',
    audioTitle: 'Trending audio — متجر غريب',
    coverUrl: 'https://picsum.photos/seed/reel2/900/1600',
    tags: ['عروض', 'تقنية'],
    likes: 8300,
    comments: 205,
    shares: 640,
    saves: 1500,
  ),
  ReelItem(
    id: 'r3',
    authorName: 'سعد المطيري',
    authorHandle: '@saad.travel',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    caption: 'قبل ما تخطط رحلتك، شوف هالمشاهد 🌊',
    audioTitle: 'صوت أصلي — سعد المطيري',
    coverUrl: 'https://picsum.photos/seed/reel3/900/1600',
    tags: ['سفر', 'تصوير'],
    likes: 24600,
    comments: 980,
    shares: 2100,
    saves: 5400,
  ),
  ReelItem(
    id: 'r4',
    authorName: 'ورشة غريب',
    authorHandle: '@greib.fix',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    verified: true,
    caption: 'خطوات صيانة بسيطة توفر عليك فاتورة pricey 🔧',
    audioTitle: 'صوت أصلي — ورشة غريب',
    coverUrl: 'https://picsum.photos/seed/reel4/900/1600',
    tags: ['صيانة', 'نصائح'],
    likes: 5600,
    comments: 143,
    shares: 320,
    saves: 980,
  ),
];