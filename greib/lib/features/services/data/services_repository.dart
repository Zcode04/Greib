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
  List<ServicePostEntry>? _allPostsCache;

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

  /// ★ كل منشورات كل الخدمات في قائمة واحدة (دفعة واحدة).
  ///
  /// تُبنى مرة واحدة بعد [load] وتُخزَّن مؤقتاً، فالاستدعاء الثاني أو بعد
  /// أي إعادة بناء للواجهة لا يقرأ الملف ولا يعيد الفرز.
  /// الترتيب: الأحدث أولاً حسب [ServicePost.timeAgo] («منذ 5 ساعات» قبل «أمس»).
  List<ServicePostEntry> get allPosts => _allPostsCache ?? const [];

  /// يبني التغذية الموحّدة من [_postsCache] و[_cache] (كل خدمة × كل منشوراتها).
  void _buildAllPosts() {
    final services = _cache ?? const <ServiceCategory>[];
    final posts = _postsCache ?? const <String, List<ServicePost>>{};
    final entries = <ServicePostEntry>[];

    for (final service in services) {
      final servicePosts = posts[service.id];
      if (servicePosts == null) continue;
      for (var i = 0; i < servicePosts.length; i++) {
        entries.add(
          ServicePostEntry(
            postId: '${service.id}#$i',
            index: i,
            service: service,
            post: servicePosts[i],
          ),
        );
      }
    }

    entries.sort(
      (a, b) => _recencyHours(a.timeAgo).compareTo(_recencyHours(b.timeAgo)),
    );
    _allPostsCache = List.unmodifiable(entries);
  }

  /// يحوّل نص «منذ 5 ساعات» / «أمس» إلى عدد ساعات (الأحدث = الأصغر).
  /// القيم غير المفهومة تُعامل كقديمة جداً فتبقى في آخر القائمة.
  static int _recencyHours(String timeAgo) {
    final text = timeAgo.trim();
    if (text.isEmpty) return 1 << 30;

    if (text.contains('الآن')) return 0;

    final numberMatch = RegExp(r'\d+').firstMatch(text);
    final value = int.tryParse(numberMatch?.group(0) ?? '') ?? 1;

    if (text.contains('ثاني')) return value ~/ 3600;
    if (text.contains('دقيقة')) return value ~/ 60;
    if (text.contains('ساع')) return value;
    if (text.contains('يوم')) return value * 24;
    if (text.contains('أسبوع')) return value * 24 * 7;
    if (text.contains('شهر')) return value * 24 * 30;

    // «أمس» / «اليوم» / «البارحة» بلا رقم ⇒ 24 ساعة و«اليوم» = الآن تقريباً.
    if (text.contains('أمس') || text.contains('بارحة')) return 24;
    if (text.contains('اليوم')) return 1;
    return 1 << 29;
  }

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

    _buildAllPosts();
  }
}
