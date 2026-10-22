// features/liveserver/liveserver_screen.dart
//
// شاشة «البث المباشر» — فيد بثوث مباشرة عمودي (المسار /liveserver).
//
// ★ تُفتح من قائمة التجار الذين يبثّون الآن (LiveMerchantsScreen) مع تمرير
//   معرّف التاجر، فيبدأ الفيد من بثّه ثم يكمل المستخدم التمرير للأسفل لمشاهدة
//   بقية بثوث التجار — بنفس فكرة فيد الصفحة الرئيسية (تمرير طبيعي متصل).
// ★ التمرير «حسّاس»: يقبل السحب باللمس والماوس واللوحة (Trackpad) معاً،
//   ولا يُعاد بناء الفيد أثناء السحب (المؤقّت ودجت مستقل) ⇒ تمرير سلس بلا تقطع.
// ★ زر الرجوع يعتمد على هيدر SuperHeader الموجود أعلى الصفحة فقط (لا تكرار).
// ★ هذه محاكاة واجهة (UI Mock) — سيتم تطويرها لاحقاً بربط بث/قنوات حقيقية.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/models/account_model.dart';
import '../../core/widgets/super_header.dart';
import '../services/data/account_repository.dart';

/// ============================================================================
///  LiveserverScreen — فيد البثوث المباشرة للتجار (المسار /liveserver).
/// ============================================================================
class LiveserverScreen extends StatefulWidget {
  const LiveserverScreen({super.key, this.storeId});

  /// ★ معرّف التاجر الذي يبدأ منه الفيد (من قائمة التجار في البث).
  final String? storeId;

  @override
  State<LiveserverScreen> createState() => _LiveserverScreenState();
}

class _LiveserverScreenState extends State<LiveserverScreen> {
  /// ★ عدد البثوث المتاحة في الفيد (نفس عدد التجار في شاشة القائمة).
  static const int _liveCount = 8;

  /// ★ المسافة بين بثّين متتاليين في الفيد.
  static const double _gap = 14;

  // ★ حالات أزرار التحكّم السفلية (تفاعلية).
  bool _micOn = true;
  bool _camOn = true;

  /// ★ قائمة البثوث في الفيد العمودي (بنفس ترتيب شاشة التجار).
  late final List<AccountProfile> _stores;

  /// ★ متحكّم التمرير العمودي — تمرير طبيعي متصل مثل فيد الصفحة الرئيسية.
  final ScrollController _controller = ScrollController();

  /// ★ فهرس البث الظاهر حالياً — يُستخدم للاهتزاز عند تغييره فقط.
  int _activeIndex = 0;

  /// ★ ارتفاع البث الواحد — يُحسب من مساحة العرض أثناء البناء.
  double _itemExtent = 0;

  /// ★ هل انتقلنا تلقائياً إلى بثّ التاجر المختار (مرة واحدة بعد أول بناء)؟
  bool _autoJumped = false;

