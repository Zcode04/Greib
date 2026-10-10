import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'location_service.dart';
import 'mauritania_regions.dart';
import 'place_model.dart';

/// LocationController — متحكم الموقع الموحّد V3 (موريتانيا أولاً).
///
///  • المدن = ولايات موريتانيا الـ15 بإحداثيات ثابتة (Offline).
///  • بقية دول العالم: GPS حي + reverseGeocode ديناميكي.
///  • API القديم محفوظ: cities / city / cityName / setCity.

/// مدينة/ولاية — بإحداثيات ثابتة.
class AppCity {
  final String name;
  final List<String> areas;
  final double lat;
  final double lng;
  final MrRegion? mrRegion;

  const AppCity({
    required this.name,
    this.areas = const [],
    required this.lat,
    required this.lng,
    this.mrRegion,
  });

  LatLng get latLng => LatLng(lat, lng);

  /// اسم المنطقة + إحداثياتها — للعرض بجوار بعض.
  String get labelWithCoords =>
      '$name · ${lat.toStringAsFixed(4)}، ${lng.toStringAsFixed(4)}';
}

class LocationController extends ChangeNotifier {
  /// ولايات موريتانيا الـ15 — مولّدة من المصدر الوحيد للحقيقة.
  static List<AppCity> get cities => MauritaniaRegions.regions
      .map((r) => AppCity(
            name: r.nameAr,
            areas: [r.capitalAr, ...r.districts.map((d) => d.nameAr)],
            lat: r.lat,
            lng: r.lng,
            mrRegion: r,
          ))
      .toList();

  LocationController() {
    _init();
  }

  Future<void> _init() async {
    final ok = await LocationService.instance.hasPermission();
    if (ok) {
      await locateMe();
    }
  }

  AppCity? _city;
  AppCity get city => _city ?? cities.first;
  String get cityName => city.name;

  /// ── الموقع الحي ──
  LatLng? _gpsLatLng;
  LatLng get activeLatLng => _gpsLatLng ?? city.latLng;
  bool get hasGpsFix => _gpsLatLng != null;

  /// اسم المنطقة الحالي بجانب إحداثياتها — للعرض في الكبسولات.
  /// الاسم من الـ Geocoder أولاً (الحي الحقيقي)، والجدول الثابت احتياط Offline.
  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  /// هامش دقة آخر إصلاح GPS مقبول — null إذا كان الموقع يدوياً/افتراضياً.
  double? _accuracyMeters;
  double? get accuracyMeters => _accuracyMeters;

  String get currentLabelWithCoords {
    final p = activeLatLng;
    final name = _currentAddress.isEmpty ? cityName : _currentAddress;
    final coords =
        '${p.latitude.toStringAsFixed(4)}، ${p.longitude.toStringAsFixed(4)}';
    final acc = _accuracyMeters;
    if (acc == null) return '$name · $coords';
    return '$name · $coords · دقة ±${acc.round()}م';
  }

  bool _locating = false;
  bool get isLocating => _locating;

  /// المكان المؤكد من المستخدم (زر تأكيد الموقع).
  PlaceModel? _confirmedPlace;
  PlaceModel? get confirmedPlace => _confirmedPlace;

  void setCity(AppCity city) {
    if (city.name == _city?.name) return;
    _city = city;
    notifyListeners();
  }

  /// جلب موقع GPS الدقيق + تسمية المنطقة. آمن للنداء المتكرر.
  /// لا يعتمد إلا إصلاحاً حقيقياً بدقة مقبولة — وإلا يُبقي الموقع السابق كما هو.
  Future<LatLng> locateMe() async {
    if (_locating) return activeLatLng;
    _locating = true;
    notifyListeners();
    try {
      final fix = await LocationService.instance.currentFix();
      if (fix != null && fix.isAcceptable) {
        _gpsLatLng = fix.point;
        _accuracyMeters = fix.accuracyMeters;
        _currentAddress = await _resolveLabel(fix.point);
        if (MauritaniaRegions.isInsideMauritania(fix.point)) {
          _adoptNearestCity(fix.point);
        }
      }
    } finally {
      _locating = false;
      notifyListeners();
    }
    return activeLatLng;
  }

  /// تثبيت موقع من الخريطة (سحب الدبوس) — أو من إصلاح GPS عبر [accuracyMeters].
  Future<void> setGpsLatLng(LatLng p,
      {bool reverseGeocode = true, double? accuracyMeters}) async {
    _gpsLatLng = p;
    _accuracyMeters = accuracyMeters; // يدوي = null (لا دقة GPS مرتبطة).
    if (reverseGeocode) {
      _currentAddress = await _resolveLabel(p);
    }
    if (MauritaniaRegions.isInsideMauritania(p)) {
      _adoptNearestCity(p);
    }
    notifyListeners();
  }

  /// تسمية النقطة: الـ Geocoder أولاً (الاسم الحقيقي للحي/الشارع)،
  /// وعند فشله (Offline/لا نتائج) الجدول الثابت داخل موريتانيا.
  Future<String> _resolveLabel(LatLng p) async {
    final geocoded = await LocationService.instance.reverseGeocodeOrNull(p);
    if (geocoded != null && geocoded.isNotEmpty) return geocoded;
    if (MauritaniaRegions.isInsideMauritania(p)) {
      return MauritaniaRegions.regionLabel(p);
    }
    return '';
  }

  void confirmPlace(PlaceModel place) {
    _confirmedPlace = place;
    _gpsLatLng = place.latLng;
    notifyListeners();
  }

  /// أقرب مدينة للنقطة — تُحدّث كبسولة المدينة تلقائياً.
  void _adoptNearestCity(LatLng p) {
    const d = Distance();
    AppCity best = cities.first;
    var bestKm = double.infinity;
    for (final c in cities) {
      final km = d.as(LengthUnit.Kilometer, p, c.latLng);
      if (km < bestKm) {
        bestKm = km;
        best = c;
      }
    }
    _city = best;
  }
}
