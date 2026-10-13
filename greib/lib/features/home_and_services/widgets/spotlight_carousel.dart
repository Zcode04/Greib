import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/widgets/draggable_sheet_body.dart';
import '../../services/data/services_repository.dart';
import '../../services/data/account_repository.dart';
import '../../services/data/commerce_aggregator_service.dart';
import '../../../../shared_widgets/smart_image.dart';
import '../../../../shared_widgets/post_sheets.dart';
import '../../../../shared_widgets/service_post_card.dart';
import '../../../../shared_widgets/store_category_tabs.dart';
import '../../../../core/widgets/app_sheet.dart';

class SpotlightSection extends StatefulWidget {
  final bool isDark;

  /// حشو الشاشة المستضيفية أفقياً (Home = 20). نحتاجه في وضع «المنشورات»
  /// لتمديد البطاقة لحواف الشاشة من داخل الحشو، بدل الاعتماد على
  /// MediaQuery (يتجاهل أي حاوية بعرض مختلف ويكسر عند تغيّر الحشو).
  final double horizontalBleed;

  /// ★ وضع «منشور واحد»: عند تمريره تعرض الودجت هذا المنشور وحده فقط
  ///   بنفس التصميم والغلاف (تمديد لحواف الشاشة) المستخدَم في تغذية
  ///   «المميز عندنا» ⇒ يُدرج ضمن تدفّق الصفحة الرئيسية (قبل/بعد «الأحدث»)
  ///   بمطابقة بصرية تامة 100% بلا أي كود تصميم موازٍ.
  final ServicePostEntry? singleEntry;

