import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/service_model.dart';

class SpotlightSection extends StatefulWidget {
  final bool isDark;

  /// حشو الشاشة المستضيفية أفقياً (Home = 20). نحتاجه في وضع «المنشورات»
  /// لتمديد البطاقة لحواف الشاشة من داخل الحشو، بدل الاعتماد على
  /// MediaQuery (يتجاهل أي حاوية بعرض مختلف ويكسر عند تغيّر الحشو).
  final double horizontalBleed;

  const SpotlightSection({
    super.key,
    required this.isDark,
    this.horizontalBleed = 20,
  });

  @override
  State<SpotlightSection> createState() => _SpotlightSectionState();
}

class _SpotlightSectionState extends State<SpotlightSection> {
  /// نسبة عرض الصفحة في الـ PageView تُحسب من العرض المتاح فعلياً (ليست ثابتة)،
  /// لذلك نحتفظ بالقيمة الحالية لإعادة بناء الـ controller عند تغيّر حجم الشاشة.
  static const double _kDefaultViewportFraction = 0.84;

  PageController _spotlightController =
      PageController(viewportFraction: _kDefaultViewportFraction);
  double? _spotlightViewportFraction = _kDefaultViewportFraction;
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
          // ★ المنشورات تتمدد خارج حشو الصفحة (من طرف لطرف)، والـ Stack
          // الافتراضي يقصّ أطرافها أثناء التبديل ⇒ نلغي القصّ ونحاذي للأعلى.
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: <Widget>[...previousChildren, ?currentChild],
          ),
          child: _isGridView
              ? _buildSpotlightPosts(services)
              : _buildSpotlightCarousel(services),
        ),
        const SizedBox(height: 10),
        if (!_isGridView)
          // ★ FittedBox ⇒ تتقلّص النقاط تلقائياً بدل فيض الصف على الشاشات
          // الضيقة (27 شريحة × 12px تتجاوز عرض الهاتف).
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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

  /// أقصى عرض لبطاقة المنشور/الشريحة: على الهاتف تملأ الشاشة من طرف لطرف
  /// (فيس بوك)، وعلى التابلت/الشاشات العريضة يبقى العمود بعرض مقروء ومتمركز.
  static const double _kMaxPostWidth = 620;

  /// أقصى جزء من البطاقة يظهر من الشريحة التالية (فيس بوك: لمحة عن الجار).
  static const double _kMaxPeek = 48;

  /// النسبة بين ارتفاع شريحة العرض وارتفاعها (الهاتف) + سقف للعرض.
  static const double _kCardHeightRatio = 0.86;
  static const double _kMinCardHeight = 200;
  static const double _kMaxCardHeight = 280;

  /// ★ العرض الأفقي للشريحة: يتمدد من طرف الشاشة لطرف (فيس بوك) ويشتق حجم
  /// البطاقة وارتفاعها من العرض الفعلي ⇒ نفس النتيجة على أي شاشة (تابلت/جوال).
  Widget _buildSpotlightCarousel(List<ServiceCategory> services) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - widget.horizontalBleed * 2;
        final bleed = widget.horizontalBleed.clamp(0.0, available / 2);
        final viewportWidth = available + bleed * 2;
        // الهاتف: 84% من العرض (مع لمحة عن التالي). العريض: عمود مقروء متمركز.
        final cardWidth =
            (viewportWidth * _kDefaultViewportFraction).clamp(
                    0.0, _kMaxPostWidth);
        final peek = (viewportWidth - cardWidth).clamp(0.0, _kMaxPeek);
        final height =
            (cardWidth * _kCardHeightRatio).clamp(_kMinCardHeight, _kMaxCardHeight);
        // النسبة نسبةً لعرض الـ PageView نفسه (cardWidth + peek) لا لعرض الشاشة.
        final fraction = cardWidth / (cardWidth + peek);

        _updatePageController(fraction);

        return OverflowBox(
          // ★ تمديد حقيقي لحواف الشاشة: يزيح الابن بصرياً فقط (بلا تغيير في
          // تخطيط العمود الأب). UnconstrainedBox يرسم أخطاء في وضع Debug،
          // والحشو السالب مرفوض في Flutter.
          alignment: Alignment.center,
          fit: OverflowBoxFit.deferToChild,
          minWidth: viewportWidth,
          maxWidth: viewportWidth,
          child: SizedBox(
            key: const ValueKey('carousel'),
            width: viewportWidth,
            height: height,
            // Center ⇒ توسيط البطاقة على الشاشات العريضة (بلا أثر على الهاتف).
            child: Center(
              child: SizedBox(
                width: cardWidth + peek,
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
              ),
            ),
          ),
        );
      },
    );
  }

  /// إعادة بناء الـ controller فقط عند تغيّر النسبة (دوران الشاشة/تغيّر العرض)
  /// مع الحفاظ على الشريحة الحالية.
  void _updatePageController(double fraction) {
    if (_spotlightViewportFraction == fraction) return;
    _spotlightViewportFraction = fraction;
    _spotlightController.dispose();
    _spotlightController =
        PageController(viewportFraction: fraction, initialPage: _spotlightIndex);
  }

  Widget _buildSpotlightPosts(List<ServiceCategory> services) {
    final visibleCount =
        _visiblePostsCount > services.length ? services.length : _visiblePostsCount;

    return LayoutBuilder(
      // ★ التجاوب: العرض المتاح فعلياً من الـ LayoutBuilder (لا MediaQuery)
      // + تمديد البطاقة لحواف الشاشة + حد أقصى على الشاشات العريضة.
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - widget.horizontalBleed * 2;
        final bleed = widget.horizontalBleed.clamp(0.0, available / 2);
        final screenWidth = available + bleed * 2;
        // الهاتف: يملأ العرض كله (فيس بوك). التابلت/العريض: عمود
        // بعرض مقروء ومتمركز.
        final postWidth =
            screenWidth > _kMaxPostWidth ? _kMaxPostWidth : screenWidth;

        return OverflowBox(
          alignment: Alignment.center,
          fit: OverflowBoxFit.deferToChild,
          minWidth: screenWidth,
          maxWidth: screenWidth,
          child: SizedBox(
            width: screenWidth,
            child: Column(
              // center ⇒ توسيط البطاقة على الشاشات العريضة (بلا أثر على الهاتف).
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: postWidth,
                  child: ListView.separated(
                    key: const ValueKey('posts'),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleCount,
                    separatorBuilder: (_, _) => Divider(
                      // ★ خلفية المنشور = خلفية التطبيق ⇒ الفاصل رفيع (وليس
                      // فجوة بلون مطابق) هو ما يفصل المنشورات كما في فيسبوك.
                      height: 1,
                      thickness: 1,
                      color: widget.isDark
                          ? AppColors.outline
                          : AppColors.lightOutline,
                    ),
                    itemBuilder: (context, i) => _spotlightPostItem(services[i]),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
            ),
          ),
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
      // ★ خلفية المنشور = خلفية التطبيق نفسها (لا surfaceCard/أبيض) ⇒ تندمج
      // البطاقة مع الصفحة من طرف لطرف كما في فيسبوك، والضوء البصري يأتي من
      // الصورة والفواصل فقط.
      color: widget.isDark ? AppColors.background : AppColors.lightBackground,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isDark ? AppColors.textPrimary : AppColors.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Greib · منذ ساعتين · ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                                fontSize: 12,
                              ),
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
          // نسبة عرض/ارتفاع ثابتة بدل ارتفاع ثابت ⇒ يتكيّف مع أي شاشة.
          _buildPostImage(imageUrl, serviceColor, service),

          // ─── 4. إحصائيات التفاعل ───
          // Flexible + قصّ النص ⇒ لا فيض على الشاشات الضيقة أو عند تكبير الخط.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _reactionChip(LucideIcons.thumbsUp, AppColors.info),
                      const SizedBox(width: 2),
                      _reactionChip(LucideIcons.heart, AppColors.error),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '٢٫١ ألف',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '٣٨ تعليق',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: widget.isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // فاصل علوي للأزرار (بعرض البطاقة كاملاً مثل فيسبوك)
          Divider(
            height: 1,
            color: widget.isDark ? AppColors.outline : AppColors.lightOutline,
          ),

          // ─── 5. أزرار الإجراءات (تفاعلات) ───
          // تملأ عرض البطاقة كاملاً (3 أزرار متساوية) بدون حشو جانبي.
          Row(
            children: [
              _fbActionButton(
                icon: LucideIcons.shoppingBag,
                label: 'طلب الآن',
                color: serviceColor,
                onTap: () => context.push(service.route),
              ),
              _fbActionButton(
                icon:
                    isFav ? LucideIcons.bookmarkCheck : LucideIcons.bookmarkPlus,
                // ★ أيقونة فقط (بلا كلمة): الإضافة للقائمة مفهومة من الرمز.
                label: null,
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
              _fbActionButton(
                icon: LucideIcons.share2,
                label: 'مشاركة',
                color: widget.isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// صورة المنشور بنسبة عرض/ارتفاع ثابتة (فيس بوك) ⇒ تتبع عرض البطاقة على
  /// أي شاشة، وتدعم روابط الشبكة ومسارات الأصول المحلية معاً.
  Widget _buildPostImage(
      String imageUrl, Color serviceColor, ServiceCategory service) {
    final isAsset = imageUrl.startsWith('assets/');

    return AspectRatio(
      aspectRatio: 1.5,
      child: isAsset
          ? Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _buildIconHero(serviceColor, service),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _buildIconHero(serviceColor, service),
            ),
    );
  }

  /// Hero Image: fallback لو فشل تحميل الصورة
  Widget _buildIconHero(Color serviceColor, ServiceCategory service) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // حجم الأيقونة نسبةً لعرض البطاقة ⇒ لا يفيض على الشاشات الضيقة.
          final badge = (constraints.maxWidth * 0.3).clamp(64.0, 120.0);
          return Center(
            child: Container(
              width: badge,
              height: badge,
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
                size: badge * 0.48,
              ),
            ),
          );
        },
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
            // حد بنفس لون خلفية المنشور (وإلا ظهرت حلقة فاتحة في الوضع الداكن).
            color: widget.isDark
                ? AppColors.background
                : AppColors.lightBackground,
            width: 1.5,
          ),
        ),
      child: Icon(icon, size: 11, color: Colors.white),
    );
  }

  /// زر إجراء يملأ ثلث عرض البطاقة (مثل فيسبوك) مع تصغير تلقائي للمحتوى
  /// بدل الفيض على الشاشات الضيقة. تمرير `label: null` ⇒ أيقونة فقط متمركزة.
  Widget _fbActionButton({
    required IconData icon,
    required String? label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                // لا مسافة/نص عند تجاوزها بأيقونة فقط.
                if (label != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
