class Hotel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final double pricePerNight;
  final List<String> amenities;

  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.pricePerNight,
    required this.amenities,
  });
}
