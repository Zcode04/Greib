import 'package:flutter/material.dart';

/// حالة إخفاء الهيدر — جسر بين تمرير الـ Home والـ SuperHeader.
/// `true` = المستخدم مرّر لأسفل → الشعار + الأيقونات مخفية (المحتوى واضح).
/// `false` = أول دخول / سحب للأعلى → الشعار + الأيقونات ظاهرة.
class HeaderCollapseState {
  static final ValueNotifier<bool> collapsed = ValueNotifier<bool>(false);
}
