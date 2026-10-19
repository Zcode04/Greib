import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';

/// ============================================================================
///  زر المايك التفاعلي بأسلوب WhatsApp — ضغطة مطوّلة + سحب للقفل/الإلغاء
/// ============================================================================
///  ★ نفس سلوك واتساب الحقيقي 100%:
///    - ضغطة مطوّلة (LongPress) تبدأ التسجيل — الضغطة السريعة تُتجاهل.
///    - المايك يكبر من 1.0 إلى 1.5 أثناء الضغط + اهتزاز خفيف.
///    - أيقونة قفل صاعدة متحركة فوق الزر (تلميح: اسحب لفوق للقفل).
///    - سحب لفوق أكثر من 60px ⇒ قفل hands-free يستمر وحده.
///    - سحب لليسار أكثر من 90px ⇒ تسليح الإلغاء (يتحوّل لأحمر).
///    - إفلات بعد القفل ⇒ يستمر. إفلات بعد تسليح الإلغاء ⇒ يُلغى.
///    - إفلات عادي ⇒ ينتقل للمعاينة قبل الإرسال.
class WhatsAppVoiceButton extends StatelessWidget {
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onHoldStart;
  final ValueChanged<Offset> onHoldMove;
  final VoidCallback onHoldEnd;
  final double micScale;
  final bool cancelArmed;

  const WhatsAppVoiceButton({
    super.key,
    required this.hasText,
    required this.onSend,
    required this.onHoldStart,
    required this.onHoldMove,
    required this.onHoldEnd,
    required this.micScale,
    required this.cancelArmed,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final bg = cancelArmed ? chat.recordingTrash : chat.sendButton;
    return GestureDetector(
      // ★ الضغطة السريعة = إرسال (عند وجود نص) أو لا شيء (بدون نص).
      onTap: () {
        HapticFeedback.mediumImpact();
        if (hasText) onSend();
      },
      // ★ الضغطة المطوّلة = بدء التسجيل (فقط بدون نص — مثل واتساب).
      onLongPressStart: (_) {
        if (hasText) return;
        HapticFeedback.mediumImpact();
        onHoldStart();
      },
      onLongPressMoveUpdate: (details) => onHoldMove(details.offsetFromOrigin),
      onLongPressEnd: (_) => onHoldEnd(),
      child: AnimatedScale(
        scale: micScale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
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
                      size: 22,
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
///  قفل صغير + سهمين صاعدين يتحركان باستمرار أثناء الضغطة المطوّلة.
///  تختفي تلقائياً عند القفل أو الإلغاء أو الإفلات.
class VoiceLockRail extends StatelessWidget {
  final Animation<double> bounce;
  final bool visible;

  const VoiceLockRail({
    super.key,
    required this.bounce,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: AnimatedBuilder(
        animation: bounce,
        builder: (_, _) => Transform.translate(
          // ★ حركة صعود ونزول مستمرة: -6 إلى -14px.
          offset: Offset(0, -6 - 8 * bounce.value),
          child: Container(
            width: 40,
            height: 84,
            decoration: BoxDecoration(
              color: chat.composerBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: chat.composerBorder.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.lock,
                  size: 16,
                  color: chat.composerIcon,
                ),
                const SizedBox(height: 2),
                Icon(
                  LucideIcons.chevronUp,
                  size: 16,
                  color: chat.composerIcon.withValues(alpha: 0.9),
                ),
                Icon(
                  LucideIcons.chevronUp,
                  size: 16,
                  color: chat.composerIcon.withValues(
                    alpha: 0.4 + 0.5 * bounce.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
