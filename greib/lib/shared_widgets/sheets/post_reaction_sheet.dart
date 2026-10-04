import 'package:flutter/material.dart';

import '../../core/models/service_model.dart';
import '../../core/widgets/draggable_sheet_body.dart';
import '../post_reaction.dart';

/// ============================================================================
///  PostReactionSheet — ورقة تفاعل المنشور:
///  صفّ إيموجي تفاعل (فيسبوك السبعة) + قائمة المتفاعلين.
///
///  الضغط على زر التفاعل في البطاقة يفتح هذه الورقة، ومن داخلها يختار
///  المستخدم تفاعله فيُحفظ ويظهر فوراً بجوار أيقونات البطاقة.
///
///  الاستخدام:
///    showAppSheet(context, builder: (ctx) => PostReactionSheet(
///      service: service, isDark: isDark,
///      reactedUsers: kMockReactedUsers, current: reactionOf(postId),
///      onReact: (value) { setReaction(postId, value); Navigator.pop(ctx); },
///    ));
/// ============================================================================
class PostReactionSheet extends StatefulWidget {
  const PostReactionSheet({
    super.key,
    required this.service,
    required this.isDark,
    required this.reactedUsers,
    required this.current,
    required this.onReact,
  });

  final ServiceCategory service;
  final bool isDark;

  /// أسماء مستخدمين وهميين لكل تفاعل.
  final Map<int, List<String>> reactedUsers;

  /// التفاعل الحالي (0 = بلا).
  final int current;

  /// يُستدعى عند اختيار إيموجي.
  final ValueChanged<int> onReact;

  @override
  State<PostReactionSheet> createState() => _PostReactionSheetState();
}

class _PostReactionSheetState extends State<PostReactionSheet> {
  late int _current = PostReaction.normalize(widget.current);
  int? _hovered;

  Widget _emojiButton(PostReaction reaction) {
    final active = _current == reaction.value;
    final hovered = _hovered == reaction.value;

    Widget iconChild;
    if (reaction.iconData != null) {
      iconChild = Icon(
        reaction.iconData,
        size: 30,
        color: active || hovered
            ? reaction.color
            : reaction.color.withValues(alpha: 0.5),
        shadows: [
          if (active || hovered)
            Shadow(
              color: reaction.color.withValues(alpha: 0.55),
              blurRadius: 12,
            ),
        ],
      );
    } else {
      iconChild = Text(
        reaction.emoji,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: 30,
          height: 1.1,
          shadows: [
            if (active || hovered)
              Shadow(
                color: reaction.color.withValues(alpha: 0.55),
                blurRadius: 12,
              ),
          ],
        ),
      );
    }

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() => _current = active ? 0 : reaction.value);
          widget.onReact(_current);
        },
        onHover: (event) =>
            setState(() => _hovered = event ? reaction.value : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.35 : (hovered ? 1.25 : 1),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: iconChild,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reactedList() {
    final entries = <(String, int)>[
      if (_current != 0) ('أنت', _current),
      for (final reaction in PostReaction.all)
        for (final name
            in widget.reactedUsers[reaction.value] ?? const <String>[])
          (name, reaction.value),
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final (name, value) = entries[i];
        final reaction = PostReaction.byValue(value)!;
        final mine = name == 'أنت';
        final primary = Theme.of(context).colorScheme.onSurface;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reaction.color.withValues(alpha: 0.15),
                ),
                child: Text(
                  name.characters.first,
                  style: TextStyle(
                    color: reaction.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: mine ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              if (reaction.iconData != null)
                Icon(reaction.iconData, size: 18, color: reaction.color)
              else
                ReactionEmoji(value, size: 18),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ★ بلا عنوان ولا فواصل: الإيموجيز في الأعلى ثم قائمة المتفاعلين.
    return DraggableSheetBody(
      initialExtent: 0.55,
      snapSizes: const [0.35, 0.45, 0.55, 0.65, 0.8],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            onHover: (event) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final dx = event.localPosition.dx;
              final width = box.size.width / PostReaction.all.length;
              final index = (dx / width).floor().clamp(
                0,
                PostReaction.all.length - 1,
              );
              final value = PostReaction.all[index].value;
              if (_hovered != value) setState(() => _hovered = value);
            },
            onExit: (_) => setState(() => _hovered = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final reaction in PostReaction.all) _emojiButton(reaction),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _reactedList(),
            ),
          ),
        ],
      ),
    );
  }
}
