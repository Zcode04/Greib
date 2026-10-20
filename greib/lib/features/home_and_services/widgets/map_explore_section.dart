import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/confirm_location_sheet.dart';
import '../../../core/widgets/map_style_selector.dart';
import '../../../core/widgets/place_search_sheet.dart';
import '../../../core/widgets/real_map_view.dart';
import '../../../shared_widgets/glass_container.dart';

/// ============================================================================
///  MapExploreSection — قسم «استكشف القريب منك».
///
///  ★ الترتيب من الأعلى:
///    1) شريط البحث (كبسولة علوية).
///    2) بطاقة العالم — الكرة الأرضية ثلاثية الأبعاد (CustomPaint).
///    3) تبويبات «الأقرب إليك» (المتاجر/المحلات/التكاسي/الوكالات/
///       المطاعم/الصيدليات/التوصيل/العقارات/الترفيه/الصحة/الرياضة)،
///       والمؤشر يظهر فوق التبويب النشط، وتحته قائمة الجهات القريبة.
///
///  ملاحظة: الكرة مرسومة بـ CustomPaint حالياً (بلا مكتبات خرائط) — تُستبدل
///  لاحقاً بطبقة خرائط حقيقية بنفس الواجهة والتبويبات.
/// ============================================================================
class MapExploreSection extends StatefulWidget {
  final bool isDark;

  const MapExploreSection({super.key, required this.isDark});

  @override
  State<MapExploreSection> createState() => _MapExploreSectionState();
}

