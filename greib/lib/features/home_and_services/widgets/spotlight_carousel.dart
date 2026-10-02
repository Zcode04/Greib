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

  /// ★ حالة العرض الشرائحي الشاملة
  bool _isGlobalCarousel = false;
  /// ★ الخدمات التي تم تحويلها للعرض الشرائحي
  final Set<String> _carouselServiceIds = {};

  final Map<String, PageController> _inlineControllers = {};
  final Map<String, int> _inlineIndexes = {};
  final Map<String, double?> _inlineFractions = {};

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
    for (final c in _inlineControllers.values) {
      c.dispose();
    }
    _sheets?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = ServicesRepository.instance.all;
    if (services.isEmpty) return const SizedBox.shrink();

    final fallbackPosts = [
      for (final service in services)
        ServicePostEntry(
          postId: service.id,
          index: 0,
          service: service,
          post: const ServicePost(text: '', imageUrls: [], timeAgo: ''),
        ),
    ];

    final allEntries = ServicesRepository.instance.allPosts;
    final baseEntries = allEntries.isNotEmpty ? allEntries : fallbackPosts;

    // إضافة بوستات وهمية ديناميكية لتجربة العرض الشرائحي لأي خدمة تم اختيارها
    final List<ServicePostEntry> enhancedEntries = List.from(baseEntries);
    if (enhancedEntries.isNotEmpty) {
      final selectedServices = _isGlobalCarousel
          ? services
          : services.where((s) => _carouselServiceIds.contains(s.id)).toList();
          
      for (final targetService in selectedServices) {
        enhancedEntries.add(ServicePostEntry(
          postId: '${targetService.id}_dummy1',
          index: 100,
          service: targetService,
          post: ServicePost(
            text: 'عرض خاص ومميز من (${targetService.title}) هذا الأسبوع!',
            imageUrls: const ['https://images.unsplash.com/photo-1555685812-4b943f1cb0eb?w=800&q=80'],
            timeAgo: 'قبل ساعتين',
          ),
        ));
        enhancedEntries.add(ServicePostEntry(
          postId: '${targetService.id}_dummy2',
          index: 101,
          service: targetService,
          post: ServicePost(
            text: 'تعرف على أحدث الإضافات لدينا في قسم ${targetService.title}.',
            imageUrls: const ['https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80'],
            timeAgo: 'قبل ٥ ساعات',
          ),
        ));
      }
    }

    final List<Widget> feedWidgets = [];
    final Set<String> processedInline = {};

    if (_isGlobalCarousel) {
      feedWidgets.add(_buildCarouselSection(enhancedEntries, inlineServiceId: null));
    } else {
      for (final entry in enhancedEntries) {
        if (_carouselServiceIds.contains(entry.service.id)) {
          if (!processedInline.contains(entry.service.id)) {
            processedInline.add(entry.service.id);
            final servicePosts = enhancedEntries
                .where((p) => p.service.id == entry.service.id)
                .toList();
            feedWidgets.add(
              _buildCarouselSection(
                servicePosts,
                inlineServiceId: entry.service.id,
              ),
            );
          }
        } else {
          feedWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _spotlightPostItem(entry),
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: feedWidgets,
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

  Widget _buildCarouselSection(
    List<ServicePostEntry> posts, {
    String? inlineServiceId,
  }) {
    if (posts.isEmpty) return const SizedBox.shrink();
    final activeIndex = inlineServiceId != null
        ? (_inlineIndexes[inlineServiceId] ?? 0)
        : _spotlightIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpotlightCarousel(posts, inlineServiceId: inlineServiceId),
          const SizedBox(height: 10),
          if (posts.length > 1) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(posts.length, (i) {
                  final active = i == activeIndex;
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
          ],
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 12,
                            end: 12,
                          ),
                          child: _softActionButton(
                            icon: LucideIcons.layoutList,
                            label: 'عرض كمنشورات',
                            onPressed: () => setState(() {
                              if (inlineServiceId != null) {
                                _carouselServiceIds.remove(inlineServiceId);
                              } else {
                                _isGlobalCarousel = false;
                                _carouselServiceIds.clear();
                              }
                            }),
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
      ),
    );
  }

  /// ★ العرض الأفقي للشريحة: يتمدد من طرف الشاشة لطرف (فيس بوك) ويشتق حجم
  /// البطاقة وارتفاعها من العرض الفعلي ⇒ نفس النتيجة على أي شاشة (تابلت/جوال).
  Widget _buildSpotlightCarousel(List<ServicePostEntry> posts, {String? inlineServiceId}) {
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

        PageController controller;
        int activeIndex;
        if (inlineServiceId != null) {
          activeIndex = _inlineIndexes[inlineServiceId] ?? 0;
          if (activeIndex >= posts.length) {
            activeIndex = posts.isEmpty ? 0 : posts.length - 1;
            _inlineIndexes[inlineServiceId] = activeIndex;
            _inlineFractions[inlineServiceId] = null;
          }
          final currentFraction = _inlineFractions[inlineServiceId];
          if (currentFraction != fraction) {
            _inlineFractions[inlineServiceId] = fraction;
            _inlineControllers[inlineServiceId]?.dispose();
            _inlineControllers[inlineServiceId] = PageController(
              viewportFraction: fraction,
              initialPage: activeIndex,
            );
          }
          controller = _inlineControllers[inlineServiceId]!;
        } else {
          if (_spotlightIndex >= posts.length) {
            _spotlightIndex = posts.isEmpty ? 0 : posts.length - 1;
            _spotlightViewportFraction = null;
          }
          _updatePageController(fraction);
          controller = _spotlightController;
          activeIndex = _spotlightIndex;
        }

        return OverflowBox(
          // ★ تمديد حقيقي لحواف الشاشة: يزيح الابن بصرياً فقط (بلا تغيير في
          // تخطيط العمود الأب). UnconstrainedBox يرسم أخطاء في وضع Debug،
          // والحشو السالب مرفوض في Flutter.
          alignment: Alignment.center,
          fit: OverflowBoxFit.deferToChild,
          minWidth: viewportWidth,
          maxWidth: viewportWidth,
          child: SizedBox(
            key: ValueKey('carousel_${inlineServiceId ?? "global"}'),
            width: viewportWidth,
            height: height,
            // Center ⇒ توسيط البطاقة على الشاشات العريضة (بلا أثر على الهاتف).
            child: Center(
              child: SizedBox(
                width: cardWidth + peek,
                child: PageView.builder(
                  controller: controller,
                  itemCount: posts.length,
                  onPageChanged: (i) {
                    if (inlineServiceId != null) {
                      setState(() => _inlineIndexes[inlineServiceId] = i);
                    } else {
                      setState(() => _spotlightIndex = i);
                    }
                  },
                  itemBuilder: (context, i) {
                    final postEntry = posts[i];
                    return AnimatedScale(
                      scale: i == activeIndex ? 1.0 : 0.93,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: i == activeIndex ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 220),
                        child: _spotlightItem(postEntry),
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

  Widget _buildSpotlightPosts(List<ServicePostEntry> posts) {
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
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServicePostCard(
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
          // ★ أزرار تحت كل منشور: «عرض المزيد» (صفحة خدمة هذا المنشور)
          //   و«عرض الشرائح» (تبديل الوضع) — لكل منشور وجهته الخاصة.
          const SizedBox(height: 6),
          _postActions(service.id),
        ],
      ),
    );
  }

  /// ★ شريط الأزرار أسفل المنشور الواحد: زرّان يملآن عرضه بالتساوي.
  Widget _postActions(String serviceId) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            // ★ الزر ينحصر داخل نصفه (بلا ملامسة حواف البطاقة) حتى لا تتداخل
            // زواياه المدوّرة مع الزر المجاور.
            padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
            child: _softActionButton(
              icon: LucideIcons.chevronDown,
              label: 'عرض المزيد',
              // ★ صفحة تفاصيل خدمة هذا المنشور ⇒ كل منشوراتها.
              onPressed: () => context.push('/service/$serviceId'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            // ★ فاصل مع الزر المجاور + مسافة عن حافة النهاية (يسار).
            padding: const EdgeInsetsDirectional.only(start: 4, end: 12),
            child: _softActionButton(
              icon: LucideIcons.galleryHorizontal,
              label: 'عرض الشرائح',
              onPressed: () => setState(() {
                _carouselServiceIds.add(serviceId);
              }),
            ),
          ),
        ),
      ],
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

  void _showSpotlightMoreSheet(ServiceCategory service) {
    final secondary = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    late final Future<void> sheet;
    sheet = showAppSheet<void>(
      context,
      builder: (sheetContext) {
        void pick(VoidCallback action) async {
          Navigator.of(sheetContext).pop();
          await sheet;
          action();
        }

        Widget row(IconData icon, String label, VoidCallback onTap, {Color? color}) {
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: color ?? service.color),
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: TextStyle(
                      color: color ?? primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return DraggableSheetBody(
          initialExtent: 0.45,
          snapSizes: const [0.35, 0.45, 0.6, 0.92],
          builder: (context, scrollController) => Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetDragArea(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Icon(LucideIcons.ellipsis, size: 18, color: secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'خيارات «${service.title}»',
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
                color: widget.isDark ? AppColors.outline : AppColors.lightOutline,
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    row(
                      LucideIcons.shoppingBag,
                      'طلب الآن',
                      () => pick(
                        () => _core.openServiceChat(context, service: service),
                      ),
                    ),
                    row(
                      LucideIcons.newspaper,
                      'عرض المزيد',
                      () => pick(
                        () => this.context.push('/service/${service.id}'),
                      ),
                    ),
                    row(
                      LucideIcons.flag,
                      'الإبلاغ',
                      () => pick(
                        () => _core.showAction(
                          context,
                          icon: LucideIcons.flag,
                          title: 'الإبلاغ',
                          hint: 'تم استلام بلاغك عن «${service.title}». سنقوم بمراجعته قريباً.',
                        ),
                      ),
                      color: AppColors.error,
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

  Widget _spotlightItem(ServicePostEntry entry) {
    final service = entry.service;
    final post = entry.post;
    final neonColor = widget.isDark
        ? AppColors.neon
        : AppColors.accentPrimaryDark;
    final isFav = _core.isFavorite(entry.postId);
    
    final imageUrl = post.imageUrls.isNotEmpty 
        ? post.imageUrls.first 
        : (service.coverImage ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: widget.isDark
            ? AppColors.neonGlow(blur: 20, alpha: 0.1)
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'post_carousel_${entry.postId}',
              child: SmartImage(
                src: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => context.push('/service/${service.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showPostImagesSheet(
                            service,
                            _entryImages(entry, imageUrl),
                          ),
                          child: Container(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.text.trim().isNotEmpty ? post.text : service.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
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
                              post.timeAgo.isNotEmpty ? post.timeAgo : service.subtitle,
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
                            icon: LucideIcons.ellipsis,
                            iconColor: Colors.white70,
                            onTap: () => _showSpotlightMoreSheet(service),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _core.openServiceChat(context, service: service),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              height: 34,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: neonColor,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.shoppingBag,
                                    size: 16,
                                    color: widget.isDark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'طلب الآن',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
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
                ),
              ),
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
