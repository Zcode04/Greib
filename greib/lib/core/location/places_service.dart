import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'location_service.dart';
import 'place_model.dart';

/// ============================================================================
///  PlacesService — بحث حقيقي مجاني عبر Nominatim (OpenStreetMap).
///
///  • بلا API Key — يعمل فوراً.
///  • debounce مدمج + حد أدنى 3 أحرف + إلغاء الطلبات القديمة.
///  • قاعدة محلية للإمارات كـ fallback عند انقطاع الإنترنت.
/// ============================================================================
class PlacesService {
  PlacesService._();
  static final PlacesService instance = PlacesService._();

  static const String _host = 'nominatim.openstreetmap.org';
  static const String _ua = 'greib-menk/1.0 (contact: support@greibmenk.ae)';

  Timer? _debounce;
  int _seq = 0;

  /// معالم إماراتية شهيرة — fallback فوري + نتائج عند البحث الفارغ.
  static const List<PlaceModel> uaeLandmarks = [
    PlaceModel(name: 'برج خليفة', address: 'داون تاون دبي، دبي', lat: 25.1972, lng: 55.2744, cityName: 'دبي'),
    PlaceModel(name: 'دبي مارينا', address: 'دبي مارينا، دبي', lat: 25.0805, lng: 55.1403, cityName: 'دبي'),
    PlaceModel(name: 'مول الإمارات', address: 'البرشاء، دبي', lat: 25.0805, lng: 55.1210, cityName: 'دبي'),
    PlaceModel(name: 'جزيرة ياس', address: 'جزيرة ياس، أبوظبي', lat: 24.4889, lng: 54.6050, cityName: 'أبوظبي'),
    PlaceModel(name: 'جامع الشيخ زايد', address: 'أبوظبي', lat: 24.4128, lng: 54.4753, cityName: 'أبوظبي'),
    PlaceModel(name: 'كورنيش الشارقة', address: 'المجاز، الشارقة', lat: 25.3306, lng: 55.3870, cityName: 'الشارقة'),
    PlaceModel(name: 'جبل جيس', address: 'رأس الخيمة', lat: 25.9500, lng: 56.1833, cityName: 'رأس الخيمة'),
    PlaceModel(name: 'كورنيش عجمان', address: 'عجمان', lat: 25.4052, lng: 55.5136, cityName: 'عجمان'),
    PlaceModel(name: 'جبل حفيت', address: 'العين', lat: 24.0567, lng: 55.7783, cityName: 'العين'),
  ];

  void dispose() => _debounce?.cancel();

  /// بحث مع debounce — يُلغي النداءات القديمة تلقائياً.
  void searchDebounced(
    String query,
    void Function(List<PlaceModel> results, bool loading) onResult, {
    LatLng? near,
    Duration delay = const Duration(milliseconds: 350),
  }) {
    _debounce?.cancel();
    final q = query.trim();
    if (q.length < 2) {
      onResult(_nearbyLandmarks(near), false);
      return;
    }
    onResult(const [], true);
    _debounce = Timer(delay, () async {
      final results = await search(q, near: near);
      onResult(results, false);
    });
  }

  /// بحث مباشر (يُستخدم من الاختبارات / النداء الواحد).
  Future<List<PlaceModel>> search(String query, {LatLng? near}) async {
    final q = query.trim();
    if (q.isEmpty) return _nearbyLandmarks(near);
    final mySeq = ++_seq;

    // 1) نتائج محلية فورية (تظهر قبل الشبكة).
    final local = _searchLocal(q);

    // 2) نتائج الشبكة (Nominatim) — تُدمج مع المحلية.
    try {
      final uri = Uri.https(_host, '/search', {
        'q': '$q, الإمارات',
        'format': 'jsonv2',
        'accept-language': 'ar',
        'countrycodes': 'ae',
        'limit': '7',
        'addressdetails': '1',
      });
      final res = await http
          .get(uri, headers: {'User-Agent': _ua})
          .timeout(const Duration(seconds: 8));
      if (mySeq != _seq) return local; // طلب أحدث تجاوز هذا الطلب.
      if (res.statusCode != 200) return local;
      final raw = jsonDecode(res.body) as List<dynamic>;
      final remote = raw.map((e) {
        final m = e as Map<String, dynamic>;
        final lat = double.tryParse('${m['lat']}') ?? 0;
        final lng = double.tryParse('${m['lon']}') ?? 0;
        final display = '${m['display_name'] ?? q}';
        final addr = m['address'] as Map<String, dynamic>?;
        final city = addr == null
            ? null
            : '${addr['city'] ?? addr['town'] ?? addr['state'] ?? ''}';
        return PlaceModel(
          name: '${m['name'] ?? q}',
          address: display.length > 90 ? '${display.substring(0, 87)}…' : display,
          lat: lat,
          lng: lng,
          cityName: (city ?? '').isEmpty ? null : city,
        );
      }).where((p) => p.lat != 0).toList();
      final merged = [...local];
      for (final r in remote) {
        if (merged.any((l) => _samePlace(l, r))) continue;
        merged.add(r);
      }
      final origin = near ?? LocationService.instance.lastKnown;
      if (origin != null) {
        const d = Distance();
        return merged
            .map((p) => p.copyWith(
                distanceKm: d.as(LengthUnit.Kilometer, origin, p.latLng)))
            .toList()
          ..sort((a, b) =>
              (a.distanceKm ?? 9999).compareTo(b.distanceKm ?? 9999));
      }
      return merged;
    } catch (e) {
      debugPrint('PlacesService.search fallback: $e');
      return local;
    }
  }

  List<PlaceModel> _searchLocal(String q) {
    final needle = q.replaceAll('ال', '');
    return uaeLandmarks.where((p) {
      return p.name.contains(q) ||
          p.address.contains(q) ||
          p.name.replaceAll('ال', '').contains(needle) ||
          (p.cityName ?? '').contains(q);
    }).toList();
  }

  List<PlaceModel> _nearbyLandmarks(LatLng? near) {
    if (near == null) return uaeLandmarks;
    const d = Distance();
    return uaeLandmarks
        .map((p) => p.copyWith(
            distanceKm: d.as(LengthUnit.Kilometer, near, p.latLng)))
        .toList()
      ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
  }

  bool _samePlace(PlaceModel a, PlaceModel b) =>
      (a.lat - b.lat).abs() < 0.0005 && (a.lng - b.lng).abs() < 0.0005;
}
