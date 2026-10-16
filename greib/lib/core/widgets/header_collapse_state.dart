import 'package:flutter/material.dart';

/// حالة إخفاء الهيدر — جسر بين تمرير الـ Home والـ SuperHeader.
/// `true` = المستخدم مرّر لأسفل → الشعار + الأيقونات مخفية (المحتوى واضح).
/// `false` = أول دخول / سحب للأعلى → الشعار + الأيقونات ظاهرة.
class HeaderCollapseState {
  static final ValueNotifier<bool> collapsed = ValueNotifier<bool>(false);

  /// ★ تصغير الشريط السفلي أثناء التمرير النشط فقط:
  /// `true` = تمرير لأسفل نشط → إخفاء الأيقونات الغير نشطة وإبقاء
  /// المحددة (house) فقط. `false` = توقف / سحب عكسي → إظهار الكل.
  /// منفصل عن `collapsed` (الهيدر يبقى مخفياً حتى السحب العكسي،
  /// بينما السفلي يعود فور التوقف — تجربة أكثر احترافية).
  static final ValueNotifier<bool> navCompact = ValueNotifier<bool>(false);

  /// ★ إخفاء الخلفية الكبيرة للشريط السفلي بعد اكتمال تسلسل الـ Pill
  /// (الأيقونة → الاسم → اختفاء الاسم): `true` = تبقى الدائرة فقط
  /// بلا شريط كبير حولها. يُصفَّر تلقائياً عند التوقف/العكسي.
  static final ValueNotifier<bool> navShellHidden =
      ValueNotifier<bool>(false);
}
