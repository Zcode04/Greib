import 'package:latlong2/latlong.dart';

// ولايات موريتانيا الـ15 بإحداثيات ثابتة — المصدر الوحيد (Offline).
class MrRegion {
  final String nameAr;
  final String capitalAr;
  final double lat;
  final double lng;
  final List<MrDistrict> districts;
  const MrRegion({required this.nameAr, required this.capitalAr,
    required this.lat, required this.lng, this.districts = const []});
  LatLng get latLng => LatLng(lat, lng);
  String coordsLabel() => '${lat.toStringAsFixed(4)}، ${lng.toStringAsFixed(4)}';
}

class MrDistrict {
  final String nameAr;
  final double lat;
  final double lng;
  const MrDistrict({required this.nameAr, required this.lat, required this.lng});
  LatLng get latLng => LatLng(lat, lng);
  String coordsLabel() => '${lat.toStringAsFixed(4)}، ${lng.toStringAsFixed(4)}';
}

class MauritaniaRegions {
  MauritaniaRegions._();
  static const LatLng kDefaultLatLng = LatLng(18.0858, -15.9785);
  static const double minLat = 14.5;
  static const double maxLat = 27.3;
  static const double minLng = -17.2;
  static const double maxLng = -4.5;
  static bool isInsideMauritania(LatLng p) =>
      p.latitude >= minLat && p.latitude <= maxLat &&
      p.longitude >= minLng && p.longitude <= maxLng;

