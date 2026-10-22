// features/liveserver/live_products_screen.dart
//
// صفحة «عرض منتجات التاجر» (المسار /live-products).
// ★ تُفتح من صفحة اختيار الوضع (LiveModeScreen).
// ★ فيد عمودي حقيقي: كل بثّ يشغل صفحة كاملة لتاجر حقيقي من متاجر التطبيق
//   (AccountRepository)، والسحب لأعلى/أسفل ينقل المستخدم إلى بثّ التاجر التالي
//   — بنفس إحساس فيد الصفحة الرئيسية.
// ★ فوق البث: عنوان «المنتجات المتوفرة الآن» + طبقة كاروسيل عائمة قابلة للتمرير
//   أفقياً (زر «معاينة» يفتح صفحة معاينة مستقلة) + زر «اطلب الآن» + أيقونة تفاعل.
// ★ التمرير «حسّاس»: نقبل السحب باللمس والماوس واللوحة اللمسية معاً، ولا يوجد
//   أي عنصر يستهلك السحب العمودي داخل البثّ (كل ما بداخله أفقي) ⇒ لا تعارض.
// ★ «اطلب الآن» يفتح محادثة الطلب بنفس آلية ميزة المنشورات (ChatPostPreview).
// ★ هذه محاكاة واجهة (UI Mock) — ستُطوَّر لاحقاً بربط بث/طلبات حقيقية.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/models/account_model.dart';
import '../../core/models/service_model.dart';
import '../../core/widgets/app_sheet.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/post_sheets.dart';
import '../communication_and_support/chat_screen.dart';
import '../services/data/account_repository.dart';
import '../services/data/commerce_aggregator_service.dart';
import '../services/data/services_repository.dart';

/// LiveProductsScreen — فيد البثوث العمودي: كل بثّ لتاجر مستقل (المسار /live-products).
class LiveProductsScreen extends StatefulWidget {
  const LiveProductsScreen({super.key});

  @override
  State<LiveProductsScreen> createState() => _LiveProductsScreenState();
}

class _LiveProductsScreenState extends State<LiveProductsScreen> {
  /// ★ عدد البثوث في الفيد (نفس عدد التجار في شاشة «التجار في البث الآن»).
  static const int _liveCount = 8;

  /// ★ التجار الباثّون في الفيد العمودي (بنفس ترتيب شاشة التجار).
  late final List<AccountProfile> _stores;

  /// ★ متحكّم الفيد العمودي — تمرير طبيعي متصل مثل فيد الصفحة الرئيسية.
  final PageController _feed = PageController();

  @override
  void initState() {
    super.initState();
    _stores = AccountRepository.instance.all
        .take(_liveCount)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _feed.dispose();
    super.dispose();
  }

  /// ★ اهتزاز خفيف عند الانتقال إلى بثّ آخر — بلا `setState` إطلاقاً
  ///   ⇒ لا إعادة بناء أثناء السحب ⇒ تمرير سلس بلا تقطع.
  void _onPageChanged(int index) => HapticFeedback.selectionClick();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      // ★ ★ جعل السحب «حسّاساً» لكل أدوات الإدخال: اللمس والماوس واللوحة
      //   اللمسية والقلم — لأن الإعداد الافتراضي لا يقبل السحب بالماوس.
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
            PointerDeviceKind.invertedStylus,
            PointerDeviceKind.unknown,
          },
        ),
        child: PageView.builder(
          controller: _feed,
          scrollDirection: Axis.vertical,
          // ★ يستجيب دائماً مع فيزياء كرة مطاطية ناعمة ⇒ إحساس تمرير سلس.
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: _stores.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, i) => _StoreLivePage(store: _stores[i]),
        ),
      ),
    );
  }
}

/// ============================================================================
///  بثّ تاجر واحد داخل الفيد العمودي: غلاف المتجر يملأ الشاشة، وفوقه شريط علوي
///  (المتجر الباثّ + شارة مباشر) ولوحة سفلية عائمة بالمنتجات وخدمات التوصيل.
/// ============================================================================
class _StoreLivePage extends StatefulWidget {
  const _StoreLivePage({required this.store});

  /// ★ التاجر الباثّ في هذا البثّ.
  final AccountProfile store;

  @override
  State<_StoreLivePage> createState() => _StoreLivePageState();
}

class _StoreLivePageState extends State<_StoreLivePage> {
  /// ★ صورة احتياطية للخلفية — تُستخدم فقط إن لم يتوفر غلاف المتجر.
  static const String _fallbackCover =
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1600&q=80';

