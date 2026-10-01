import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/service_model.dart';
import '../../services/data/services_repository.dart';
import '../../../../shared_widgets/smart_image.dart';
import '../../../../shared_widgets/post_sheets.dart';
import '../../../../shared_widgets/service_post_card.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../communication_and_support/chat_screen.dart';

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

  PageController _spotlightController = PageController(
    viewportFraction: _kDefaultViewportFraction,
  );
  double? _spotlightViewportFraction = _kDefaultViewportFraction;
  int _spotlightIndex = 0;

  /// ★ النواة المشتركة مع صفحة تفاصيل الخدمة: التفاعل والمفضلة والتعليقات
  /// والأوراق كلها في مكان واحد (PostSheetsController) ⇒ لا نسختان من المنطق.
  /// تُنشأ عند تغيّر السمة وتُصرَّف مع الودجت.
  PostSheetsController? _sheets;
  PostSheetsController get _core => _sheets!;

  /// ★ نبدأ بوضع المنشورات: كل منشورات كل الخدمات دفعة واحدة.
  bool _isGridView = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // نُعيد البناء فقط عند تغيّر الوضع (لا في كل استدعاء).
    if (_sheets == null || _sheets!.isDark != isDark) {
      _sheets?.dispose();
      _sheets = PostSheetsController(isDark: isDark);
    }
  }

  @override
  void dispose() {
    _spotlightController.dispose();
    _sheets?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = ServicesRepository.instance.all;
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
        // من اليمين) وبزر التبديل في الزاوية الأخرى، و«عرض المزيد» يظهر فقط في
        // وضع المنشورات (يفتح صفحة تفاصيل أول خدمة ⇒ كل منشوراتها). الصف يتمدّد
        // لحواف الشاشة (مثل البطاقة تماماً) ليبقى بنفس عرض المنشور.
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
                    if (_isGridView && services.length > 1) ...[
                      Expanded(
                        child: Padding(
                          // ★ الزر ينحصر داخل نصفه (بلا ملامسة حواف البطاقة)
                          // حتى لا تتداخل زواياه المدوّرة مع عناصر الجوار.
                          // ★ مسافة عن حافة البداية (يمين) + فاصل مع الزر المجاور.
                          padding: const EdgeInsetsDirectional.only(
                            start: 12,
                            end: 4,
                          ),
                          child: _softActionButton(
                            icon: LucideIcons.chevronDown,
                            label: 'عرض المزيد',
                            // ★ الانتقال لصفحة تفاصيل أول خدمة معروضة، وهي
                            // الصفحة المخصّصة لعرض كل منشورات تلك الخدمة.
                            onPressed: () =>
                                context.push('/service/${services.first.id}'),
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Padding(
                        // ★ فاصل مع الزر المجاور + مسافة عن حافة النهاية (يسار).
                        padding: const EdgeInsetsDirectional.only(
                          start: 4,
                          end: 12,
                        ),
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
    // ★ كل منشورات كل الخدمات في استدعاء واحد (لا نعدّ على الخدمات).
    final entries = ServicesRepository.instance.allPosts;
    final posts = entries.isNotEmpty
        ? entries
        : [
            // شبكة أمان: لا يوجد أي منشور ⇒ نعرض الخدمات نفسها كبطاقات.
            for (final service in services)
              ServicePostEntry(
                postId: service.id,
                index: 0,
                service: service,
                post: const ServicePost(text: '', imageUrls: [], timeAgo: ''),
              ),
          ];

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
                    itemCount: posts.length,
                    // ★ بلا فاصل بين المنشورات — المسافة العمودية من البطاقة نفسها.
                    separatorBuilder: (_, _) => const SizedBox.shrink(),
                    itemBuilder: (context, i) => _spotlightPostItem(posts[i]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ★ المنشور في الصفحة الرئيسية = نفس بطاقة `ServicePostCard` ونفس نواة
  /// الأوراق `PostSheetsController` المستخدمَين في تبويبات صفحة تفاصيل الخدمة
  /// ⇒ تصميم ومنطق تفاعل واحد في التطبيق كله.
  ///
  /// `ListenableBuilder` ⇒ أي تغيير (تفاعل/مفضلة) من داخل أي ورقة يعيد
  /// بناء البطاقة تلقائياً عبر `notifyListeners`.
  Widget _spotlightPostItem(ServicePostEntry entry) {
    final service = entry.service;
    // صورة افتراضية للخدمات التي ليس لها صورة
    final String imageUrl =
        service.coverImage ??
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80';
    // ★ مفتاح التفاعل = معرّف المنشور (لا الخدمة) ⇒ منشورات نفس الخدمة
    //   لا تتشارك الإعجاب/المفضلة/التعليقات.
    final postId = entry.postId;
    final images = _entryImages(entry, imageUrl);
    final core = _core;

    return ListenableBuilder(
      listenable: core,
      builder: (context, _) => ServicePostCard(
        service: service,
        isDark: widget.isDark,
        imageUrls: images,
        backgroundColor: widget.isDark
            ? AppColors.background
            : AppColors.lightBackground,
        // ★ الأعداد كما كانت: ثابتة ومشتقّة من معرّف المنشور.
        countSeed: postId,
        likeCount: PostSheetsController.countFor(postId, 80, 10),
        commentCount: PostSheetsController.countFor(postId, 40, 2),
        shareCount: PostSheetsController.countFor(postId, 20, 1),
        // ---------- الحالة من النواة المشتركة ----------
        reaction: core.reactionOf(postId),
        isSaved: core.isFavorite(postId),
        // ★ الاختيار يتم داخل الورقة (كما كان سلوكياً)، فالنقر يفتحها فقط
        //   والبطاقة لا تبدّل التفاعل بنفسها.
        delegateReactionToCallback: true,
        onReaction: () =>
            core.showReaction(context, postId: postId, service: service),
        onSaveChanged: (value) => core.setFavorite(postId, value),
        // ★ نفس الاستدعاءات المستخدمة في صفحة التفاصيل (نواة واحدة).
        onRequest: () => core.openServiceChat(context, service: service),
        onImageTap: () => _showPostImagesSheet(service, images),
        onComment: () =>
            core.showComments(context, postId: postId, service: service),
        onShare: () => core.showAction(
          context,
          icon: LucideIcons.repeat2,
          title: 'إعادة النشر',
          hint: 'نشر رابط «${service.title}» على صفحتك.',
        ),
      ),
    );
  }

  /// ★ صور المنشور: صوره هي أولاً، ثم صور الخدمة كاحتياط.
  /// (المنشور بلا صور ⇒ نرجع لصورة غلاف الخدمة أو الصورة الافتراضية).
  List<String> _entryImages(ServicePostEntry entry, String fallback) {
    final own = entry.imageUrls
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (own.isNotEmpty) return own;
    return _postImages(entry.service, fallback);
  }

  List<String> _postImages(ServiceCategory service, String fallback) {
    final extra = service.imageUrls
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    // ★ بديل فارغ أو فاضٍ ⇒ لا صور إطلاقاً (لا رابط فارغ في المعاينة).
    if (extra.isEmpty) {
      return fallback.trim().isEmpty ? const <String>[] : [fallback];
    }
    return [service.coverImage ?? fallback, ...extra];
  }

  /// ★ ورقة خيارات صور المنشور: عند الضغط على أي صورة لا نفتح المعاينة
  /// مباشرة، بل نعرض ثلاث خيارات: «مشاهدة صور» (المعاينة الكاملة)،
  /// «طلب الآن» (محادثة مقدّم الخدمة)، و«عرض المزيد» (منشورات أخرى لنفس
  /// الخدمة). تعمل في وضعي المنشورات والشرائح.
  void _showPostImagesSheet(ServiceCategory service, List<String> images) {
    // ★ في الشريحة قد تكون الخدمة بلا صورة ⇒ لا معاينة (بلا قائمة صور وهمية).
    final secondary = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    // ★ كل خيار ينتظر إغلاق الورقة فعلياً ثم ينفَّذ ⇒ الإجراء يعمل على
    // الشاشة (لا داخل ورقة تُغلق) وبلا تكديس ورقة فوق ورقة.
    late final Future<void> sheet;
    sheet = showAppSheet<void>(
      context,
      builder: (sheetContext) {
        void pick(VoidCallback action) async {
          Navigator.of(sheetContext).pop();
          await sheet;
          action();
        }

        Widget row(IconData icon, String label, VoidCallback onTap) {
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: service.color),
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ★ نفس سلوك ورقة التعليقات: ورقة كبيرة ديناميكية، السحب للأعلى
        // يوسّعها حتى 92% من الشاشة، وللأسفل يصغّرها/يغلقها، مع Snap.
        return DraggableSheetBody(
          initialExtent: 0.6,
          snapSizes: const [0.35, 0.45, 0.55, 0.6, 0.7, 0.8, 0.92],
          builder: (context, scrollController) => Column(
            mainAxisSize: MainAxisSize.max,
            // ★ stretch ⇒ الرأس والخيارات تأخذ عرض الورقة كله (منطقة سحب كاملة).
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ★ الرأس منطقة سحب أيضاً: للأعلى توسّع الورقة، ولأسفل تصغيرها.
              SheetDragArea(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Icon(LucideIcons.images, size: 18, color: secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          images.isEmpty
                              ? service.title
                              : 'صور «${service.title}» (${images.length})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: widget.isDark
                    ? AppColors.outline
                    : AppColors.lightOutline,
              ),
              // ★ الخيارات مرتبطة بـ ScrollController الخاص بالورقة ⇒ السحب
              // داخلها يوسّع الورقة (لا تمرير، لقلة الخيارات).
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    // 1) معاينة كاملة (كما كان سلوك الضغط على الصورة).
                    if (images.isNotEmpty)
                      row(
                        LucideIcons.maximize2,
                        'مشاهدة صور',
                        () => pick(
                          () => _core.openImagePreview(
                            context,
                            images: images,
                            service: service,
                          ),
                        ),
                      ),
                    // 2) طلب الآن ⇒ محادثة مباشرة مع مقدّم الخدمة.
                    row(
                      LucideIcons.shoppingBag,
                      'طلب الآن',
                      () => pick(
                        () => _core.openServiceChat(context, service: service),
                      ),
                    ),
                    // 3) المزيد ⇒ الانتقال لصفحة تفاصيل الخدمة.
                    row(
                      LucideIcons.newspaper,
                      'عرض المزيد',
                      () => pick(
                        // ★ نستخدم سياق الـState لا سياق الورقة (أُغلقت).
                        () => this.context.push('/service/${service.id}'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _spotlightItem(ServiceCategory service) {
    final neonColor = widget.isDark
        ? AppColors.neon
        : AppColors.accentPrimaryDark;
    final isFav = _core.isFavorite(service.id);

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
        onTap: () => context.push('/service/${service.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                // ★ الضغط على الصورة ⇒ نفس ورقة الخيارات (مشاهدة صور /
                // طلب الآن / عرض المزيد)، بدل فتح صفحة الخدمة مباشرة.
                child: GestureDetector(
                  onTap: () => _showPostImagesSheet(
                    service,
                    _postImages(service, service.coverImage ?? ''),
                  ),
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
                          child: (service.coverImage != null)
                              ? ClipOval(
                                  child: SmartImage(
                                    src: service.coverImage,
                                    placeholder: Icon(
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
                  onTap: () => _core.setFavorite(service.id, !isFav),
                ),
                const SizedBox(width: 6),
                _spotlightIconButton(
                  icon: LucideIcons.arrowLeft,
                  iconColor: widget.isDark ? Colors.black : Colors.white,
                  filledBackground: neonColor,
                  onTap: () => context.push('/service/${service.id}'),
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
