// features/liveserver/live_merchants_screen.dart
//
// صفحة «التجار في البث الآن» (المسار /live-merchants).
// ★ تُفتح من «الاتصال المباشر بالتاجر» في صفحة اختيار وضع البث.
// ★ تعرض كاروسيل أفقي كبير للمتاجر التي تبثّ الآن (من متاجر التطبيق الحقيقية)،
//   كل بطاقة تُظهر غلافاً/بروفايل كبيراً + شارة «مباشر» + اسم الخدمة + عدد
//   المشاهدين + زر الاتصال ⇒ شاشة الاتصال (/liveserver).
// ★ محاكاة واجهة (UI Mock) — ستُطوَّر لاحقاً بربط بث حقيقي.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/models/account_model.dart';
import '../services/data/account_repository.dart';
import '../services/data/services_repository.dart';

/// LiveMerchantsScreen — كاروسيل التجار الذين يبثّون الآن (المسار /live-merchants).
class LiveMerchantsScreen extends StatefulWidget {
  const LiveMerchantsScreen({super.key});

  @override
  State<LiveMerchantsScreen> createState() => _LiveMerchantsScreenState();
}

class _LiveMerchantsScreenState extends State<LiveMerchantsScreen> {
  /// ★ عدد المتاجر التي نعتبرها «تبثّ الآن» (محاكاة ثابتة في كل مرة).
  static const int _liveCount = 8;

  /// ★ نسبة عرض البطاقة من الشاشة — تُظهر جزءاً من البطاقة التالية (Peek)
  ///   ليدرك المستخدم أن الكاروسيل قابل للتمرير.
  static const double _viewportFraction = 0.78;

  late final PageController _controller;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
    _controller.addListener(() {
      final page = _controller.page ?? 0;
      if ((page - _page).abs() > 0.002) setState(() => _page = page);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<AccountProfile> get _liveStores => AccountRepository.instance.all
      .take(_liveCount)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final stores = _liveStores;
    final cardHeight = (context.screenHeight * 0.60).clamp(360.0, 540.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: SafeArea(
        child: Column(
          children: [
            const _MerchantsTopBar(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _MerchantsHeader(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: cardHeight,
                    child: PageView.builder(
                      controller: _controller,
                      padEnds: false,
                      clipBehavior: Clip.none,
                      itemCount: stores.length,
                      itemBuilder: (context, i) {
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            // ★ تصغير البطاقات الجانبية لإبراز البطاقة النشطة.
                            final delta = _controller.position.haveDimensions
                                ? (_controller.page ?? 0) - i
                                : 0.0;
                            final scale =
                                (1 - delta.abs() * 0.09).clamp(0.86, 1.0);
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: _LiveStoreCard(
                            store: stores[i],
                            viewers: 120 + i * 37,
                            onConnect: () => _connect(stores[i]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DotsIndicator(count: stores.length, page: _page),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ★ الاتصال بالتاجر: فتح شاشة الاتصال بنفس مكوّن البث الحالي.
  void _connect(AccountProfile store) {
    HapticFeedback.mediumImpact();
    context.push('/liveserver?store=${store.id}');
  }
}

/// الشريط العلوي: رجوع + عنوان + شارة «مباشر».
class _MerchantsTopBar extends StatelessWidget {
  const _MerchantsTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 4),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'التجار في البث الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.iconColors.error,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.radio, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'مباشر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ترويسة الكاروسيل: عنوان + وصف إرشادي.
class _MerchantsHeader extends StatelessWidget {
  const _MerchantsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التجار الذين يبثّون الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اسحب لاستعراض البثوث، واختر تاجراً للاتصال به مباشرة.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة تاجر كبيرة تملأ ارتفاع الكاروسيل: غلاف + شارة مباشر + بروفايل كبير
/// + اسم الخدمة + المشاهدون + زر الاتصال.
class _LiveStoreCard extends StatelessWidget {
  const _LiveStoreCard({
    required this.store,
    required this.viewers,
    required this.onConnect,
  });

  final AccountProfile store;
  final int viewers;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final cover = store.coverUrl ?? store.avatarUrl;
    final service = ServicesRepository.instance.byId(store.serviceId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onConnect,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFF141A26),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ★ خلفية البطاقة: غلاف المتجر (أو صورة البروفايل).
                  if (cover != null)
                    Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _CardFallback(),
                    )
                  else
                    const _CardFallback(),

                  // ★ طبقة تعتيم متدرّجة لضمان مقروئية العناصر أعلى/أسفل البطاقة.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.28, 0.55, 1.0],
                        colors: [
                          Color(0xA6000000),
                          Color(0x00000000),
                          Color(0x40000000),
                          Color(0xE60B0F17),
                        ],
                      ),
                    ),
                  ),

                  // ★ المحتوى فوق الخلفية.
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // الشريط العلوي: شارة «مباشر» + عدد المشاهدين.
                        Row(
                          children: [
                            const _LiveBadge(),
                            const Spacer(),
                            _ViewersPill(viewers: viewers),
                          ],
                        ),
                        const Spacer(),
                        // ★ البروفايل الكبير للشخص مع إطار «مباشر».
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.iconColors.error,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white24,
                              backgroundImage: store.avatarUrl == null
                                  ? null
                                  : NetworkImage(store.avatarUrl!),
                              child: store.avatarUrl == null
                                  ? const Icon(
                                      LucideIcons.store,
                                      size: 34,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // اسم التاجر + شارة التوثيق.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                store.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (store.isVerified) ...[
                              const SizedBox(width: 5),
                              Icon(
                                LucideIcons.badgeCheck,
                                size: 16,
                                color: context.iconColors.info,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // اسم الخدمة (الفئة).
                        if (service != null)
                          Center(
                            child: Text(
                              service.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 3),
                        // حالة «يبثّ الآن».
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: context.iconColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'يبثّ الآن',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _ConnectButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// خلفية بديلة عند غياب/فشل صورة الغلاف.
class _CardFallback extends StatelessWidget {
  const _CardFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
    );
  }
}

/// شارة «مباشر» الحمراء أعلى البطاقة.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.iconColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.radio, size: 13, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'مباشر الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// حبّة عدد المشاهدين أعلى البطاقة.
class _ViewersPill extends StatelessWidget {
  const _ViewersPill({required this.viewers});

  final int viewers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.eye, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            '$viewers',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// زر «الاتصال المباشر» أسفل البطاقة (Pill بتدرّج أزرق).
class _ConnectButton extends StatelessWidget {
  const _ConnectButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.phoneCall, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'الاتصال المباشر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر الصفحات (Dots) أسفل الكاروسيل — يبرز البطاقة النشطة.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.page});

  final int count;
  final double page;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = (page - i).abs() < 0.5;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? context.iconColors.error
                : Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
