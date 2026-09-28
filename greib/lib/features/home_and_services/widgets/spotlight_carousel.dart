import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/service_model.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../communication_and_support/chat_screen.dart';
import 'package:flutter/gestures.dart' show Drag;

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

/// تعليق واحد داخل ورقة التعليقات (وهمية أو يكتبها المستخدم).
class _PostComment {
  const _PostComment(this.author, this.text, {this.mine = false});

  final String author;
  final String text;

  /// تعليق المستخدم الحالي ⇒ يُعرض بلون مختلف (فقاعة بلون أنعم).
  final bool mine;
}

class _SpotlightSectionState extends State<SpotlightSection> {
  /// نسبة عرض الصفحة في الـ PageView تُحسب من العرض المتاح فعلياً (ليست ثابتة)،
  /// لذلك نحتفظ بالقيمة الحالية لإعادة بناء الـ controller عند تغيّر حجم الشاشة.
  static const double _kDefaultViewportFraction = 0.84;

  PageController _spotlightController = PageController(
    viewportFraction: _kDefaultViewportFraction,
  );
  double? _spotlightViewportFraction = _kDefaultViewportFraction;
  int _spotlightIndex = 0;
  final Set<String> _favoriteServiceIds = {};

  /// تفاعل المنشور لكل خدمة: 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  /// دورة الضغط: بلا ← إعجاب ← عدم إعجاب ← بلا.
  final Map<String, int> _reactions = {};