  /// خدمة المتجر (اللون + المعرّف + الأيقونة) — تُستخدم في محادثة الطلب.
  late final ServiceCategory _service;

  /// ★ المنتجات المتوفرة الآن لهذا التاجر (CommerceAggregatorService).
  late final List<AggregatedProduct> _products;

  /// ★ خدمات التوصيل المتاحة — من خدمات التطبيق (ServicesRepository).
  late final List<ServiceCategory> _services;

  /// ★ نواة الأوراق المشتركة ⇒ نفس سلوك «طلب الآن» المستخدم في المنشورات.
  PostSheetsController? _sheets;

  final PageController _carousel = PageController(viewportFraction: 0.34);

  /// فهرس المنتج النشط في الكاروسيل.
  int _index = 0;

  /// حالة التفاعل: 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  int _reaction = 0;
  bool _following = false;

  String get _storeName => widget.store.name;

  @override
  void initState() {
    super.initState();
    final store = widget.store;
    _service =
        ServicesRepository.instance.byId(store.serviceId) ??
        ServicesRepository.instance.all.first;
    // ★ منتجات هذا التاجر (فئة خدمته)، وإن لم تتوفر منتجات في فئته نعرض
    //   الكتالوج العام ⇒ لا يظهر بثّ بلا منتجات.
    final own = CommerceAggregatorService.instance
        .getProductsForCategorySync(store.serviceId)
        .where((p) => p.inStock)
        .take(8)
        .toList(growable: false);
    _products = own.isNotEmpty
        ? own
        : CommerceAggregatorService.instance
              .getProductsForCategorySync('all')
              .where((p) => p.inStock)
              .take(8)
              .toList(growable: false);
    // ★ خدمات التوصيل المتاحة (أول 4 خدمات).
    _services = ServicesRepository.instance.all.take(4).toList(growable: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_sheets == null || _sheets!.isDark != isDark) {
      _sheets?.dispose();
      _sheets = PostSheetsController(isDark: isDark);
    }
  }

  @override
  void dispose() {
    _carousel.dispose();
    _sheets?.dispose();
    super.dispose();
  }

  /// صور المنتجات — تُستخدم في صفحة المعاينة المستقلة.
  List<String> get _productImages =>
      _products.map((p) => p.imageUrl).toList(growable: false);

