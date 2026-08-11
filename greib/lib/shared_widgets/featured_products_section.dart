import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/mock_data/mock_data.dart';
import '../core/theme/app_colors.dart';

/// قسم "منتجات مختارة لك" — شريط تصنيفات أفقي + شبكة منتجات مُفلترة
/// بأسلوب متجانس مع باقي شاشة الـ Home (نفس الألوان، الزوايا، الظلال).
class FeaturedProductsSection extends StatefulWidget {
  const FeaturedProductsSection({super.key});

  @override
  State<FeaturedProductsSection> createState() => _FeaturedProductsSectionState();
}

class _FeaturedProductsSectionState extends State<FeaturedProductsSection> {
  String _selectedCategory = 'all'; // التصنيف المُفعّل افتراضياً: الكل
  bool _isExpanded = false; // حالة توسيع قائمة المنتجات
  static const int _collapsedCount = 4; // عدد الكروت الظاهرة أول مرة

  // المنتجات بعد الفلترة حسب التصنيف (selectedCategory)
  List<Product> get _filteredProducts {
    if (_selectedCategory == 'all') return MockData.products;
    return MockData.products
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  // بعد الفلترة، نطبّق التقليص فوقها (قبل التوسيع)
  List<Product> get _visibleProducts {
    final filtered = _filteredProducts;
    return _isExpanded ? filtered : filtered.take(_collapsedCount).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canExpand = _filteredProducts.length > _collapsedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryChips(isDark),
        const SizedBox(height: 14),
        // AnimatedSize لأنيميشن سلس عند التوسيع/الطيّ
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _buildProductsGrid(isDark),
          ),
        ),
        if (canExpand) ...[
          const SizedBox(height: 18),
          _buildShowMoreButton(isDark),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // شريط التصنيفات الأفقي
  // ---------------------------------------------------------------------------
  Widget _buildCategoryChips(bool isDark) {
    final accentColor =
        isDark ? AppColors.accentPrimaryLight : AppColors.accentPrimary;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MockData.productCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = MockData.productCategories[i];
          final id = cat['id']!;
          final label = cat['label']!;
          final isSelected = id == _selectedCategory;

          return InkWell(
            onTap: () => setState(() {
              _selectedCategory = id;
              _isExpanded = false; // صفّر التوسيع عند تبديل التصنيف
            }),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.transparent : null),
                gradient: isSelected
                    ? null
                    : (isDark
                        ? null
                        : const LinearGradient(
                            colors: AppColors.catalogCardGradientLight,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : (isDark
                          ? Colors.white10
                          : AppColors.lightOutline),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark
                            ? AppColors.textPrimary
                            : Colors.white),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // شبكة المنتجات (تُفلتر حسب _selectedCategory)
  // نستخدم ValueKey على التصنيف لكي يتعرف AnimatedSwitcher على التغيير
  // ---------------------------------------------------------------------------
  Widget _buildProductsGrid(bool isDark) {
    final products = _visibleProducts;

    return GridView.builder(
      key: ValueKey('$_selectedCategory-$_isExpanded'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, i) => _productCard(products[i], isDark),
    );
  }

  // ---------------------------------------------------------------------------
  // كرت منتج واحد (صورة + اسم + سعر/سعر قديم مشطوب + تقييم)
  // ---------------------------------------------------------------------------
  Widget _productCard(Product product, bool isDark) {
    final accentColor =
        isDark ? AppColors.accentPrimaryLight : AppColors.accentPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: AppColors.catalogCardGradientLight,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? AppColors.violetGlow(blur: 20, alpha: 0.10)
            : [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- صورة المنتج ----
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white.withValues(
                            alpha: isDark ? 0 : 0.14),
                        child: Center(
                          child: Icon(
                            LucideIcons.shoppingBag,
                            color: isDark ? accentColor : Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.oldPrice != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ---- النص السفلي ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // السعر + السعر القديم المشطوب
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          color: isDark
                              ? accentColor
                              : Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${product.oldPrice!.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMuted
                                : Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // التقييم
                  Row(
                    children: [
                      Icon(
                        LucideIcons.star,
                        size: 13,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                              : Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // زر "عرض المزيد / عرض أقل" — نفس تصميم _buildShowMoreButton في الـ Home
  // (كبسولة بلون accent + سهم chevron مع AnimatedRotation)
  // ---------------------------------------------------------------------------
  Widget _buildShowMoreButton(bool isDark) {
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: neonColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: neonColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'عرض أقل' : 'عرض المزيد',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                duration: const Duration(milliseconds: 280),
                turns: _isExpanded ? 0.5 : 0,
                child: Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
