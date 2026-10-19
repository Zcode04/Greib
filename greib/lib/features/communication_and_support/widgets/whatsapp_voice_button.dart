import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';

/// ============================================================================
///  زر المايك التفاعلي بأسلوب WhatsApp — ضغطة مطوّلة + سحب للقفل/الإلغاء
/// ============================================================================
///  ★ نفس سلوك واتساب الحقيقي:
///    - ضغطة مطوّلة (LongPress) تبدأ التسجيل — الضغطة السريعة تُتجاهل (إلا إذا كان هناك نص).
///    - المايك يكبر إلى ~1.5x بحركة spring أثناء الضغط + اهتزاز خفيف.
///    - يتحرك المايك أفقياً مع الإصبع أثناء السحب للإلغاء.
///    - يتحول لسلة حمراء وينكمش عند تجاوز عتبة الإلغاء.
class WhatsAppVoiceButton extends StatefulWidget {
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onHoldStart;
  final ValueChanged<Offset> onHoldMove;
  final VoidCallback onHoldEnd;
  final double micScale;
  final bool cancelArmed;
  final Offset translationOffset;
  final double cancelProgress;

  const WhatsAppVoiceButton({
    super.key,
    required this.hasText,
    required this.onSend,
    required this.onHoldStart,
    required this.onHoldMove,
    required this.onHoldEnd,
    required this.micScale,
    required this.cancelArmed,
    this.translationOffset = Offset.zero,
    this.cancelProgress = 0.0,
  });

  @override
  State<WhatsAppVoiceButton> createState() => _WhatsAppVoiceButtonState();
}

class _WhatsAppVoiceButtonState extends State<WhatsAppVoiceButton> {
  Offset? _startPosition;
  DateTime? _downTime;
  Timer? _holdTimer;
  bool _isHolding = false;

  void _triggerHoldStart() {
    if (_isHolding || widget.hasText) return;
    _isHolding = true;
    _holdTimer?.cancel();
    HapticFeedback.lightImpact();
    widget.onHoldStart();
  }

  void _onPointerDown(PointerDownEvent event) {
    _startPosition = event.position;
    _downTime = DateTime.now();
    _isHolding = false;
    _holdTimer?.cancel();

    if (!widget.hasText) {
      // استجابة فائقة السرعة: 100ms فقط للثبات (بدلاً من 500ms)
      _holdTimer = Timer(const Duration(milliseconds: 100), () {
        _triggerHoldStart();
      });
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_startPosition == null) return;
    final delta = event.position - _startPosition!;

    // ★ بمجرد حدوث أي سحب سريع (أكثر من 4px)، يبدأ التسجيل فوراً دون أي انتظار!
    if (!_isHolding && !widget.hasText) {
      if (delta.distance > 4.0) {
        _triggerHoldStart();
      }
    }

    if (_isHolding) {
      widget.onHoldMove(delta);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _holdTimer?.cancel();
    final wasHolding = _isHolding;
    _isHolding = false;

    if (widget.hasText) {
      final duration = DateTime.now().difference(_downTime ?? DateTime.now());
      final distance = _startPosition != null
          ? (event.position - _startPosition!).distance
          : 0.0;
      if (duration.inMilliseconds < 450 && distance < 25.0) {
        HapticFeedback.lightImpact();
        widget.onSend();
      }
    } else {
      if (wasHolding) {
        widget.onHoldEnd();
      }
    }
    _startPosition = null;
    _downTime = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _holdTimer?.cancel();
    if (_isHolding) {
      _isHolding = false;
      widget.onHoldEnd();
    }
    _startPosition = null;
    _downTime = null;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    // ★ خلفية الزر من الثيم بدل الثابت.
    final bg = widget.cancelArmed ? chat.recordingTrash : chat.sendButton;
    final effectiveScale = widget.cancelArmed
        ? (widget.micScale * 0.85).clamp(0.6, 1.6)
        : widget.micScale;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Transform.translate(
        offset: widget.translationOffset,
        child: AnimatedScale(
          scale: effectiveScale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bg.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: RotationTransition(
                    turns: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                    child: child,
                  ),
                ),
                child: widget.hasText
                    ? Icon(
                        LucideIcons.send,
                        key: const ValueKey('send_icon'),
                        color: chat.sendIcon,
                        size: 21,
                      )
                    : Icon(
                        widget.cancelArmed ? LucideIcons.trash2 : LucideIcons.mic,
                        key: ValueKey(widget.cancelArmed ? 'trash_icon' : 'mic_icon'),
                        color: chat.sendIcon,
                        size: 23,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
///  سكة القفل الصاعدة فوق زر المايك — تلميح واتساب الشهير
/// ============================================================================
///  قفل يتحول من مغلق → مفتوح تدريجياً مع السحب، وسهمين صاعدين يتحركان.
///  الكبسولة تمتد ارتفاعاً مع تقدم السحب. تختفي عند القفل أو الإفلات.
class VoiceLockRail extends StatelessWidget {
  final Animation<double> bounce;       // حركة السهمين الصاعدة/النازلة
  final double lockProgress;            // 0.0 (مغلق) → 1.0 (مفتوح/مقفل)
  final bool visible;
  final bool isRTL;

  const VoiceLockRail({
    super.key,
    required this.bounce,
    this.lockProgress = 0.0,
    required this.visible,
    this.isRTL = true,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final double railHeight = 84.0 + (40.0 * lockProgress.clamp(0.0, 1.0)); // تمدد من 84 إلى 124px
    final bool isNearLock = lockProgress >= 0.6;
    final IconData lockIcon = isNearLock ? LucideIcons.lockOpen : LucideIcons.lock;
    // ★ ألوان القفل والسكة من الثيم بدل الثابت.
    final Color lockColor = isNearLock ? chat.sendButton : chat.composerIcon;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: bounce,
          builder: (context, child) {
            final bounceOffset = -6.0 - (8.0 * bounce.value);
            return Transform.translate(
              offset: Offset(0, bounceOffset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                width: 42,
                height: railHeight,
                decoration: BoxDecoration(
                  // ★ خلفية السكة متوافقة تماماً مع الثيم (ليلي / نهاري)
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F2C34)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Icon(
                        lockIcon,
                        key: ValueKey(isNearLock),
                        size: 19,
                        color: lockColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      LucideIcons.chevronUp,
                      size: 15,
                      color: chat.composerIcon.withValues(alpha: 0.85),
                    ),
                    Icon(
                      LucideIcons.chevronUp,
                      size: 15,
                      color: chat.composerIcon.withValues(
                        alpha: 0.35 + (0.55 * bounce.value),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
