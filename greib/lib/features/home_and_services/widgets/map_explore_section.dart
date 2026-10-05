import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared_widgets/glass_container.dart';

/// ============================================================================
///  MapExploreSection — قسم «استكشف القريب منك».
///
///  ★ الترتيب من الأعلى:
///    1) شريط البحث (كبسولة علوية).
///    2) بطاقة العالم — الكرة الأرضية ثلاثية الأبعاد (CustomPaint).
///    3) ثلاثة تبويبات: المتاجر / المحلات / التكاسي الأقرب إليك،
///       والمؤشر (نقطة/خط صغير) يظهر فوق التبويب النشط في المنتصف.
///
///  ملاحظة: الكرة مرسومة بـ CustomPaint حالياً (بلا مكتب�� خرائط) — تُستبدل
///  لاحقاً بطبقة خرائط حقيقية بنفس الواجهة والتبويبات.
/// ============================================================================
class MapExploreSection extends StatefulWidget {
  final bool isDark;

  const MapExploreSection({super.key, required this.isDark});

  @override
  State<MapExploreSection> createState() => _MapExploreSectionState();
}

class _MapExploreSectionState extends State<MapExploreSection> {
  /// التبويب النشط: 0 = المتاجر، 1 = المحلات، 2 = التكاسي.
  int _tab = 0;

  static const List<String> _tabs = [
    'المتاجر الأقرب إليك',
    'المحلات الأقرب إليك',
    'التكاسي الأقرب إليك',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchBar(),
        const SizedBox(height: 14),
        _worldCard(),
        const SizedBox(height: 14),
        _tabsBar(),
      ],
    );
  }

  // ---------- 1) شريط البحث العلوي ----------
  Widget _searchBar() {
    final tint = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final hint = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(24),
      opacity: widget.isDark ? 0.06 : 0.1,
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 18, color: hint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ابحث عن متجر أو محل أو تاكسي…',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: hint, fontSize: 14),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.slidersHorizontal, size: 16, color: tint),
          ),
        ],
      ),
    );
  }

  // ---------- 2) بطاقة العالم (الكرة ثلاثية الأبعاد) ----------
  Widget _worldCard() {
    final tint = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final label = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      borderRadius: BorderRadius.circular(28),
      opacity: widget.isDark ? 0.05 : 0.1,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'العالم',
                  style: TextStyle(
                    color: label,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'موقعك الحالي',
                style: TextStyle(
                  color: widget.isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.locateFixed, size: 14, color: tint),
            ],
          ),
          const SizedBox(height: 12),
          // ★ الكرة: نسبة ثابتة حتى لا تتشوّه على أي شاشة.
          AspectRatio(
            aspectRatio: 1.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية متدرّجة (توهّج نيون داكن / أزرق فاتح).
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.2, -0.2),
                        radius: 1.1,
                        colors: widget.isDark
                            ? [
                                tint.withValues(alpha: 0.18),
                                AppColors.background,
                              ]
                            : [
                                tint.withValues(alpha: 0.12),
                                AppColors.lightSurface,
                              ],
                      ),
                    ),
                  ),
                  // شبكة خطوط الطول/العرض (بلا تفاعل — طبقة زخرفية فقط).
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _GlobeGridPainter(
                        line:
                            (widget.isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary)
                                .withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                  // الكرة الدوّارة + نقاط approximates المواقع.
                  const Center(child: _SpinningGlobe()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 3) التبويبات الثلاثة + مؤشر التبويب النشط ----------
  Widget _tabsBar() {
    final tint = widget.isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final inactive = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final active = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    return Row(
      children: List.generate(_tabs.length, (i) {
        final selected = i == _tab;
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _tab = i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ★ المؤشر: يظهر في الأعلى فوق التبويب النشط فقط.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 3,
                    width: selected ? 22 : 0,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    // ★ لا فيض النص على الشاشات الضيقة.
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _tabs[i],
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? active : inactive,
                        fontSize: 12.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
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
        builder: (context, _) =>
            CustomPaint(painter: _GlobePainter(turns: _spin.value)),
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

  const _GlobePainter({required this.turns});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1) جسم الكرة: تدرّج كروي (فاتح أعلى اليمين ⇒ إحساس ثلاثي الأبعاد).
    final sphere = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 1.0,
        colors: [Color(0xFF3B82F6), Color(0xFF0F172A)],
        stops: [0.0, 1.0],
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
      canvas.drawCircle(p, 2.4, Paint()..color = const Color(0xFF10B981));
    }
  }

  @override
  bool shouldRepaint(_GlobePainter oldDelegate) => oldDelegate.turns != turns;
}
