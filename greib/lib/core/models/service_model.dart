import 'package:flutter/material.dart';

/// ============================================================================
///  ServiceCategory — نموذج الخدمة (Entity).
///
///  البيانات تأتي من ملف واحد: assets/data/services.json
///  وهو المصدر الوحيد للحقيقة (Single Source of Truth) لكل الخدمات.
/// ============================================================================
class ServiceCategory {
  final String id;
  final String title;
  final String subtitle;

  /// وصف الخدمة — يظهر في صفحة التفاصيل.
  final String description;

  /// اسم الأيقونة كنص (String) يُترجم لاحقاً إلى IconData.
  final String iconName;

  /// لون الخدمة — يقود تدرّج صفحة التفاصيل بالكامل.
  final Color color;

  /// كود اللون السداسي كما ورد في JSON.
  final String colorHex;

  final String? price;
  final String? deliveryTime;
  final String? rating;

  /// صور إضافية (معرض صور) — optional.
  final List<String> imageUrls;

  /// الصورة الأساسية للبطاقة (Cover Image) — أول عنصر في `imageUrls`.
  /// مشتقة (Derived) من المصدر الواحد، فلا تحتاج تخزيناً منفصلاً.
  String? get coverImage => imageUrls.isEmpty ? null : imageUrls.first;

  /// بقية الصور بعد الصورة الأساسية (Extra / Gallery Images).
  List<String> get extraImages =>
      imageUrls.length <= 1 ? const [] : imageUrls.sublist(1);

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconName,
    required this.color,
    required this.colorHex,
    this.price,
    this.deliveryTime,
    this.rating,
    this.imageUrls = const [],
  });

  /// يبني الخدمة من JSON مع قراءة آمنة للأنواع (Safe casting).
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    final hex = json['color'] as String? ?? '#3B82F6';
    return ServiceCategory(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'circle',
      color: _hexToColor(hex),
      colorHex: hex,
      price: json['price'] as String?,
      deliveryTime: json['deliveryTime'] as String?,
      rating: json['rating'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'iconName': iconName,
    'color': colorHex,
    'price': price,
    'deliveryTime': deliveryTime,
    'rating': rating,
    'imageUrls': imageUrls,
  };

  /// يحوّل "#RRGGBB" إلى Color مع رجوع للون الرسمي عند الفشل.
  static Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF3B82F6);
    return Color(cleaned.length == 6 ? 0xFF000000 | value : value);
  }
}

/// ============================================================================
///  ServicePost — منشور إضافي لنفس الخدمة (ورقة «عرض المزيد»).
/// ============================================================================
class ServicePost {
  final String text;
  final List<String> imageUrls;
  final String timeAgo;

  const ServicePost({
    required this.text,
    required this.imageUrls,
    required this.timeAgo,
  });

  factory ServicePost.fromJson(Map<String, dynamic> json) => ServicePost(
    text: json['text'] as String? ?? '',
    imageUrls: (json['imageUrls'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    timeAgo: json['timeAgo'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'imageUrls': imageUrls,
    'timeAgo': timeAgo,
  };
}

/// ============================================================================
///  ServicePostEntry — منشور واحد مرتبط بالخدمة التي ينتمي إليها.
///
///  الغرض: جلب *كل* منشورات *كل* الخدمات دفعة واحدة (تغذية موحّدة) بدل
///  استدعاء `postsFor(serviceId)` لكل خدمة على حدة.
///  الـ `postId` فريد ومشتق من الخدمة ⇒ التفاعل والمفضلة والتعليقات
///  لا تتداخل بين منشورات الخدمة نفسها.
/// ============================================================================
class ServicePostEntry {
  /// معرّف فريد للمنشور = «معرّف_الخدمة#ترتيب_المنشور» (يُستخدم للتفاعل).
  final String postId;

  /// ترتيب المنشور داخل خدمته (يحفظ الترتيب الأصلي في الملف).
  final int index;

  /// الخدمة صاحبة المنشور (لازم للتنقّل والصور ولون البطاقة).
  final ServiceCategory service;

  /// بيانات المنشور نفسها.
  final ServicePost post;

  const ServicePostEntry({
    required this.postId,
    required this.index,
    required this.service,
    required this.post,
  });

  /// وقت النشر كنص جاهز للعرض («منذ 5 ساعات»).
  String get timeAgo => post.timeAgo;

  /// نص المنشور.
  String get text => post.text;

  /// صور المنشور — قد تكون فارغة (⇒ نستعمل صورة الخدمة كبديل).
  List<String> get imageUrls => post.imageUrls;
}
