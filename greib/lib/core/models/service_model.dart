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

/// منشور إضافي لنفس الخدمة (ورقة «عرض المزيد»): نص + صور + زمن النشر.
class ServicePost {
  final String text;
  final List<String> imageUrls;
  final String timeAgo;

  const ServicePost({
    required this.text,
    required this.imageUrls,
    required this.timeAgo,
  });
}
