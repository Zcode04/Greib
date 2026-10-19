import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';
import '../../../core/theme/design_tokens.dart';
import 'whatsapp_voice_button.dart';
import 'whatsapp_voice_recorder.dart';

/// ============================================================================
///  شريط الإدخال السفلي بأسلوب WhatsApp الحقيقي (WhatsApp Input Bar)
/// ============================================================================
///  ★ كبسولة إدخال بيضاوية مستقلة + زر إجراء عائم دائري:
///    - أيقونة الإيموجي (ابتسامة)
///    - حقل إدخال مرن متعدد الأسطر
///    - زر إرفاق الوسائط (مشبك الورق)
///    - زر الكاميرا السريع (يختفي بنعومة عند بدء الكتابة)
///    - زر عائم دائري يتحول بحركة ناعمة بين الميكروفون والإرسال
///    - تبديل سلس (Crossfade) لمحتوى الكبسولة إلى عداد التسجيل وسهم الإلغاء
///      أثناء الضغطة المطوّلة (holding) والسحب (lockDragging).
class WhatsAppInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onAttach;
  final VoidCallback onCamera;
  final ValueChanged<String> onChanged;
  final VoidCallback? onEmojiToggle;
  // ★ callbacks الضغطة المطوّلة بأسلوب واتساب (null = السلوك القديم).
  final VoidCallback? onHoldStart;
  final ValueChanged<Offset>? onHoldMove;
  final VoidCallback? onHoldEnd;
  final double micScale;
  final bool cancelArmed;
  // ★ معايير إضافية اختيارية لدعم تجربة واتساب الكاملة (RTL + سحب + عداد)
  final bool isHolding;
  final int recordSeconds;
  final Offset micTranslationOffset;
  final double cancelProgress;

  const WhatsAppInputBar({
    super.key,
    required this.controller,
    required this.hasText,
    required this.onSend,
    required this.onVoice,
    required this.onAttach,
    required this.onCamera,
    required this.onChanged,
    this.onEmojiToggle,
    this.onHoldStart,
    this.onHoldMove,
    this.onHoldEnd,
    this.micScale = 1.0,
    this.cancelArmed = false,
    this.isHolding = false,
    this.recordSeconds = 0,
    this.micTranslationOffset = Offset.zero,
    this.cancelProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // الحقل البيضاوي الرئيسي (Pill Container)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: chat.inputField,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 180),
                crossFadeState: isHolding
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                // محتوى الإدخال العادي (idle)
                firstChild: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // زر الابتسامة / الإيموجي
                    _actionButton(
                      icon: LucideIcons.smile,
                      color: chat.composerIcon,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onEmojiToggle?.call();
                      },
                      tooltip: 'رموز تعبيرية',
                    ),

                    // حقل النص
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: TextField(
                          controller: controller,
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          cursorColor: const Color(0xFF1FA855),
                          cursorWidth: 2,
                          cursorRadius: const Radius.circular(2),
                          style: TextStyle(
                            color: chat.inputText,
                            fontSize: 15.5,
                            height: 1.35,
                          ),
                          onChanged: onChanged,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: TextStyle(
                              color: chat.inputHint,
                              fontSize: 15,
                            ),
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // مشبك المرفقات
                    _actionButton(
                      icon: LucideIcons.paperclip,
                      color: chat.composerIcon,
                      rotation: -0.4,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onAttach();
                      },
                      tooltip: 'إرفاق وسائط',
                    ),

                    // زر الكاميرا (يظهر فقط إذا كان الحقل فارغاً)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: (!hasText && controller.text.isEmpty)
                          ? _actionButton(
                              icon: LucideIcons.camera,
                              color: chat.composerIcon,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                onCamera();
                              },
                              tooltip: 'كاميرا',
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                // محتوى كبسولة التسجيل أثناء الضغط المطوّل (holding / lockDragging)
                secondChild: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      // النقطة الحمراء النابضة
                      const WhatsAppRecordingPulseDot(),
                      const SizedBox(width: 10),

                      // عداد وقت التسجيل mm:ss
                      Text(
                        formatVoiceDuration(recordSeconds),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: chat.inputText,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),

                      const Spacer(),

                      // مؤشر اسحب للإلغاء مع السهم النابض (يخفت تدريجياً مع السحب)
                      WhatsAppSlideToCancel(
                        opacity: (1.0 - cancelProgress).clamp(0.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.xs + 2),

          // زر الإجراء: تفاعلي (ضغطة مطوّلة + قفل + إلغاء) عند توفر callbacks،
          // وإلا السلوك القديم (نقرة تبدأ التسجيل).
          if (onHoldStart != null)
            WhatsAppVoiceButton(
              hasText: hasText,
              onSend: onSend,
              onHoldStart: onHoldStart!,
              onHoldMove: onHoldMove ?? (_) {},
              onHoldEnd: onHoldEnd ?? () {},
              micScale: micScale,
              cancelArmed: cancelArmed,
              translationOffset: micTranslationOffset,
              cancelProgress: cancelProgress,
            )
          else
            _buildFloatingActionButton(chat),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
    double rotation = 0.0,
  }) {
    return IconButton(
      icon: Transform.rotate(
        angle: rotation,
        child: Icon(icon, color: color, size: 22),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      constraints: const BoxConstraints(minWidth: 38, minHeight: 46),
      splashRadius: 20,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  Widget _buildFloatingActionButton(AppChatColors chat) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1FA855),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1FA855).withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            if (hasText) {
              onSend();
            } else {
              onVoice();
            }
          },
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) {
                return ScaleTransition(
                  scale: anim,
                  child: RotationTransition(
                    turns: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                    child: child,
                  ),
                );
              },
              child: hasText
                  ? Icon(
                      LucideIcons.send,
                      key: const ValueKey('send_icon'),
                      color: chat.sendIcon,
                      size: 21,
                    )
                  : Icon(
                      LucideIcons.mic,
                      key: const ValueKey('mic_icon'),
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
