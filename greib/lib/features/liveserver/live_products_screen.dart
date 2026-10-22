// features/liveserver/live_products_screen.dart
//
// صفحة «عرض منتجات التاجر» (المسار /live-products).
// ★ تُفتح من صفحة اختيار الوضع (LiveModeScreen).
// ★ صورة تملأ الصفحة + كاروسيل صور أفقي (تمرير/معاينة) + زر «اطلب الآن»
//   + أيقونة تفاعل تفتح شيت بسيط (تفاعل + متابعة + مشاركة).
// ★ هذه محاكاة واجهة (UI Mock) بصور وهمية من الإنترنت — ستُطوَّر لاحقاً.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/widgets/app_sheet.dart';
import '../../shared_widgets/app_button.dart';

/// LiveProductsScreen — عرض منتجات التاجر أثناء البث (المسار /live-products).
class LiveProductsScreen extends StatefulWidget {
  const LiveProductsScreen({super.key});

  @override
  State<LiveProductsScreen> createState() => _LiveProductsScreenState();
}

class _LiveProductsScreenState extends State<LiveProductsScreen> {
  /// ★ صور وهمية من الإنترنت (نفس أسلوب باقي التطبيق).
  static const List<String> _images = [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1000&q=80',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=1000&q=80',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1000&q=80',
    'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=1000&q=80',
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1000&q=80',
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=1000&q=80',
  ];

  final PageController _carousel = PageController(viewportFraction: 0.30);

  /// الصورة النشطة (المعروضة كخلفية كاملة).
  int _index = 0;

