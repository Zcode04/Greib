import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/models/service_model.dart';

/// ============================================================================
///  ServicesRepository — طبقة البيانات (Data Layer).
///
///  المسؤول الوحيد عن تحميل الخدمات من الملف المصدر:
///      assets/data/services.json
///
///  هذا هو المصدر الوحيد للحقيقة (Single Source of Truth):
///  - إضافة خدمة جديدة = تعديل JSON فقط، بدون لمس أي كود.
///  - استبدال هذا الصف لاحقاً بـ RemoteDataSource = صفر تغيير في الـ UI.
///
///  ملاحظة: التوقيع مستقبلي (Future) ليشبه طبقة API، لكنه متزامن هنا
///  لأن المصدر ملف محلي يُحمَّل مرة واحدة قبل تشغيل التطبيق.
/// ============================================================================
class ServicesRepository {
  ServicesRepository._();

  static const _assetPath = 'assets/data/services.json';

  /// نسخة واحدة فقط (Singleton) — التحميل يحدث مرة واحدة في عمر التطبيق.
  static final ServicesRepository instance = ServicesRepository._();

  List<ServiceCategory>? _cache;
  Map<String, List<ServicePost>>? _postsCache;

  /// هل البيانات جاهزة؟ تستخدمه الواجهة لتفادي الوميض قبل التحميل.
  bool get isLoaded => _cache != null;

  /// كل الخدمات — محمّلة مسبقاً في main() قبل runApp.
  List<ServiceCategory> get all => _cache ?? const [];

  /// خدمة واحدة بمعرّفها — تستخدمها صفحة التفاصيل.
  ServiceCategory? byId(String id) {
    for (final service in all) {
      if (service.id == id) return service;
    }
    return null;
  }

  /// منشورات الخدمة الإضافية (ورقة «عرض المزيد») — قائمة فارغة إن لم يوجد شيء.
  List<ServicePost> postsFor(String serviceId) =>
      _postsCache?[serviceId] ?? const [];

  /// يحمّل الملف ويبني الـ cache. يُستدعى مرة واحدة قبل runApp.
  Future<void> load() async {
    if (_cache != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;

    _cache = (decoded['services'] as List<dynamic>? ?? const [])
        .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    final posts = decoded['posts'] as Map<String, dynamic>? ?? const {};
    _postsCache = posts.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((e) => ServicePost.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }
}
