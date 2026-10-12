import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'user_request_story_card.dart';

// ─────────────────────────────────────────────
//  بيانات العناصر الرائجة — نموذج فيسبوك:
//  كل خدمة = حساب له صفحات (stories) خاصة به
//  المستخدم يقلّب صفحات الخدمة الواحدة، ثم ينتقل للخدمة التالية
// ─────────────────────────────────────────────
class TrendingItem {
  final String title;
  final String imageUrl;
  final String badge;

  /// تصنيف الخدمة (توصيل / طعام / إلكترونيات ...) — يظهر شارة بجانب
  /// التوقيت في عارض الستوري، وجاهز لأي ميزات متقدمة لاحقاً (فلترة، بحث...)
  final String category;

  /// صفحات الستوري الخاصة بهذه الخدمة (مثل الـ 20 صورة في ستوري فيسبوك)
  /// ★ إن تُرك فارغاً تُستخدم [imageUrl] كصفحة وحيدة تلقائياً
  final List<String> pages;

  const TrendingItem({
    required this.title,
    required this.imageUrl,
    this.badge = 'رائج',
    this.category = 'عام',
    this.pages = const [],
  });

  /// الصفحات الفعلية: المخصصة أو [imageUrl] كصفحة وحيدة
  List<String> get storyPages => pages.isEmpty ? [imageUrl] : pages;
}

const _kItems = [
  TrendingItem(title: 'توصيل سريع', category: 'توصيل', imageUrl: 'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=400&q=80', badge: '🔥 رائج', pages: [
    'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=1080&q=80',
    'https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=1080&q=80',
    'https://images.unsplash.com/photo-1600320254374-ce2d293c324e?w=1080&q=80',
  ]),
  TrendingItem(title: 'فنادق فاخرة', category: 'سفر', imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80', badge: '⭐ مميز', pages: [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1080&q=80',
    'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1080&q=80',
  ]),
  TrendingItem(title: 'رحلات جوية', category: 'سفر', imageUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&q=80', badge: '✈️ رائج', pages: [
    'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1080&q=80',
    'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=1080&q=80',
    'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1080&q=80',
  ]),
  TrendingItem(title: 'طب وصيدلة', category: 'صحة', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&q=80', badge: '💊 جديد', pages: [
    'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=1080&q=80',
    'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1080&q=80',
  ]),
  TrendingItem(title: 'تسوق يومي', category: 'إلكترونيات', imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80', badge: '🛍 رائج', pages: [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1080&q=80',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1080&q=80',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1080&q=80',
  ]),
  TrendingItem(title: 'مطاعم مميزة', category: 'طعام', imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&q=80', badge: '🍽 رائج', pages: [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1080&q=80',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1080&q=80',
  ]),
];

// ─────────────────────────────────────────────
//  الويدجت الرئيسية
// ─────────────────────────────────────────────
class TrendingStoriesSection extends StatefulWidget {
  final bool isDark;
  const TrendingStoriesSection({super.key, required this.isDark});
  @override
  State<TrendingStoriesSection> createState() => _TrendingStoriesSectionState();
}

