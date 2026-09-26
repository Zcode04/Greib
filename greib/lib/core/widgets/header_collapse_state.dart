import 'package:flutter/material.dart';

/// حالة انكماش الهيدر — جسر بين تمرير الـ Home والـ SuperHeader.
/// `true` = المستخدم مرّر → الهيدر المصغّر. `false` = أول دخول → الحجم الكامل.
class HeaderCollapseState {
  static final ValueNotifier<bool> collapsed = ValueNotifier<bool>(false);
}