  const SpotlightSection({
    super.key,
    required this.isDark,
    this.horizontalBleed = 20,
    this.singleEntry,
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
  void initState() {
    super.initState();
    StoreSelectedCategory.notifier.addListener(_onCategoryChanged);
  }

  void _onCategoryChanged() {
    if (mounted) {
      setState(() {
        _spotlightIndex = 0;
      });
      if (_spotlightController.hasClients) {
        _spotlightController.jumpToPage(0);
      }
    }
  }

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
    StoreSelectedCategory.notifier.removeListener(_onCategoryChanged);
    _spotlightController.dispose();
    for (final c in _inlineControllers.values) {
      c.dispose();
    }
    _sheets?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ★ وضع «منشور واحد»: نستخدم حرفياً نفس غلاف المنشور المفرد
    // (`_buildSinglePost`) المستخدَم في تغذية «المميز عندنا» ⇒ تصميم
    // وأبعاد مطابقة 100%، ومصدر واحد للتطوير لاحقاً.
    if (widget.singleEntry != null) {
      return _buildSinglePost(widget.singleEntry!);
    }

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
    final currentCategory = StoreSelectedCategory.notifier.value;

    // منشورات الخدمات الأساسية (أو بديلة إن لم تكن هناك منشورات في الملف)
    final allEntries = ServicesRepository.instance.allPosts;
    final baseEntries = allEntries.isNotEmpty ? allEntries : fallbackPosts;

    // تجميع منشورات الفئات لتشمل كل تصنيف مختار أو الكل
    final List<ServicePostEntry> enhancedEntries = [];

    // إذا تم اختيار 'all'، نعرض منشورات جميع الخدمات ومنشورات التجارة
    if (currentCategory == 'all') {
      enhancedEntries.addAll(baseEntries);

      // إضافة بوستات تفاعلية للأقسام التجارية الرئيسية لضمان ظهور منشورات لكل الفئات
      for (final cat in MockData.productCategories) {
        if (cat['id'] == 'all') continue;
        final products = CommerceAggregatorService.instance.getProductsForCategorySync(cat['id']!);
        if (products.isNotEmpty) {
          final topProduct = products.first;
          final catService = ServiceCategory(
            id: 'store_${cat['id']}',
            title: cat['label']!,
            subtitle: 'وصل حديثاً من ${topProduct.sourceStore}',
            description: topProduct.name,
            iconName: 'shopping-bag',
            color: const Color(0xFF10B981),
            colorHex: '#10B981',
            price: '${topProduct.customPrice.toStringAsFixed(0)} ${topProduct.currency}',
            imageUrls: [topProduct.imageUrl],
          );
          enhancedEntries.add(ServicePostEntry(
            postId: 'feed_${cat['id']}_${topProduct.id}',
            index: 0,
            service: catService,
            post: ServicePost(
              text: 'عروض حصرية في قسم ${cat['label']}: ${topProduct.name} بسعر ${topProduct.customPrice.toStringAsFixed(0)} ${topProduct.currency} فقط!',
              imageUrls: [topProduct.imageUrl],
              timeAgo: 'وصل حديثاً',
            ),
          ));
        }
      }
    } else {
      // فئة محددة: إما خدمة محلية (طعام، صيدلية، توصيل...) أو تجارة (أزياء، إلكترونيات، فنادق...)
      final matchingServices = services.where((s) {
        if (currentCategory == 'food' && s.id == 'food') return true;
        if (currentCategory == 'pharmacy' && s.id == 'pharmacy') return true;
        if (currentCategory == 'delivery' && (s.id == 'delivery' || s.id == 'ride')) return true;
        return s.id == currentCategory;
      }).toList();

      if (matchingServices.isNotEmpty) {
        for (final s in matchingServices) {
          final sPosts = baseEntries.where((e) => e.service.id == s.id).toList();
          if (sPosts.isNotEmpty) {
            enhancedEntries.addAll(sPosts);
          } else {
            enhancedEntries.add(ServicePostEntry(
              postId: s.id,
              index: 0,
              service: s,
              post: ServicePost(
                text: s.description,
                imageUrls: s.imageUrls,
                timeAgo: 'الآن',
              ),
            ));
          }
        }
      }

      // إضافة بوستات المنتجات المجمعة الخاصة بهذا التصنيف تحديداً
      final catProducts = CommerceAggregatorService.instance.getProductsForCategorySync(currentCategory);
      final catLabel = MockData.productCategories.firstWhere(
        (c) => c['id'] == currentCategory,
        orElse: () => {'label': 'المنتجات'},
      )['label']!;

      for (var i = 0; i < catProducts.length && i < 4; i++) {
        final prod = catProducts[i];
        final isHotel = prod.category == 'hotels';
        final catService = ServiceCategory(
          id: 'store_${prod.id}',
          title: isHotel ? prod.name : catLabel,
          subtitle: isHotel ? 'حجز فندقي عائلي' : 'متوفر عبر ${prod.sourceStore}',
          description: prod.name,
          iconName: isHotel ? 'hotel' : 'shopping-bag',
          color: isHotel ? const Color(0xFF1E6B3C) : const Color(0xFF3B82F6),
          colorHex: isHotel ? '#1E6B3C' : '#3B82F6',
          price: isHotel ? '${prod.customPrice.toStringAsFixed(0)} ر.س/ليلة' : '${prod.customPrice.toStringAsFixed(0)} ${prod.currency}',
          imageUrls: [prod.imageUrl],
        );

        enhancedEntries.add(ServicePostEntry(
          postId: 'post_cat_${prod.id}',
          index: i,
          service: catService,
          post: ServicePost(
            text: isHotel
                ? 'إقامة مميزة في ${prod.name} - تقييم ${prod.rating} ★ مع إطلالة فاخرة وخدمات عائلية متكاملة.'
                : 'وصل حديثاً في $catLabel: ${prod.name} بسعر ${prod.customPrice.toStringAsFixed(0)} ${prod.currency} (متجر ${prod.sourceStore})',
            imageUrls: [prod.imageUrl],
            timeAgo: i == 0 ? 'الآن' : 'منذ ساعة',
          ),
        ));
      }
    }

    // إذا لم يكن هناك شيء في التصفية، نعرض المنشورات الافتراضية
    if (enhancedEntries.isEmpty) {
      enhancedEntries.addAll(baseEntries);
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
          feedWidgets.add(_buildSinglePost(entry));
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

  /// ★ غلاف المنشور المفرد الوحيد في التطبيق — يُستخدم حرفياً في:
  ///   1) تغذية «المميز عندنا» (المنشورات غير المحمّلة في كاروسيل)، و
  ///   2) وضع «منشور واحد» المُدرج في تدفّق الصفحة الرئيسية (قبل/بعد «الأحدث»).
  /// ⇒ مصدر تصميم واحد ⇒ تطابق بصري 100% وإدارة أبعاد موحّدة.
  ///
  /// التمديد لحواف الشاشة عبر `OverflowBox` + `LayoutBuilder` (بلا تغيير في
  /// تخطيط الأب)، مع توسيط العمود بسقف `_kMaxPostWidth` على الشاشات العريضة.
  Widget _buildSinglePost(ServicePostEntry entry) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - widget.horizontalBleed * 2;
        final bleed = widget.horizontalBleed.clamp(0.0, available / 2);
        final screenWidth = available + bleed * 2;
        final postWidth = screenWidth > _kMaxPostWidth ? _kMaxPostWidth : screenWidth;

        return OverflowBox(
          alignment: Alignment.center,
          fit: OverflowBoxFit.deferToChild,
          minWidth: screenWidth,
          maxWidth: screenWidth,
          child: SizedBox(
            width: screenWidth,
            child: Center(
              child: SizedBox(
                width: postWidth,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _spotlightPostItem(entry),
                ),
              ),
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
            // ★ الضغط على اسم/صورة صاحب المنشور يعرض نفس ورقة الخيارات.
            onAuthorTap: () => _showPostImagesSheet(service, images),
            onComment: () =>
                core.showComments(context, postId: postId, service: service),
            onShare: () => core.showShare(
              context,
              postId: postId,
              service: service,
            ),
            // ★ نفس وضع الشرائح المستعمل في الشريط أسفل المنشور.
            onShowSlides: () => setState(() {
              _carouselServiceIds.add(service.id);
            }),
          ),
        ],
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

  /// \u2605 \u0648\u0631\u0642\u0629 \u062e\u064a\u0627\u0631\u0627\u062a \u0635\u0648\u0631\u0629/\u0645\u0646\u0634\u0648\u0631 \u2014 \u0628\u0644\u0627 \u0639\u0646\u0648\u0627\u0646\u060c \u0641\u0642\u0637 \u0627\u0644\u0623\u0632\u0631\u0627\u0631 \u0627\u0644\u0623\u0631\u0628\u0639\u0629.
  void _showPostImagesSheet(ServiceCategory service, List<String> images) {
    late final Future<void> sheet;
    sheet = showAppSheet<void>(
      context,
      builder: (sheetContext) {
        void pick(VoidCallback action) async {
          Navigator.of(sheetContext).pop();
          await sheet;
          action();
        }

        // ★ لون موحّد مع بقية الأوراق (لون نص السطح) بلا عنوان علوي.
        final sheetText = Theme.of(sheetContext).colorScheme.onSurface;

        Widget row(IconData icon, String label, VoidCallback onTap) {
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(icon, size: 24, color: sheetText),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: sheetText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ★ نفس شكل ورقة زر الأقوان (⋯): قابلة للسحب بأحجام دينامية، بلا عنوان.
        return DraggableSheetBody(
          initialExtent: 0.45,
          snapSizes: const [0.35, 0.45, 0.6, 0.92],
          builder: (context, scrollController) => Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
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
                      LucideIcons.user,
                      'عرض الملف الشخصي',
                      () => pick(() {
                        final accounts = AccountRepository.instance
                            .forService(service.id);
                        if (accounts.isNotEmpty) {
                          this.context.push('/account/${accounts.first.id}');
                        }
                      }),
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
    late final Future<void> sheet;
    sheet = showAppSheet<void>(
      context,
      builder: (sheetContext) {
        void pick(VoidCallback action) async {
          Navigator.of(sheetContext).pop();
          await sheet;
          action();
        }

        // ★ لون موحّد مع بقية الأوراق، بلا عنوان علوي.
        final sheetText = Theme.of(sheetContext).colorScheme.onSurface;
        final outline = Theme.of(
          sheetContext,
        ).dividerColor.withValues(alpha: 0.6);

        Widget row(IconData icon, String label, VoidCallback onTap, {Color? color}) {
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: color ?? sheetText),
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: TextStyle(
                      color: color ?? sheetText,
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
              Divider(height: 1, color: outline),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
