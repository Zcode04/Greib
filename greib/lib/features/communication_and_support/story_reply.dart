import 'package:flutter/material.dart';

/// ============================================================================
///  StoryReply — رد المستخدم على ستوري خدمة (Story-to-Chat Bridge).
///  يُنشأ في عارض الستوري، ويُسلَّم لـ ChatDetailScreen فيُرسل تلقائياً
///  كرسالة مرفقة ببطاقة الستوري (مثل إنستغرام/واتساب).
/// ============================================================================
@immutable
class StoryReply {
  /// معرّف الستوري/الخدمة.
  final String storyId;

  /// اسم الخدمة (مطاعم مميزة / توصيل سريع...).
  final String serviceTitle;

  /// تصنيف الخدمة (طعام / توصيل...) — يُعرض شارة.
  final String serviceCategory;

  /// صورة الصفحة التي كان يشاهدها المستخدم لحظة الرد.
  final String storyImageUrl;

  /// نص الرسالة التي كتبها المستخدم.
  final String message;

  final DateTime sentAt;

  StoryReply({
    required this.storyId,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.storyImageUrl,
    required this.message,
    DateTime? sentAt,
  }) : sentAt = sentAt ?? DateTime.now();
}
