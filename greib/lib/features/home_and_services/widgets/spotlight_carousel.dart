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
    final visibleCount =
        _visiblePostsCount > services.length ? services.length : _visiblePostsCount;

    return Builder(
      builder: (context) {
        // عرض الشاشة الكامل — نستخدمه لتمديد البطاقة من طرف لطرف
        final screenWidth = MediaQuery.sizeOf(context).width;
        // الصفحة لها padding أفقي 20px من كل جانب
        const hPad = 20.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transform.translate يزيح البطاقة 20px يساراً بصرياً فقط
            // بينما Column لا تزال ترى الارتفاع الصحيح → لا تداخل مع المحتوى
            Transform.translate(
              offset: const Offset(-hPad, 0),
              child: SizedBox(
                width: screenWidth,
                child: ListView.separated(
                  key: const ValueKey('posts'),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleCount,
                  separatorBuilder: (_, _) => SizedBox(
                    height: 8,
                    child: ColoredBox(
                      color: widget.isDark
                          ? AppColors.background
                          : AppColors.lightBackground,
                    ),
                  ),
                  itemBuilder: (context, i) => _spotlightPostItem(services[i]),
                ),
              ),
            ),
            if (visibleCount < services.length)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: (widget.isDark
                            ? AppColors.neon
                            : AppColors.accentPrimaryDark)
                        .withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => setState(() => _visiblePostsCount++),
                  icon: Icon(
                    LucideIcons.chevronDown,
                    size: 16,
                    color: widget.isDark
                        ? AppColors.neon
                        : AppColors.accentPrimaryDark,
                  ),
                  label: Text(
                    'عرض المزيد',
                    style: TextStyle(
                      color: widget.isDark
                          ? AppColors.neon
                          : AppColors.accentPrimaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _spotlightPostItem(ServiceCategory service) {
    final serviceColor = service.color;
    final isFav = _favoriteServiceIds.contains(service.id);
    
    // صورة افتراضية للخدمات التي ليس لها صورة
    final String imageUrl = service.imageUrl ?? 
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80';

    return Container(
      color: widget.isDark ? AppColors.surfaceCard : Colors.white,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 1. رأس المنشور (Profile) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الحساب (أيقونة الخدمة)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: serviceColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: serviceColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    MockData.getIconByName(service.iconName),
                    color: serviceColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // اسم الحساب والوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title, // مثل: Brandon (توصيل طعام)
                        style: TextStyle(
                          color: widget.isDark ? AppColors.textPrimary : AppColors.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Greib · منذ ساعتين · ',
                            style: TextStyle(
                              color: widget.isDark
                                  ? AppColors.textSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            LucideIcons.globe,
                            size: 12,
                            color: widget.isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // أيقونات الخيارات
                Icon(
                  LucideIcons.ellipsis,
                  color: widget.isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Icon(
                  LucideIcons.x,
                  color: widget.isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── 2. نص المنشور (Post Text) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              service.subtitle, // مثل: My view (من مطعمك المفضل)
              style: TextStyle(
                color: widget.isDark ? AppColors.textPrimary : AppColors.lightText,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── 3. صورة المنشور (Edge-to-Edge) ───
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildIconHero(serviceColor, service),
          ),

          // ─── 4. إحصائيات التفاعل ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _reactionChip(LucideIcons.thumbsUp, AppColors.info),
                    const SizedBox(width: 2),
                    _reactionChip(LucideIcons.heart, AppColors.error),
                    const SizedBox(width: 6),
                    Text(
                      '٢٫١ ألف',
                      style: TextStyle(
                        color: widget.isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  '٣٨ تعليق',
                  style: TextStyle(
                    color: widget.isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // فاصل علوي للأزرار
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: widget.isDark ? AppColors.outline : AppColors.lightOutline,
            ),
          ),

          // ─── 5. أزرار الإجراءات (تفاعلات) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _fbActionButton(
                    icon: LucideIcons.shoppingBag,
                    label: 'طلب الآن',
                    color: serviceColor,
                    onTap: () => context.push(service.route),
                  ),
                ),
                Expanded(
                  child: _fbActionButton(
                    icon: isFav
                        ? LucideIcons.bookmarkCheck
                        : LucideIcons.bookmarkPlus,
                    label: 'للقائمة',
                    color: isFav
                        ? serviceColor
                        : (widget.isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary),
                    onTap: () => setState(() {
                      if (isFav) {
                        _favoriteServiceIds.remove(service.id);
                      } else {
                        _favoriteServiceIds.add(service.id);
                      }
                    }),
                  ),
                ),
                Expanded(
                  child: _fbActionButton(
                    icon: LucideIcons.share2,
                    label: 'مشاركة',
                    color: widget.isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Image: fallback لو فشل تحميل الصورة
  Widget _buildIconHero(Color serviceColor, ServiceCategory service) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            serviceColor.withValues(alpha: 0.22),
            serviceColor.withValues(alpha: 0.07),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: serviceColor.withValues(alpha: 0.18),
            border: Border.all(
              color: serviceColor.withValues(alpha: 0.38),
              width: 2,
            ),
          ),
          child: Icon(
            MockData.getIconByName(service.iconName),
            color: serviceColor,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _reactionChip(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: widget.isDark ? AppColors.surfaceCard : Colors.white,
          width: 1.5,
        ),
      ),
      child: Icon(icon, size: 11, color: Colors.white),
    );
  }

  Widget _fbActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
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
