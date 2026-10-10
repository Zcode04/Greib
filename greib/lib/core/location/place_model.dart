import 'package:latlong2/latlong.dart';

/// ============================================================================
///  PlaceModel — مكان بإحداثيات حقيقية (مصدر واحد لكل الخرائط).
/// ============================================================================
class PlaceModel {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? cityName;
  final double? distanceKm;

  const PlaceModel({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.cityName,
    this.distanceKm,
  });

  LatLng get latLng => LatLng(lat, lng);

  String get latLngLabel =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';

  String distanceLabel() {
    final d = distanceKm;
    if (d == null) return '';
    if (d < 1) return '${(d * 1000).round()} م';
    return '${d.toStringAsFixed(1)} كم';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'cityName': cityName,
      };

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        name: (json['name'] ?? '') as String,
        address: (json['address'] ?? '') as String,
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        cityName: json['cityName'] as String?,
      );

  PlaceModel copyWith({double? distanceKm, String? address}) => PlaceModel(
        name: name,
        address: address ?? this.address,
        lat: lat,
        lng: lng,
        cityName: cityName,
        distanceKm: distanceKm ?? this.distanceKm,
      );
}
