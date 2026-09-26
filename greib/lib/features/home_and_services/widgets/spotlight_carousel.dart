import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/service_model.dart';

class SpotlightSection extends StatefulWidget {
  final bool isDark;

  const SpotlightSection({super.key, required this.isDark});

  @override
  State<SpotlightSection> createState() => _SpotlightSectionState();
}

class _SpotlightSectionState extends State<SpotlightSection> {
  final PageController _spotlightController = PageController(viewportFraction: 0.84);
  int _spotlightIndex = 0;
  final Set<String> _favoriteServiceIds = {};
  bool _isGridView = false;
  int _visiblePostsCount = 2;

  @override
  void dispose() {
    _spotlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = MockData.services;
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isGridView
              ? _buildSpotlightPosts(services)
              : _buildSpotlightCarousel(services),
        ),
        const SizedBox(height: 10),
        if (!_isGridView)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(services.length, (i) {
              final active = i == _spotlightIndex;
              final neonColor = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? neonColor
                      : (widget.isDark ? Colors.white24 : AppColors.lightOutline),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: (widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            // ★ تسمية مميزة لا تتكرر مع بقية أزرار الصفحة («عرض المزيد»
            // تظهر في قسمي الخدمات والمنتجات) + أيقونة تشرح الناتج.
            icon: Icon(
              _isGridView ? LucideIcons.galleryHorizontal : LucideIcons.layoutList,
              size: 16,
              color: widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark,
            ),
            label: Text(
              _isGridView ? 'عرض الشرائح' : 'عرض كمنشورات',
              style: TextStyle(
                color: widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpotlightCarousel(List<ServiceCategory> services) {
    return SizedBox(
      key: const ValueKey('carousel'),
      height: 232,
      child: PageView.builder(
        controller: _spotlightController,
        itemCount: services.length,
        onPageChanged: (i) => setState(() => _spotlightIndex = i),
        itemBuilder: (context, i) {
          final s = services[i];
          return AnimatedScale(
            scale: i == _spotlightIndex ? 1.0 : 0.93,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: i == _spotlightIndex ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 220),
              child: _spotlightItem(s),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpotlightPosts(List<ServiceCategory> services) {
    final visibleCount = _visiblePostsCount > services.length ? services.length : _visiblePostsCount;
    return Column(
      children: [
        ListView.separated(
          key: const ValueKey('posts'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) => _spotlightPostItem(services[i]),
        ),
        if (visibleCount < services.length)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: (widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => setState(() => _visiblePostsCount++),
              icon: Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark,
              ),
              label: Text(
                'عرض المزيد',
                style: TextStyle(
                  color: widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _spotlightPostItem(ServiceCategory service) {
    final neonColor = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceCard : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? AppColors.outline : AppColors.lightOutline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (like FB post header)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: neonColor.withValues(alpha: 0.15),
                  child: Icon(MockData.getIconByName(service.iconName), color: neonColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: TextStyle(
                          color: widget.isDark ? AppColors.textPrimary : AppColors.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        service.subtitle,
                        style: TextStyle(
                          color: neonColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Image / Content
          if (service.imageUrl != null)
            Image.network(
              service.imageUrl!,
              height: 200,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 200,
              color: neonColor.withValues(alpha: 0.1),
              child: Icon(MockData.getIconByName(service.iconName), color: neonColor, size: 60),
            ),
            
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _postActionButton(
                  icon: LucideIcons.shoppingBag,
                  label: 'طلب الآن',
                  color: neonColor,
                  onTap: () => context.push(service.route),
                ),
                _postActionButton(
                  icon: _favoriteServiceIds.contains(service.id) ? LucideIcons.checkSquare : LucideIcons.bookmarkPlus,
                  label: 'للقائمة',
                  color: widget.isDark ? Colors.white70 : AppColors.lightTextSecondary,
                  onTap: () {
                    setState(() {
                      if (_favoriteServiceIds.contains(service.id)) {
                        _favoriteServiceIds.remove(service.id);
                      } else {
                        _favoriteServiceIds.add(service.id);
                      }
                    });
                  },
                ),
                _postActionButton(
                  icon: LucideIcons.share2,
                  label: 'مشاركة',
                  color: widget.isDark ? Colors.white70 : AppColors.lightTextSecondary,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spotlightItem(ServiceCategory service) {
    final neonColor = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final isFav = _favoriteServiceIds.contains(service.id);

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(28),
      opacity: widget.isDark ? 0.05 : 0.1,
      boxShadow: widget.isDark
          ? AppColors.neonGlow(blur: 20, alpha: 0.1)
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => context.push(service.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'service_${service.id}',
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: neonColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: 0.1,
                        child: (service.imageUrl != null)
                            ? ClipOval(
                                child: Image.network(
                                  service.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    MockData.getIconByName(service.iconName),
                                    color: neonColor,
                                    size: 40,
                                  ),
                                ),
                              )
                            : Icon(
                                MockData.getIconByName(service.iconName),
                                color: neonColor,
                                size: 40,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.isDark ? AppColors.textPrimary : AppColors.lightText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: neonColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                _spotlightIconButton(
                  // الحالة (مفضّل/غير مفضّل) تُعبّر عنها الألوان والخلفية.
                  icon: LucideIcons.heart,
                  iconColor: isFav
                      ? AppColors.error
                      : (widget.isDark ? Colors.white70 : AppColors.lightTextSecondary),
                  filledBackground: isFav
                      ? AppColors.error.withValues(alpha: 0.15)
                      : null,
                  onTap: () => setState(() {
                    if (isFav) {
                      _favoriteServiceIds.remove(service.id);
                    } else {
                      _favoriteServiceIds.add(service.id);
                    }
                  }),
                ),
                const SizedBox(width: 6),
                _spotlightIconButton(
                  icon: LucideIcons.arrowLeft,
                  iconColor: widget.isDark ? Colors.black : Colors.white,
                  filledBackground: neonColor,
                  onTap: () => context.push(service.route),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _spotlightIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
    Color? filledBackground,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filledBackground ?? Colors.transparent,
          border: filledBackground == null
              ? Border.all(color: iconColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}
