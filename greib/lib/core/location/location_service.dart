import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'mauritania_regions.dart';

/// LocationService — GPS دقيق + Geocoding.
/// • الافتراضي = نواكشوط (موريتانيا أولاً).
/// • الدقة: LocationAccuracy.best للتماسك والصلابة.
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

  /// الموقع الحالي بدقة عالية (مع fallback لئلا يعلق الـ UI).
  Future<LatLng> currentLatLng({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      final ok = await ensurePermission();
      if (!ok) return _lastKnown ?? kDefaultLatLng;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(timeout);
      _lastKnown = LatLng(pos.latitude, pos.longitude);
      return _lastKnown!;
    } catch (_) {
      return _lastKnown ?? kDefaultLatLng;
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

  /// تحويل إحداثية → عنوان عربي مقروء.
  Future<String> reverseGeocode(LatLng point) async {
    try {
      final list = await geo.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (list.isEmpty) return _fallbackLabel(point);
      final p = list.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.country,
      ].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();
      if (parts.isEmpty) return _fallbackLabel(point);
      // نُبقي أول 3 مكونات حتى لا يطول العنوان في البطاقات.
      return parts.take(3).join('، ');
    } catch (_) {
      return _fallbackLabel(point);
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
