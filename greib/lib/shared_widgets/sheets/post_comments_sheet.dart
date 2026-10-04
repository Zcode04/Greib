import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/service_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/draggable_sheet_body.dart';

/// ============================================================================
///  PostCommentsSheet — ورقة التعليقات (Bottom Sheet):
///  قائمة تعليقات المنشور + حقل إضافة تعليق.
///
///  Widget حالة مستقل: يملك الـ TextEditingController ويحرّره في dispose.
///  ارتفاعه ديناميكي (Draggable) ⇒ يتقلّص مع لوحة المفاتيح.
///
///  الاستخدام:
///    showAppSheet(context, builder: (_) =>
///        PostCommentsSheet(service: service, isDark: isDark, comments: list));
/// ============================================================================
class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({
    super.key,
    required this.service,
    required this.isDark,
    required this.comments,
  });

  final ServiceCategory service;
  final bool isDark;
  final List<PostComment> comments;

  @override
  State<PostCommentsSheet> createState() => PostCommentsSheetState();
}

class PostCommentsSheetState extends State<PostCommentsSheet> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => widget.comments.add(PostComment('أنت', text, mine: true)));
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.service.color;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;
    final secondary = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final line = widget.isDark ? AppColors.outline : AppColors.lightOutline;

    return DraggableSheetBody(
      initialExtent: 0.6,
      snapSizes: const [0.35, 0.45, 0.55, 0.6, 0.7, 0.8, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetDragArea(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Icon(LucideIcons.messagesSquare, size: 18, color: secondary),
                  const SizedBox(width: 8),
                  Text(
                    'التعليقات (${widget.comments.length})',
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: line),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _commentRow(widget.comments[i]),
            ),
          ),
          Divider(height: 1, color: line),
          // حقل التعليق + زر الإرسال.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: primary, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'اكتب تعليقاً…',
                      hintStyle: TextStyle(color: secondary, fontSize: 13),
                      filled: true,
                      fillColor: widget.isDark
                          ? AppColors.surface
                          : AppColors.lightBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _submit,
                  icon: Icon(LucideIcons.send, size: 20, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentRow(PostComment c) {
    final accent = widget.service.color;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.15),
          ),
          child: Icon(LucideIcons.user, size: 16, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.mine
                  ? accent.withValues(alpha: 0.12)
                  : (widget.isDark ? AppColors.surfaceCard : Colors.white),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.author,
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(c.text, style: TextStyle(color: primary, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// تعليق واحد (وهمي أو يكتبه المستخدم).
class PostComment {
  const PostComment(this.author, this.text, {this.mine = false});

  final String author;
  final String text;

  /// تعليق المستخدم الحالي ⇒ يُعرض بلون مختلف.
  final bool mine;
}