  /// حالة التفاعل: 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  int _reaction = 0;
  bool _following = false;

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  /// ★ معاينة الصورة فقط على شاشة كاملة (تمرير بين الصور + إغلاق).
  void _openPreview(int index) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) =>
            _ImagePreview(images: _images, initialIndex: index),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _orderNow() {
    HapticFeedback.mediumImpact();
    context.showSnackBar('تم إرسال طلبك إلى التاجر، سيتم التواصل معك.');
  }

  /// ★ فتح شيت التفاعل البسيط (تفاعل + متابعة/إلغاء + مشاركة).
  void _openInteractionSheet() {
    HapticFeedback.selectionClick();
    showAppSheet(
      context,
      builder: (_) => _LiveInteractionSheet(
        reaction: _reaction,
        following: _following,
        onReaction: (value) {
          if (mounted) setState(() => _reaction = value);
        },
        onFollow: (value) {
          if (mounted) setState(() => _following = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ★ الخلفية: صورة المنتج الحالية تملأ الصفحة.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Image.network(
              _images[_index],
              key: ValueKey(_index),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFF141A24),
                child: Center(
                  child: Icon(
                    LucideIcons.image,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          // ★ تظليل علوي/سفلي لضمان قراءة العناصر فوق الصورة.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.22, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context),
                const Spacer(),
                _buildBottomPanel(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── الشريط العلوي: رجوع + اسم التاجر + شارة «مباشر» ───
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 0),
      child: Row(
        children: [
          _GlassButton(
            icon: LucideIcons.chevronRight,
            tooltip: 'رجوع',
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    LucideIcons.store,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'متجر الأناقة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const _PulsingLiveBadge(),
        ],
      ),
    );
  }

  // ─── اللوحة السفلية: الكاروسيل + (اطلب الآن + أيقونة التفاعل) ───
  Widget _buildBottomPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCarousel(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: AppButton(
                    label: 'اطلب الآن',
                    icon: LucideIcons.shoppingBag,
                    onPressed: _orderNow,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ReactionIconButton(
                active: _reaction == 1,
                onTap: _openInteractionSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 88,
      child: PageView.builder(
        controller: _carousel,
        itemCount: _images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          final active = i == _index;
          return GestureDetector(
            onTap: () => _openPreview(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: active ? 0 : 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  width: active ? 2.5 : 1,
                ),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.white.withValues(alpha: 0.08),
                    child: const Icon(
                      LucideIcons.image,
                      size: 22,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ============================================================================
///  أيقونة التفاعل (إعجاب) — تفتح شيت التفاعل البسيط.
/// ============================================================================
class _ReactionIconButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _ReactionIconButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'التفاعل',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: active ? 0.22 : 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? const Color(0xFFE5484D).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.22),
              width: active ? 1.6 : 1,
            ),
          ),
          child: Icon(
            LucideIcons.heart,
            size: 24,
            color: active ? const Color(0xFFE5484D) : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// زر زجاجي دائري صغير (رجوع ونحوه).
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

/// شارة «مباشر» نابضة.
class _PulsingLiveBadge extends StatefulWidget {
  const _PulsingLiveBadge();

  @override
  State<_PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<_PulsingLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
            child: const Icon(LucideIcons.radio, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Text(
            'مباشر',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  شيت التفاعل البسيط: تفاعل (إعجاب/عدم إعجاب) + متابعة/إلغاء + مشاركة.
/// ============================================================================
class _LiveInteractionSheet extends StatefulWidget {
  const _LiveInteractionSheet({
    required this.reaction,
    required this.following,
    required this.onReaction,
    required this.onFollow,
  });

  /// 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  final int reaction;
  final bool following;
  final ValueChanged<int> onReaction;
  final ValueChanged<bool> onFollow;

  @override
  State<_LiveInteractionSheet> createState() => _LiveInteractionSheetState();
}

class _LiveInteractionSheetState extends State<_LiveInteractionSheet> {
  late int _reaction = widget.reaction;
  late bool _following = widget.following;

  void _selectReaction(int value) {
    HapticFeedback.selectionClick();
    setState(() => _reaction = _reaction == value ? 0 : value);
    widget.onReaction(_reaction);
  }

  void _toggleFollow() {
    HapticFeedback.selectionClick();
    setState(() => _following = !_following);
    widget.onFollow(_following);
  }

  Future<void> _share() async {
    HapticFeedback.selectionClick();
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    try {
      await Share.share(
        'شاهد منتجات «متجر الأناقة» على تطبيق گريب منك:\n'
        'https://greib.app/live/products',
        subject: 'عرض المنتجات المباشر',
        sharePositionOrigin: origin,
      );
    } catch (_) {
      // تجاهل إذا ألغى المستخدم المشاركة.
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textColors.primary;
    final textSecondary = context.textColors.secondary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التفاعل',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            // ─── خياري التفاعل: إعجاب / عدم إعجاب ───
            Row(
              children: [
                Expanded(
                  child: _ReactionTile(
                    icon: LucideIcons.thumbsUp,
                    label: 'إعجاب',
                    count: '1.2 ألف',
                    color: context.accentColor,
                    active: _reaction == 1,
                    onTap: () => _selectReaction(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReactionTile(
                    icon: LucideIcons.thumbsDown,
                    label: 'عدم إعجاب',
                    count: '3',
                    color: textSecondary,
                    active: _reaction == -1,
                    onTap: () => _selectReaction(-1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ─── متابعة/إلغاء المتابعة + مشاركة ───
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _following ? 'إلغاء المتابعة' : 'متابعة',
                    icon: _following
                        ? LucideIcons.userMinus
                        : LucideIcons.userPlus,
                    type: _following
                        ? ButtonType.secondary
                        : ButtonType.primary,
                    onPressed: _toggleFollow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'مشاركة',
                    icon: LucideIcons.share2,
                    type: ButtonType.secondary,
                    onPressed: _share,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// خيار تفاعل واحد (أيقونة + عنوان + عدّاد) بحد مميّز عند التحديد.
class _ReactionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ReactionTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = context.backgroundColors.surfaceElevated;
    final outline = context.backgroundColors.outline;
    final textPrimary = context.textColors.primary;
    final textSecondary = context.textColors.tertiary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.14) : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : outline,
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: active ? color : textPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
///  معاينة الصورة على شاشة كاملة (الصورة فقط + إغلاق).
/// ============================================================================
class _ImagePreview extends StatefulWidget {
  const _ImagePreview({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  late final PageController _page = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final many = widget.images.length > 1;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (_, _, _) => const Icon(
                    LucideIcons.image,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          // زر الإغلاق.
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + 6,
            end: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'إغلاق',
              icon: const Icon(LucideIcons.x, color: Colors.white),
            ),
          ),
          // عدّاد الصور.
          if (many)
            PositionedDirectional(
              top: MediaQuery.paddingOf(context).top + 12,
              start: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_index + 1}/${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