class _MapExploreSectionState extends State<MapExploreSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchBar(),
        const SizedBox(height: 14),
        _liveMapCard(),
        const SizedBox(height: 14),
        NearbyServicesSection(isDark: widget.isDark),
      ],
    );
  }


  // ---------- 1) شريط البحث — يفتح بحثاً حقيقياً ----------
  Widget _searchBar() {
    // ★ كل الألوان من اللوحة المركزية (Color Palette) عبر السياق.
    final tint = context.iconColors.primary;
    final hint = context.textColors.secondary;
    return GestureDetector(
      onTap: () async {
        final loc = context.read<LocationController>();
        final near = loc.activeLatLng;
        final picked = await PlaceSearchSheet.show(context, near: near);
        if (picked == null) return;
        if (!context.mounted) return;
        loc.confirmPlace(picked);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم اختيار: ${picked.name}')),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(24),
        opacity: widget.isDark ? 0.06 : 0.1,
        child: Row(
          children: [
            Icon(LucideIcons.search, size: 18, color: hint),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ابحث عن متجر أو محل أو تاكسي...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: hint, fontSize: 14),
              ),
            ),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.slidersHorizontal, size: 16, color: tint),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 2) بطاقة العالم 3D (الوضع العادي) + خريطة اختيارية ----------
  /// ★ العادي = الكرة الأرضية الدوّارة _worldCardInner كما كانت قبل المكتبات.
  /// الخريطة الحقيقية لا تظهر إلا إذا فعّلها المستخدم من زر «الخريطة».
  Widget _liveMapCard() {
    final loc = context.watch<LocationController>();
    final useReal = AppPrefs.useRealMaps;
    final label = context.textColors.primary;
    final tint = context.iconColors.primary;
    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      borderRadius: BorderRadius.circular(28),
      opacity: widget.isDark ? 0.05 : 0.1,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(useReal ? 'الخريطة الحية' : 'العالم',
                  style: TextStyle(color: label, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (useReal) {
                    await MapStyleSelector.show(context);
                  } else {
                    await AppPrefs.setUseRealMaps(true);
                  }
                  if (context.mounted) setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(useReal ? LucideIcons.layers : LucideIcons.map,
                        size: 13, color: tint),
                      const SizedBox(width: 4),
                      Text(useReal ? 'نمط الخريطة' : 'الخريطة',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tint)),
                    ],
                  ),
                ),
              ),
              if (useReal) ...[
                const SizedBox(width: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await AppPrefs.setUseRealMaps(false);
                    if (context.mounted) setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.globe, size: 13, color: tint),
                        const SizedBox(width: 4),
                        Text('كرة 3D',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tint)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (useReal)
            GestureDetector(
              onTap: () => ConfirmLocationSheet.show(context),
              child: AbsorbPointer(
                child: RealMapView(
                  initialCenter: loc.activeLatLng,
                  initialZoom: 13, height: 200,
                  interactive: false, showLocateButton: false,
                  useStoredStyle: true,
                ),
              ),
            )
          else
            _worldCardInner(),
        ],
      ),
    );
  }

  // ---------- بطاقة العالم 3D الأصلية (الوضع العادي قبل المكتبات) ----------
  Widget _worldCardInner() {
    final tint = context.iconColors.primary;
    final label = context.textColors.primary;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text('العالم',
                style: TextStyle(color: label, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            Text('موقعك الحالي',
              style: TextStyle(
                color: context.textColors.secondary,
                fontSize: 12)),
            const SizedBox(width: 4),
            Icon(LucideIcons.locateFixed, size: 14, color: tint),
          ],
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.2, -0.2),
                      radius: 1.1,
                      colors: [
                        tint.withValues(alpha: 0.18),
                        context.backgroundColors.primary,
                      ],
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _GlobeGridPainter(
                      line: context.textColors.secondary.withValues(alpha: 0.28)),
                  ),
                ),
                const Center(child: _SpinningGlobe()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
///  NearbyServicesSection — تبويبات وقائمة «الأقرب إليك» (المتاجر/المحلات/التكاسي/...).
///  تُستخدم في صفحة موقعي (MapExploreSection) وداخل شيت اختيار الموقع (LocationPickerSheet).
/// ============================================================================
class NearbyServicesSection extends StatefulWidget {
  final bool isDark;

  const NearbyServicesSection({super.key, required this.isDark});

  @override
  State<NearbyServicesSection> createState() => _NearbyServicesSectionState();
}

class _NearbyServicesSectionState extends State<NearbyServicesSection> {
  final ScrollController _tabsController = ScrollController();
  int _tab = 0;

  @override
  void dispose() {
    _tabsController.dispose();
    super.dispose();
  }

  /// جهات التبويب النشط.
  List<_NearbyPlace> get _nearbyForTab => _tabs[_tab].places;

  /// ★ تبويبات «الأقرب إليك» — تغطي كل خدمات التطبيق، وكل تبويب له جهاته
  ///   القريبة بنفس الشكل (بروفايل + حالة اتصال + زر تواصل).
  static const List<_NearbyTab> _tabs = [
    _NearbyTab('المتاجر', [
      _NearbyPlace('متجر الحلويات', 'حلويات شرقية وغربية', true, '', '🍰', 0.4),
      _NearbyPlace(
        'متجر الملابس',
        'أزياء رجالية ونسائية',
        false,
        'آخر ظهور قبل 5 دقائق',
        '👕',
        0.8,
      ),
      _NearbyPlace('متجر الأمانة', 'بقالة ومواد غذائية', true, '', '🛒', 1.2),
      _NearbyPlace(
        'متجر Florence',
        'عطور ومستحضرات',
        false,
        'آخر ظهور قبل 12 دقيقة',
        '🌸',
        1.6,
      ),
    ]),
    _NearbyTab('المحلات', [
      _NearbyPlace('محل بيفوت', 'ملابس رجالية', true, '', '🧥', 0.3),
      _NearbyPlace(
        'محل الأثاث الحديث',
        'طقم صالون كامل',
        false,
        'آخر ظهور قبل 8 دقائق',
        '🛋️',
        0.9,
      ),
      _NearbyPlace('محل الإلكترونيات', 'هواتف وإكسسوارات', true, '', '📱', 1.4),
      _NearbyPlace(
        'محل الزهور',
        'تنسيق هدايا ومناسبات',
        false,
        'آخر ظهور قبل 20 دقيقة',
        '💐',
        2.1,
      ),
    ]),
    _NearbyTab('التكاسي', [
      _NearbyPlace(
        'تاكسي أحمد',
        'سيارة فضة · التوصيل خلال 4 دقائق',
        true,
        '',
        '🚕',
        0.2,
      ),
      _NearbyPlace(
        'تاكسي النور',
        'سيارة بيضاء · التوصيل خلال 6 دقائق',
        false,
        'آخر ظهور قبل 3 دقائق',
        '🚙',
        0.7,
      ),
      _NearbyPlace(
        'تاكسي السرعة',
        'سيارة سوداء · التوصيل خلال 9 دقائق',
        true,
        '',
        '🚖',
        1.5,
      ),
    ]),
    _NearbyTab('الوكالات', [
      _NearbyPlace(
        'وكالة النور للسيارات',
        'تأجير سيارات وتأمين',
        true,
        '',
        '🚗',
        0.5,
      ),
      _NearbyPlace(
        'وكالة الأمانة العقارية',
        'بيع وتأجير عقارات',
        false,
        'آخر ظهور قبل 7 دقائق',
        '🏢',
        1.1,
      ),
      _NearbyPlace('وكالة الشحن السريع', 'شحن بري وبحري', true, '', '📦', 1.9),
    ]),
    _NearbyTab('المطاعم', [
      _NearbyPlace('مطعم السراج', 'مشاوي ومشويات', true, '', '🍽️', 0.4),
      _NearbyPlace(
        'مطعم البيت',
        'مأكولات عربية',
        false,
        'آخر ظهور قبل 10 دقائق',
        '🍲',
        0.9,
      ),
      _NearbyPlace('مطعم البحر', 'مأكولات بحرية', true, '', '🦐', 1.5),
    ]),
    _NearbyTab('الصيدليات', [
      _NearbyPlace(
        'صيدلية الحياة',
        'أدوية ومستلزمات طبية',
        true,
        '',
        '💊',
        0.3,
      ),
      _NearbyPlace(
        'صيدلية الشفاء',
        'مستلزمات الأم والطفل',
        false,
        'آخر ظهور قبل 15 دقيقة',
        '🩺',
        1.0,
      ),
    ]),
    _NearbyTab('التوصيل', [
      _NearbyPlace(
        'فريق توصيل گريب',
        'توصيل خلال 30 دقيقة',
        true,
        '',
        '🚚',
        0.6,
      ),
      _NearbyPlace('توصيل سريع', 'توصيل داخل المدينة', true, '', '🛵', 1.3),
    ]),
    _NearbyTab('العقارات', [
      _NearbyPlace('شقق النخيل', 'شقق للإيجار', true, '', '🏠', 0.8),
      _NearbyPlace(
        'مكاتب الأفق',
        'مكاتب تجارية',
        false,
        'آخر ظهور قبل 14 دقيقة',
        '🏢',
        1.7,
      ),
    ]),
    _NearbyTab('الترفيه', [
      _NearbyPlace('صالة السلام', 'ألعاب جماعية', true, '', '🎳', 1.2),
      _NearbyPlace(
        'مقهى الأصيل',
        'قهوة مختصة',
        false,
        'آخر ظهور قبل 6 دقائق',
        '☕',
        0.6,
      ),
    ]),
    _NearbyTab('الصحة', [
      _NearbyPlace('مركز LIFE الصحي', 'فحوصات دورية', true, '', '🩺', 1.4),
      _NearbyPlace(
        'مختبر برود',
        'تحاليل مخبرية',
        false,
        'آخر ظهور قبل 25 دقيقة',
        '🧪',
        2.2,
      ),
    ]),
    _NearbyTab('الرياضة', [
      _NearbyPlace('نادي النصر الرياضية', 'تدريب وألعاب', true, '', '🏋️', 0.9),
      _NearbyPlace(
        'ملعب الوصل',
        'حجز ملاعب',
        false,
        'آخر ظهور قبل 18 دقيقة',
        '⚽',
        1.8,
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = context.textColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${_tabs[_tab].label} الأقرب إليك',
          style: TextStyle(
            color: primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _tabsBar(),
        const SizedBox(height: 14),
        _nearbyList(),
      ],
    );
  }

  // ---------- تبويبات الأقرب إليك ----------
  Widget _tabsBar() {
    final inactive = context.textColors.secondary;
    final active = context.textColors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        controller: _tabsController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final selected = i == _tab;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _tab = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                child: Text(
                  _tabs[i].label,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected ? active : inactive,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------- قائمة «الأقرب إليك» ----------
  Widget _nearbyList() {
    final tint = context.iconColors.primary;
    final primary = context.textColors.primary;
    final secondary = context.textColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _nearbyForTab.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _nearbyCard(
            _nearbyForTab[i],
            tint: tint,
            primary: primary,
            secondary: secondary,
          ),
        ],
      ],
    );
  }

  Widget _nearbyCard(
    _NearbyPlace place, {
    required Color tint,
    required Color primary,
    required Color secondary,
  }) {
    final presence = place.online ? 'متصل الآن' : place.lastSeen;
    final quiet = context.backgroundColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: quiet),
            child: Text(place.emoji, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  place.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondary, fontSize: 11.5),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: place.online
                            ? AppColors.success
                            : secondary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        presence,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: place.online ? tint : secondary,
                          fontSize: 11,
                          fontWeight: place.online
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      ' · ${place.distance} كم',
                      style: TextStyle(color: secondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => context.push('/chat'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: tint.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.messageCircle, size: 15, color: tint),
                  const SizedBox(width: 5),
                  Text(
                    'تواصل الآن',
                    style: TextStyle(
                      color: tint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
///  _NearbyTab — تبويب «الأقرب إليك» (اسم + جهاته القريبة).
/// ============================================================================
class _NearbyTab {
  final String label;
  final List<_NearbyPlace> places;

  const _NearbyTab(this.label, this.places);
}

/// ============================================================================
///  _NearbyPlace — جهة قريبة واحدة (متجر/محل/تاكسي/وكالة/مطعم…).
/// ============================================================================
class _NearbyPlace {
  final String name;
  final String category;

  /// متصل الآن = true، وإلا فنص آخر ظهور في [lastSeen].
  final bool online;
  final String lastSeen;

  /// رمز البروفايل.
  final String emoji;

  /// المسافة بالكيلومترات.
  final double distance;

  const _NearbyPlace(
    this.name,
    this.category,
    this.online,
    this.lastSeen,
    this.emoji,
    this.distance,
  );
}

/// ============================================================================
///  _GlobeGridPainter — شبكة خطوط الطول والعرض خلف الكرة (زخرفة).
/// ============================================================================
class _GlobeGridPainter extends CustomPainter {
  final Color line;

  const _GlobeGridPainter({required this.line});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // خطوط عرض (أفقية).
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // خطوط طول (عمودية).
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GlobeGridPainter oldDelegate) => oldDelegate.line != line;
}

/// ============================================================================
///  _SpinningGlobe — الكرة الأرضية الدوّارة (مكوّن 3 دي مبسّط).
///
///  طبقة دوّارة مستقلة (RotationTransition) ⇒ زاوية دوران واحدة محسوبة
///  هنا بدل تحريك الويدجت أو إعادة بناء الشجرة كل إطار.
/// ============================================================================
class _SpinningGlobe extends StatefulWidget {
  const _SpinningGlobe();

  @override
  State<_SpinningGlobe> createState() => _SpinningGlobeState();
}

class _SpinningGlobeState extends State<_SpinningGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  /// ★ مواقع تقريبية (خط العرض/الطول) تُعرض كنقاط على الكرة.
  static const List<List<double>> _pins = [
    [25.2, 55.3], // دبي
    [24.7, 46.7], // الرياض
    [30.0, 31.2], // القاهرة
    [31.2, 34.8], // القدس
    [33.5, 36.3], // دمشق
    [21.4, 39.8], // مكة
    [15.4, 44.2], // صنعاء
  ];

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      width: 128,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, _) => CustomPaint(
          painter: _GlobePainter(
            turns: _spin.value,
            brand: context.accentColor,
            background: context.backgroundColors.primary,
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
///  _GlobePainter — رسم الكرة: دوائر + قارات مبسّطة + نقاط المواقع.
/// ============================================================================
class _GlobePainter extends CustomPainter {
  /// دوران الكرة (0..1 دورة كاملة).
  final double turns;

  /// ★ لون الكرة من اللوحة المركزية (يسري مع تغيير الهوية فوراً).
  final Color brand;

  /// ★ لون الخلفية من اللوحة المركزية.
  final Color background;

  const _GlobePainter({
    required this.turns,
    required this.brand,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1) جسم الكرة: تدرّج كروي (فاتح أعلى اليمين ⇒ إحساس ثلاثي الأبعاد).
    final sphere = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 1.0,
        colors: [brand, background],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, sphere);

    // 2) خطوط الطول/العرض على سطح الكرة (دوران ⇒ حركة Continua).
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final phase = turns * 2 * math.pi;

    // خطوط عرض (موازاة أفقية، ثابتة).
    for (final lat in [-60.0, -30.0, 0.0, 30.0, 60.0]) {
      final dy = radius * math.sin(lat * math.pi / 180);
      final w = radius * math.cos(lat * math.pi / 180);
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(0, dy),
          width: w * 2,
          height: math.max(w * 0.28, radius * 0.16),
        ),
        line,
      );
    }

    // خطوط طول: نرسمها كدوائر عرضها يتقلّص مع دوران الكرة (illusion).
    for (var i = 0; i < 6; i++) {
      final lon = (i / 6) * 2 * math.pi + phase;
      final w = radius * math.cos(lon).abs();
      if (w < 1) continue;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: w * 2, height: radius * 2),
        line,
      );
    }

    // 3) حافة فاتحة رفيعة ⇒ ترسّخ الكروية.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.25),
    );

    // 4) نقاط المواقع الثابتة (أمام الكرة ⇒ إحداثياتها محسوبة نسبياً).
    final pins = _SpinningGlobeState._pins;
    final refLat = pins.first[0];
    final refLon = pins.first[1];
    for (final pin in pins) {
      final lat = pin[0];
      final lon = pin[1];
      // إسقاط تقريبي (إسقاط-toiيسبورث مبسّط) بالنسبة لمرجع دبي.
      final x = ((lon - refLon) * math.cos(lat * math.pi / 180)) / 90 * radius;
      final y = ((refLat - lat) / 90) * radius;
      final p = center.translate(x, y);
      // نقلة فقط داخل قرص الكرة.
      if ((p - center).distance > radius * 0.94) continue;
      canvas.drawCircle(p, 2.4, Paint()..color = AppColors.success);
    }
  }

  @override
  bool shouldRepaint(_GlobePainter oldDelegate) =>
      oldDelegate.turns != turns ||
      oldDelegate.brand != brand ||
      oldDelegate.background != background;
}
