class Hotel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  /// صور إضافية لمعرض المنشور (شبكة 3:2) — أولها [imageUrl] عادةً.
  final List<String> gallery;

  /// نص المنشور. إن لم يُحدَّد يُشتق تلقائياً من الموقع والمرافق.
  final String? description;
  final double rating;
  final double pricePerNight;
  final List<String> amenities;

  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    this.gallery = const [],
    this.description,
    required this.rating,
    required this.pricePerNight,
    required this.amenities,
  });

  /// نص المنشور الفعلي (المخصص، أو مركّب من المرافق والموقع).
  String get postText =>
      description ??
      'عِش تجربة استثنائية في $name بـ $location — تشطيب راقٍ وخدمات تشمل ${amenities.take(3).join('، ')}.';

  /// كل صور المنشور (الإضافية أو الأساسية فقط).
  List<String> get postImages =>
      gallery.where((e) => e.trim().isNotEmpty).isEmpty
      ? [imageUrl]
      : gallery.where((e) => e.trim().isNotEmpty).toList(growable: false);
}
