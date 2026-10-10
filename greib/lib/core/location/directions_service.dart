import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// ============================================================================
///  DirectionsService — مسار حقيقي مجاني عبر OSRM (بلا API Key).
///
///  • يُرجع نقاط الـ polyline + المسافة + المدة.
///  • fallback: خط مستقيم منقّط عند فشل الشبكة.
/// ============================================================================
class RouteInfo {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;

  const RouteInfo({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });
}

class DirectionsService {
  DirectionsService._();
  static final DirectionsService instance = DirectionsService._();

  /// مسار القيادة بين نقطتين.
  Future<RouteInfo> route(LatLng from, LatLng to) async {
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'greib-menk/1.0'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('OSRM ${res.statusCode}');
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = json['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) throw Exception('no route');
      final r = routes.first as Map<String, dynamic>;
      final geom = r['geometry'] as Map<String, dynamic>;
      final coords = geom['coordinates'] as List<dynamic>;
      final points = coords.map((c) {
        final pair = c as List<dynamic>;
        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();
      if (points.isEmpty) throw Exception('empty geometry');
      return RouteInfo(
        points: points,
        distanceKm: ((r['distance'] as num?)?.toDouble() ?? 0) / 1000,
        durationMin: ((r['duration'] as num?)?.toDouble() ?? 0) / 60,
      );
    } catch (e) {
      debugPrint('DirectionsService fallback straight line: $e');
      const d = Distance();
      return RouteInfo(
        points: [from, to],
        distanceKm: d.as(LengthUnit.Kilometer, from, to),
        durationMin: d.as(LengthUnit.Kilometer, from, to) * 2,
      );
    }
  }
}
