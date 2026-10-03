import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';

/// ============================================================================
///  PostReaction — تفاعلات المنشور (بنمط فيسبوك).
///
///  ★ كل تفاعل له شكل واحد مشترك: إما أيقونة (thumbs-up / thumbs-down)
///    أو إيموجي النظام (تلقائي 3D على iOS، ملوّن مسطّح على Android).
///    التدفق: إعجاب، عدم إعجاب، حب، دهشة، حزن.
///
///  ★ `value` هو المفتاح唯一的 الوحيد المستخدم في `PostSheetsController`
///    (0 = بلا تفاعل، 1..5 = التفاعلات بالترتيب أدناه).
/// ============================================================================
@immutable
class PostReaction {
  const PostReaction({
    required this.value,
    this.icon,
    this.emoji = '',
    required this.label,
    required this.color,
  });

  /// مفتاح التفاعل (يُحفظ في حالة المنشور).
  final int value;

  /// أيقونة التفاعل (بديل الإيموجي عند التوفّر).
  final IconData? icon;

  /// إيموجي النظام المعروض في الورقة بجوار أيقونات البطاقة (فارغ إن وُجدت أيقونة).
  final String emoji;

  /// الاسم العربي (يظهر عند الضغط على التفاعل داخل الورقة).
  final String label;

  /// اللون (لون الأيقونة في الزر + لون الإطار المميّز).
  final Color color;

  /// ★ كل التفاعلات المعروضة (مثل فيسبوك) بترتيب التدفق.
  static const List<PostReaction> all = [
    PostReaction(
      value: 1,
      icon: LucideIcons.thumbsUp,
      label: 'إعجاب',
      color: AppColors.info,
    ),
    PostReaction(
      value: 2,
      icon: LucideIcons.thumbsDown,
      label: 'عدم إعجاب',
      color: Color(0xFF6B7280),
    ),
    PostReaction(value: 3, emoji: '❤️', label: 'حب', color: Color(0xFFE5484D)),
    PostReaction(value: 4, emoji: '😮', label: 'دهشة', color: Color(0xFF8B5CF6)),
    PostReaction(value: 5, emoji: '😔', label: 'حزن', color: Color(0xFF3B82F6)),
  ];

  /// تفاعل غير معروف ⇒ null (لا نخترع شكلاً).
  static PostReaction? byValue(int value) {
    for (final r in all) {
      if (r.value == value) return r;
    }
    return null;
  }

  /// ★ توحيد القيم القديمة/المحذوفة على المجموعة الحالية.
  static int normalize(int value) {
    return (value >= 1 && value <= 5) ? value : 0;
  }

  /// الإيموجي المقابل للقيمة (سريع للعرض، فارغ للتفاعلات ذات الأيقونة).
  static String emojiOf(int value) => byValue(normalize(value))?.emoji ?? '';
}

/// ★ شكل تفاعل واحد (أيقونة أو إيموجي) بحجم موحّد — سطر واحد في كل مكان.
class ReactionGlyph extends StatelessWidget {
  const ReactionGlyph(
    this.value, {
    super.key,
    this.size = 20,
    this.color,
  });

  final int value;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final reaction = PostReaction.byValue(PostReaction.normalize(value));
    final icon = reaction?.icon;
    if (icon != null) {
      return Icon(icon, size: size, color: color);
    }
    final emoji = reaction?.emoji ?? '';
    if (emoji.isEmpty) return SizedBox(width: size, height: size);
    return Text(
      emoji,
      // ★ الإيموجي نظامي ⇒ نتجاهل fontScale حتى لا ينكسر صفّ الورقة.
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size, height: 1.1),
    );
  }
}