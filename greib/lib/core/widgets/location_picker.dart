import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../location/location_controller.dart';
import '../location/mauritania_regions.dart';
import '../theme/design_tokens.dart';
import 'app_sheet.dart';

/// عنصر واحد في قائمة الاختيار — ولاية أو مقاطعة.
class _PlaceEntry {
  final String name;
  final String subtitle;
  final double lat;
  final double lng;
  final bool isRegion;
  final MrRegion region;

  const _PlaceEntry({
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lng,
    required this.isRegion,
    required this.region,
  });
}

/// LocationPickerSheet — «أنت الآن في …» مع كرة أرضية ثلاثية الأبعاد.
///
/// البنية: نص التعريف ← زر «تفاصيل موقعي» (يتمدد) ← الكرة الأرضية
/// ← زر «الأقرب إلى منطقتك» (يعرض القائمة، 3 عناصر + عرض المزيد).
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 3;
  static const double _cardRadius = 18;

  late final AnimationController _globeCtrl;

  int _visibleCount = _pageSize;
  bool _detailsOpen = false;
  bool _nearestOpen = false;

  @override
  void initState() {
    super.initState();
    _globeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    // تحديد الموقع تلقائياً عند فتح الشيت.
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

  @override
  void dispose() {
    _globeCtrl.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (!mounted) return;
    try {
      await context.read<LocationController>().locateMe();
    } catch (_) {
      // نكتفي بآخر موقع معروف عند الفشل.
    }
  }

  /// قائمة مسطّحة مرتبة: كل ولاية تليها مقاطعاتها مباشرة.
  static final List<_PlaceEntry> _entries = [
    for (final r in MauritaniaRegions.regions) ...[
      _PlaceEntry(
        name: r.nameAr,
        subtitle: 'ولاية · العاصمة ${r.capitalAr}',
        lat: r.lat,
        lng: r.lng,
        isRegion: true,
        region: r,
      ),
      for (final d in r.districts)
        _PlaceEntry(
          name: d.nameAr,
          subtitle: 'مقاطعة · ولاية ${r.nameAr}',
          lat: d.lat,
          lng: d.lng,
          isRegion: false,
          region: r,
        ),
    ],
  ];

  bool get _hasMore => _visibleCount < _entries.length;

  void _showMore() {
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, _entries.length);
    });
  }

  /// الدول العربية — موريتانيا فعّالة حالياً، والباقي قيد التطوير لاحقاً.
  static const List<(String, String)> _arabCountries = [
    ('🇲🇷', 'موريتانيا'),
    ('🇸🇦', 'السعودية'),
    ('🇦🇪', 'الإمارات'),
    ('🇶🇦', 'قطر'),
    ('🇰🇼', 'الكويت'),
    ('🇧🇭', 'البحرين'),
    ('🇴🇲', 'عُمان'),
    ('🇾🇪', 'اليمن'),
    ('🇮🇶', 'العراق'),
    ('🇸🇾', 'سوريا'),
    ('🇱🇧', 'لبنان'),
    ('🇯🇴', 'الأردن'),
    ('🇵🇸', 'فلسطين'),
    ('🇪🇬', 'مصر'),
    ('🇸🇩', 'السودان'),
    ('🇱🇾', 'ليبيا'),
    ('🇹🇳', 'تونس'),
    ('🇩🇿', 'الجزائر'),
    ('🇲🇦', 'المغرب'),
    ('🇩🇯', 'جيبوتي'),
    ('🇸🇴', 'الصومال'),
    ('🇰🇲', 'جزر القمر'),
  ];

  // ───────────────────────── مكوّنات مساعدة ─────────────────────────

  String _distanceLabel(double km) {
    if (km < 1) return 'أقل من 1 كم';
    if (km < 100) return '${km.toStringAsFixed(0)} كم';
    return '${(km / 10).round() * 10} كم';
  }

  void _select(BuildContext context, _PlaceEntry entry) {
    final city = AppCity(
      name: entry.name,
      areas: [entry.region.nameAr, entry.region.capitalAr],
      lat: entry.lat,
      lng: entry.lng,
      mrRegion: entry.region,
    );
    context.read<LocationController>().setCity(city);
    context.pop();
  }

  /// زر كبسولة مع سهم يدور عند الفتح.
  Widget _pillButton(
    ThemeData theme, {
    required String label,
    required bool open,
    required VoidCallback onTap,
  }) {
    final ink = theme.colorScheme.onSurface;
    return Material(
      color: ink.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(99),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(ink.withValues(alpha: 0.08)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: const Icon(LucideIcons.chevronDown, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// سطر «التسمية: القيمة» داخل بطاقة التفاصيل.
  Widget _detailRow(
    ThemeData theme, {
    required String label,
    required String value,
    VoidCallback? onTap,
    bool dropdown = false,
  }) {
    final ink = theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      overlayColor: WidgetStatePropertyAll(ink.withValues(alpha: 0.08)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 3,
        ),
        child: Row(
          children: [
            Text(
              '$label:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (dropdown) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: ink.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────── شاشة الدول ─────────────────────────

  void _showCountriesSheet(BuildContext context) {
    final theme = Theme.of(context);
    showAppSheet(
      context,
      scrollControlled: false,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'اختر الدولة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _arabCountries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final (flag, name) = _arabCountries[index];
                    final active = name == 'موريتانيا';
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: active
                          ? () => Navigator.of(sheetContext).pop()
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        child: Row(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? null
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                            if (!active)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'قريباً',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── البناء ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = context.watch<LocationController>();
    final ink = theme.colorScheme.onSurface;
    // اللوحة سوداء دائماً، فنجعل نصوصها فاتحة في الوضعين.
    final panelTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: theme.colorScheme.copyWith(
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
      ),
    );

    // موقع المستخدم الفعلي: GPS الحي إن وُجد، وإلا مركز المدينة المختارة.
    final point = location.activeLatLng;
    final nearestRegion = MauritaniaRegions.nearestRegion(point);
    final nearestDistrict =
        MauritaniaRegions.nearestDistrict(nearestRegion, point);
    final placeName = nearestDistrict?.nameAr ?? nearestRegion.nameAr;

    // ترتيب كل الأماكن حسب المسافة (تُحسب مرة واحدة لكل عنصر).
    const distCalc = Distance();
    final km = <_PlaceEntry, double>{
      for (final e in _entries)
        e: distCalc.as(LengthUnit.Kilometer, point, LatLng(e.lat, e.lng)),
    };
    final sorted = List<_PlaceEntry>.from(_entries)
      ..sort((a, b) => km[a]!.compareTo(km[b]!));
    final shown = sorted.take(_visibleCount).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── التعريف: أنت الآن في: ──
            const SizedBox(height: AppSpacing.sm),
            Text(
              location.isLocating ? 'جارٍ تحديد موقعك…' : 'أنت الآن في:',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            // اسم المنطقة تحت «أنت الآن في:» بخط كبير.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                placeName,
                key: ValueKey(placeName),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // ── الكرة الأرضية + لوحة التفاصيل تطفو فوقها ──
            const SizedBox(height:0),
            SizedBox(
              height: 365,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الكرة (اضغط عليها لإعادة تحديد الموقع).
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: location.isLocating ? null : _locate,
                      child: AnimatedOpacity(
                        opacity: _detailsOpen ? 0.7 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: CustomPaint(
                          painter: _GlobePainter(
                            t: _globeCtrl,
                            color: ink,
                            userLat: point.latitude * math.pi / 180,
                            userLng: point.longitude * math.pi / 180,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                  // اللوحة الزجاجية.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1).animate(anim),
                        child: child,
                      ),
                    ),
                    child: !_detailsOpen
                        ? const SizedBox.shrink(key: ValueKey('closed'))
                        : Container(
                            key: const ValueKey('open'),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              // خلفية سوداء بشفافية ضئيلة.
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius:
                                  BorderRadius.circular(_cardRadius + 4),
                              // ستروك ضئيل.
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 0.8,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _detailRow(
                                        panelTheme,
                                        label: 'الدولة',
                                        value: 'موريتانيا 🇲🇷',
                                        dropdown: true,
                                        onTap: () =>
                                            _showCountriesSheet(context),
                                      ),
                                      _detailRow(
                                        panelTheme,
                                        label: 'الولاية',
                                        value: nearestRegion.nameAr,
                                      ),
                                      if (nearestDistrict != null)
                                        _detailRow(
                                          panelTheme,
                                          label: 'المقاطعة',
                                          value: nearestDistrict.nameAr,
                                        ),
                                      _detailRow(
                                        panelTheme,
                                        label: 'أنت الآن مضبوط في',
                                        value: location.cityName,
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: _pillButton(
                theme,
                label: 'تفاصيل موقعي',
                open: _detailsOpen,
                onTap: () => setState(() => _detailsOpen = !_detailsOpen),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, thickness: 1, color: ink.withValues(alpha: 0.12)),
            const SizedBox(height: AppSpacing.md),

            // ── الأقرب إلى منطقتك ──
            Center(
              child: _pillButton(
                theme,
                label: 'الأقرب إلى منطقتك',
                open: _nearestOpen,
                onTap: () => setState(() => _nearestOpen = !_nearestOpen),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !_nearestOpen
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Column(
                        children: [
                          for (final entry in shown) ...[
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                overlayColor: WidgetStatePropertyAll(
                                  ink.withValues(alpha: 0.08),
                                ),
                                onTap: () => _select(context, entry),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm + 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              entry.subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        _distanceLabel(km[entry]!),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color:
                                              theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          if (_hasMore)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xs),
                              child: SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: _showMore,
                                  icon: const Icon(LucideIcons.chevronDown,
                                      size: 18),
                                  label: Text(
                                    'عرض المزيد · ${_entries.length - _visibleCount} متبقٍ',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ink,
                                    side: BorderSide.none,
                                    backgroundColor:
                                        ink.withValues(alpha: 0.06),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// كرة أرضية إلكترونية (هولوغرام): شبكة خطوط طول/عرض + نقاط + مدار + نبض
/// عند موقع المستخدم. تتمايل ببطء حول موقعه فيبقى دائماً في مقدمة الكرة.
class _GlobePainter extends CustomPainter {
  final Animation<double> t;
  final Color color;
  final double userLat; // راديان
  final double userLng; // راديان

  _GlobePainter({
    required this.t,
    required this.color,
    required this.userLat,
    required this.userLng,
  }) : super(repaint: t);

  static const int _dotCount = 340;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 * 0.72;
    final tv = t.value;
    final sway = math.sin(tv * 2 * math.pi) * 0.55;
    final rot = -userLng + sway;
    final tiltCos = math.cos(userLat);
    final tiltSin = math.sin(userLat);

    // إسقاط نقطة (خط عرض/طول) على الشاشة: (x, y, z) مع z>0 = الوجه الأمامي.
    (double, double, double) proj(double lat, double lng) {
      final l = lng + rot;
      final x = math.cos(lat) * math.sin(l);
      final y = math.sin(lat);
      final z = math.cos(lat) * math.cos(l);
      final y2 = y * tiltCos - z * tiltSin;
      final z2 = y * tiltSin + z * tiltCos;
      return (x, y2, z2);
    }

    Offset scr((double, double, double) p) =>
        Offset(c.dx + p.$1 * r, c.dy - p.$2 * r);

    // الهالة.
    canvas.drawCircle(
      c,
      r * 1.4,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.7, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.4)),
    );

    // جسم الكرة وحافتها.
    canvas.drawCircle(c, r, Paint()..color = color.withValues(alpha: 0.035));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = color.withValues(alpha: 0.35),
    );

    // شبكة خطوط الطول والعرض.
    final front = Path();
    final back = Path();
    void seg(double la1, double ln1, double la2, double ln2) {
      final a = proj(la1, ln1);
      final b = proj(la2, ln2);
      final target = (a.$3 + b.$3) >= 0 ? front : back;
      final pa = scr(a);
      final pb = scr(b);
      target.moveTo(pa.dx, pa.dy);
      target.lineTo(pb.dx, pb.dy);
    }

    const rad = math.pi / 180;
    for (final latDeg in const [-60, -30, 0, 30, 60]) {
      const n = 64;
      for (var i = 0; i < n; i++) {
        seg(latDeg * rad, i / n * 2 * math.pi, latDeg * rad,
            (i + 1) / n * 2 * math.pi);
      }
    }
    for (var m = 0; m < 18; m++) {
      final lng = m * 20 * rad;
      for (var d = -90; d < 90; d += 6) {
        seg(d * rad, lng, (d + 6) * rad, lng);
      }
    }
    canvas.drawPath(
      back,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = color.withValues(alpha: 0.07),
    );
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = color.withValues(alpha: 0.38),
    );

    // نقاط إلكترونية موزعة بانتظام (فيبوناتشي).
    final dotPaint = Paint();
    const golden = math.pi * (3 - 2.2360679775);
    for (var i = 0; i < _dotCount; i++) {
      final y = 1 - 2 * (i + 0.5) / _dotCount;
      final lat = math.asin(y);
      final lng = i * golden;
      final p = proj(lat, lng);
      if (p.$3 <= 0) continue;
      dotPaint.color = color.withValues(alpha: 0.2 + 0.6 * p.$3);
      canvas.drawCircle(scr(p), 0.6 + 1.0 * p.$3, dotPaint);
    }

    // مدار حلقي مع قمر صناعي صغير.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.35);
    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: r * 2.6,
      height: r * 0.7,
    );
    canvas.drawOval(
      orbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = color.withValues(alpha: 0.2),
    );
    final a = tv * 2 * math.pi * 2;
    canvas.drawCircle(
      Offset(math.cos(a) * r * 1.3, math.sin(a) * r * 0.35),
      2.6,
      Paint()..color = color.withValues(alpha: 0.9),
    );
    canvas.restore();

    // موقع المستخدم: نقطة + نبضات.
    final me = scr(proj(userLat, userLng));
    for (var k = 0; k < 2; k++) {
      final phase = (tv * 4 + k * 0.5) % 1.0;
      canvas.drawCircle(
        me,
        5 + phase * 24,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: (1 - phase) * 0.55),
      );
    }
    canvas.drawCircle(me, 4.5, Paint()..color = color);
    canvas.drawCircle(
      me,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _GlobePainter old) =>
      old.color != color || old.userLat != userLat || old.userLng != userLng;
}