import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/hotel_model.dart';

/// ============================================================================
///  قسم "الفنادق المختارة" — نفس فكرة قسم "المميز عندنا":
///  · يبدأ بوضع **المنشورات** (بوست واحد فقط).
///  · «عرض المزيد» يجلب منشوراً جديداً في كل ضغطة.
///  · زر التبديل ينقل بين المنشورات والشرائح (PageView بنقاط).
///  · المنشور والشرائح يتمددان لحواف الشاشة (OverflowBox) كما في "المميز".
/// ============================================================================
class HotelsSection extends StatefulWidget {
  final bool isDark;

  /// حشو الشاشة المستضيفية أفقياً (Home = 20) — يُستخدم لتمديد المنشور
  /// والشرائح لحواف الشاشة من داخل الحشو.
  final double horizontalBleed;

  const HotelsSection({
    super.key,
    required this.isDark,
    this.horizontalBleed = 20,
  });

  @override
  State<HotelsSection> createState() => _HotelsSectionState();
}

class _HotelsSectionState extends State<HotelsSection> {
  /// ★ نبدأ بوضع المنشورات، وب بوست واحد فقط؛ «عرض المزيد» يزيد واحداً.
  bool _isGridView = true;
  int _visiblePostsCount = 1;

  /// تفاعل كل منشور: 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  final Map<String, int> _reactions = {};

  /// الفنادق المحفوظة (زر الحفظ في رأس المنشور وفي الشريحة).
  final Set<String> _favoriteHotelIds = {};

  /// الشريحة الحالية في وضع الشرائح.
  int _slideIndex = 0;

  /// أقصى عرض لعمود القراءة (تابلت) — الهاتف يملأ العرض من طرف لطرف.
  static const double _kMaxPostWidth = 620;

  /// أقصى جزء من البطاقة يظهر من الشريحة التالية (لمحة عن الجار).
  static const double _kMaxPeek = 48;

  /// نسبة ارتفاع شريحة العرض إلى عرضها + سقف وحد أدنى.
  static const double _kCardHeightRatio = 0.68;
  static const double _kMinCardHeight = 190;
  static const double _kMaxCardHeight = 260;

  /// نسبة عرض الصفحة في الـ PageView (تُعاد حسابياً من العرض الفعلي).
  static const double _kDefaultViewportFraction = 0.84;
  PageController _slideController = PageController(
    viewportFraction: _kDefaultViewportFraction,
  );
  double? _slideViewportFraction = _kDefaultViewportFraction;

  /// لون الفنادق: ثابت بسياقه السياحي (يقرأ فوق الصور والنصوص).
  static const Color _hotelColor = AppColors.serviceTourism;

  /// اللون الرسمي المقروء حسب الوضع (للأزرار والنقاط).
  Color get _tint => AppColors.accentFor(widget.isDark);

