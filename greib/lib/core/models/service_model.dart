import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final Color color;
  final String route;
  final String? imageUrl;

  /// صور إضافية مرفقة بالبطاقة (معرض صور) — اختيارية.
  final List<String> imageUrls;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.color,
    required this.route,
    this.imageUrl,
    this.imageUrls = const [],
  });
}