  /// ★ فتح صفحة معاينة مستقلة تعرض الصورة بشكل أكبر (تمرير بين الصور + تكبير).
  void _openPreview(int index) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _ImagePreview(images: _productImages, initialIndex: index),
      ),
    );
  }

  /// ★ «اطلب الآن»: نفس آلية المنشورات — فتح محادثة الطلب مع التاجر ومعاينة
  ///   المنتج المحدد كـمرفق جاهز للإرسال.
  void _orderNow() {
    if (_products.isEmpty) return;
    HapticFeedback.mediumImpact();
    final product = _products[_index.clamp(0, _products.length - 1)];
    _sheets!.openServiceChat(
      context,
      service: _service,
      conversationTitle: _storeName,
      preview: ChatPostPreview(
        title: product.name,
        subtitle:
            '${product.customPrice.toStringAsFixed(0)} ${product.currency} • متوفر الآن',
        imageUrl: product.imageUrl,
        color: _service.color,
      ),
    );
  }

  /// ★ فتح شيت التفاعل البسيط (تفاعل + متابعة/إلغاء + مشاركة).
  void _openInteractionSheet() {
    HapticFeedback.selectionClick();
    showAppSheet(
      context,
      builder: (_) => _LiveInteractionSheet(
        storeName: _storeName,
        reaction: _reaction,
        following: _following,
        onReaction: (value) {
          if (mounted) setState(() => _reaction = value);
        },
        onFollow: (value) {
          if (mounted) setState(() => _following = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ★ خلفية البث: غلاف المتجر يملأ كامل الشاشة ولا يتغيّر مع الكاروسيل.
          Positioned.fill(
            child: Image.network(
              widget.store.coverUrl ?? _fallbackCover,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFF141A24),
                child: Center(
                  child: Icon(
                    LucideIcons.image,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          // ★ تظليل علوي/سفلي + تظليل خفيف عام لضمان قراءة العناصر فوق الصورة.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.60),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.90),
                ],
                stops: const [0.0, 0.22, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context),
                const Spacer(),
                _buildBottomPanel(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── الشريط العلوي: رجوع + المتجر الباثّ + شارة «مباشر» ───
  Widget _buildTopBar(BuildContext context) {
    final avatarUrl = widget.store.avatarUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 0),
      child: Row(
        children: [
          _GlassButton(
            icon: LucideIcons.chevronRight,
            tooltip: 'رجوع',
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white24,
                  backgroundImage: avatarUrl == null
                      ? null
                      : NetworkImage(avatarUrl),
                  child: avatarUrl == null
                      ? const Icon(
                          LucideIcons.store,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  _storeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.store.isVerified) ...[
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.badgeCheck,
                    size: 14,
                    color: context.iconColors.info,
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          const _PulsingLiveBadge(),
        ],
      ),
    );
  }

  // ─── اللوحة السفلية: عنوان المنتجات + الكاروسيل + (اطلب الآن + التفاعل) ───
  Widget _buildBottomPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ★ عنوان القسم: منتجات المتجر المتوفرة الآن.
          const Text(
            'المنتجات المتوفرة الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'يمكنكم الطلب الآن مباشرة من البث',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          // ★ طبقة الكاروسيل العائمة فوق البث (منتجات يمكن تمريرها أفقياً).
          _buildFloatingCarouselLayer(),
          const SizedBox(height: 18),
          // ★ طبقة «خدمات التوصيل المتاحة» أسفل كاروسيل المنتجات.
          _buildDeliveryServicesLayer(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: AppButton(
                    label: 'اطلب الآن',
                    icon: LucideIcons.shoppingBag,
                    onPressed: _orderNow,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ReactionIconButton(
                active: _reaction == 1,
                onTap: _openInteractionSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ★ طبقة «خدمات التوصيل المتاحة» أسفل كاروسيل المنتجات: عنوان + أفاتار
  ///   دائري لكل خدمة، قابلة للتمرير أفقياً (نفس أسلوب طبقة المنتجات).
  Widget _buildDeliveryServicesLayer() {
    if (_services.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خدمات التوصيل المتاحة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _services.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => _ServiceAvatarButton(
              service: _services[i],
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/service/${_services[i].id}');
              },
            ),
          ),
        ),
      ],
    );
  }

  /// ★ طبقة الكاروسيل العائمة فوق البث: صور المنتجات المتوفرة الآن يمكن
  ///   تمريرها أفقياً من اليمين لليسار، وزر «معاينة» يفتح صفحة المعاينة.
  Widget _buildFloatingCarouselLayer() {
    if (_products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 156,
      child: PageView.builder(
        controller: _carousel,
        padEnds: false,
        itemCount: _products.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          final active = i == _index;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: GestureDetector(
              onTap: () => _openPreview(i),
              child: AnimatedScale(
                scale: active ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.28),
                      width: active ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: active ? 0.45 : 0.28,
                        ),
                        blurRadius: active ? 18 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _products[i].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.white.withValues(alpha: 0.08),
                            child: const Icon(
                              LucideIcons.image,
                              size: 26,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        // تدرّج سفلي بسيط لإبراز زر المعاينة فوق الصورة.
                        PositionedDirectional(
                          start: 0,
                          end: 0,
                          bottom: 0,
                          height: 66,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // ★ زر «معاينة» — يظهر بجانب كل منتج داخل الكاروسيل.
                        PositionedDirectional(
                          start: 8,
                          end: 8,
                          bottom: 8,
                          child: _PreviewButton(onTap: () => _openPreview(i)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ============================================================================
///  أيقونة التفاعل (إعجاب) — تفتح شيت التفاعل البسيط.
/// ============================================================================
class _ReactionIconButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _ReactionIconButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'التفاعل',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: active ? 0.22 : 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? const Color(0xFFE5484D).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.22),
              width: active ? 1.6 : 1,
            ),
          ),
          child: Icon(
            LucideIcons.heart,
            size: 24,
            color: active ? const Color(0xFFE5484D) : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ★ أفاتار دائري لخدمة توصيل (صورة الخدمة أو أيقونتها) + اسمها أسفلها.
class _ServiceAvatarButton extends StatelessWidget {
  const _ServiceAvatarButton({required this.service, required this.onTap});

  final ServiceCategory service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover = service.coverImage;
    return SizedBox(
      width: 68,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.35),
                  border: Border.all(
                    color: service.color.withValues(alpha: 0.9),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: cover == null
                      ? Icon(
                          MockData.getIconByName(service.iconName),
                          size: 24,
                          color: Colors.white,
                        )
                      : Image.network(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            MockData.getIconByName(service.iconName),
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ★ زر «معاينة» — يظهر أسفل كل صورة داخل الكاروسيل، والضغط عليه يفتح
///   صفحة المعاينة المستقلة لتلك الصورة تحديداً.
class _PreviewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PreviewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.maximize2, size: 13, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'معاينة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر زجاجي دائري صغير (رجوع ونحوه).
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

/// شارة «مباشر» نابضة.
class _PulsingLiveBadge extends StatefulWidget {
  const _PulsingLiveBadge();

  @override
  State<_PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<_PulsingLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
            child: const Icon(LucideIcons.radio, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Text(
            'مباشر',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  شيت التفاعل البسيط: تفاعل (إعجاب/عدم إعجاب) + متابعة/إلغاء + مشاركة.
/// ============================================================================
class _LiveInteractionSheet extends StatefulWidget {
  const _LiveInteractionSheet({
    required this.storeName,
    required this.reaction,
    required this.following,
    required this.onReaction,
    required this.onFollow,
  });

  /// اسم المتجر الباثّ (يظهر في نص المشاركة).
  final String storeName;

  /// 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  final int reaction;
  final bool following;
  final ValueChanged<int> onReaction;
  final ValueChanged<bool> onFollow;

  @override
  State<_LiveInteractionSheet> createState() => _LiveInteractionSheetState();
}

class _LiveInteractionSheetState extends State<_LiveInteractionSheet> {
  late int _reaction = widget.reaction;
  late bool _following = widget.following;

  void _selectReaction(int value) {
    HapticFeedback.selectionClick();
    setState(() => _reaction = _reaction == value ? 0 : value);
    widget.onReaction(_reaction);
  }

  void _toggleFollow() {
    HapticFeedback.selectionClick();
    setState(() => _following = !_following);
    widget.onFollow(_following);
  }

  Future<void> _share() async {
    HapticFeedback.selectionClick();
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    try {
      await Share.share(
        'شاهد منتجات «${widget.storeName}» على تطبيق گريب منك:\n'
        'https://greib.app/live/products',
        subject: 'عرض المنتجات المباشر',
        sharePositionOrigin: origin,
      );
    } catch (_) {
      // تجاهل إذا ألغى المستخدم المشاركة.
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textColors.primary;
    final textSecondary = context.textColors.secondary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التفاعل',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            // ─── خياري التفاعل: إعجاب / عدم إعجاب ───
            Row(
              children: [
                Expanded(
                  child: _ReactionTile(
                    icon: LucideIcons.thumbsUp,
                    label: 'إعجاب',
                    count: '1.2 ألف',
                    color: context.accentColor,
                    active: _reaction == 1,
                    onTap: () => _selectReaction(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReactionTile(
                    icon: LucideIcons.thumbsDown,
                    label: 'عدم إعجاب',
                    count: '3',
                    color: textSecondary,
                    active: _reaction == -1,
                    onTap: () => _selectReaction(-1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ─── متابعة/إلغاء المتابعة + مشاركة ───
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _following ? 'إلغاء المتابعة' : 'متابعة',
                    icon: _following
                        ? LucideIcons.userMinus
                        : LucideIcons.userPlus,
                    type: _following
                        ? ButtonType.secondary
                        : ButtonType.primary,
                    onPressed: _toggleFollow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'مشاركة',
                    icon: LucideIcons.share2,
                    type: ButtonType.secondary,
                    onPressed: _share,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// خيار تفاعل واحد (أيقونة + عنوان + عدّاد) بحد مميّز عند التحديد.
class _ReactionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ReactionTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = context.backgroundColors.surfaceElevated;
    final outline = context.backgroundColors.outline;
    final textPrimary = context.textColors.primary;
    final textSecondary = context.textColors.tertiary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.14) : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : outline,
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: active ? color : textPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
///  صفحة معاينة مستقلة تعرض الصورة بشكل أكبر (الصورة فقط + تكبير + إغلاق).
/// ============================================================================
class _ImagePreview extends StatefulWidget {
  const _ImagePreview({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  late final PageController _page = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final many = widget.images.length > 1;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.images[i],
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
                  errorBuilder: (_, _, _) => const Icon(
                    LucideIcons.image,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          // زر الإغلاق.
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + 6,
            end: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'إغلاق',
              icon: const Icon(LucideIcons.x, color: Colors.white),
            ),
          ),
          // عدّاد الصور.
          if (many)
            PositionedDirectional(
              top: MediaQuery.paddingOf(context).top + 12,
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
        ],
      ),
    );
  }
}
