import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:greib_menk/core/location/directions_service.dart';
import 'package:greib_menk/core/location/location_controller.dart';
import 'package:greib_menk/core/location/map_config.dart';
import 'package:greib_menk/core/location/mauritania_regions.dart';
import 'package:greib_menk/core/location/place_model.dart';
import 'package:greib_menk/core/location/places_service.dart';

/// منظومة الموقع — موريتانيا أولاً: ولايات ثابتة + GPS دقيق + بحث محلي.
void main() {
  group('MauritaniaRegions — الولايات الـ15 ثابتة', () {
    test('عدد الولايات 15', () {
      expect(MauritaniaRegions.regions.length, 15);
    });

    test('كل الولايات داخل حدود موريتانيا', () {
      for (final r in MauritaniaRegions.regions) {
        expect(MauritaniaRegions.isInsideMauritania(r.latLng), isTrue,
            reason: r.nameAr);
      }
    });

    test('نواكشوط الجنوبية في موقعها الصحيح', () {
      final nkc = MauritaniaRegions.regions.first;
      expect(nkc.nameAr, 'نواكشوط الجنوبية');
      expect(nkc.lat, closeTo(18.0858, 0.001));
      expect(nkc.lng, closeTo(-15.9785, 0.001));
    });

    test('نقطة دبي خارج موريتانيا', () {
      expect(
        MauritaniaRegions.isInsideMauritania(const LatLng(25.2, 55.3)),
        isFalse,
      );
    });

    test('regionLabel يعرض المقاطعة والولاية', () {
      final label = MauritaniaRegions.regionLabel(
        const LatLng(18.0589, -15.9690),
      );
      expect(label, contains('عرفات'));
    });
  });

  group('LocationController — موريتانيا أولاً', () {
    test('المدن = الولايات الـ15', () {
      expect(LocationController.cities.length, 15);
      expect(LocationController.cities.first.name, 'نواكشوط الجنوبية');
    });

    test('setCity يحافظ على API القديم', () {
      final c = LocationController();
      expect(c.cityName, 'نواكشوط الجنوبية');
      c.setCity(LocationController.cities[9]);
      expect(c.cityName, 'آدرار');
    });

    test('activeLatLng يساوي نواكشوط قبل GPS', () {
      final c = LocationController();
      expect(c.hasGpsFix, isFalse);
      expect(c.activeLatLng.latitude, closeTo(18.0858, 0.001));
    });

    test('currentLabelWithCoords يعرض الاسم + الإحداثيات', () {
      final c = LocationController();
      expect(c.currentLabelWithCoords, contains('نواكشوط الجنوبية'));
      expect(c.currentLabelWithCoords, contains('18.0858'));
    });

    test('confirmPlace يثبّت الموقع', () {
      final c = LocationController();
      const p = PlaceModel(
        name: 'سوق العاصمة',
        address: 'لكصر، نواكشوط',
        lat: 18.1080,
        lng: -15.9785,
      );
      c.confirmPlace(p);
      expect(c.confirmedPlace?.name, 'سوق العاصمة');
      expect(c.hasGpsFix, isTrue);
      expect(c.activeLatLng.latitude, closeTo(18.1080, 0.0001));
    });
  });

  group('PlacesService — بحث موريتاني فوري', () {
    test('البحث عن نواكشوط يجد الولايات الثلاث', () async {
      final r = await PlacesService.instance.search('نواكشوط');
      expect(r.length, greaterThanOrEqualTo(3));
      expect(r.first.cityName, contains('نواكشوط'));
    });

    test('البحث عن كيفه يجد الولاية بإحداثيات ثابتة', () async {
      final r = await PlacesService.instance.search('كيفه');
      expect(r, isNotEmpty);
      expect(r.first.lat, closeTo(16.6167, 0.001));
    });

    test('الاستعلام الفارغ يرجع المعالم مرتبة بالقرب', () async {
      final r = await PlacesService.instance.search(
        '',
        near: const LatLng(18.0858, -15.9785),
      );
      expect(r, isNotEmpty);
      expect(r.first.distanceKm, isNotNull);
    });
  });

  group('MapConfig — التبديل الاحترافي', () {
    test('الوضع العادي = الكرة 3D (kUseRealMaps معطّل افتراضياً)', () {
      expect(MapConfig.kUseRealMaps, isFalse);
    });

    test('الوضع الداكن يستخدم بلاطات داكنة', () {
      expect(MapConfig.providerFor(true), MapProviderKind.osmDark);
      expect(MapConfig.providerFor(false), MapProviderKind.osm);
    });

    test('روابط البلاطات صالحة', () {
      for (final k in MapProviderKind.values) {
        expect(MapConfig.tileUrl(k), contains('https://'));
      }
    });
  });

  group('PlaceModel', () {
    test('distanceLabel يعرض م/كم بشكل صحيح', () {
      const near = PlaceModel(
          name: 'a', address: 'b', lat: 0, lng: 0, distanceKm: 0.4);
      const far = PlaceModel(
          name: 'a', address: 'b', lat: 0, lng: 0, distanceKm: 2.35);
      expect(near.distanceLabel(), '400 م');
      expect(far.distanceLabel(), '2.4 كم');
    });

    test('toJson/fromJson دائرية', () {
      const p = PlaceModel(
          name: 'n', address: 'a', lat: 18.08, lng: -15.97,
          cityName: 'نواكشوط الجنوبية');
      final back = PlaceModel.fromJson(p.toJson());
      expect(back.lat, 18.08);
      expect(back.cityName, 'نواكشوط الجنوبية');
    });
  });

  group('DirectionsService — fallback آمن', () {
    test('يرجع خطاً مستقيماً عند انقطاع الشبكة', () async {
      const from = LatLng(18.0858, -15.9785);
      const to = LatLng(18.1080, -15.9785);
      final route = await DirectionsService.instance.route(from, to);
      expect(route.points.length, greaterThanOrEqualTo(2));
      expect(route.distanceKm, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
