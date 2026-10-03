import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// ============================================================================
///  PostReaction — تفاعلات المنشور (بنمط فيسبوك) بأيموجي الجهاز.
///
///  ★ بلا أصول صور: نعتمد على إيموجي النظام (تلقائي 3D على iOS، ملوّن
///    مسطّح على Android) ⇒ نفس الكود يعمل على كل الأجهزة بلا حزم صور.
///
///  ★ `value` هو المفتاح唯一的 الوحيد المستخدم في `PostSheetsController`
///    (0 = بلا تفاعل، 1..7 = التفاعلات بالترتيب أدناه).
/// ============================================================================
@immutable
class PostReaction {
  const PostReaction({
    required this.value,
    required this.emoji,
    required this.label,
    required this.color,
  });

  /// مفتاح التفاعل (يُحفظ في حالة المنشور).
  final int value;

  /// إيموجي النظام المعروض في الورقة بجوار أيقونات البطاقة.
  final String emoji;

  /// الاسم العربي (يظهر عند الضغط على الإيموجي داخل الورقة).
  final String label;

  /// اللون (لون الأيقونة في الزر + لون الإطار المميّز).
  final Color color;

  /// ★ كل التفاعلات المعروضة (مثل فيسبوك): إعجاب، حب، دهشة، حزن، غضب.
  ///   (تم حذف «اهتمام» و«ضحك» من المجموعة.)
  static const List<PostReaction> all = [
    PostReaction(value: 1, emoji: '👍', label: 'إعجاب', color: AppColors.info),
    PostReaction(value: 2, emoji: '❤️', label: 'حب', color: Color(0xFFE5484D)),
    PostReaction(
      value: 3,
      emoji: '😮',
      label: 'دهشة',
      color: Color(0xFF8B5CF6),
    ),
    PostReaction(value: 4, emoji: '😔', label: 'حزن', color: Color(0xFF3B82F6)),
    PostReaction(value: 5, emoji: '😡', label: 'غضب', color: AppColors.error),
  ];

  /// تفاعل غير معروف ⇒ null (لا نخترع إيموجي).
  static PostReaction? byValue(int value) {
    for (final r in all) {
      if (r.value == value) return r;
    }
    return null;
  }

  /// ★ توحيد القيم القديمة/المحذوفة على المجموعة الحالية:
  ///   1 ⇒ إعجاب، -1 ⇒ حزن، 4/7 (ضحك/غضب القديم) ⇒ غضب، وما عداه ⇒ بلا.
  static int normalize(int value) {
    if (value == -1) return 4;
    if (value == 7) return 5;
    return (value >= 1 && value <= 5) ? value : 0;
  }

  /// الإيموجي المقابل للقيمة (سريع للعرض داخل البطاقة).
  static String emojiOf(int value) => byValue(normalize(value))?.emoji ?? '';
}

/// إيموجي تفاعل واحد بحجم موحّد (سطر واحد في كل مكان).
class ReactionEmoji extends StatelessWidget {
  const ReactionEmoji(
    this.value, {
    super.key,
    this.size = 20,
    this.selected = false,
  });

  final int value;
  final double size;

  /// إبراز بصري (ظل خفيف) عند الاختيار/العرض المميّز.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final emoji = ReactionEmoji.emojiOf(value);
    if (emoji.isEmpty) return SizedBox(width: size, height: size);
    return Text(
      emoji,
      // ★ الإيموجي نظامي ⇒ نتجاهل fontScale حتى لا ينكسر صفّ الورقة.
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size, height: 1.1),
    );
  }

  static String emojiOf(int value) {
    for (final r in PostReaction.all) {
      if (r.value == PostReaction.normalize(value)) return r.emoji;
    }
    return '';
  }
}
