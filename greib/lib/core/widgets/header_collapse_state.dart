import 'package:flutter/material.dart';

/// حالة إخفاء الهيدر — نظام الاتجاه النقي:
/// أسفل = إخفاء، توقف/أعلى = إظهار فوري.
class HeaderCollapseState {
  static final ValueNotifier<bool> collapsed = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> navCompact = ValueNotifier<bool>(false);

  /// عودة فورية لكل شيء (توقف/عكسي).
  static void restoreNow() {
    collapsed.value = false;
    navCompact.value = false;
  }
}
