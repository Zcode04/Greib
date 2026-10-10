import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

/// بلدية موريتانية بحدودها الرسمية (مضلعات مبسّطة من بيانات OCHA/HDX).
/// التعرف على المنطقة هنا يقيني (نقطة داخل مضلع) وليس تخمين "الأقرب".
class MrCommuneZone {
  /// اسم البلدية (المصدر الرسمي لاتيني).
  final String commune;

  /// اسم المقاطعة لاتيني + عربي (فارغ إن لم تُترجم).
  final String moughataa;
  final String moughataaAr;

  /// اسم الولاية بالعربية.
  final String wilayaAr;

  /// [minLng, minLat, maxLng, maxLat] — فلتر سريع قبل فحص المضلع.
  final List<double> bbox;

  /// حلقات خارجية؛ كل نقطة [lng, lat].
  final List<List<List<double>>> rings;

  const MrCommuneZone({
    required this.commune,
    required this.moughataa,
    required this.moughataaAr,
    required this.wilayaAr,
    required this.bbox,
    required this.rings,
  });

  /// تسمية كاملة: بلدية · مقاطعة · ولاية — تُسقط الأجزاء غير المعروفة.
  String get label {
    final mo = moughataaAr.isNotEmpty ? moughataaAr : moughataa;
    if (mo.isEmpty || mo == '0') return '$commune · $wilayaAr';
    return '$commune · $mo · $wilayaAr';
  }
}

/// محرك التعرف اليقيني على المناطق الإدارية الموريتانية — يعمل Offline بالكامل.
class MrAdminZones {
  MrAdminZones._();
  static final MrAdminZones instance = MrAdminZones._();

  static const _assetPath = 'assets/geo/mr_communes.json';

  List<MrCommuneZone>? _zones;
  bool _loadFailed = false;

  /// تحميل كسول مرة واحدة — آمن للنداء المتكرر.
  Future<void> ensureLoaded() async {
    if (_zones != null || _loadFailed) return;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final list = json.decode(raw) as List<dynamic>;
      _zones = list.map((e) {
        final m = e as Map<String, dynamic>;
        return MrCommuneZone(
          commune: m['c'] as String,
          moughataa: m['m'] as String,
          moughataaAr: (m['ma'] as String?) ?? '',
          wilayaAr: m['w'] as String,
          bbox: (m['bb'] as List).cast<num>().map((v) => v.toDouble()).toList(),
          rings: (m['rings'] as List)
              .map((r) => (r as List)
                  .map((pt) => (pt as List).cast<num>().map((v) => v.toDouble()).toList())
                  .toList())
              .toList(),
        );
      }).toList();
    } catch (_) {
      _loadFailed = true;
    }
  }

  /// البلدية التي تقع فيها النقطة — null خارج موريتانيا أو عند فشل التحميل.
  MrCommuneZone? findCommune(LatLng p) {
    final zones = _zones;
    if (zones == null) return null;
    for (final z in zones) {
      final bb = z.bbox;
      if (p.longitude < bb[0] || p.latitude < bb[1] ||
          p.longitude > bb[2] || p.latitude > bb[3]) {
        continue;
      }
      for (final ring in z.rings) {
        if (_pointInRing(p.longitude, p.latitude, ring)) return z;
      }
    }
    return null;
  }

  /// تسمية يقينية للنقطة: بلدية · مقاطعة · ولاية — أو null خارج الحدود.
  String? labelFor(LatLng p) => findCommune(p)?.label;

  /// Ray casting — عدد تقاطعات فردي = النقطة داخل الحلقة.
  static bool _pointInRing(double x, double y, List<List<double>> ring) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i][0], yi = ring[i][1];
      final xj = ring[j][0], yj = ring[j][1];
      if ((yi > y) != (yj > y) &&
          x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }
}
