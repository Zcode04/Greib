class TravelDestination {
  final String id;
  final String title;
  final String country;
  final String imageUrl;

  /// نص المنشور (وصف الرحلة).
  final String description;

  /// سعر الرحلة للشخص الواحد.
  final double price;

  /// صور إضافية لمعرض المنشور (شبكة 3:2) — أولها [imageUrl] عادةً.
  final List<String> gallery;

  /// مدة الرحلة ونوعها — تُستخدم كشارات داخل المنشور.
  final String duration;
  final String tripType;
  final double rating;
  final List<String> highlights;

  const TravelDestination({
    required this.id,
    required this.title,
    required this.country,
    required this.imageUrl,
    this.gallery = const [],
    required this.description,
    required this.price,
    this.duration = '5 أيام',
    this.tripType = 'ذهاب وعودة',
    this.rating = 4.7,
    this.highlights = const [],
  });

  /// كل صور المنشور (الإضافية أو الأساسية فقط).
  List<String> get postImages =>
      gallery.where((e) => e.trim().isNotEmpty).toList(growable: false).isEmpty
      ? [imageUrl]
      : gallery.where((e) => e.trim().isNotEmpty).toList(growable: false);
}
