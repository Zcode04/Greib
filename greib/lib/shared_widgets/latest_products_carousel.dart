import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/mock_data/mock_data.dart';
import '../core/models/product_model.dart';
import '../core/theme/app_colors.dart';

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
    _pageController = PageController(viewportFraction: 0.82);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 252,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _latest.length,
            itemBuilder: (context, i) => _card(_latest[i], isDark, i == _current),
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
  Widget _card(Product p, bool isDark, bool active) {
    final accent = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;
    return AnimatedScale(
      scale: active ? 1.0 : 0.96,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: isDark ? AppColors.violetGlow(blur: 22, alpha: 0.12) : [BoxShadow(color: AppColors.accentPrimary.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: AppColors.accentPrimaryDark, child: const Center(child: Icon(LucideIcons.shoppingBag, size: 52, color: Colors.white)))),
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.25), Colors.black.withValues(alpha: 0.85)], stops: const [0.35, 0.6, 1.0]))),
              Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4))]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.sparkles, size: 12, color: Colors.white), SizedBox(width: 4), Text('الأحدث', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))]))),
              Positioned(
                left: 12, right: 12, bottom: 12,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(children: [Text('${p.price.toStringAsFixed(0)} ر.س', style: TextStyle(color: isDark ? AppColors.neon : AppColors.accentPrimary, fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(width: 8), const Icon(LucideIcons.star, size: 13, color: AppColors.warning), const SizedBox(width: 3), Text(p.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))]),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => context.push('/orders'), style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: isDark ? Colors.black : Colors.white, padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0), icon: Icon(LucideIcons.shoppingCart, size: 16, color: isDark ? Colors.black : Colors.white), label: const Text('طلب الآن', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