  /// تعليقات كل منشور (بيانات وهمية + ما يكتبه المستخدم داخل الورقة).
  final Map<String, List<_PostComment>> _comments = {};
  /// ★ نبدأ بوضع المنشورات، وب بوست واحد فقط؛ «عرض المزيد» يزيد واحداً كل ضغطة.
  bool _isGridView = true;
  int _visiblePostsCount = 1;

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
        // ★ في وضع المنشورات نقترب من أزرار التفاعل أسفل آخر منشور.
        SizedBox(height: _isGridView ? 0 : 10),
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
                final neonColor = widget.isDark
                    ? AppColors.neon
                    : AppColors.accentPrimaryDark;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? neonColor
                        : (widget.isDark
                              ? Colors.white24
                              : AppColors.lightOutline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 8),
        // ★ زرّان يملآن العرض أفقياً (Expanded لكل منهما ⇒ نصف العرض لكل زر)
        // على طرفي السطر: «عرض المزيد» في زاوية اليمين (بداية السطر في الاتجاه
        // من اليمين) وبزر التبديل في الزاوية الأخرى، والثاني يظهر فقط في وضع
        // المنشورات عند وجود منشورات مخفية. الصف يتمدّد لحواف الشاشة (مثل
        // البطاقة تماماً) ليبقى بنفس عرض المنشور ويزداد العرض الأفقي.
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
                    if (_isGridView && _visiblePostsCount < services.length) ...[
                      Expanded(
                        child: Padding(
                          // ★ الزر ينحصر داخل نصفه (بلا ملامسة حواف البطاقة)
                          // حتى لا تتداخل زواياه المدوّرة مع عناصر الجوار.
                          padding: const EdgeInsetsDirectional.only(
                            start: 0,
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
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: _softActionButton(
                          icon: _isGridView
                              ? LucideIcons.galleryHorizontal
                              : LucideIcons.layoutList,
                          // ★ تسمية مميزة لا تتكرر مع بقية أزرار الصفحة + أيقونة تشرح الناتج.
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

  /// زر «ناعم» موحّد الشكل (خلفية شفافة + زوايا دائرية) لزرّي أسفل المنشورات.
  Widget _softActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final tint = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: tint.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        // ★ الزر يملأ عرضه ⇒ توسيط المحتوى داخله.
        alignment: Alignment.center,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: tint),
      label: Text(
        label,
        style: TextStyle(
          color: tint,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// «طلب الآن» ⇒ محادثة مباشرة مع مقدّم الخدمة (لا الصفحة التعريفية)،
  /// ومعها معاينة المنشور (صورته + تفاصيله) كمرفق بانتظار إرسال المستخدم.
  void _openServiceChat(ServiceCategory service) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          conversationTitle: service.title,
          conversationId: 'service_${service.id}',
          avatar: service.iconName,
          phone: '',
          online: true,
          activity: 'متصل الآن',
          isGroup: false,
          postPreview: ChatPostPreview(
            title: service.title,
            subtitle: service.subtitle,
            imageUrl: service.imageUrl,
            color: service.color,
          ),
        ),
      ),
    );
  }

  /// أقصى عرض لبطاقة المنشور/الشريحة: على الهاتف تملأ الشاشة من طرف لطرف
  /// (فيس بوك)، وعلى التابلت/الشاشات العريضة يبقى العمود بعرض مقروء ومتمركز.
  static const double _kMaxPostWidth = 620;

  /// أقصى جزء من البطاقة يظهر من الشريحة التالية (فيس بوك: لمحة عن الجار).
  static const double _kMaxPeek = 48;

  /// نصف قطر «كامل» (rounded-full) لخلفيات الأزرار الكبسولية.
  static const double _kPillRadius = 999;

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
        final cardWidth = (viewportWidth * _kDefaultViewportFraction).clamp(
          0.0,
          _kMaxPostWidth,
        );
        final peek = (viewportWidth - cardWidth).clamp(0.0, _kMaxPeek);
        final height = (cardWidth * _kCardHeightRatio).clamp(
          _kMinCardHeight,
          _kMaxCardHeight,
        );
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
    _spotlightController = PageController(
      viewportFraction: fraction,
      initialPage: _spotlightIndex,
    );
  }

  Widget _buildSpotlightPosts(List<ServiceCategory> services) {
    final visibleCount = _visiblePostsCount > services.length
        ? services.length
        : _visiblePostsCount;

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
                    itemBuilder: (context, i) =>
                        _spotlightPostItem(services[i]),
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
    final reaction = _reactions[service.id] ?? 0;

    // صورة افتراضية للخدمات التي ليس لها صورة
    final String imageUrl =
        service.imageUrl ??
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
                // ★ الإضافة للقائمة: الزر الوحيد في طرف الهيدر (مكان ⋯ سابقاً).
                InkWell(
                  onTap: () => setState(() {
                    if (isFav) {
                      _favoriteServiceIds.remove(service.id);
                    } else {
                      _favoriteServiceIds.add(service.id);
                    }
                  }),
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
                          ? serviceColor
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

          // ─── 2. نص المنشور (Post Text) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              service.subtitle, // مثل: My view (من مطعمك المفضل)
              style: TextStyle(
                color: widget.isDark
                    ? AppColors.textPrimary
                    : AppColors.lightText,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── 3. صورة المنشور (Edge-to-Edge) ───
          // نسبة عرض/ارتفاع ثابتة بدل ارتفاع ثابت ⇒ يتكيّف مع أي شاشة.
          _buildPostImagesGallery(imageUrl, serviceColor, service),

          // ─── 4. أيقونات التفاعل (بلا أعداد) ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _reactionChip(LucideIcons.thumbsUp, AppColors.info),
                const SizedBox(width: 2),
                _reactionChip(LucideIcons.thumbsDown, AppColors.error),
              ],
            ),
          ),

          // فاصل علوي للأزرار (بعرض البطاقة كاملاً مثل فيسبوك)
          Divider(
            height: 1,
            color: widget.isDark ? AppColors.outline : AppColors.lightOutline,
          ),

          // ─── 5. أزرار الإجراءات (تفاعلات) ───
          // «طلب الآن» يأخذ ثلث عرض البطاقة (ملتصق بالزاوية)، والمجموعة الثلاث
          // تأخذ الباقي (⅔) ⇒ أيقونات أكبر ومنطقة لمس مريحة بلا تصغير.
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _fbActionButton(
                  icon: LucideIcons.shoppingBag,
                  label: 'طلب الآن',
                  color: serviceColor,
                  onTap: () => _openServiceChat(service),
                ),
              ),
              // ★ مسافة فاصلة واسعة قبل مجموعة الأيقونات.
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Padding(
                  // ★ مسافة صغيرة من زاوية النهاية حتى لا تلتصق المجموعة بالحافة.
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Row(
                    children: [
                      // ★ تفاعل المنشور: إعجاب ← ضغط ← عدم إعجاب ← ضغط ← بلا.
                      // كل خلية Expanded ⇒ توزيع متساوٍ وخلفيات متماثلة.
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
                          count: _countFor(service.id, 80, 10),
                          onTap: () => _showPostActionSheet(
                            // ★ بلا أيقونة: الجملة وحدها في رأس الورقة.
                            title: 'تفاعل المنشور',
                            draggable: true,
                            options: (sheetContext) => [
                              // StatefulBuilder ⇒ الزرّان والأعداد تتحدّث فوراً
                              // داخل الورقة عند تغيير تفاعل المستخدم.
                              StatefulBuilder(
                                builder: (context, setSheetState) {
                                  final current = _reactions[service.id] ?? 0;
                                  final idle = widget.isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary;
                                  final likeCount =
                                      _kMockLikedUsers.length +
                                      (current == 1 ? 1 : 0);
                                  final dislikeCount =
                                      _kMockDislikedUsers.length +
                                      (current == -1 ? 1 : 0);

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // زرّان: إعجاب / عدم إعجاب.
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _fbActionButton(
                                              grouped: true,
                                              icon: LucideIcons.thumbsUp,
                                              label: 'إعجاب',
                                              color: current == 1
                                                  ? AppColors.info
                                                  : idle,
                                              onTap: () => setSheetState(() {
                                                _reactions[service.id] = 1;
                                                setState(() {});
                                              }),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _fbActionButton(
                                              grouped: true,
                                              icon: LucideIcons.thumbsDown,
                                              label: 'عدم إعجاب',
                                              color: current == -1
                                                  ? AppColors.error
                                                  : idle,
                                              onTap: () => setSheetState(() {
                                                _reactions[service.id] = -1;
                                                setState(() {});
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      // ★ تبويب يحمل الأعداد: كم إعجاب وكم
                                      // عدم إعجاب (يتبع تفاعل المستخدم).
                                      SizedBox(
                                        height: 240,
                                        child: DefaultTabController(
                                          length: 2,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TabBar(
                                                labelColor: AppColors.info,
                                                unselectedLabelColor: idle,
                                                indicatorColor: AppColors.info,
                                                indicatorSize:
                                                    TabBarIndicatorSize.tab,
                                                dividerColor: widget.isDark
                                                    ? AppColors.outline
                                                    : AppColors.lightOutline,
                                                labelStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                tabs: [
                                                  Tab(
                                                    text: 'إعجاب ($likeCount)',
                                                  ),
                                                  Tab(
                                                    text:
                                                        'عدم إعجاب ($dislikeCount)',
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: TabBarView(
                                                  children: [
                                                    _reactionUsersList(
                                                      _kMockLikedUsers,
                                                      LucideIcons.thumbsUp,
                                                      AppColors.info,
                                                    ),
                                                    _reactionUsersList(
                                                      _kMockDislikedUsers,
                                                      LucideIcons.thumbsDown,
                                                      AppColors.error,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _fbActionButton(
                          grouped: true,
                          // ★ أيقونة فقط (بلا كلمة): المحادثة مفهومة من الرمز.
                          icon: LucideIcons.messageCircle,
                          label: null,
                          color: widget.isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                          count: _countFor(service.id, 40, 2),
                          onTap: () => _showCommentsSheet(service),
                        ),
                      ),
                      Expanded(
                        child: _fbActionButton(
                          grouped: true,
                          // ★ أيقونة فقط (بلا كلمة): المشاركة مفهومة من الرمز.
                          icon: LucideIcons.repeat2,
                          label: null,
                          color: widget.isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                          count: _countFor(service.id, 20, 1),
                          onTap: () => _showPostActionSheet(
                            icon: LucideIcons.repeat2,
                            title: 'إعادة النشر',
                            hint: 'نشر رابط «${service.title}» على صفحتك.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// عدد ثابت مشتق من معرّف الخدمة ⇒ يبقى رقماً إنجليزياً (40، 128) بجانب كل
  /// أيقونة، ومستقر بين إعادة البناءات (بلا عشوائية تتغيّر كل إطار).
  static String _countFor(String id, int span, int min) =>
      (min + id.hashCode.abs() % span).toString();

  /// ★ ورقة التعليقات: Widget حالة مستقل يملك `TextEditingController` بنفسه
  /// (تحريره في `dispose` لا يدوياً ⇒ لا «استخدام بعد التحرير» عند الإغلاق)،
  /// وارتفاعها `maxHeight` لا ثابت ⇒ لا فيض عند فتح لوحة المفاتيح.
  void _showCommentsSheet(ServiceCategory service) {
    // قائمة قابلة للتوسيع (ليست const) حتى يضيف المستخدم تعليقاته.
    final list = _comments.putIfAbsent(
      service.id,
      () => [
        const _PostComment('سارة', 'الخدمة ممتازة وسرعة التنفيذ رهيبة.'),
        const _PostComment('محمد', 'جرّبتها أمس وأنصح فيها بشدة.'),
        const _PostComment('ريم', 'هل يوجد خصم للمتابعة الشهرية؟'),
      ],
    );

    showAppSheet<void>(
      context,
      builder: (_) => _CommentsSheet(
        service: service,
        isDark: widget.isDark,
        comments: list,
      ),
    );
  }

  /// ★ ورقة سفلية موحّدة (`showAppSheet`) تظهر عند ضغط أيقونة من أزرار
  /// إجراءات المنشور. `draggable: true` ⇒ ورقة ديناميكية: سحب للأعلى للتكبير
  /// (مع Snap عند مواضع محددة) وسحب للأسفل للإغلاق.
  void _showPostActionSheet({
    IconData? icon,
    required String title,
    String? hint,
    List<Widget> Function(BuildContext sheetContext)? options,
    bool draggable = false,
  }) {
    final secondary = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    showAppSheet<void>(
      context,
      scrollControlled: draggable,
      builder: (sheetContext) {
        // رأس الورقة (أيقونة اختيارية + جملة + تلميح) — مشترك بين النمطين.
        final header = <Widget>[
          // ★ الأيقونة اختيارية: ورقة التفاعل تعرض الجملة فقط.
          if (icon != null) ...[
            Icon(icon, size: 18, color: secondary),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(hint, style: TextStyle(color: secondary, fontSize: 13)),
          ],
        ];

        // نمط ديناميكي: الورقة تتبع إصبع السحب وتتمدد/تنكمش.
        if (draggable) {
          return _DraggableSheetBody(
            // ★ مواضع Snap متقاربة ⇒ أي مسافة سحب تقفز لأقرب موضع بدل
            // الرجوع للوضع الابتدائي (ما كان يوهم بأن التوسيع لا يعمل).
            initialExtent: 0.5,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                ...header,
                if (options != null) ...[
                  const SizedBox(height: 8),
                  ...options(sheetContext),
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...header,
              if (options != null) ...[
                const SizedBox(height: 8),
                ...options(sheetContext),
              ],
            ],
          ),
        );
      },
    );
  }

  /// أسماء مستخدمين وهميين (كما يعرض فيسبوك من تفاعلوا مع المنشور).
  static const List<String> _kMockLikedUsers = [
    'سارة',
    'محمد',
    'ريم',
    'خالد',
    'نور',
    'يوسف',
  ];

  static const List<String> _kMockDislikedUsers = ['ليان', 'عمر', 'هدى', 'فهد'];

  /// قائمة مستخدمين داخل التبويب: صورة رمزية (أول حرف) + الاسم + أيقونة
  /// التفاعل بجانبه (إعجاب أو عدم إعجاب) بنفس لون التبويب.
  Widget _reactionUsersList(
    List<String> names,
    IconData reactionIcon,
    Color reactionColor,
  ) {
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: names.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final name = names[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reactionColor.withValues(alpha: 0.15),
                ),
                child: Text(
                  name.characters.first,
                  style: TextStyle(
                    color: reactionColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: primary, fontSize: 14),
                ),
              ),
              // أيقونة التفاعل بجانب الاسم.
              Icon(reactionIcon, size: 16, color: reactionColor),
            ],
          ),
        );
      },
    );
  }

  /// ★ صور البطاقة: كل ما هو مرفق بها (`imageUrls`) أو الصورة الأساسية.
  List<String> _postImages(ServiceCategory service, String fallback) {
    final extra = service.imageUrls
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (extra.isEmpty) return [fallback];
    return [service.imageUrl ?? fallback, ...extra];
  }

  /// صورة واحدة (شبكة أو أصل) مع بديل أيقونة عند فشل التحميل.
  Widget _postImageTile(
    String url,
    Color serviceColor,
    ServiceCategory service, {
    BoxFit fit = BoxFit.cover,
  }) {
    return url.startsWith('assets/')
        ? Image.asset(
            url,
            fit: fit,
            errorBuilder: (_, _, _) => _buildIconHero(serviceColor, service),
          )
        : Image.network(
            url,
            fit: fit,
            errorBuilder: (_, _, _) => _buildIconHero(serviceColor, service),
          );
  }

  /// معرض صور المنشور: صورة واحدة بنسبة ثابتة، أو صورتان جنباً إلى جنب
  /// (فيس بوك)، وكلها تفتح معاينة كاملة عند الضغط.
  Widget _buildPostImagesGallery(
    String imageUrl,
    Color serviceColor,
    ServiceCategory service,
  ) {
    final images = _postImages(service, imageUrl);

    void openPreview() => _openImagePreview(images, service: service);

    if (images.length == 1) {
      return InkWell(
        onTap: openPreview,
        child: AspectRatio(
          aspectRatio: 1.5,
          child: _postImageTile(images.first, serviceColor, service),
        ),
      );
    }

    // صورتان+: شبكة بصفّين ⇒ مساحة كبيرة لكل صورة.
    return InkWell(
      onTap: openPreview,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _postImageTile(images[0], serviceColor, service),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: _postImageTile(
                      images.length > 1 ? images[1] : images.first,
                      serviceColor,
                      service,
                    ),
                  ),
                  if (images.length > 2) ...[
                    const SizedBox(height: 2),
                    Expanded(
                      child: _postImageTile(images[2], serviceColor, service),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ★ معاينة كاملة للصور: شاشة سوداء + PageView (سحب بين الصور) + عدّاد
  /// وزر إغلاق + تكبير/تصغير بالمزدوج.
  void _openImagePreview(
    List<String> images, {
    required ServiceCategory service,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'معاينة الصور',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (_, _, _) =>
          _ImagePreviewDialog(images: images, service: service),
      transitionBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
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

  /// زر إجراء يملأ ربع عرض البطاقة (مثل فيسبوك) مع تصغير تلقائي للمحتوى
  /// بدل الفيض على الشاشات الضيقة. تمرير `label: null` ⇒ أيقونة فقط متمركزة،
  /// و`count` ⇒ رقم بجانبها (أرقام لاتينية مثل 40). الخلفية «كبسولة» (pill)
  /// تغطي الأيقونة والرقم/الكلمة معاً. `grouped: true` ⇒ مقاس أكبر (منطقة لمس
  /// مريحة) بلا محاذاة زاوية؛ والزر المنفرد يلتصق بزاوية البطاقة (start)
  /// بدل التوسيط.
  Widget _fbActionButton({
    required IconData icon,
    required String? label,
    required Color color,
    required VoidCallback onTap,
    String? count,
    bool grouped = false,
  }) {
    // ★ المجموعة الثلاث أكبر قليلاً ⇒ منطقة لمس مريحة (≈52px ارتفاع).
    final iconSize = grouped ? 20.0 : 18.0;
    // ★ توسيع أفقي للخلفية فقط (الأيقونة/الرقم بلا تغيير) ⇒ مظهر أنيق ومتوازن.
    final pillHPad = grouped ? 22.0 : 18.0;
    final pillVPad = grouped ? 8.0 : 7.0;
    final countSize = grouped ? 12.5 : 12.0;

    final pill = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        // ★ كل زر يملأ الخلية بالتساوي (توسيع أفقي للخلفية فقط) ⇒ خلفيات
        // متماثلة الأبعاد، والمسافات بينها متساوية بلا فواصل يدوية.
        padding: EdgeInsets.symmetric(vertical: grouped ? 9 : 8),
        child: Align(
          alignment: grouped
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          // ★ الخلفية تملأ الخلية بالتساوي في المجموعة ⇒ أزرار متساوية الأبعاد
          // ومتناظرة، بينما يبقى زر «طلب الآن» ملتصقاً بعرض محتواه.
          child: Container(
            width: grouped ? double.infinity : null,
            // خلفية موحّدة تغطي الأيقونة والرقم/الكلمة ⇒ rounded-full.
            padding: EdgeInsets.symmetric(
              horizontal: pillHPad,
              vertical: pillVPad,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(_kPillRadius),
            ),
            child: FittedBox(
              // ★ تصغير المحتوى عند ضيق الشاشة بدل فيض الخلفية.
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: color),
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
                  if (count != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      count,
                      maxLines: 1,
                      style: TextStyle(
                        // الرقم أخف من الكلمة ⇒ لا يزاحم الأيقونة.
                        color: color.withValues(alpha: 0.75),
                        fontSize: countSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return pill;
  }

  Widget _spotlightItem(ServiceCategory service) {
    final neonColor = widget.isDark
        ? AppColors.neon
        : AppColors.accentPrimaryDark;
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
                color: widget.isDark
                    ? AppColors.textPrimary
                    : AppColors.lightText,
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
                      : (widget.isDark
                            ? Colors.white70
                            : AppColors.lightTextSecondary),
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

/// ============================================================================
///  ورقة التعليقات (Bottom Sheet): قائمة تعليقات + حقل إضافة.
///  Widget حالة مستقل: يملك الـ controller ويحرّره في dispose، وارتفاعه
///  maxHeight (لا ثابت) ⇒ يتقلّص مع لوحة المفاتيح بدل الفيض، ويختفي نظيفاً
///  عند الإغلاق (بلا «استخدام بعد التحرير» ولا شريط تحذير في Debug).
/// ============================================================================
class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.service,
    required this.isDark,
    required this.comments,
  });

  final ServiceCategory service;
  final bool isDark;
  final List<_PostComment> comments;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => widget.comments.add(_PostComment('أنت', text, mine: true)));
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.service.color;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;
    final secondary = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final line = widget.isDark ? AppColors.outline : AppColors.lightOutline;

    // ★ ورقة ديناميكية: السحب للأعلى يكشف المزيد، وللأسفل يغلقها، مع Snap.
    return _DraggableSheetBody(
      initialExtent: 0.6,
      snapSizes: const [0.35, 0.45, 0.55, 0.6, 0.7, 0.8, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        // ★ stretch ⇒ الرأس والفواصل تأخذ عرض الورقة كله (منطقة سحب كاملة).
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ★ الرأس منطقة سحب أيضاً: للأعلى توسّع الورقة، ولأسفل تصغيرها.
          _SheetDragArea(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Icon(LucideIcons.messagesSquare, size: 18, color: secondary),
                  const SizedBox(width: 8),
                  Text(
                    'التعليقات (${widget.comments.length})',
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: line),
          // ★ القائمة مرتبطة بـ ScrollController الخاص بالورقة ⇒ السحب داخلها
          // يمرّرها أولاً، وبعد نهايتها يوسّع/يصغّر الورقة.
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _commentRow(widget.comments[i]),
            ),
          ),
          Divider(height: 1, color: line),
          // حقل التعليق + زر الإرسال (ثابت أسفل الورقة لا يمرّر).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: primary, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'اكتب تعليقاً…',
                      hintStyle: TextStyle(color: secondary, fontSize: 13),
                      filled: true,
                      fillColor: widget.isDark
                          ? AppColors.surface
                          : AppColors.lightBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _submit,
                  icon: Icon(LucideIcons.send, size: 20, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// صف تعليق واحد (صورة رمزية + فقاعة نص).
  Widget _commentRow(_PostComment c) {
    final accent = widget.service.color;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.15),
          ),
          child: Icon(LucideIcons.user, size: 16, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.mine
                  ? accent.withValues(alpha: 0.12)
                  : (widget.isDark ? AppColors.surfaceCard : Colors.white),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.author,
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(c.text, style: TextStyle(color: primary, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
///  جسم ورقة سفلية ديناميكي (Draggable): ارتفاعه نسبة من الشاشة ويتغيّر مع
///  السحب — للأعلى تكبير (حتى 92%) مع Snap عند مواضع محددة، وللأسفل تصغير
///  حتى الإغلاق. `builder` يستلم `ScrollController` الخاص بالورقة لربطه
///  بالقائمة الداخلية فتمرّر قائمة التعليقات نفسها.
/// ============================================================================
class _DraggableSheetBody extends StatelessWidget {
  const _DraggableSheetBody({
    required this.builder,
    this.initialExtent = 0.5,
    this.snapSizes = const [0.32, 0.42, 0.5, 0.6, 0.7, 0.8, 0.92],
  });

  final Widget Function(BuildContext context, ScrollController controller)
  builder;
  final double initialExtent;
  final List<double> snapSizes;

  static const double _kMinExtent = 0.32;
  static const double _kMaxExtent = 0.92;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialExtent,
      minChildSize: _kMinExtent,
      maxChildSize: _kMaxExtent,
      // ★ Snap: يتوقف عند المواضع المحددة (تجربة احترافية) بدل التوقف العشوائي.
      snap: true,
      snapSizes: snapSizes,
      builder: (context, controller) => builder(context, controller),
    );
  }
}

/// ============================================================================
///  منطقة سحب داخل الورقة (مثل رأسها): تنشئ نشاط سحب حقيقي
///  (`ScrollPosition.drag`) على نفس `ScrollController` الخاص بـ
///  `DraggableScrollableSheet`، فيصبح السحب للأعلى توسّعاً ولأسفل
///  تصغيراً/إغلاقاً — تماماً كالسحب على القوائم نفسها.
/// ============================================================================
class _SheetDragArea extends StatefulWidget {
  const _SheetDragArea({required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  State<_SheetDragArea> createState() => _SheetDragAreaState();
}

class _SheetDragAreaState extends State<_SheetDragArea> {
  Drag? _drag;

  @override
  void dispose() {
    _drag?.cancel();
    _drag = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ★ عرض كامل ⇒ منطقة السحب تغطي كل عرض الرأس (وليس النص في المنتصف فقط).
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onVerticalDragStart: (details) {
          // ★ نشاط سحب رسمي للإطار ⇒ لا تحذيرات عند إعادة توجيه السحب،
          // والـ Snap/animation يعملان كما لو سحبت القائمة نفسها.
          _drag = widget.controller.position.drag(details, () => _drag = null);
        },
        onVerticalDragUpdate: (details) {
          _drag?.update(
            DragUpdateDetails(
              delta: Offset(0, details.delta.dy),
              primaryDelta: details.delta.dy,
              globalPosition: details.globalPosition,
              sourceTimeStamp: details.sourceTimeStamp,
            ),
          );
        },
        onVerticalDragEnd: (details) {
          // إنهاء السحب ⇒ إطلاق الـ Snap على أقرب موضع.
          _drag?.end(details);
          _drag = null;
        },
        onVerticalDragCancel: () {
          _drag?.cancel();
          _drag = null;
        },
        child: widget.child,
      ),
    );
  }
}

/// ============================================================================
///  معاينة صور البطاقة: شاشة كاملة سوداء مع PageView للتنقل بين الصور،
///  عدّاد «2/3»، زر إغلاق، وتكبير/تصغير بالمزدوج (InteractiveViewer).
///  تدعم روابط الشبكة ومسارات الأصول المحلية معاً (مع بديل أيقونة).
/// ============================================================================
class _ImagePreviewDialog extends StatefulWidget {
  const _ImagePreviewDialog({required this.images, required this.service});

  final List<String> images;
  final ServiceCategory service;

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog>
    with SingleTickerProviderStateMixin {
  late final PageController _page = PageController(initialPage: 0);
  late int _index = 0;

  // ★ التكبير/التصغير: قرص الإصبعين (pinch) + زر تكبير/تصغير، بتكبير
  // *متحرّك* حول مركز الشاشة (لا قفز من الزاوية) وبانتقال أنيميشن ناعم.
  final TransformationController _zoom = TransformationController();
  late final AnimationController _zoomAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  Animation<Matrix4>? _zoomTween;
  bool _zoomed = false;
  Size _viewport = Size.zero;

  // ★ نقرة واحدة على الصورة = تكبير/تصغير (Listener خام ⇒ تعمل في الحالتين،
  // ويبقى السحب الأفقي للتنقل بين الصور بلا تعارض).
  Offset? _pressAt;
  DateTime? _pressedAt;

  static const double _kTapSlop = 12;
  static const Duration _kTapWindow = Duration(milliseconds: 350);

  void _onPointerDown(PointerDownEvent event) {
    _pressAt = event.position;
    _pressedAt = DateTime.now();
  }

  void _onPointerUp(PointerUpEvent event) {
    final start = _pressAt;
    final at = _pressedAt;
    _pressAt = null;
    _pressedAt = null;
    if (start == null || at == null) return;
    final moved = (event.position - start).distance;
    final held = DateTime.now().difference(at);
    if (moved < _kTapSlop && held < _kTapWindow) _toggleZoom();
  }

  @override
  void initState() {
    super.initState();
    _zoomAnim.addListener(() {
      final tween = _zoomTween;
      if (tween != null) _zoom.value = tween.value;
    });
  }

  /// تكبير/تصغير ناعم حول مركز العرض ⇒ لا قفز إلى الزوايا.
  void _animateZoomTo(bool zoomIn) {
    final target = zoomIn ? 2.5 : 1.0;
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    final end = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(target, target, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);

    _zoomTween = Matrix4Tween(
      begin: _zoom.value.clone(),
      end: end,
    ).animate(CurvedAnimation(parent: _zoomAnim, curve: Curves.easeOutCubic));

    setState(() => _zoomed = zoomIn);
    _zoomAnim
      ..reset()
      ..forward();
  }

  void _toggleZoom() => _animateZoomTo(!_zoomed);

  @override
  void dispose() {
    _zoomAnim.dispose();
    _page.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// بديل أيقونة عند فشل تحميل الصورة.
  Widget _fallback() => Center(
    child: Icon(
      MockData.getIconByName(widget.service.iconName),
      size: 72,
      color: widget.service.color,
    ),
  );

  Widget _image(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // ★ LayoutBuilder ⇒ مركز التكبير = مركز العرض الفعلي.
      body: LayoutBuilder(
        builder: (context, constraints) {
          _viewport = Size(constraints.maxWidth, constraints.maxHeight);
          return _buildStack(context);
        },
      ),
    );
  }

  Widget _buildStack(BuildContext context) {
    final many = widget.images.length > 1;
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          child: PageView.builder(
            controller: _page,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              // ★ عودة ناعمة للوضع الطبيعي عند الانتقال لصورة أخرى.
              if (_zoomed) _animateZoomTo(false);
              setState(() => _index = i);
            },
            itemBuilder: (context, i) => InteractiveViewer(
              transformationController: _zoom,
              minScale: 1,
              maxScale: 4,
              // ★ pan مُفعّل فقط بعد التكبير ⇒ السحب الأفقي ينقل بين الصور
              // ما دامت الصورة غير مكبّرة.
              panEnabled: _zoomed,
              onInteractionEnd: (_) => setState(
                () => _zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01,
              ),
              // ★ قرص الإصبعين للتكبير/التصغير (pinch) + زر أعلى الشاشة.
              child: Center(child: _image(widget.images[i])),
            ),
          ),
        ),
        // عدّاد الصور.
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 8,
          start: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        // ★ شعار التطبيق بجوار زر الإغلاق.
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 4,
          end: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'گريب منك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              // ★ زر التكبير/التصغير (يعمل دائماً، بخلاف النقر المزدوج الذي
              // يبتلعه الـ InteractiveViewer بعد التكبير).
              IconButton(
                onPressed: _toggleZoom,
                icon: Icon(
                  _zoomed ? LucideIcons.zoomOut : LucideIcons.zoomIn,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
        if (many)
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: i == _index ? 1 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
