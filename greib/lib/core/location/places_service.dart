import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'location_service.dart';
import 'mauritania_regions.dart';
import 'place_model.dart';

/// PlacesService — بحث مجاني عبر Nominatim (بلا API Key).
/// • متحيز لموريتانيا (countrycodes=mr).
/// • نتائج محلية فورية: الولايات + المقاطعات + المعالم (Offline).

/// ============================================================================
///  PlacesService — بحث حقيقي مجاني عبر Nominatim (OpenStreetMap).
///
///  • بلا API Key — يعمل فوراً.
///  • debounce مدمج + حد أدنى 3 أحرف + إلغاء الطلبات القديمة.
///  • قاعدة محلية لموريتانيا كـ fallback عند انقطاع الإنترنت.
/// ============================================================================
class PlacesService {
  PlacesService._();
  static final PlacesService instance = PlacesService._();

  static const String _host = 'nominatim.openstreetmap.org';
  static const String _ua = 'greib-menk/1.0 (contact: support@greibmenk.mr)';

  Timer? _debounce;
  int _seq = 0;

  /// معالم موريتانية شهيرة — fallback فوري + نتائج عند البحث الفارغ.
  /// الإحداثيات ثابتة من MauritaniaRegions (مستقرة Offline).
  static const List<PlaceModel> uaeLandmarks = [
    PlaceModel(name: 'المسجد السعودي', address: 'تفرغ زينة، نواكشوط', lat: 18.0910, lng: -15.9950, cityName: 'نواكشوط الغربية'),
    PlaceModel(name: 'سوق العاصمة', address: 'لكصر، نواكشوط', lat: 18.1080, lng: -15.9785, cityName: 'نواكشوط الغربية'),
    PlaceModel(name: 'مطار نواكشوط أم التونسي', address: 'نواكشوط', lat: 18.0970, lng: -15.9470, cityName: 'نواكشوط الشمالية'),
    PlaceModel(name: 'ميناء نواكشوط', address: 'الميناء، نواكشوط', lat: 18.0430, lng: -16.0120, cityName: 'نواكشوط الجنوبية'),
    PlaceModel(name: 'ميناء نواذيبو', address: 'نواذيبو', lat: 20.9333, lng: -17.0333, cityName: 'داخلت نواذيبو'),
    PlaceModel(name: 'سوق كيفه المركزي', address: 'كيفه', lat: 16.6167, lng: -11.4000, cityName: 'لعصابة'),
    PlaceModel(name: 'سوق روصو', address: 'روصو', lat: 16.5000, lng: -15.2333, cityName: 'الترارزة'),
    PlaceModel(name: 'سوق النعمة', address: 'النعمة', lat: 16.6167, lng: -7.2500, cityName: 'الحوض الشرقي'),
    PlaceModel(name: 'سوق أطار', address: 'أطار', lat: 20.5167, lng: -13.0500, cityName: 'آدرار'),
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

    // 2) نتائج الشبكة (Nominatim) — متحيزة لموريتانيا.
    try {
      final uri = Uri.https(_host, '/search', {
        'q': '$q, موريتانيا',
        'format': 'jsonv2',
        'accept-language': 'ar',
        'countrycodes': 'mr',
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
    bool match(String s) =>
        s.contains(q) || s.replaceAll('ال', '').contains(needle);

    final out = <PlaceModel>[];
    // 1) الولايات — بإحداثيات ثابتة.
    for (final r in MauritaniaRegions.regions) {
      if (match(r.nameAr) || match(r.capitalAr)) {
        out.add(PlaceModel(
          name: r.nameAr,
          address: '${r.capitalAr} · ${r.coordsLabel()}',
          lat: r.lat,
          lng: r.lng,
          cityName: r.nameAr,
        ));
      }
      // 2) المقاطعات — بإحداثيات ثابتة.
      for (final d in r.districts) {
        if (match(d.nameAr)) {
          out.add(PlaceModel(
            name: d.nameAr,
            address: '${r.nameAr} · ${d.coordsLabel()}',
            lat: d.lat,
            lng: d.lng,
            cityName: r.nameAr,
          ));
        }
      }
      if (out.length >= 8) break;
    }
    // 3) المعالم.
    for (final p in uaeLandmarks) {
      if (p.name.contains(q) ||
          p.address.contains(q) ||
          p.name.replaceAll('ال', '').contains(needle) ||
          (p.cityName ?? '').contains(q)) {
        out.add(p);
      }
      if (out.length >= 10) break;
    }
    return out;
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
