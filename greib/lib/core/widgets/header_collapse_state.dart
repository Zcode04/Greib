import 'dart:async';

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

  /// ★ إخفاء الدائرة الأخيرة أيضاً (شاشة فارغة تماماً لأقصى وضوح).
  /// `true` = حتى أيقونة house مخفية. تُضبط بعد اختفاء الخلفية بقليل.
  static final ValueNotifier<bool> navDotHidden =
      ValueNotifier<bool>(false);

  /// ★ مؤقت العودة بعد التوقف (ثانيتان) — أي تمرير جديد يلغيه.
  static Timer? _restoreTimer;

  /// إلغاء مؤقت العودة (عند أي تمرير جديد).
  static void cancelRestore() {
    _restoreTimer?.cancel();
    _restoreTimer = null;
  }

  /// جدولة عودة كل شيء (هيدر + سفلي) بعد ثانيتين من التوقف.
  static void scheduleRestore() {
    cancelRestore();
    _restoreTimer = Timer(const Duration(seconds: 2), () {
      collapsed.value = false;
      navCompact.value = false;
      navShellHidden.value = false;
      navDotHidden.value = false;
    });
  }

  /// عودة فورية (سحب عكسي / نقرة) — تلغي المؤقت وتصفّر كل الحالات.
  static void restoreNow() {
    cancelRestore();
    collapsed.value = false;
    navCompact.value = false;
    navShellHidden.value = false;
    navDotHidden.value = false;
  }
}
