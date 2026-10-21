import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../features/home_and_services/widgets/map_explore_section.dart';
import '../location/location_controller.dart';
import '../location/mauritania_regions.dart';
import '../theme/design_tokens.dart';
import '../extensions/context_extensions.dart';
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
  /// [plain] يُستخدم عندما يوضع الزر داخل كبسولة خارجية مشتركة — يزيل الخلفية الفردية.
  /// [showIcon] يُظهر/يخفي أيقونة السهم المنبثق (تُعطّل داخل الكبسولة المشتركة إن ced إلى false).
  /// [icon] أيقونة ثابتة تُعرض إلى يسار نص الزر.
  /// [closedIcon] / [openIcon] أيقونتان تتغيران حسب حالة الفتح (تُOverride [icon] إن وُجدت).
  Widget _pillButton(
    ThemeData theme, {
    required String label,
    required bool open,
    required VoidCallback onTap,
    bool plain = false,
    bool showIcon = true,
    IconData? icon,
    IconData? closedIcon,
    IconData? openIcon,
  }) {
    final ink = theme.colorScheme.onSurface;
    // أيقونة جانبية ثابتة أو متغيرة حسب حالة الفتح.
    final sideIcon = open ? openIcon ?? closedIcon ?? icon : closedIcon ?? icon;
    if (plain) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sideIcon != null) ...[
                Icon(sideIcon, size: 16, color: ink),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: AppSpacing.xs),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: const Icon(LucideIcons.chevronDown, size: 18),
                ),
              ],
            ],
          ),
        ),
      );
    }
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
              if (sideIcon != null) ...[
                Icon(sideIcon, size: 16, color: ink),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: AppSpacing.xs),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: const Icon(LucideIcons.chevronDown, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────── لوحة التفاصيل (ستايل الهاكرز) ─────────────────────

  String _fmtCoord(double v, {required bool isLat}) {
    final hemi = isLat ? (v >= 0 ? 'N' : 'S') : (v >= 0 ? 'E' : 'W');
    return '${v.abs().toStringAsFixed(4)}° $hemi';
  }

  String _fmtDms(double v, {required bool isLat}) {
    final hemi = isLat ? (v >= 0 ? 'N' : 'S') : (v >= 0 ? 'E' : 'W');
    final total = (v.abs() * 3600).round();
    final d = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '$d°${m.toString().padLeft(2, '0')}′${s.toString().padLeft(2, '0')}″ $hemi';
  }

  /// خانة واحدة: تسمية صغيرة (معيّن صغير + نص) وتحتها القيمة.
  Widget _hackerCell(
    ThemeData t, {
    required String label,
    required Widget value,
    required double opacity,
    VoidCallback? onTap,
  }) {
    final onMedia = context.textColors.onMedia;
    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        overlayColor:
            WidgetStatePropertyAll(onMedia.withValues(alpha: 0.08)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: onMedia.withValues(alpha: 0.70),
                          width: 0.9,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: t.textTheme.labelMedium?.copyWith(
                      color: onMedia.withValues(alpha: 0.60),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              value,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHackerPanel(
    ThemeData t, {
    required String regionName,
    required String districtName,
    required String cityName,
    required LatLng point,
  }) {
    final onMedia = context.textColors.onMedia;
    final valueStyle = t.textTheme.titleLarge?.copyWith(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 1.2,
    );
    final mono = t.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final lineColor = onMedia.withValues(alpha: 0.18);

    return TweenAnimationBuilder<double>(
      key: const ValueKey('open'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, v, _) {
        // ظهور متتابع لكل خانة.
        double op(int i) => ((v - i * 0.14) / 0.4).clamp(0.0, 1.0);

        // الزاوية 1: الدولة
        final country = _hackerCell(
          t,
          label: 'الدولة',
          opacity: op(0),
          onTap: () => _showCountriesSheet(context),
          value: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'موريتانيا',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle,
                ),
              ),
              const SizedBox(width: 6),
              const Text('🇲🇷', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 2),
              Icon(
                LucideIcons.chevronDown,
                size: 14,
                color: onMedia.withValues(alpha: 0.54),
              ),
            ],
          ),
        );

        // الزاوية 2: الولاية
        final region = _hackerCell(
          t,
          label: 'الولاية',
          opacity: op(1),
          value: Text(
            regionName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        );

        // الزاوية 3: المقاطعة
        final district = _hackerCell(
          t,
          label: 'المقاطعة',
          opacity: op(2),
          value: Text(
            districtName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        );

        // الزاوية 4: الإحداثيات (أرقام صحيحة من الموقع الفعلي)
        final coords = _hackerCell(
          t,
          label: 'إحداثياتك',
          opacity: op(3),
          value: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmtCoord(point.latitude, isLat: true), style: mono),
                  const SizedBox(height: 2),
                  Text(_fmtCoord(point.longitude, isLat: false), style: mono),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmtDms(point.latitude, isLat: true)}  '
                    '${_fmtDms(point.longitude, isLat: false)}',
                    style: mono?.copyWith(
                      fontSize: 9.5,
                      color: onMedia.withValues(alpha: 0.54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            // خلفية سوداء بشفافية ضئيلة.
            color: context.backgroundColors.mediaScrim.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(_cardRadius + 4),
            // ستروك ضئيل.
            border: Border.all(
              color: onMedia.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
          child: CustomPaint(
            foregroundPainter: _CornerBracketsPainter(onMedia),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ترويسة اللوحة
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: onMedia,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: onMedia.withValues(alpha: 0.7),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تفاصيل الموقع',
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            cityName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.labelSmall
                                ?.copyWith(
                                  color: onMedia.withValues(alpha: 0.54),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.6, color: lineColor),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: country),
                        VerticalDivider(
                            width: 1, thickness: 0.6, color: lineColor),
                        Expanded(child: region),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.6, color: lineColor),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: district),
                        VerticalDivider(
                            width: 1, thickness: 0.6, color: lineColor),
                        Expanded(child: coords),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    // اللوحة سوداء دائماً، فنجعل نصوصها فاتحة في الوضعين ⇒ "على الوسائط".
    final onMedia = context.textColors.onMedia;
    final panelTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: onMedia,
        displayColor: onMedia,
      ),
      colorScheme: theme.colorScheme.copyWith(
        onSurface: onMedia,
        onSurfaceVariant: onMedia.withValues(alpha: 0.70),
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
            // اسم المنطقة تحت «أنت الآن في:» — يتلاشى عند ظهور اللوحة.
            AnimatedOpacity(
              opacity: _detailsOpen ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  placeName,
                  key: ValueKey(placeName),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 35,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // ── الكرة الأرضية + لوحة التفاصيل تطفو فوقها ──
            const SizedBox(height: 0),
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
                        : _buildHackerPanel(
                            panelTheme,
                            regionName: nearestRegion.nameAr,
                            districtName: nearestDistrict?.nameAr ?? '—',
                            cityName: location.cityName,
                            point: point,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pillButton(
                      theme,
                      label: 'تفاصيل موقعي',
                      open: _detailsOpen,
                      plain: true,
                      closedIcon: LucideIcons.chevronDown,
                      openIcon: LucideIcons.chevronUp,
                      showIcon: false,
                      onTap: () => setState(() => _detailsOpen = !_detailsOpen),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      width: 1.0,
                      height: 6,
                      color: theme.dividerColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _pillButton(
                      theme,
                      label: 'الأقرب إلى منطقتك',
                      open: _nearestOpen,
                      plain: true,
                      closedIcon: LucideIcons.mapPin,
                      openIcon: LucideIcons.chevronUp,
                      showIcon: false,
                      onTap: () => setState(() => _nearestOpen = !_nearestOpen),
                    ),
                  ],
                ),
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
                                    'عرض المزيد',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ink,
                                    side: BorderSide.none,
                                    backgroundColor:
                                        ink.withValues(alpha: 0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            NearbyServicesSection(isDark: theme.brightness == Brightness.dark),
          ],
        ),
      ),
    );
  }
}

/// أقواس زوايا رفيعة على لوحة التفاصيل (لمسة الهاكرز) — باللون الأبيض.
class _CornerBracketsPainter extends CustomPainter {
  final Color color;

  const _CornerBracketsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.7);
    const l = 14.0;
    const o = 8.0; // ابتعاد عن الحافة بسبب انحناء الزوايا
    final w = size.width, h = size.height;

    void corner(double x, double y, double dx, double dy) {
      canvas.drawPath(
        Path()
          ..moveTo(x + dx * l, y)
          ..lineTo(x, y)
          ..lineTo(x, y + dy * l),
        p,
      );
    }

    corner(o, o, 1, 1);
    corner(w - o, o, -1, 1);
    corner(o, h - o, 1, -1);
    corner(w - o, h - o, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter old) =>
      old.color != color;
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
    // حافة الكرة فقط (بدون هالة أو تعبئة).
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