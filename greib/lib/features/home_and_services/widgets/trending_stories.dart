import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  بيانات العناصر الرائجة
// ─────────────────────────────────────────────
class _TrendingItem {
  final String title;
  final String imageUrl;
  final String badge;
  const _TrendingItem({required this.title, required this.imageUrl, this.badge = 'رائج'});
}

const _kItems = [
  _TrendingItem(title: 'توصيل سريع', imageUrl: 'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=400&q=80', badge: '🔥 رائج'),
  _TrendingItem(title: 'فنادق فاخرة', imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80', badge: '⭐ مميز'),
  _TrendingItem(title: 'رحلات جوية', imageUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&q=80', badge: '✈️ رائج'),
  _TrendingItem(title: 'طب وصيدلة', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&q=80', badge: '💊 جديد'),
  _TrendingItem(title: 'تسوق يومي', imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80', badge: '🛍 رائج'),
  _TrendingItem(title: 'مطاعم مميزة', imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&q=80', badge: '🍽 رائج'),
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
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
              child: const _UserRequestCard(),
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
                    pageBuilder: (_, __, ___) => StoryViewerPage(items: _kItems, initialIndex: i),
                    transitionsBuilder: (_, animation, __, child) =>
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
//  بطاقة المستخدم (CTA — طلب الآن)
// ─────────────────────────────────────────────
class _UserRequestCard extends StatelessWidget {
  const _UserRequestCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 130,
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1B2537), const Color(0xFF0F172A)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFBFDBFE),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                border: Border.all(color: const Color(0xFF3B82F6), width: 2),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF3B82F6), size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              'خدمة\nشخصية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E3A5F),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Text(
                  'طلب الآن',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  بطاقة قصة عادية
// ─────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  final _TrendingItem item;
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
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800, child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40)),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: Colors.grey.shade900, child: const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)));
                  },
                ),
                Positioned(top: 0, left: 0, right: 0, child: Container(height: 80, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xCC000000), Colors.transparent])))),
                Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 100, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xEE000000), Colors.transparent])))),
                Positioned(
                  top: 10, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24, width: 0.8)),
                    child: Text(item.badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
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
  final List<_TrendingItem> items;
  final int initialIndex;
  const StoryViewerPage({super.key, required this.items, required this.initialIndex});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _StoryFullView(item: widget.items[i]),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ProgressBar(
                      count: widget.items.length,
                      currentIndex: _index,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    widget.items[_index].badge,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.items[_index].title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('استكشف الآن'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryFullView extends StatelessWidget {
  final _TrendingItem item;
  const _StoryFullView({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
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
              color: Colors.white.withOpacity(i <= currentIndex ? 0.95 : 0.35),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