  @override
  @override
  Widget build(BuildContext context) {
    final hotels = MockData.mockHotels;
    if (hotels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ★ AnimatedSwitcher لتبديل سلس بين المنشورات والشرائح. البطاقة
        // تتمدد خارج حشو الصفحة ⇒ نلغي القصّ ونحاذي للأعلى.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: <Widget>[...previousChildren, ?currentChild],
          ),
          child: _isGridView ? _buildPosts(hotels) : _buildSlides(hotels),
        ),
        // النقاط تظهر في وضع الشرائح فقط.
        if (!_isGridView) ...[
          const SizedBox(height: 10),
          // ★ FittedBox ⇒ تتقلّص النقاط تلقائياً بدل فيض الصف على الشاشات الضيقة.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(hotels.length, (i) {
                final active = i == _slideIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? _tint
                        : (widget.isDark
                              ? Colors.white24
                              : AppColors.lightOutline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
        const SizedBox(height: 8),
        // ★ صف زرّان بعرض كامل: «عرض المزيد» (بداية السطر/يمين) يظهر فقط عند
        // وجود منشورات مخفية، وزر التبديل (نهاية السطر/يسار) دائماً.
        LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width - widget.horizontalBleed * 2;
            final bleed = widget.horizontalBleed.clamp(0.0, available / 2);
            final fullWidth = available + bleed * 2;
            return OverflowBox(
              alignment: Alignment.center,
              fit: OverflowBoxFit.deferToChild,
              minWidth: fullWidth,
              maxWidth: fullWidth,
              child: SizedBox(
                width: fullWidth,
                child: Row(
                  children: [
                    if (_isGridView && _visiblePostsCount < hotels.length) ...[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 12,
                            end: 4,
                          ),
                          child: _softActionButton(
                            icon: LucideIcons.chevronDown,
                            label: 'عرض المزيد',
                            onPressed: () =>
                                setState(() => _visiblePostsCount++),
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 4,
                          end: 12,
                        ),
                        child: _softActionButton(
                          icon: _isGridView
                              ? LucideIcons.galleryHorizontal
                              : LucideIcons.layoutList,
                          label: _isGridView ? 'عرض الشرائح' : 'عرض كمنشورات',
                          onPressed: () =>
                              setState(() => _isGridView = !_isGridView),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================================================
  //  وضع المنشورات
  // ==========================================================================
  Widget _buildPosts(List<Hotel> hotels) {
    final visibleCount = _visiblePostsCount > hotels.length
        ? hotels.length
        : _visiblePostsCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - widget.horizontalBleed * 2;
        final bleed = widget.horizontalBleed.clamp(0.0, available / 2);
        final screenWidth = available + bleed * 2;
        // الهاتف: من طرف لطرف (فيس بوك). العريض: عمود مقروء متمركز.
        final postWidth = screenWidth > _kMaxPostWidth
            ? _kMaxPostWidth
            : screenWidth;

        return OverflowBox(
          alignment: Alignment.center,
          fit: OverflowBoxFit.deferToChild,
          minWidth: screenWidth,
          maxWidth: screenWidth,
          child: SizedBox(
            width: screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: postWidth,
                  child: Column(
                    key: const ValueKey('posts'),
                    children: List.generate(visibleCount, (i) {
                      return Column(
                        children: [
                          if (i > 0)
                            Divider(
                              // ★ خلفية المنشور = خلفية التطبيق ⇒ الفاصل الرفيع
                              // (لا فجوة ملوّنة) هو ما يفصل المنشورات.
                              height: 1,
                              thickness: 1,
                              color: widget.isDark
                                  ? AppColors.outline
                                  : AppColors.lightOutline,
                            ),
                          _postItem(hotels[i]),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// منشور واحد: رأس (الفندق) ← نص ← معرض صور ← شارات ← تفاعل ← إجراءات.
  Widget _postItem(Hotel hotel) {
    final reaction = _reactions[hotel.id] ?? 0;
    final isFav = _favoriteHotelIds.contains(hotel.id);

    return Container(
      // ★ خلفية المنشور = خلفية التطبيق نفسها (لا surfaceCard/أبيض).
      color: widget.isDark ? AppColors.background : AppColors.lightBackground,
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 1. رأس المنشور ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isDark
                              ? AppColors.textPrimary
                              : AppColors.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${hotel.location} · منذ ${_agoFor(hotel.id)} · ',
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
                // زر الحفظ في طرف الهيدر.
                InkWell(
                  onTap: () => _toggleFavorite(hotel.id),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Icon(
                      isFav
                          ? LucideIcons.bookmarkCheck
                          : LucideIcons.bookmarkPlus,
                      color: isFav
                          ? _hotelColor
                          : (widget.isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── 2. نص المنشور ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              hotel.postText,
              style: TextStyle(
                color: widget.isDark
                    ? AppColors.textPrimary
                    : AppColors.lightText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── 3. معرض الصور (نسبة ثابتة بدل ارتفاع ثابت) ───
          _imagesGallery(hotel),

          const SizedBox(height: 12),

          // ─── 4. التقييم والسعر والمرافق كشارات ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  icon: LucideIcons.star,
                  text: hotel.rating.toStringAsFixed(1),
                  color: AppColors.warning,
                ),
                _infoChip(
                  icon: LucideIcons.badgeDollarSign,
                  text: '${hotel.pricePerNight.toStringAsFixed(0)} درهم/ليلة',
                  color: _hotelColor,
                ),
                ...hotel.amenities
                    .take(3)
                    .map(
                      (a) => _infoChip(
                        icon: LucideIcons.check,
                        text: a,
                        color: AppColors.success,
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── 5. تفاعل المنشور (إعجاب / عدم إعجاب) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _reactionChip(LucideIcons.thumbsUp, AppColors.info, 1, hotel),
                const SizedBox(width: 2),
                _reactionChip(
                  LucideIcons.thumbsDown,
                  AppColors.error,
                  -1,
                  hotel,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: widget.isDark ? AppColors.outline : AppColors.lightOutline,
          ),

          // ─── 6. أزرار الإجراءات ───
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 12),
                // «احجز الآن» ثلث العرض، ومجموعة الأيقونات الباقي (⅔).
                Expanded(
                  flex: 1,
                  child: _fbActionButton(
                    icon: LucideIcons.bedDouble,
                    label: 'احجز الآن',
                    color: _hotelColor,
                    onTap: () => context.push('/tourism'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _fbActionButton(
                            grouped: true,
                            icon: reaction >= 0
                                ? LucideIcons.thumbsUp
                                : LucideIcons.thumbsDown,
                            label: null,
                            color: reaction == 0
                                ? (widget.isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary)
                                : (reaction > 0
                                      ? AppColors.info
                                      : AppColors.error),
                            count: reaction == 1 ? 129 : 128,
                            onTap: () => setState(() {
                              final current = _reactions[hotel.id] ?? 0;
                              _reactions[hotel.id] = current >= 0 ? 0 : 1;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _fbActionButton(
                            grouped: true,
                            icon: LucideIcons.messageCircle,
                            label: null,
                            color: widget.isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            count: 24,
                            onTap: () => _showCommentsSheet(hotel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _fbActionButton(
                            grouped: true,
                            icon: LucideIcons.repeat2,
                            label: null,
                            color: widget.isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            count: 11,
                            onTap: () => _showShareSheet(hotel),
                          ),
                        ),
                      ],
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

  // ==========================================================================
  //  وضع الشرائح
  // ==========================================================================
  Widget _buildSlides(List<Hotel> hotels) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - widget.horizontalBleed * 2;
        final bleed = widget.horizontalBleed.clamp(0.0, available / 2);
        final viewportWidth = available + bleed * 2;
        // الهاتف: 84% من العرض (مع لمحة عن التالي). العريض: عمود مقروء.
        final cardWidth = (viewportWidth * _kDefaultViewportFraction).clamp(
          0.0,
          _kMaxPostWidth,
        );
        final peek = (viewportWidth - cardWidth).clamp(0.0, _kMaxPeek);
        final height = (cardWidth * _kCardHeightRatio).clamp(
          _kMinCardHeight,
          _kMaxCardHeight,
        );
        // النسبة نسبةً لعرض الـ PageView نفسه لا لعرض الشاشة.
        final fraction = cardWidth / (cardWidth + peek);

        _updateSlideController(fraction);

        return OverflowBox(
          alignment: Alignment.center,
          fit: OverflowBoxFit.deferToChild,
          minWidth: viewportWidth,
          maxWidth: viewportWidth,
          child: SizedBox(
            key: const ValueKey('slides'),
            width: viewportWidth,
            height: height,
            child: Center(
              child: SizedBox(
                width: cardWidth + peek,
                child: PageView.builder(
                  controller: _slideController,
                  itemCount: hotels.length,
                  onPageChanged: (i) => setState(() => _slideIndex = i),
                  itemBuilder: (context, i) => AnimatedScale(
                    scale: i == _slideIndex ? 1.0 : 0.93,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: i == _slideIndex ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 220),
                      child: _slideItem(hotels[i]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// شريحة واحدة: صورة + تدرّج + السعر + الاسم/الموقع/التقييم + زر الحفظ.
  Widget _slideItem(Hotel hotel) {
    final isFav = _favoriteHotelIds.contains(hotel.id);
    return GestureDetector(
      onTap: () => context.push('/tourism'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.isDark ? Colors.black38 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                hotel.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallbackArt(),
              ),
              // تدرّج سفلي لإبراز النص.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),
              // شارة السعر.
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _hotelColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${hotel.pricePerNight.toStringAsFixed(0)} درهم/ليلة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // زر الحفظ.
              Positioned(
                top: 10,
                left: 10,
                child: InkWell(
                  onTap: () => _toggleFavorite(hotel.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav
                          ? LucideIcons.bookmarkCheck
                          : LucideIcons.bookmarkPlus,
                      size: 16,
                      color: isFav ? _hotelColor : Colors.white,
                    ),
                  ),
                ),
              ),
              // الاسم + الموقع + التقييم.
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          LucideIcons.star,
                          color: AppColors.warning,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }

  // ==========================================================================
  //  عناصر مشتركة
  // ==========================================================================

  /// صورة الحساب: أيقونة الفندق داخل دائرة بلون القسم.
  Widget _avatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _hotelColor.withValues(alpha: 0.15),
        border: Border.all(color: _hotelColor.withValues(alpha: 0.3), width: 1),
      ),
      child: const Icon(LucideIcons.hotel, color: _hotelColor, size: 20),
    );
  }

  /// بديل أنيق بدل مساحة فارغة عند تعذّر تحميل الصورة.
  Widget _fallbackArt() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _hotelColor.withValues(alpha: 0.45),
            AppColors.accentPrimaryDark,
          ],
        ),
      ),
      child: const Center(
        child: Icon(LucideIcons.hotel, size: 32, color: Colors.white54),
      ),
    );
  }

  /// صورة واحدة بنسبة ثابتة، أو صورتان/ثلاث بتخطيط فايس بوك.
  Widget _imagesGallery(Hotel hotel) {
    final images = hotel.postImages;
    if (images.length == 1) {
      return GestureDetector(
        onTap: () => _openImagePreview(hotel, images),
        child: AspectRatio(aspectRatio: 1.5, child: _imageTile(images.first)),
      );
    }
    return GestureDetector(
      onTap: () => _openImagePreview(hotel, images),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Row(
          children: [
            Expanded(flex: 3, child: _imageTile(images[0])),
            const SizedBox(width: 2),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _imageTile(images[1])),
                  if (images.length > 2) ...[
                    const SizedBox(height: 2),
                    Expanded(child: _imageTile(images[2])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackArt(),
    );
  }

  /// شارة صغيرة (تقييم / سعر / مرفق).
  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: widget.isDark
                  ? AppColors.textPrimary
                  : AppColors.lightText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// تفاعل المنشور: بلا ← إعجاب/عدم إعجاب ← ضغط ← بلا.
  Widget _reactionChip(IconData icon, Color color, int value, Hotel hotel) {
    final active = (_reactions[hotel.id] ?? 0) == value;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() {
        final current = _reactions[hotel.id] ?? 0;
        _reactions[hotel.id] = current == value ? 0 : value;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Icon(
          icon,
          size: 18,
          color: active
              ? color
              : (widget.isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary),
        ),
      ),
    );
  }

  /// زر إجراء بنمط فايس بوك: «احجز الآن» بعلامة + مجموعة أيقونات بخلفيات.
  Widget _fbActionButton({
    required IconData icon,
    required String? label,
    required Color color,
    VoidCallback? onTap,
    int? count,
    bool grouped = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: grouped ? 18 : 16, color: color),
        if (label != null) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (count != null) ...[
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: widget.isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return Material(
      color: grouped
          ? (widget.isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.04))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Center(child: content),
        ),
      ),
    );
  }

  /// زر «ناعم» موحّد الشكل لزرّي أسفل القسم.
  Widget _softActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: _tint.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        alignment: Alignment.center,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: _tint),
      label: Text(
        label,
        style: TextStyle(
          color: _tint,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// تبديل حفظ الفندق (يُستدعى من المنشور والشريحة).
  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteHotelIds.contains(id)) {
        _favoriteHotelIds.remove(id);
      } else {
        _favoriteHotelIds.add(id);
      }
    });
  }

  /// إعادة بناء الـ controller فقط عند تغيّر النسبة (دوران الشاشة) مع
  /// الحفاظ على الشريحة الحالية.
  void _updateSlideController(double fraction) {
    if (_slideViewportFraction == fraction) return;
    _slideViewportFraction = fraction;
    _slideController.dispose();
    _slideController = PageController(
      viewportFraction: fraction,
      initialPage: _slideIndex,
    );
  }

  /// نصّ زمان ثابت لكل منشور (مشتق من الـ id ⇒ لا يتغيّر بين البناءات).
  String _agoFor(String id) {
    const options = ['ساعة', 'ساعتين', '3 ساعات', '5 ساعات', 'يوم'];
    final sum = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return options[sum % options.length];
  }

  /// معاينة كاملة لصور المنشور.
  void _openImagePreview(Hotel hotel, List<String> images) {
    final initial = images.indexOf(hotel.imageUrl).clamp(0, images.length - 1);
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => _HotelImagePreview(
          images: images,
          initialIndex: initial,
          title: hotel.name,
        ),
      ),
    );
  }

  /// ورقة المشاركة.
  void _showShareSheet(Hotel hotel) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مشاركة ${hotel.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'سيظهر رابط الفندق «${hotel.name}» في منشورك.',
                textAlign: TextAlign.center,
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
      ),
    );
  }

  /// ورقة التعليقات (تعليقات وهمية لكل منشور).
  void _showCommentsSheet(Hotel hotel) {
    const mockComments = [
      ('سارة', 'فندق رائع، الإطلالة تستحق السعر.'),
      ('خالد', 'هل يوجد إفطار مشمول؟'),
      ('منى', 'حجزت العام الماضي وكنت راضية جداً.'),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'التعليقات · ${hotel.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: mockComments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final comment = mockComments[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _hotelColor.withValues(alpha: 0.2),
                        child: Text(
                          comment.$1[0],
                          style: const TextStyle(
                            color: AppColors.onBrand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comment.$2,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// معاينة صور المنشور بملء الشاشة (PageView + عدّاد + تكبير).
class _HotelImagePreview extends StatefulWidget {
  const _HotelImagePreview({
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  final List<String> images;
  final int initialIndex;
  final String title;

  @override
  State<_HotelImagePreview> createState() => _HotelImagePreviewState();
}

class _HotelImagePreviewState extends State<_HotelImagePreview> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              child: Image.network(
                widget.images[i],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    LucideIcons.imageOff,
                    color: Colors.white24,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_index + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