class _TrendingStoriesSectionState extends State<TrendingStoriesSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: Directionality.of(context) == TextDirection.rtl,
        padding: EdgeInsets.zero,
        // +1 لبطاقة المستخدم
        itemCount: _kItems.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          // البطاقة الأخيرة: بطاقة المستخدم (تظهر في اليسار في RTL)
          if (i == _kItems.length) {
            final anim = CurvedAnimation(
              parent: _controller,
              curve: Interval((_kItems.length * 0.1).clamp(0.0, 0.9), 1.0, curve: Curves.easeOutBack),
            );
            return AnimatedBuilder(
              animation: anim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, 28 * (1 - anim.value)),
                child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
              ),
              child: const UserRequestStoryCard(),
            );
          }

          // باقي البطاقات
          final delay = i * 0.1;
          final anim = CurvedAnimation(
            parent: _controller,
            curve: Interval(delay.clamp(0.0, 0.9), (delay + 0.5).clamp(0.1, 1.0), curve: Curves.easeOutBack),
          );
          return AnimatedBuilder(
            animation: anim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, 28 * (1 - anim.value)),
              child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
            ),
            child: _StoryCard(
              item: _kItems[i],
              isPressed: _pressedIndex == i,
              onTap: () {
                setState(() => _pressedIndex = null);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 260),
                    pageBuilder: (_, _, _) => StoryViewerPage(items: _kItems, initialIndex: i),
                    transitionsBuilder: (_, animation, _, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              onTapDown: () => setState(() => _pressedIndex = i),
              onTapUp: () => setState(() => _pressedIndex = null),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  بطاقة قصة عادية
// ─────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  final TrendingItem item;
  final bool isPressed;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  const _StoryCard({required this.item, required this.isPressed, required this.onTap, required this.onTapDown, required this.onTapUp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 130,
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: Colors.grey.shade800, child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40)),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: Colors.grey.shade900, child: const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)));
                  },
                ),
                Positioned(top: 0, left: 0, right: 0, child: Container(height: 80, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xCC000000), Colors.transparent])))),
                Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 100, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xEE000000), Colors.transparent])))),
                Positioned(
                  top: 10,
                  left: 8,
                  // ★ ستايل فيسبوك: دائرة بروفايل بحلقة زرقاء بدل شارة "رائج"
                  child: Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0866FF),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: 34,
                          height: 34,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12, left: 8, right: 8,
                  child: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, height: 1.2, shadows: [Shadow(color: Colors.black87, blurRadius: 6)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  شاشة عرض القصة (Story Viewer) — بملء الشاشة
// ─────────────────────────────────────────────
class StoryViewerPage extends StatefulWidget {
  final List<TrendingItem> items;
  final int initialIndex;
  const StoryViewerPage({super.key, required this.items, required this.initialIndex});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  // ★ نموذج فيسبوك:
  //  - السحب الأفقي = التنقل بين الخدمات (الحسابات)
  //  - زرّا chevron = التنقل بين صفحات نفس الخدمة فقط
  //  - التقدم التلقائي = عند اكتمال صفحات الخدمة ينتقل للخدمة التالية
  late final PageController _serviceController;
  late int _serviceIndex;
  late int _pageIndex;

  /// مؤقت التقدم التلقائي (5 ثوانٍ لكل صفحة — مثل فيسبوك)
  Timer? _autoTimer;

  /// صفحات الخدمة الحالية
  List<String> get _pages => widget.items[_serviceIndex].storyPages;

  @override
  void initState() {
    super.initState();
    _serviceIndex = widget.initialIndex;
    _pageIndex = 0;
    _serviceController = PageController(initialPage: widget.initialIndex);
    _restartAutoTimer();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _serviceController.dispose();
    super.dispose();
  }

  /// إعادة تشغيل مؤقت الصفحة الحالية
  void _restartAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _autoNext();
    });
  }

  /// التقدم التلقائي: صفحة تالية، أو الخدمة التالية عند الاكتمال
  /// ★ عند آخر خدمة: يغلق العارض (نهاية الستوريز — مثل فيسبوك)
  void _autoNext() {
    if (_pageIndex < _pages.length - 1) {
      setState(() => _pageIndex += 1);
      _restartAutoTimer();
    } else if (_serviceIndex < widget.items.length - 1) {
      _goToService(_serviceIndex + 1);
    } else {
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  /// الانتقال لخدمة جديدة (سحب أو تلقائي): يبدأ من أول صفحة
  void _goToService(int i) {
    setState(() {
      _serviceIndex = i;
      _pageIndex = 0;
    });
    _restartAutoTimer();
  }

  /// زر التالي: يتنقل بين صفحات نفس الخدمة فقط — لا يغادر الخدمة
  void _nextPage() {
    if (_pageIndex < _pages.length - 1) {
      setState(() => _pageIndex += 1);
      _restartAutoTimer();
    }
  }

  /// زر السابق: يتنقل بين صفحات نفس الخدمة فقط — لا يغادر الخدمة
  void _previousPage() {
    if (_pageIndex > 0) {
      setState(() => _pageIndex -= 1);
      _restartAutoTimer();
    }
  }

  /// هل يوجد صفحة سابقة/تالية داخل نفس الخدمة؟
  bool get _hasPreviousPage => _pageIndex > 0;
  bool get _hasNextPage => _pageIndex < _pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            // ★ السحب الأفقي = التنقل بين الخدمات (مثل السحب بين حسابات فيسبوك)
            controller: _serviceController,
            onPageChanged: _goToService,
            itemCount: widget.items.length,
            itemBuilder: (_, s) {
              // الخدمة الحالية فقط تفاعلية؛ البقية عرض ثابت لأول صفحة
              // (تجنّب PageView متداخلة — مصدر لخبطة السحب)
              final page = s == _serviceIndex
                  ? _pageIndex.clamp(0, widget.items[s].storyPages.length - 1)
                  : 0;
              return _StoryFullView(
                key: ValueKey('service_${s}_page_$page'),
                imageUrl: widget.items[s].storyPages[page],
              );
            },
          ),
          // ── الهيدر: ProgressBar (صفحات الخدمة الحالية فقط) + بروفايل ──
          // ★ المؤشر يعرض عدد صفحات هذه الخدمة فقط — مثل فيسبوك
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProgressBar(
                    count: _pages.length,
                    currentIndex: _pageIndex,
                  ),
                  const SizedBox(height: 10),
                  _StoryHeader(
                    imageUrl: widget.items[_serviceIndex].imageUrl,
                    title: widget.items[_serviceIndex].title,
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
          // ── زرّا التنقل: صفحات نفس الخدمة فقط (لا يغادران الخدمة) ──
          // ★ الانتقال بين الخدمات يتم بالسحب أو تلقائياً عند الاكتمال
          if (_hasPreviousPage)
            PositionedDirectional(
              start: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _StoryNavArrow(
                  icon: Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  onTap: _previousPage,
                ),
              ),
            ),
          if (_hasNextPage)
            PositionedDirectional(
              end: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _StoryNavArrow(
                  icon: Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  onTap: _nextPage,
                ),
              ),
            ),
          // ── الأسفل: ردود جاهزة + شريط التفاعل ──
          // ★ Gradient سفلي يحمي النص من ضياعه فوق الصورة
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 28, 12, bottomPad + 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: Directionality.of(context) ==
                          TextDirection.rtl,
                      child: Row(
                        children: [
                          _QuickReply(
                            label: 'مرتاح 😊',
                            onTap: () => context.showSnackBar(
                                'تم إرسال: مرتاح 😊'),
                          ),
                          _QuickReply(
                            label: 'جيد جداً!',
                            onTap: () => context.showSnackBar(
                                'تم إرسال: جيد جداً!'),
                          ),
                          _QuickReply(
                            label: 'رائع! 🥹😂',
                            onTap: () => context.showSnackBar(
                                'تم إرسال: رائع! 🥹😂'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StoryReplyBar(
                      onEmoji: (e) => context.showSnackBar(e),
                      onMessageTap: () => context.showSnackBar(
                          'الردود الخاصة — قريباً'),
                      onShare: () => context.showSnackBar(
                          'المشاركة — قريباً'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// هيدر الستوري: بروفايل + اسم + وقت + أزرار
class _StoryHeader extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onClose;
  const _StoryHeader({
    required this.imageUrl,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0866FF),
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 32,
                height: 32,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey.shade700,
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white70, size: 18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'الآن · 0:15',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                ),
              ),
            ],
          ),
        ),
        _HeaderBtn(icon: Icons.volume_up_rounded, onTap: () {}),
        _HeaderBtn(icon: Icons.more_horiz_rounded, onTap: () {}),
        _HeaderBtn(icon: Icons.close_rounded, onTap: onClose),
      ],
    );
  }
}

