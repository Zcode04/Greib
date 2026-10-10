import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'location_service.dart';
import 'place_model.dart';

/// ============================================================================
///  LocationController — متحكم الموقع الموحّد V2 (متوافق رجعياً 100%).
///
///  • يحافظ على API القديم: cities / city / cityName / setCity — فلا ينكسر
///    أي ويدجت (StickyTabsBar / LocationPill / LocationPicker).
///  • يضيف: إحداثيات حقيقية لكل مدينة + موقع GPS حي + عنوان معكوس.
/// ============================================================================

/// مدينة ضمن التطبيق — الآن بإحداثيات حقيقية.
class AppCity {
  final String name;
  final List<String> areas;
  final double lat;
  final double lng;

  const AppCity({
    required this.name,
    this.areas = const [],
    required this.lat,
    required this.lng,
  });

  LatLng get latLng => LatLng(lat, lng);
}

class LocationController extends ChangeNotifier {
  /// المدن المدعومة — بإحداثيات عواصم حقيقية.
  static const List<AppCity> cities = [
    AppCity(name: 'دبي', areas: ['الممزر', 'ديرة', 'الكرامة', 'القصيص', 'البرشاء'], lat: 25.2048, lng: 55.2708),
    AppCity(name: 'أبوظبي', areas: ['مدينة خليفة', 'السعديات', 'الروضة', 'التل'], lat: 24.4539, lng: 54.3773),
    AppCity(name: 'الشارقة', areas: ['المجاز', 'النوف', 'الحيرة'], lat: 25.3463, lng: 55.4209),
    AppCity(name: 'العين', areas: ['وسط المدينة', 'الفلاح'], lat: 24.2075, lng: 55.7447),
    AppCity(name: 'عجمان', areas: ['البستان', 'الراشدية'], lat: 25.4052, lng: 55.5136),
    AppCity(name: 'رأس الخيمة', areas: ['المعيريض', 'الظيت'], lat: 25.7885, lng: 55.9593),
  ];

  LocationController() {
    _init();
  }

  Future<void> _init() async {
    final ok = await LocationService.instance.hasPermission();
    if (ok) {
      await locateMe();
    }
  }

  AppCity _city = cities.first;
  AppCity get city => _city;
  String get cityName => _city.name;

  /// ── الجديد: الموقع الحي ──
  LatLng? _gpsLatLng;
  LatLng get activeLatLng => _gpsLatLng ?? _city.latLng;
  bool get hasGpsFix => _gpsLatLng != null;

  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  bool _locating = false;
  bool get isLocating => _locating;

  /// المكان المؤكد من المستخدم (زر تأكيد الموقع).
  PlaceModel? _confirmedPlace;
  PlaceModel? get confirmedPlace => _confirmedPlace;

  void setCity(AppCity city) {
    if (city.name == _city.name) return;
    _city = city;
    notifyListeners();
  }

  /// جلب موقع GPS الحقيقي + عكس العنوان. آمن للنداء المتكرر.
  Future<LatLng> locateMe() async {
    if (_locating) return activeLatLng;
    _locating = true;
    notifyListeners();
    try {
      final p = await LocationService.instance.currentLatLng();
      _gpsLatLng = p;
      _currentAddress = await LocationService.instance.reverseGeocode(p);
      _adoptNearestCity(p);
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
      _currentAddress = await LocationService.instance.reverseGeocode(p);
    }
    _adoptNearestCity(p);
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
