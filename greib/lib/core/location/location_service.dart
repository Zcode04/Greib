import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'mauritania_regions.dart';

/// إصلاح GPS حقيقي — إحداثية + هامش الدقة بالأمتار.
class GpsFix {
  final LatLng point;
  final double accuracyMeters;
  const GpsFix({required this.point, required this.accuracyMeters});

  /// أسوأ دقة مقبولة — فوقها نعتبر الإصلاح غير موثوق.
  static const double kMaxAcceptableAccuracyM = 30;
  bool get isAcceptable => accuracyMeters <= kMaxAcceptableAccuracyM;
}

/// LocationService — GPS دقيق + Geocoding.
/// • الافتراضي = نواكشوط (موريتانيا أولاً).
/// • الدقة: LocationAccuracy.best للتماسك والصلابة.
/// • لا fallback صامت: currentFix يرجع null عند الفشل بدل إحداثية مزيّفة.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// نواكشوط — الإحداثية الافتراضية.
  static const LatLng kDefaultLatLng = MauritaniaRegions.kDefaultLatLng;

  LatLng? _lastKnown;
  LatLng? get lastKnown => _lastKnown;

  final Distance _distance = const Distance();

  /// هل خدمة الموقع مفعّلة + الإذن ممنوح سلفاً (بدون طلب)؟
  Future<bool> hasPermission() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return false;
      final perm = await Geolocator.checkPermission();
      return perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// هل خدمة الموقع مفعّلة + الإذن ممنوح؟
  Future<bool> ensurePermission() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return false;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return false;
      return perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// إصلاح GPS حقيقي بدقة عالية — يرجع null عند الفشل (لا قيمة مزيّفة أبداً).
  /// المتصل هو من يقرر الاحتياط (آخر موقع معروف / الافتراضي).
  ///
  /// يأخذ عيّنة أولى سريعة، فإن لم تبلغ دقة [kMaxAcceptableAccuracyM] يستمع
  /// لبث الحركة حتى [timeout] ويحتفظ بأدق قراءة — GPS يتحسّن مع ثوانٍ إضافية.
  Future<GpsFix?> currentFix({Duration timeout = const Duration(seconds: 12)}) async {
    try {
      final ok = await ensurePermission();
      if (!ok) return null;
      final first = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 8),
        ),
      ).timeout(const Duration(seconds: 9));
      _lastKnown = LatLng(first.latitude, first.longitude);
      var best = GpsFix(point: _lastKnown!, accuracyMeters: first.accuracy);
      if (best.isAcceptable) return best;

      // القراءة الأولى دون العتبة — نُكمل الاستماع حتى نهاية المهلة.
      const settings = LocationSettings(accuracy: LocationAccuracy.best);
      final stream = Geolocator.getPositionStream(locationSettings: settings);
      try {
        await for (final p in stream.timeout(timeout)) {
          final fix = GpsFix(
            point: LatLng(p.latitude, p.longitude),
            accuracyMeters: p.accuracy,
          );
          if (fix.accuracyMeters < best.accuracyMeters) {
            best = fix;
            _lastKnown = fix.point;
          }
          if (best.isAcceptable) break;
        }
      } on TimeoutException {
        // انتهت المهلة — نُرجع أدق قراءة وصلتنا والمتصل يحكم على قبولها.
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  /// بث الحركة الدقيق — للتتبع الحي.
  Stream<LatLng> positionStream() {
    try {
      const settings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      );
      return Geolocator.getPositionStream(locationSettings: settings)
          .map((p) {
        _lastKnown = LatLng(p.latitude, p.longitude);
        return _lastKnown!;
      }).handleError((_) => kDefaultLatLng);
    } catch (_) {
      return Stream.value(_lastKnown ?? kDefaultLatLng);
    }
  }

  /// تحويل إحداثية → عنوان عربي مقروء (مع fallback للإحداثيات).
  Future<String> reverseGeocode(LatLng point) async =>
      await reverseGeocodeOrNull(point) ?? _fallbackLabel(point);

  /// فرض العربية في نتائج الـ Geocoder — مرة واحدة لأنها إعداد عام.
  bool _localeForced = false;

  /// تحويل إحداثية → عنوان عربي مقروء، أو null عند الفشل (Offline/لا نتائج).
  Future<String?> reverseGeocodeOrNull(LatLng point) async {
    try {
      if (!_localeForced) {
        await geo.setLocaleIdentifier('ar');
        _localeForced = true;
      }
      final list = await geo.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (list.isEmpty) return null;
      final p = list.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.country,
      ].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();
      if (parts.isEmpty) return null;
      // نُبقي أول 3 مكونات حتى لا يطول العنوان في البطاقات.
      return parts.take(3).join('، ');
    } catch (_) {
      return null;
    }
  }

  String _fallbackLabel(LatLng p) =>
      '${p.latitude.toStringAsFixed(5)}، ${p.longitude.toStringAsFixed(5)}';

  /// المسافة بالكيلومتر بين نقطتين.
  double distanceKm(LatLng a, LatLng b) =>
      _distance.as(LengthUnit.Kilometer, a, b);

  /// فتح إعدادات الموقع / التطبيق عند الرفض الدائم.
  Future<void> openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {
      debugPrint('LocationService: cannot open settings');
    }
  }
}
