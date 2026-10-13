import 'package:flutter/foundation.dart';

/// ============================================================================
///  مخزن سجل عمليات البحث — مصدر مشترك بين شاشة البحث وصفحة «سجل البحث».
///
///  ★ مؤقتاً في الذاكرة فقط (in-memory)؛ سيُستبدل لاحقاً بتخزين دائم
///    (Hive / SharedPreferences) عند تطوير الميزة — دون تغيير الواجهة العامة.
///
///  كل ما يبحث عنه المستخدم يُسجَّل تلقائياً عبر [add]، ويظهر في صفحة السجل.
/// ============================================================================
class SearchHistoryStore {
  SearchHistoryStore._();

  static final SearchHistoryStore instance = SearchHistoryStore._();

  /// قائمة عمليات البحث (الأحدث أولاً) مع إمكانية الاستماع للتغييرات.
  final ValueNotifier<List<String>> entries =
      ValueNotifier<List<String>>(<String>[
    'توصيل طلبات',
    'عيادة أسنان',
    'فندق 5 نجوم',
    'سيارة إيجار',
  ]);

  /// يضيف عملية بحث جديدة في المقدمة (ويمنع التكرار).
  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = List<String>.from(entries.value);
    list.remove(q);
    list.insert(0, q);
    entries.value = list;
  }

  /// يحذف عملية بحث محددة من السجل.
  void remove(String query) {
    entries.value = List<String>.from(entries.value)..remove(query);
  }

  /// يمسح كل عمليات البحث.
  void clear() => entries.value = <String>[];
}
