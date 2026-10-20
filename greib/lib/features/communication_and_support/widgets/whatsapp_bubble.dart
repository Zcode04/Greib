import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/chat_colors.dart';
import 'chat_whatsapp_ui.dart';

/// ============================================================================
///  فقاعة بأسلوب WhatsApp مع دعم كامل للسحب للرد (Swipe to Reply)
/// ============================================================================
///  ★ مطابقة تماماً لشكل وتجربة واتساب:
///    - ذيل منحنٍ دقيق عند زاوية الفقاعة
///    - ظلال بطاقة خافتة تعطي عمقاً بصرياً
///    - إيماءة سحب سلسة مع أيقونة الرد الدائرية التفاعلية وارتداد فيزيائي
///    - ربط كامل بلون الفقاعة من [AppChatColors]
class WhatsAppBubbleShell extends StatefulWidget {
  final bool isMine;
  final double maxWidth;
  final Widget child;
  final VoidCallback? onSwipeReply;
  final VoidCallback? onLongPress;

  const WhatsAppBubbleShell({
    super.key,
    required this.isMine,
    required this.maxWidth,
    required this.child,
    this.onSwipeReply,
    this.onLongPress,
  });

  @override
  State<WhatsAppBubbleShell> createState() => _WhatsAppBubbleShellState();
}

class _WhatsAppBubbleShellState extends State<WhatsAppBubbleShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _dragAnimation;

  double _dragOffset = 0.0;
  bool _thresholdReached = false;
  static const double _kTriggerThreshold = 48.0;
  static const double _kMaxDrag = 68.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _dragAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        )..addListener(() {
          setState(() => _dragOffset = _dragAnimation.value);
        });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.onSwipeReply == null) return;
    // السحب نحو الداخل (الرد):
    // إذا كانت الرسالة لي (على اليمين) نسحب لليسار (-dx).
    // إذا كانت للطرف الآخر (على اليسار) نسحب لليمين (+dx).
    final delta = details.primaryDelta ?? 0.0;
    final sign = widget.isMine ? -1.0 : 1.0;
    final effectiveDelta = delta * sign;

    setState(() {
      _dragOffset = (_dragOffset + effectiveDelta).clamp(0.0, _kMaxDrag);
      if (_dragOffset >= _kTriggerThreshold && !_thresholdReached) {
        _thresholdReached = true;
        HapticFeedback.lightImpact();
      } else if (_dragOffset < _kTriggerThreshold) {
        _thresholdReached = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.onSwipeReply == null) return;
    if (_thresholdReached) {
      widget.onSwipeReply?.call();
    }
    _animController.reset();
    _dragAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
    _thresholdReached = false;
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final bubbleColor = widget.isMine ? chat.bubbleMine : chat.bubbleTheirs;
    final sign = widget.isMine ? -1.0 : 1.0;
    final translationX = _dragOffset * sign;
    final replyProgress = (_dragOffset / _kTriggerThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          // أيقونة الرد المنبثقة خلف الفقاعة أثناء السحب
          if (_dragOffset > 0)
            Positioned(
              right: widget.isMine ? null : 8,
              left: widget.isMine ? 8 : null,
              child: Opacity(
                opacity: replyProgress,
                child: Transform.scale(
                  scale: 0.6 + (0.4 * replyProgress),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: chat.sendButton,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.backgroundColors.scrim.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      LucideIcons.reply,
                      color: chat.sendIcon,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),

          // الفقاعة الرئيسية مع الذيل
          Transform.translate(
            offset: Offset(translationX, 0),
            child: Align(
              alignment: widget.isMine
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2.5,
                ),
                constraints: BoxConstraints(maxWidth: widget.maxWidth),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // جسم الفقاعة — مقاسات واتساب الحقيقي: padding مدمج + radius 8.5
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.isMine ? 8.5 : 0),
                          topRight: Radius.circular(widget.isMine ? 0 : 8.5),
                          bottomLeft: const Radius.circular(8.5),
                          bottomRight: const Radius.circular(8.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.backgroundColors.scrim.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: widget.child,
                    ),

                    // ذيل الفقاعة المتصل بزاوية البداية
                    Positioned(
                      top: 0,
                      right: widget.isMine ? -6.0 : null,
                      left: widget.isMine ? null : -6.0,
                      child: CustomPaint(
                        size: const Size(7, 10),
                        painter: BubbleTailPainter(
                          color: bubbleColor,
                          isMine: widget.isMine,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
