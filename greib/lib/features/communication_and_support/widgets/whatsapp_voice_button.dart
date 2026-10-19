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
class WhatsAppVoiceButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final bg = cancelArmed ? chat.recordingTrash : const Color(0xFF1FA855);
    final effectiveScale = cancelArmed
        ? (micScale * 0.85).clamp(0.6, 1.6)
        : micScale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // ★ الضغطة السريعة = إرسال (عند وجود نص) أو لا شيء (بدون نص).
      onTap: () {
        HapticFeedback.lightImpact();
        if (hasText) onSend();
      },
      // ★ الضغطة المطوّلة = بدء التسجيل (فقط بدون نص — مثل واتساب).
      onLongPressStart: (_) {
        if (hasText) return;
        HapticFeedback.lightImpact();
        onHoldStart();
      },
      onLongPressMoveUpdate: (details) => onHoldMove(details.offsetFromOrigin),
      onLongPressEnd: (_) => onHoldEnd(),
      child: Transform.translate(
        offset: translationOffset,
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
                child: hasText
                    ? Icon(
                        LucideIcons.send,
                        key: const ValueKey('send_icon'),
                        color: chat.sendIcon,
                        size: 21,
                      )
                    : Icon(
                        cancelArmed ? LucideIcons.trash2 : LucideIcons.mic,
                        key: ValueKey(cancelArmed ? 'trash_icon' : 'mic_icon'),
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
    final Color lockColor = isNearLock ? const Color(0xFF1FA855) : chat.composerIcon;

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: chat.composerBorder.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
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