  @override
  void initState() {
    super.initState();
    _stores = AccountRepository.instance.all
        .take(_liveCount)
        .toList(growable: false);

    // ★ نبدأ من التاجر المختار (إن وُجد) ثم يكمل المستخدم التمرير.
    final found = widget.storeId == null
        ? -1
        : _stores.indexWhere((s) => s.id == widget.storeId);
    _activeIndex = found >= 0 ? found : 0;

    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// ★ تحديث البث النشط حسب موضع التمرير.
  ///   ملاحظة: لا نستدعي `setState` هنا إطلاقاً ⇒ لا إعادة بناء أثناء السحب
  ///   ⇒ تمرير سلس تماماً (الاهتزاز وحده يتغيّر).
  void _onScroll() {
    if (_itemExtent <= 0 || _stores.length < 2) return;
    final raw = (_controller.offset / _itemExtent).round();
    final i = raw < 0
        ? 0
        : (raw >= _stores.length ? _stores.length - 1 : raw);
    if (i == _activeIndex) return;
    _activeIndex = i;
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17), // خلفية داكنة تناسب البث
      // ★ زر الرجوع يأتي من الهيدر فقط (SuperHeader) — بدون أي تكرار.
      appBar: SuperHeader(title: 'البث المباشر', showBackButton: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ★ ارتفاع البث الواحد: يملأ معظم الشاشة وتظهر حافة البث التالي
          //   أسفله ⇒ يدرك المستخدم أن هناك بثوثاً أخرى بالتمرير.
          _itemExtent = (constraints.maxHeight * 0.86).clamp(280.0, 1000.0);

          // ★ الانتقال مرة واحدة إلى بثّ التاجر المختار (بلا أنميشن).
          if (!_autoJumped) {
            _autoJumped = true;
            if (_activeIndex > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _controller.hasClients) {
                  _controller.jumpTo((_itemExtent + _gap) * _activeIndex);
                }
              });
            }
          }

          // ★ ★ جعل التمرير «حسّاساً»: نسمح بالسحب بكل أدوات الإدخال
          //   (لمس / ماوس / لوحة لمس / قلم) بدل اللمس وحده.
          return ScrollConfiguration(
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
            child: ListView.separated(
              controller: _controller,
              // ★ يستجيب دائماً مع فيزياء كرة مطاطية ناعمة ⇒ إحساس تمرير سلس.
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: _stores.length,
              separatorBuilder: (_, _) => const SizedBox(height: _gap),
              itemBuilder: (context, i) => SizedBox(
                height: _itemExtent,
                child: _LiveStreamCard(
                  store: _stores[i],
                  micOn: _micOn,
                  camOn: _camOn,
                  viewers: 96 + i * 43,
                  onToggleMic: () => setState(() => _micOn = !_micOn),
                  onToggleCam: () => setState(() => _camOn = !_camOn),
                  onEnd: () => Navigator.of(context).maybePop(),
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
///  بطاقة بثّ واحد داخل الفيد: شاشة التاجر (أكبر) + شاشة الضيف (أنت)
///  + شريط المعلومات + أزرار التحكّم — بنفس تصميم محادثة الاتصال الهاتفي.
/// ============================================================================
class _LiveStreamCard extends StatelessWidget {
  final AccountProfile? store;
  final bool micOn;
  final bool camOn;
  final int viewers;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onEnd;

  const _LiveStreamCard({
    required this.store,
    required this.micOn,
    required this.camOn,
    required this.viewers,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- الشاشة الرئيسية: التاجر الذي يبثّ الآن ---
        Expanded(
          flex: 3,
          child: _PersonFeed(
            name: store?.name ?? 'المُذيع',
            role: 'التاجر • يبثّ الآن',
            avatarUrl: store?.avatarUrl,
            gradient: const [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
            micOn: micOn,
            camOn: camOn,
          ),
        ),
        const SizedBox(height: 10),
        // --- شاشة الضيف (الشخص الثاني) — أصغر ---
        const Expanded(
          flex: 2,
          child: _PersonFeed(
            name: 'أنت',
            role: 'معاينة الكاميرا',
            gradient: [Color(0xFF6D28D9), Color(0xFFDB2777)],
            micOn: true,
            camOn: true,
          ),
        ),
        const SizedBox(height: 12),
        // --- شريط المعلومات (مشاهدون + المؤقّت) + شارة LIVE ---
        _LiveInfoBar(viewers: viewers),
        const SizedBox(height: 12),
        // --- أزرار التحكّم ---
        _ControlBar(
          micOn: micOn,
          camOn: camOn,
          onToggleMic: onToggleMic,
          onToggleCam: onToggleCam,
          onEnd: onEnd,
        ),
      ],
    );
  }
}

/// ============================================================================
///  شاشة شخص واحد (محاكاة بث): خلفية متدرّجة + صورة رمزية + شارة الحالة.
/// ============================================================================
class _PersonFeed extends StatelessWidget {
  final String name;
  final String role;
  final List<Color> gradient;
  final bool micOn;
  final bool camOn;

  /// ★ صورة الطرف (إن وُجدت) — تُعرض بدل الأيقونة الرمزية.
  final String? avatarUrl;

  const _PersonFeed({
    required this.name,
    required this.role,
    required this.gradient,
    required this.micOn,
    required this.camOn,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ★ تظليل سفلي لقراءة النص.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
            // ★ الصورة الرمزية في المنتصف (صورة التاجر إن وُجدت).
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    backgroundImage: avatarUrl == null
                        ? null
                        : NetworkImage(avatarUrl!),
                    child: avatarUrl == null
                        ? Icon(
                            LucideIcons.circleUser,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.95),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // ★ شارة «الكاميرا مطفأة» عند إيقاف الكاميرا.
            if (!camOn)
              const Center(
                child: Icon(
                  LucideIcons.videoOff,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
            // ★ حالة المايك أسفل الشاشة.
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  micOn ? LucideIcons.mic : LucideIcons.micOff,
                  size: 16,
                  color: micOn ? Colors.white : context.iconColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
///  شارة «مباشر LIVE» نابضة + عدّاد المشاهدين + المؤقّت.
/// ============================================================================
class _LiveInfoBar extends StatelessWidget {
  final int viewers;

  const _LiveInfoBar({required this.viewers});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ★ شارة LIVE النابضة.
        const _PulsingLiveBadge(),
        // ★ عدّاد المشاهدات.
        _InfoChip(icon: LucideIcons.eye, text: '$viewers'),
        // ★ مؤقّت مدة البث — ودجت مستقل (لا يُعيد بناء الفيد).
        const _StreamTimer(),
      ],
    );
  }
}

/// ★ مؤقّت البث كودجت مستقل: يُحدّث نفسه كل ثانية فقط، فلا يُعيد بناء الفيد
///   أثناء التمرير ⇒ يبقى السحب سلساً بلا تقطع.
class _StreamTimer extends StatefulWidget {
  const _StreamTimer();

  @override
  State<_StreamTimer> createState() => _StreamTimerState();
}

class _StreamTimerState extends State<_StreamTimer> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return _InfoChip(icon: LucideIcons.dot, text: '$m:$s', ltr: true);
  }
}

/// شارة «مباشر» مع نبض (باستخدام AnimationController داخلي).
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.iconColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
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

/// رقاقة معلومات صغيرة (أيقونة + نص) بخلفية شبه شفافة.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool ltr;

  const _InfoChip({required this.icon, required this.text, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            textDirection: ltr ? TextDirection.ltr : null,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  أزرار التحكّم السفلية (مايك / كاميرا / إنهاء).
/// ============================================================================
class _ControlBar extends StatelessWidget {
  final bool micOn;
  final bool camOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onEnd;

  const _ControlBar({
    required this.micOn,
    required this.camOn,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleControl(
          icon: micOn ? LucideIcons.mic : LucideIcons.micOff,
          active: micOn,
          tooltip: micOn ? 'كتم المايك' : 'تشغيل المايك',
          onTap: onToggleMic,
        ),
        const SizedBox(width: 20),
        _CircleControl(
          icon: camOn ? LucideIcons.video : LucideIcons.videoOff,
          active: camOn,
          tooltip: camOn ? 'إيقاف الكاميرا' : 'تشغيل الكاميرا',
          onTap: onToggleCam,
        ),
        const SizedBox(width: 20),
        // ★ زر إنهاء البث (أحمر دائم).
        _CircleControl(
          icon: LucideIcons.phoneOff,
          active: true,
          isDestructive: true,
          tooltip: 'إنهاء البث',
          onTap: onEnd,
        ),
      ],
    );
  }
}

/// زر تحكّم دائري مع تغيّر الخلفية حسب الحالة.
class _CircleControl extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDestructive;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleControl({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive
        ? context.iconColors.error
        : (active
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.08));

    // ★ GestureDetector بدل InkWell: لا يستهلك إيماءات السحب العمودي إطلاقاً
    //   ⇒ التمرير يبقى حسّاساً حتى فوق أزرار التحكّم.
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.white
                : (active ? Colors.white : Colors.white54),
            size: 24,
          ),
        ),
      ),
    );
  }
}