  static const List<MrRegion> regions = [
    MrRegion(nameAr: 'نواكشوط الجنوبية', capitalAr: 'نواكشوط',
      lat: 18.0858, lng: -15.9785, districts: [
        MrDistrict(nameAr: 'عرفات', lat: 18.0589, lng: -15.9690),
        MrDistrict(nameAr: 'الميناء', lat: 18.0430, lng: -16.0120),
        MrDistrict(nameAr: 'الرياض', lat: 18.0750, lng: -15.9400)]),
    MrRegion(nameAr: 'نواكشوط الشمالية', capitalAr: 'دار النعيم',
      lat: 18.1150, lng: -15.9600, districts: [
        MrDistrict(nameAr: 'دار النعيم', lat: 18.1150, lng: -15.9600),
        MrDistrict(nameAr: 'تيارت', lat: 18.1350, lng: -15.9750),
        MrDistrict(nameAr: 'توجنين', lat: 18.1550, lng: -15.9450)]),
    MrRegion(nameAr: 'نواكشوط الغربية', capitalAr: 'تفرغ زينة',
      lat: 18.0950, lng: -16.0050, districts: [
        MrDistrict(nameAr: 'تفرغ زينة', lat: 18.0950, lng: -16.0050),
        MrDistrict(nameAr: 'لكصر', lat: 18.1050, lng: -15.9950),
        MrDistrict(nameAr: 'السبخة', lat: 18.0750, lng: -16.0200)]),
    MrRegion(nameAr: 'الحوض الشرقي', capitalAr: 'النعمة',
      lat: 16.6167, lng: -7.2500, districts: [
        MrDistrict(nameAr: 'النعمة', lat: 16.6167, lng: -7.2500),
        MrDistrict(nameAr: 'باسكنو', lat: 15.8667, lng: -6.9333),
        MrDistrict(nameAr: 'ولاتة', lat: 17.3000, lng: -7.0333)]),
    MrRegion(nameAr: 'الحوض الغربي', capitalAr: 'العيون',
      lat: 16.6667, lng: -9.6167, districts: [
        MrDistrict(nameAr: 'العيون', lat: 16.6667, lng: -9.6167),
        MrDistrict(nameAr: 'كوبني', lat: 15.8000, lng: -9.3833),
        MrDistrict(nameAr: 'الطينطان', lat: 16.3833, lng: -10.1667)]),
    MrRegion(nameAr: 'لعصابة', capitalAr: 'كيفه',
      lat: 16.6167, lng: -11.4000, districts: [
        MrDistrict(nameAr: 'كيفه', lat: 16.6167, lng: -11.4000),
        MrDistrict(nameAr: 'باركيول', lat: 16.5167, lng: -11.2333)]),
    MrRegion(nameAr: 'غورغول', capitalAr: 'كيهيدي',
      lat: 16.1500, lng: -13.5000, districts: [
        MrDistrict(nameAr: 'كيهيدي', lat: 16.1500, lng: -13.5000),
        MrDistrict(nameAr: 'مونغل', lat: 16.0167, lng: -13.3333)]),
    MrRegion(nameAr: 'البراكنة', capitalAr: 'ألاك',
      lat: 17.0500, lng: -13.9167, districts: [
        MrDistrict(nameAr: 'ألاك', lat: 17.0500, lng: -13.9167),
        MrDistrict(nameAr: 'بوغي', lat: 16.5833, lng: -14.2667)]),
    MrRegion(nameAr: 'الترارزة', capitalAr: 'روصو',
      lat: 16.5000, lng: -15.2333, districts: [
        MrDistrict(nameAr: 'روصو', lat: 16.5000, lng: -15.2333),
        MrDistrict(nameAr: 'بوتلميت', lat: 17.0333, lng: -14.7833)]),
    MrRegion(nameAr: 'آدرار', capitalAr: 'أطار',
      lat: 20.5167, lng: -13.0500, districts: [
        MrDistrict(nameAr: 'أطار', lat: 20.5167, lng: -13.0500),
        MrDistrict(nameAr: 'شنقيط', lat: 20.4500, lng: -12.3500),
        MrDistrict(nameAr: 'وادان', lat: 20.9333, lng: -11.6167)]),
    MrRegion(nameAr: 'داخلت نواذيبو', capitalAr: 'نواذيبو',
      lat: 20.9333, lng: -17.0333, districts: [
        MrDistrict(nameAr: 'نواذيبو', lat: 20.9333, lng: -17.0333),
        MrDistrict(nameAr: 'الشامي', lat: 21.0000, lng: -16.1000)]),
    MrRegion(nameAr: 'تكانت', capitalAr: 'تجكجة',
      lat: 18.4333, lng: -11.4333, districts: [
        MrDistrict(nameAr: 'تجكجة', lat: 18.4333, lng: -11.4333)]),
    MrRegion(nameAr: 'كيدي ماغا', capitalAr: 'سيلبابي',
      lat: 15.1500, lng: -12.1833, districts: [
        MrDistrict(nameAr: 'سيلبابي', lat: 15.1500, lng: -12.1833),
        MrDistrict(nameAr: 'غابو', lat: 15.0333, lng: -12.5667)]),
    MrRegion(nameAr: 'إنشيري', capitalAr: 'أكجوجت',
      lat: 19.7500, lng: -14.3833, districts: [
        MrDistrict(nameAr: 'أكجوجت', lat: 19.7500, lng: -14.3833)]),
    MrRegion(nameAr: 'تيرس زمور', capitalAr: 'ازويرات',
      lat: 22.6833, lng: -12.4833, districts: [
        MrDistrict(nameAr: 'ازويرات', lat: 22.6833, lng: -12.4833),
        MrDistrict(nameAr: 'افديرك', lat: 22.6667, lng: -12.6833)]),
  ];

  static MrRegion nearestRegion(LatLng p) {
    const d = Distance();
    var best = regions.first;
    var bestKm = double.infinity;
    for (final r in regions) {
      final km = d.as(LengthUnit.Kilometer, p, r.latLng);
      if (km < bestKm) { bestKm = km; best = r; }
    }
    return best;
  }

  static MrDistrict? nearestDistrict(MrRegion region, LatLng p) {
    if (region.districts.isEmpty) return null;
    const d = Distance();
    var best = region.districts.first;
    var bestKm = double.infinity;
    for (final dist in region.districts) {
      final km = d.as(LengthUnit.Kilometer, p, dist.latLng);
      if (km < bestKm) { bestKm = km; best = dist; }
    }
    return best;
  }

  static String regionLabel(LatLng p) {
    final region = nearestRegion(p);
    final dist = nearestDistrict(region, p);
    if (dist == null) return region.nameAr;
    const d = Distance();
    final km = d.as(LengthUnit.Kilometer, p, dist.latLng);
    if (km > 60) return region.nameAr;
    return '${dist.nameAr} · ${region.nameAr}';
  }
}
