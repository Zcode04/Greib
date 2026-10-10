import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/location/location_controller.dart';
import '../../core/location/location_service.dart';
import '../../core/location/map_config.dart';
import '../../core/location/place_model.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/location_permission_prompt.dart';
import '../../core/widgets/globe_3d.dart';
import '../../core/widgets/map_style_selector.dart';
import '../../core/widgets/place_search_sheet.dart';
import '../../shared_widgets/glass_container.dart';

/// ============================================================================
///  MapsScreen — شاشة الموقع الكاملة.
///
///  ★ الوضع العادي = الكرة الأرضية 3D (التصميم الأصلي قبل المكتبات).
///  الخريطة الحقيقية اختيارية: تظهر فقط عند ضغط زر «الخريطة».
/// ============================================================================
class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  final MapController _map = MapController();
  LatLng _center = LocationService.kDefaultLatLng;
  String _address = 'جارٍ تحديد موقعك…';
  Marker? _picked;
  bool _ready = false;

  /// ★ هل الخريطة الحقيقية مفعّلة؟ الافتراضي = false (كرة 3D).
  bool _showRealMap = false;

  // ── نمط الخريطة ──
  late MapProviderKind _kind;

  // ── موقع GPS الحي + Pulse animation ──
  LatLng? _myLocation;
  /// هامش دقة آخر إصلاح GPS — null عند اختيار يدوي/سحب الخريطة.
  double? _accuracyM;
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _kind = MapConfig.providerFromIndex(AppPrefs.mapStyleIndex);

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _boot();
  }

  @override
  void dispose() {
    _map.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    // طلب الإذن أولاً (إذا لم يُمنح بعد) — بدون حجز context عبر الفجوات.
    final ok = await LocationService.instance.ensurePermission();
    if (!mounted) return;
    if (!ok) {
      final granted = await LocationPermissionPrompt.request(context);
      if (!granted) {
        // fallback: استخدام الإحداثي الافتراضي.
        if (mounted) setState(() => _ready = true);
        return;
      }
    }

    if (!mounted) return;
    final loc = context.read<LocationController>();
    final p   = await loc.locateMe();
    if (!mounted) return;
    setState(() {
      _center     = p;
      _myLocation = loc.hasGpsFix ? p : null;
      _address    = loc.currentAddress.isEmpty
          ? 'تعذّر تحديد موقعك — فعّل GPS وحاول مجدداً'
          : loc.currentAddress;
      _accuracyM  = loc.accuracyMeters;
      _ready      = true;
    });
    _move(p, 15);
  }

  void _move(LatLng p, double zoom) {
    try { _map.move(p, zoom); } catch (_) {}
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final ok = await LocationService.instance.ensurePermission();
      if (!ok && mounted) {
        await LocationPermissionPrompt.request(context);
        return;
      }
      final fix = await LocationService.instance.currentFix();
      // إصلاح فاشل أو رديء = لا نحرّك الخريطة ولا نعرض موقعاً وهمياً.
      if (fix == null || !fix.isAcceptable || !mounted) return;
      // التسمية عبر الكنترولر: الـ Geocoder أولاً، وجدول موريتانيا احتياطاً.
      final loc = context.read<LocationController>();
      await loc.setGpsLatLng(fix.point, accuracyMeters: fix.accuracyMeters);
      if (!mounted) return;
      setState(() {
        _myLocation = fix.point;
        _center     = fix.point;
        _accuracyM  = fix.accuracyMeters;
        if (loc.currentAddress.isNotEmpty) _address = loc.currentAddress;
      });
      _move(fix.point, 16);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _search() async {
    final picked = await PlaceSearchSheet.show(context, near: _center);
    if (picked == null || !mounted) return;
    setState(() {
      _center = picked.latLng;
      _address = picked.address;
      _picked = Marker(
        point: picked.latLng,
        width: 48,
        height: 48,
        child: const Icon(LucideIcons.mapPin, size: 44, color: Colors.redAccent),
      );
    });
    _move(picked.latLng, 16);
  }

  Future<void> _pickStyle() async {
    final picked = await MapStyleSelector.show(context);
    if (picked != null && mounted) {
      setState(() => _kind = picked);
      // إعادة بناء الخريطة بالنمط الجديد.
    }
  }

  List<Marker> get _allMarkers {
    final list = <Marker>[];
    final picked = _picked;
    if (picked != null) list.add(picked);
    final myLoc = _myLocation;
    if (myLoc != null) list.add(_myLocationMarker);
    return list;
  }

  Marker get _myLocationMarker => Marker(
    point: _myLocation!,
    width: 56,
    height: 56,
    child: AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48 * _pulseAnim.value,
            height: 48 * _pulseAnim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neon.withValues(alpha: 0.20 * (1 - _pulseAnim.value + 0.4)),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neon,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [BoxShadow(color: AppColors.neon.withValues(alpha: 0.5), blurRadius: 8)],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;

    return Scaffold(
      body: Stack(
        children: [
          // ★ الوضع العادي: الكرة 3D تملأ الخلفية.
          // الخريطة الحقيقية تظهر فقط عند تفعيل _showRealMap.
          if (_showRealMap)
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 14,
                onPositionChanged: (pos, _) async {
                  _center = pos.center;
                  if (!_ready) return;
                  _accuracyM = null; // سحب يدوي — لا دقة GPS مرتبطة.
                  final addr = await LocationService.instance
                      .reverseGeocode(_center);
                  if (mounted) setState(() => _address = addr);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConfig.tileUrl(_kind),
                  subdomains: MapConfig.subdomains(_kind),
                  userAgentPackageName: 'ae.greibmenk.app',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: _allMarkers),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(MapConfig.attribution(_kind)),
                  ],
                ),
              ],
            )
          else
            _globeBackground(isDark),

          // ── دبوس المركز (للخريطة الحقيقية فقط) ──
          if (_showRealMap && _picked == null)
            Center(
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mapPin,
                        size: 44,
                        color: AppColors.accentFor(isDark),
                        shadows: const [Shadow(color: Colors.black38, blurRadius: 10)]),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

          // ── Loading overlay ──
          if (!_ready)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // ── شريط الأعلى: رجوع + عنوان + بحث ──
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _search,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: BorderRadius.circular(24),
                opacity: isDark ? 0.8 : 0.9,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowRight),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_accuracyM != null)
                            Text(
                              'دقة GPS: ±${_accuracyM!.round()} م',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.search,
                        color: isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark),
                  ],
                ),
              ),
            ),
          ),

          // ── أزرار الجانب: موقعي + تبديل كرة/خريطة + نمط الخريطة ──
          Positioned(
            bottom: 200,
            right: 16,
            child: Column(
              children: [
                _MapFab(
                  icon: _locating
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(LucideIcons.locateFixed, size: 20, color: Colors.white),
                  color: tint,
                  onTap: _locateMe,
                  tooltip: 'موقعي',
                ),
                const SizedBox(height: 12),
                // ★ زر التبديل: كرة 3D ←→ خريطة حقيقية.
                _MapFab(
                  icon: Icon(_showRealMap ? LucideIcons.globe : LucideIcons.map,
                      size: 20, color: Colors.white),
                  color: _showRealMap ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
                  onTap: () => setState(() => _showRealMap = !_showRealMap),
                  tooltip: _showRealMap ? 'الوضع العادي (كرة 3D)' : 'الخريطة الحقيقية',
                ),
                if (_showRealMap) ...[
                  const SizedBox(height: 12),
                  _MapFab(
                    icon: Icon(_kindIcon(_kind), size: 20, color: Colors.white),
                    color: _kindColor(_kind),
                    onTap: _pickStyle,
                    tooltip: 'نمط الخريطة',
                  ),
                ],
              ],
            ),
          ),

          // ── Bottom Sheet: الأماكن المحفوظة + زر التأكيد ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.background : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('الأماكن المحفوظة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          (isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark)
                              .withValues(alpha: 0.2),
                      child: Icon(LucideIcons.home,
                          color: isDark
                              ? AppColors.accentPrimary
                              : AppColors.accentPrimaryDark),
                    ),
                    title: const Text('المنزل',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('دبي مارينا, برج الأميرة'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.info.withValues(alpha: 0.2),
                      child: const Icon(LucideIcons.briefcase, color: AppColors.info),
                    ),
                    title: const Text('العمل',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('مركز دبي المالي العالمي'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final place = PlaceModel(
                        name: 'موقع محدد',
                        address: _address,
                        lat: _center.latitude,
                        lng: _center.longitude,
                        cityName: context.read<LocationController>().cityName,
                      );
                      context.read<LocationController>().confirmPlace(place);
                      context.pop(place);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.onAccentPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('تأكيد الموقع',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ★ خلفية الكرة 3D للوضع العادي — تملأ الشاشة خلف البطاقة السفلية.
  Widget _globeBackground(bool isDark) {
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFE8EEF5);
    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 120),
            // الكرة في الوسط.
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.neon : AppColors.accentPrimaryDark)
                          .withValues(alpha: 0.25),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Globe3D(size: 280),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'العالم',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _address,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _kindIcon(MapProviderKind k) => switch (k) {
    MapProviderKind.satellite => LucideIcons.satellite,
    MapProviderKind.osmDark   => LucideIcons.moon,
    MapProviderKind.osm       => LucideIcons.map,
  };

  Color _kindColor(MapProviderKind k) => switch (k) {
    MapProviderKind.satellite => const Color(0xFF10B981),
    MapProviderKind.osmDark   => const Color(0xFF8B5CF6),
    MapProviderKind.osm       => const Color(0xFF3B82F6),
  };
}

// ── FAB صغير للجانب ─────────────────────────────────────────────────────────
class _MapFab extends StatelessWidget {
  final Widget icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _MapFab({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: color.withValues(alpha: 0.4),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: icon,
          ),
        ),
      ),
    );
  }
}
