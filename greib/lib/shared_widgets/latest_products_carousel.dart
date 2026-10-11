import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/extensions/context_extensions.dart';
import '../core/theme/app_colors.dart';
import '../features/services/data/commerce_aggregator_service.dart';
import 'store_category_tabs.dart';

/// بطاقة "الأحدث" والتجارة المجمعة — تتفاعل فوراً مع التبويب المختار
/// وتجلب المحتوى والأسعار ومتاجر المصدر (نون، أمازون، إلخ) من CommerceAggregatorService.
class LatestProductsCarousel extends StatefulWidget {
  const LatestProductsCarousel({super.key});
  @override
  State<LatestProductsCarousel> createState() => _LatestProductsCarouselState();
}

class _LatestProductsCarouselState extends State<LatestProductsCarousel> {
  late final PageController _pageController;
  List<AggregatedProduct> _products = [];
  Timer? _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _loadProductsForCurrentCategory();
    _pageController = PageController(viewportFraction: 1.0);
    StoreSelectedCategory.notifier.addListener(_onCategoryChanged);
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _products.isEmpty) return;
      _current = (_current + 1) % _products.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _current,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _loadProductsForCurrentCategory() {
    final catId = StoreSelectedCategory.notifier.value;
    _products = CommerceAggregatorService.instance.getProductsForCategorySync(catId);
    if (_products.isEmpty) {
      _products = CommerceAggregatorService.instance.getProductsForCategorySync('all');
    }
  }

  void _onCategoryChanged() {
    if (!mounted) return;
    setState(() {
      _loadProductsForCurrentCategory();
      _current = 0;
    });
    if (_pageController.hasClients && _products.isNotEmpty) {
      _pageController.jumpToPage(0);
    }
    _startTimer();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    StoreSelectedCategory.notifier.removeListener(_onCategoryChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_products.isEmpty) return const SizedBox.shrink();
    final dotColor = context.accentColor;
    final inactiveDotColor = context.backgroundColors.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _products.length,
            itemBuilder: (context, i) => _banner(_products[i], isDark),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_products.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? dotColor : inactiveDotColor,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
        if (_products.length > 1) ...[
          const SizedBox(height: 14),
          _buildQuickProductsTray(isDark),
        ],
      ],
    );
  }

  Widget _banner(AggregatedProduct p, bool isDark) {
    final accent = context.accentColor;
    final hasDiscount = p.oldPrice != null && p.oldPrice! > p.customPrice;
    final discountPct = hasDiscount
        ? (((p.oldPrice! - p.customPrice) / p.oldPrice!) * 100).round()
        : 0;
    final isHotel = p.category == 'hotels';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.12 : 0.22),
            blurRadius: isDark ? 22 : 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              p.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, _) => Container(
                color: accent,
                child: Center(
                  child: Icon(
                    isHotel ? LucideIcons.hotel : LucideIcons.shoppingBag,
                    size: 52,
                    color: ctx.textColors.onAccent,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.88),
                    Colors.black.withValues(alpha: 0.52),
                    Colors.black.withValues(alpha: 0.04),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isHotel ? const Color(0xFF1E6B3C) : AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (isHotel ? const Color(0xFF1E6B3C) : AppColors.error)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHotel ? LucideIcons.hotel : LucideIcons.sparkles,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isHotel ? 'إقامة عائلية' : 'الأحدث',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'خصم $discountPct%',
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.store, size: 10, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      p.sourceStore,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 14,
              left: 14,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isHotel
                                ? (p.tags.isNotEmpty ? p.tags[0] : 'إقامة فاخرة')
                                : 'وصل حديثاً',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              isHotel
                                  ? '${p.customPrice.toStringAsFixed(0)} ر.س/ليلة'
                                  : '${p.customPrice.toStringAsFixed(0)} ${p.currency}',
                              style: const TextStyle(
                                color: Color(0xFFFFD54F),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${p.oldPrice!.toStringAsFixed(0)} ${p.currency}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.star, size: 12, color: AppColors.warning),
                            const SizedBox(width: 3),
                            Text(
                              p.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (p.reviewsCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${p.reviewsCount})',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: context.textColors.onAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      isHotel ? LucideIcons.calendarCheck : LucideIcons.shoppingCart,
                      size: 15,
                      color: context.textColors.onAccent,
                    ),
                    label: Text(
                      isHotel ? 'احجز' : 'اطلب',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickProductsTray(bool isDark) {
    final accent = context.accentColor;
    final trayItems = _products.take(6).toList();

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: trayItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = trayItems[i];
          final isActive = i == _current;
          return GestureDetector(
            onTap: () {
              setState(() => _current = i);
              if (_pageController.hasClients) {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? accent : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, _) => Container(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        child: Icon(LucideIcons.image, size: 22, color: accent),
                      ),
                    ),
                    Container(
                      color: Colors.black.withValues(
                        alpha: isActive ? 0.2 : 0.45,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Text(
                          p.customPrice.toStringAsFixed(0),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
