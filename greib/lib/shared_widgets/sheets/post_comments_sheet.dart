import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/service_model.dart';
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
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = primary.withValues(alpha: 0.6);

    // ★ بلا عنوان ولا فواصل: قائمة التعليقات ثم حقل الإرسال.
    return DraggableSheetBody(
      initialExtent: 0.6,
      snapSizes: const [0.35, 0.45, 0.55, 0.6, 0.7, 0.8, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _commentRow(widget.comments[i]),
            ),
          ),
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
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
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
    final primary = Theme.of(context).colorScheme.onSurface;

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
        // ★ النص بلا فقاعة/خلفية.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.author,
                style: TextStyle(
                  color: primary.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(c.text, style: TextStyle(color: primary, fontSize: 14)),
            ],
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
