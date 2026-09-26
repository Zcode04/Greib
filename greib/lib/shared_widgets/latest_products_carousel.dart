import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/mock_data/mock_data.dart';
import '../core/models/product_model.dart';
import '../core/theme/app_colors.dart';

/// بطاقة "الأحدث" — بانر بعرض كامل (ستايل متاجر إلكترونية) يعرض 4 منتجات.
class LatestProductsCarousel extends StatefulWidget {
  const LatestProductsCarousel({super.key});
  @override
  State<LatestProductsCarousel> createState() => _LatestProductsCarouselState();
}

class _LatestProductsCarouselState extends State<LatestProductsCarousel> {
  late final PageController _pageController;
  late final List<Product> _latest;
  Timer? _autoTimer;
  int _current = 0;
  @override
  void initState() {
    super.initState();
    final all = MockData.products;
    _latest = all.length <= 4 ? List<Product>.from(all) : all.sublist(all.length - 4).reversed.toList();
    _pageController = PageController(viewportFraction: 1.0);
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _latest.isEmpty) return;
      _current = (_current + 1) % _latest.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(_current, duration: const Duration(milliseconds: 550), curve: Curves.easeInOut);
      }
    });
  }
  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_latest.isEmpty) return const SizedBox.shrink();
    final dotColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _latest.length,
            itemBuilder: (context, i) => _banner(_latest[i], isDark),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_latest.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(color: active ? dotColor : (isDark ? Colors.white24 : AppColors.lightOutline), borderRadius: BorderRadius.circular(5)),
            );
          }),
        ),
      ],
    );
  }
  Widget _banner(Product p, bool isDark) {
    final accent = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
    final hasDiscount = p.oldPrice != null && p.oldPrice! > p.price;
    final discountPct = hasDiscount ? (((p.oldPrice! - p.price) / p.oldPrice!) * 100).round() : 0;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: isDark ? AppColors.violetGlow(blur: 22, alpha: 0.12) : [BoxShadow(color: AppColors.accentPrimary.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: AppColors.accentPrimaryDark, child: const Center(child: Icon(LucideIcons.shoppingBag, size: 52, color: Colors.white)))),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Colors.black.withValues(alpha: 0.88), Colors.black.withValues(alpha: 0.55), Colors.black.withValues(alpha: 0.05)], stops: const [0.0, 0.55, 1.0]))),
            Positioned(
              top: 12, right: 12,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4))]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.sparkles, size: 12, color: Colors.white), SizedBox(width: 4), Text('الأحدث', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))])),
                if (hasDiscount) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Text('خصم $discountPct%', style: const TextStyle(color: Color(0xFFB42318), fontSize: 11, fontWeight: FontWeight.w800)))],
              ]),
            ),
            Positioned(
              right: 14, left: 14, bottom: 14,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8)), child: const Text('وصل حديثا', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 6),
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                  const SizedBox(height: 4),
                  Row(children: [Text('${p.price.toStringAsFixed(0)} ر.س', style: TextStyle(color: isDark ? AppColors.neon : const Color(0xFFFFD54F), fontWeight: FontWeight.w900, fontSize: 16)), if (hasDiscount) ...[const SizedBox(width: 8), Text('${p.oldPrice!.toStringAsFixed(0)} ر.س', style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500, decoration: TextDecoration.lineThrough))], const SizedBox(width: 8), const Icon(LucideIcons.star, size: 13, color: AppColors.warning), const SizedBox(width: 3), Text(p.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))]),
                ])),
                const SizedBox(width: 12),
                ElevatedButton.icon(onPressed: () => context.push('/orders'), style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: isDark ? Colors.black : Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0), icon: Icon(LucideIcons.shoppingCart, size: 16, color: isDark ? Colors.black : Colors.white), label: const Text('اطلب', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
