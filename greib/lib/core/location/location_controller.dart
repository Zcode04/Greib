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
  /// داخل موريتانيا: من الجدول الثابت. خارجها: من reverseGeocode.
  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  String get currentLabelWithCoords {
    final p = activeLatLng;
    final name = _currentAddress.isEmpty ? cityName : _currentAddress;
    return '$name · ${p.latitude.toStringAsFixed(4)}، ${p.longitude.toStringAsFixed(4)}';
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
  Future<LatLng> locateMe() async {
    if (_locating) return activeLatLng;
    _locating = true;
    notifyListeners();
    try {
      final p = await LocationService.instance.currentLatLng();
      _gpsLatLng = p;
      if (MauritaniaRegions.isInsideMauritania(p)) {
        // ★ داخل موريتانيا: الاسم من الجدول الثابت (مستقر Offline).
        _currentAddress = MauritaniaRegions.regionLabel(p);
        _adoptNearestCity(p);
      } else {
        // ★ خارج موريتانيا: الاسم ديناميكي حسب الموقع الحالي.
        _currentAddress =
            await LocationService.instance.reverseGeocode(p);
      }
    } finally {
      _locating = false;
      notifyListeners();
    }
    return activeLatLng;
  }

  /// تثبيت موقع من الخريطة (سحب الدبوس).
  Future<void> setGpsLatLng(LatLng p, {bool reverseGeocode = true}) async {
    _gpsLatLng = p;
    if (reverseGeocode) {
      if (MauritaniaRegions.isInsideMauritania(p)) {
        _currentAddress = MauritaniaRegions.regionLabel(p);
      } else {
        _currentAddress =
            await LocationService.instance.reverseGeocode(p);
      }
    }
    if (MauritaniaRegions.isInsideMauritania(p)) {
      _adoptNearestCity(p);
    }
    notifyListeners();
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