/// زر سهم التنقل الجانبي — دائرة شفافة بحد أبيض
class _StoryNavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StoryNavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.45),
          border: Border.all(color: Colors.white30, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

/// زر دائري شفاف للهيدر (صوت / خيارات / إغلاق / مشاركة)
class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
        ),
      ),
    );
  }
}

/// زر رد جاهز — حبة داكنة شفافة مثل الصورة
class _QuickReply extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickReply({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 0.8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// شريط الرد السفلي: إيموجي + حقل رسالة + مشاركة
class _StoryReplyBar extends StatelessWidget {
  final ValueChanged<String> onEmoji;
  final VoidCallback onMessageTap;
  final VoidCallback onShare;
  const _StoryReplyBar({
    required this.onEmoji,
    required this.onMessageTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _EmojiBtn(emoji: '😂', onTap: () => onEmoji('😂')),
        _EmojiBtn(emoji: '👍', onTap: () => onEmoji('👍')),
        _EmojiBtn(emoji: '❤️', onTap: () => onEmoji('❤️')),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onMessageTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Text(
                'إرسال رسالة...',
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _HeaderBtn(icon: Icons.share_rounded, onTap: onShare),
      ],
    );
  }
}

/// زر إيموجي دائري سريع
class _EmojiBtn extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  const _EmojiBtn({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsetsDirectional.only(end: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

class _StoryFullView extends StatelessWidget {
  final String imageUrl;
  const _StoryFullView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey.shade900),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)));
          },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x88000000), Colors.transparent, Color(0x99000000)], stops: [0, 0.45, 1])),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _ProgressBar({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 4),
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: i <= currentIndex ? 0.95 : 0.35),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
