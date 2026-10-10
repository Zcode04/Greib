import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:greib_menk/core/location/directions_service.dart';
import 'package:greib_menk/core/location/location_controller.dart';
import 'package:greib_menk/core/location/map_config.dart';
import 'package:greib_menk/core/location/place_model.dart';
import 'package:greib_menk/core/location/places_service.dart';

/// منظومة الخرائط الحقيقية: إحداثيات + بحث محلي + تبديل المزوّد.
void main() {
  group('AppCity — إحداثيات حقيقية', () {
    test('كل المدن لها lat/lng داخل الإمارات', () {
      for (final c in LocationController.cities) {
        expect(c.lat, greaterThan(22.0));
        expect(c.lat, lessThan(27.0));
        expect(c.lng, greaterThan(51.0));
        expect(c.lng, lessThan(57.0));
      }
    });

    test('دبي في موقعها الصحيح', () {
      final dubai = LocationController.cities.first;
      expect(dubai.name, 'دبي');
      expect(dubai.lat, closeTo(25.20, 0.01));
      expect(dubai.lng, closeTo(55.27, 0.01));
    });
  });

  group('LocationController — توافق رجعي', () {
    test('setCity يحافظ على API القديم', () {
      final c = LocationController();
      expect(c.cityName, 'دبي');
      c.setCity(LocationController.cities[1]);
      expect(c.cityName, 'أبوظبي');
    });

    test('activeLatLng يساوي إحداثية المدينة قبل GPS', () {
      final c = LocationController();
      expect(c.hasGpsFix, isFalse);
      expect(c.activeLatLng.latitude, closeTo(25.20, 0.01));
    });

    test('confirmPlace يثبّت الموقع', () {
      final c = LocationController();
      const p = PlaceModel(
        name: 'برج خليفة',
        address: 'داون تاون دبي',
        lat: 25.1972,
        lng: 55.2744,
      );
      c.confirmPlace(p);
      expect(c.confirmedPlace?.name, 'برج خليفة');
      expect(c.hasGpsFix, isTrue);
      expect(c.activeLatLng.latitude, closeTo(25.1972, 0.0001));
    });
  });

  group('PlacesService — بحث محلي فوري', () {
    test('البحث عن برج يجد برج خليفة', () async {
      final r = await PlacesService.instance.search('برج خليفة');
      expect(r, isNotEmpty);
      expect(r.first.lat, closeTo(25.1972, 0.001));
    });

    test('الاستعلام الفارغ يرجع المعالم مرتبة بالقرب', () async {
      final r = await PlacesService.instance.search(
        '',
        near: const LatLng(25.0805, 55.1403),
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
          name: 'n', address: 'a', lat: 25.1, lng: 55.2, cityName: 'دبي');
      final back = PlaceModel.fromJson(p.toJson());
      expect(back.lat, 25.1);
      expect(back.cityName, 'دبي');
    });
  });

  group('DirectionsService — fallback آمن', () {
    test('يرجع خطاً مستقيماً عند انقطاع الشبكة', () async {
      const from = LatLng(25.2048, 55.2708);
      const to = LatLng(25.1972, 55.2744);
      final route = await DirectionsService.instance.route(from, to);
      expect(route.points.length, greaterThanOrEqualTo(2));
      expect(route.distanceKm, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
