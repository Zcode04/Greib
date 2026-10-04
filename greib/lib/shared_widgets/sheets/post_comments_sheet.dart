import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/service_model.dart';

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
  final FocusNode _inputFocus = FocusNode();

  /// ★ حقل الرد المباشر (علاقة بتعليق محدّد).
  final TextEditingController _replyInput = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  /// ★ فهرس التعليق الجاري الرد عليه (null = رد عام).
  int? _replyingTo;

  /// ★ خيوط الردود المفتوحة (تُعرض الردود مرتّبة زمنياً).
  final Set<int> _openThreads = {};

  /// ★ عدّاد تسلسلي للترتيب الزمني للردود.
  static int _seq = 0;

  /// ★ مفتاح ورقة التعليقات لنموّها للأعلى أثناء الكتابة.
  ///   (حالة DraggableScrollableSheet خاصة في Flutter ⇒ نُناديها ديناميكياً).
  final GlobalKey<State<DraggableScrollableSheet>> _sheetKey =
      GlobalKey<State<DraggableScrollableSheet>>();

  /// ★ التعليقات الموسّعة (اضغط «عرض المزيد»).
  final Set<int> _expanded = {};

  /// ★ عدد الكلمات المعروضة قبل الطي (بأسلوب منصات التواصل).
  static const int _collapsedWords = 10;

  /// ★ الحد الأقصى لطول التعليق الواحد (حرف) — حماية لقاعدة البيانات.
  static const int _maxChars = 500;

  /// ★ يظهر العدّاد بعد هذا العدد (تحذير مبكر).
  static const int _counterAfter = 300;

  /// ★ حجم الورقة الأساسي وأقصى نسبة نموّها مع طول الكتابة.
  static const double _baseExtent = 0.6;
  static const double _maxExtent = 0.92;

  @override
  void initState() {
    super.initState();
    // ★ عند فتح لوحة المفاتيح يتمدّد الحقل والأورقة للأعلى.
    _inputFocus.addListener(_onFocusChanged);
    _input.addListener(_onTextChanged);
    _replyFocus.addListener(_onFocusChanged);
    _replyInput.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _input
      ..removeListener(_onTextChanged)
      ..dispose();
    _replyFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _replyInput
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_inputFocus.hasFocus) _growTo(_baseExtent);
  }

  /// ★ نموّ متناسب مع طول النص: كلما كبرت الرسالة كبرت الورقة.
  void _onTextChanged() {
    final ratio = _input.text.characters.length / _maxChars;
    _growTo((_baseExtent + ratio * (_maxExtent - _baseExtent)).clamp(
      _baseExtent,
      _maxExtent,
    ));
  }

  void _growTo(double size) {
    final state = _sheetKey.currentState;
    if (state == null) return;
    final current = (state as dynamic).size as double?;
    if (current != null && (current - size).abs() < 0.01) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (_sheetKey.currentState as dynamic).animateTo(
        size.clamp(0.35, _maxExtent),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _submit() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => widget.comments.add(PostComment('أنت', text, mine: true)));
    _input.clear();
  }

  /// ★ بدء الرد على تعليق محدّد (علاقة مباشرة بالمعلّق).
  void _startReply(int index) {
    setState(() => _replyingTo = index);
    _replyFocus.requestFocus();
  }

  /// ★ فتح/طي خيط الردود.
  void _toggleThread(int index) {
    setState(() {
      if (_openThreads.contains(index)) {
        _openThreads.remove(index);
      } else {
        _openThreads.add(index);
      }
    });
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
    _replyInput.clear();
    _replyFocus.unfocus();
  }

  void _submitReply(int index) {
    final text = _replyInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.comments[index].replies.add(
        PostComment('أنت', text, mine: true, seq: ++_seq),
      );
    });
    _replyInput.clear();
    _cancelReply();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = primary.withValues(alpha: 0.6);

    // ★ بلا عنوان ولا فواصل: قائمة التعليقات ثم حقل الإرسال،
    //   والورقة تنمو للأعلى تلقائياً مع الكتابة حتى 500 حرف.
    return DraggableScrollableSheet(
      key: _sheetKey,
      expand: false,
      initialChildSize: _baseExtent,
      minChildSize: 0.35,
      maxChildSize: _maxExtent,
      snap: false,
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
              itemBuilder: (context, i) => _commentRow(
                widget.comments[i],
                index: i,
              ),
            ),
          ),
          // حقل التعليق + زر الإرسال (بحد أقصى 500 حرف).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _input,
              builder: (context, value, _) {
                final count = value.text.characters.length;
                final nearLimit = count >= _counterAfter;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        focusNode: _inputFocus,
                        minLines: 1,
                        maxLines: 8,
                        maxLength: _maxChars,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submit(),
                        style: TextStyle(color: primary, fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          counterText: nearLimit
                              ? '$count/$_maxChars'
                              : '',
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
                      onPressed: count == 0 ? null : _submit,
                      icon: Icon(
                        LucideIcons.send,
                        size: 20,
                        color: count == 0
                            ? secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ★ حقل الرد المباشر (يظهر أسفل التعليق المحدّد).
  Widget _replyField(int index) {
    final primary = Theme.of(context).colorScheme.onSurface;
    final accent = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _replyInput,
            focusNode: _replyFocus,
            minLines: 1,
            maxLines: 4,
            maxLength: _maxChars,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submitReply(index),
            style: TextStyle(color: primary, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: 'اكتب رداً…',
              hintStyle: TextStyle(
                color: primary.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
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
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => _submitReply(index),
          icon: Icon(LucideIcons.send, size: 18, color: accent),
        ),
        IconButton(
          onPressed: _cancelReply,
          icon: Icon(
            LucideIcons.x,
            size: 18,
            color: primary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _commentRow(PostComment c, {required int index}) {
    final accent = widget.service.color;
    final primary = Theme.of(context).colorScheme.onSurface;
    final expanded = _expanded.contains(index);
    final moreColor = Theme.of(context).colorScheme.primary;
    final secondary = primary.withValues(alpha: 0.6);
    // ★ طي ذكي بعد 10 كلمات + ثلاث نقاط، كمنصات التواصل.
    final words = c.text.split(RegExp(r'\s+'));
    final canExpand = words.length > _collapsedWords;
    final shown = (!canExpand || expanded)
        ? c.text
        : '${words.take(_collapsedWords).join(' ')}…';

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
              Text(shown, style: TextStyle(color: primary, fontSize: 14)),
              const SizedBox(height: 4),
              // ★ Threaded replies: عدّاد «رد N» يفتح خيط الردود مرتّباً زمنياً.
              Row(
                children: [
                  _ReplyToggle(
                    color: moreColor,
                    count: c.replies.length,
                    open: _openThreads.contains(index),
                    onTap: () => _toggleThread(index),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _startReply(index),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'رد',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (_openThreads.contains(index) && c.replies.isNotEmpty)
                for (final reply in c.replies.toList()
                  ..sort((a, b) => a.seq.compareTo(b.seq)))
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            LucideIcons.user,
                            size: 12,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${reply.author}: ',
                                  style: TextStyle(
                                    color: primary.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: reply.text,
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              if (_replyingTo == index)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _replyField(index),
                ),
              if (canExpand)
                _MoreToggle(
                  expanded: expanded,
                  color: moreColor,
                  onTap: () => setState(() {
                    if (expanded) {
                      _expanded.remove(index);
                    } else {
                      _expanded.add(index);
                    }
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ★ زر «رد» على تعليق.
class _ReplyToggle extends StatelessWidget {
  const _ReplyToggle({
    required this.color,
    required this.count,
    required this.open,
    required this.onTap,
  });

  final Color color;
  final int count;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.messageCircle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            count == 0 ? 'رد' : 'رد $count',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 2),
            Icon(
              open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16,
              color: color,
            ),
          ],
        ],
      ),
    );
  }
}

/// ★ زر «عرض المزيد / عرض أقل» أسفل التعليق الطويل.
class _MoreToggle extends StatelessWidget {
  const _MoreToggle({
    required this.expanded,
    required this.color,
    required this.onTap,
  });

  final bool expanded;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expanded ? 'عرض أقل' : 'عرض المزيد',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// تعليق واحد (وهمي أو يكتبه المستخدم).
class PostComment {
  const PostComment(
    this.author,
    this.text, {
    this.mine = false,
    this.replies = const [],
    this.seq = 0,
  });

  final String author;
  final String text;

  /// تعليق المستخدم الحالي ⇒ يُعرض بلون مختلف.
  final bool mine;

  /// ★ الردود على هذا التعليق (علاقة مباشرة بالمعلّق).
  final List<PostComment> replies;

  /// ★ تسلسل زمني لعرض الردود بالترتيب (الأقدم أولاً).
  final int seq;
}
