import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../location/location_controller.dart';
import '../location/location_service.dart';
import '../location/map_config.dart';
import '../storage/app_prefs.dart';

import '../extensions/context_extensions.dart';
import '../theme/design_tokens.dart';
import 'location_permission_prompt.dart';

/// ============================================================================
///  RealMapView — خريطة OSM/CartoDB/Esri حقيقية بموقع GPS حي.
///
///  جديد v2:
///   • يقرأ نمط الخريطة من AppPrefs.mapStyleIndex (عادي/داكن/أقمار).
///   • زر "موقعي" يطلب إذن GPS احترافياً ثم ينتقل للموقع الحقيقي.
///   • مؤشر Pulse نيون على الموقع الحالي.
///   • يحترم interactive=false بالكامل (للبطاقة المصغرة).
/// ============================================================================
class RealMapView extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<Marker> extraMarkers;
  final bool showLocateButton;
  final bool interactive;
  final double height;
  final ValueChanged<LatLng>? onCenterChanged;
  final MapController? controller;

  /// إذا true يستخدم نمط الخريطة المحفوظ في AppPrefs بدلاً من اختيار dark/light تلقائياً.
  final bool useStoredStyle;

  const RealMapView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 14.0,
    this.extraMarkers = const [],
    this.showLocateButton = true,
    this.interactive = true,
    this.height = 260,
    this.onCenterChanged,
    this.controller,
    this.useStoredStyle = true,
  });

  @override
  State<RealMapView> createState() => RealMapViewState();
}

class RealMapViewState extends State<RealMapView>
    with SingleTickerProviderStateMixin {
  late final MapController _ctrl;
  bool _ownsController = false;

  // ── Pulse animation للموقع الحي ──
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  LatLng? _myLocation;
  bool _locating = false;

  MapController get mapController => _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? MapController();
    _ownsController = widget.controller == null;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // جلب الموقع المحفوظ إذا كان متاحاً.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshMyLocation());
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void moveTo(LatLng p, {double? zoom}) {
    try {
      _ctrl.move(p, zoom ?? _ctrl.camera.zoom);
    } catch (_) {}
  }

  /// يجلب الموقع الحقيقي ويتحرك إليه.
  Future<void> _refreshMyLocation({bool askPermission = false}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      bool ok = await LocationService.instance.ensurePermission();
      if (!ok && askPermission && mounted) {
        ok = await LocationPermissionPrompt.request(context);
      }
      if (!ok) return;
      final fix = await LocationService.instance.currentFix();
      // لا نحرّك الخريطة لإصلاح فاشل أو رديء الدقة — أمانة العرض أولاً.
      if (fix == null || !fix.isAcceptable || !mounted) return;
      setState(() => _myLocation = fix.point);
      moveTo(fix.point, zoom: 16);
      // تحديث Controller أيضاً إذا كان موجوداً.
      if (mounted) {
        final loc = context.read<LocationController>();
        await loc.setGpsLatLng(fix.point, accuracyMeters: fix.accuracyMeters);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  MapProviderKind _tileKind() {
    if (widget.useStoredStyle) {
      return MapConfig.providerFromIndex(AppPrefs.mapStyleIndex);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MapConfig.providerFor(isDark);
  }

  @override
  void didUpdateWidget(RealMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCenter != oldWidget.initialCenter) {
      moveTo(widget.initialCenter, zoom: widget.initialZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final kind = _tileKind();
    // ★ كل الألوان من اللوحة المركزية (Color Palette) عبر السياق.
    final tint = context.iconColors.primary;

    // دمج الدبابيس: موقعي + Extra markers من الخارج.
    final markers = [
      ...widget.extraMarkers,
      if (_myLocation != null) _buildMyLocationMarker(tint),
    ];

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Stack(
          children: [
            // ── خريطة الخلفية ──
            FlutterMap(
              mapController: _ctrl,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: widget.initialZoom,
                interactionOptions: InteractionOptions(
                  flags: widget.interactive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
                onPositionChanged: (pos, _) {
                  widget.onCenterChanged?.call(pos.center);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConfig.tileUrl(kind),
                  subdomains: MapConfig.subdomains(kind),
                  userAgentPackageName: 'ae.greibmenk.app',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: markers),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(MapConfig.attribution(kind)),
                  ],
                ),
              ],
            ),

            // ── دبوس المركز (إذا لم تكن هناك دبابيس خارجية) ──
            if (widget.interactive && widget.extraMarkers.isEmpty)
              Center(
                child: IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 38,
                        color: context.iconColors.primary,
                        shadows: [
                          Shadow(
                            color: context.backgroundColors.scrim
                                .withValues(alpha: 0.38),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

            // ── زر "موقعي الحي" ──
            if (widget.showLocateButton && widget.interactive)
              Positioned(
                bottom: 28,
                left: 10,
                child: Material(
                  color: theme.colorScheme.surface.withValues(alpha: 0.95),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _refreshMyLocation(askPermission: true),
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: _locating
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: tint,
                              ),
                            )
                          : Icon(LucideIcons.locateFixed,
                              size: 20, color: tint),
                    ),
                  ),
                ),
              ),

            // ── بادج نمط الخريطة (أيقونة صغيرة علوية يمين) ──
            if (widget.interactive)
              Positioned(
                top: 12,
                right: 12,
                child: _KindBadge(kind: kind, isDark: isDark),
              ),
          ],
        ),
      ),
    );
  }

  /// بناء دبوس الموقع الحي مع تأثير Pulse.
  Marker _buildMyLocationMarker(Color tint) {
    return Marker(
      point: _myLocation!,
      width: 56,
      height: 56,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            // دائرة خارجية نابضة.
            Container(
              width: 48 * _pulseAnim.value,
              height: 48 * _pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tint.withValues(alpha: 0.20 * (1 - _pulseAnim.value + 0.4)),
              ),
            ),
            // نقطة المركز.
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tint,
                border: Border.all(color: context.textColors.onAccent, width: 2.5),
                boxShadow: [
                  BoxShadow(color: tint.withValues(alpha: 0.5), blurRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── بادج النمط الصغير ────────────────────────────────────────────────────────
class _KindBadge extends StatelessWidget {
  final MapProviderKind kind;
  final bool isDark;

  const _KindBadge({required this.kind, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (kind) {
      MapProviderKind.satellite => (
          'أقمار',
          LucideIcons.satellite,
          context.iconColors.success
        ),
      MapProviderKind.osmDark   => ('داكن', LucideIcons.moon,      const Color(0xFF8B5CF6)),
      MapProviderKind.osm       => ('عادي', LucideIcons.map,       context.accentColor),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.backgroundColors.scrim.withValues(alpha: 0.12),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
