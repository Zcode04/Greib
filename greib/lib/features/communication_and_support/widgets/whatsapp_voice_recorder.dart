import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';

/// ============================================================================
///  حالات آلة تسجيل الصوت الست (WhatsApp Voice Recording State Machine)
/// ============================================================================
enum ComposerVoiceState {
  idle,         // 1. الوضع الطبيعي: شريط إدخال بيضاوي وزر مايك أخضر
  holding,      // 2. الضغط المطوّل: مايك مكبّر + كبسولة قفل + تبديل الشريط
  lockDragging, // 3. السحب: للأعلى للقفل أو أفقياً للإلغاء مع تثبيت المحور
  locked,       // 4. التسجيل المقفل: لوحة سفلية بيضاء بموجة حية وأزرار تحكم
  paused,       // 5. الإيقاف المؤقت: موجة متجمدة مع مؤشر تشغيل وزر استئناف
  sent,         // 6. الإرسال: انطواء اللوحة وظهور الفقاعة
  cancelled,    // الإلغاء: انكماش وحذف
}

/// Helper to format seconds as mm:ss
String formatVoiceDuration(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// ============================================================================
///  النقطة الحمراء النابضة للتسجيل النشط
/// ============================================================================
class WhatsAppRecordingPulseDot extends StatefulWidget {
  const WhatsAppRecordingPulseDot({super.key});

  @override
  State<WhatsAppRecordingPulseDot> createState() => _WhatsAppRecordingPulseDotState();
}

class _WhatsAppRecordingPulseDotState extends State<WhatsAppRecordingPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFFE53956),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// ============================================================================
///  مؤشر "اسحب للإلغاء" مع احترام كامل لـ RTL وحركة سهم نابضة متكررة
/// ============================================================================
class WhatsAppSlideToCancel extends StatefulWidget {
  final double opacity;
  const WhatsAppSlideToCancel({super.key, this.opacity = 1.0});

  @override
  State<WhatsAppSlideToCancel> createState() => _WhatsAppSlideToCancelState();
}

class _WhatsAppSlideToCancelState extends State<WhatsAppSlideToCancel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final chevronIcon = isRTL ? LucideIcons.chevronRight : LucideIcons.chevronLeft;
    final double slideOffset = (isRTL ? 4.0 : -4.0) * _ctrl.value;

    return Opacity(
      opacity: widget.opacity.clamp(0.0, 1.0),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(slideOffset, 0),
                child: Icon(
                  chevronIcon,
                  size: 16,
                  color: chat.recordingWaveUnplayed.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'اسحب للإلغاء',
                style: TextStyle(
                  color: chat.inputText.withValues(alpha: 0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ============================================================================
///  رسام الموجة الصوتية الحية (Live Waveform CustomPainter)
/// ============================================================================
///  - 60 إطاراً بالثانية مع RepaintBoundary
///  - أعمدة تتغير حسب الـ amplitude الحقيقي وتتحرك من اليمين لليسار
///  - مؤشر تشغيل أخضر playhead عند التجميد (paused)
class LiveWaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;
  final bool isPaused;
  final double animationValue;
  final double? playheadPosition; // 0.0 .. 1.0
  final bool isRTL;

  const LiveWaveformPainter({
    required this.waveform,
    required this.color,
    required this.isPaused,
    required this.animationValue,
    this.playheadPosition,
    this.isRTL = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveform.isEmpty) {
      // خط أساسي خفيف عند البداية قبل وصول عينات
      final basePaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        basePaint,
      );
      return;
    }

    final barPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    const double barWidth = 3.0;
    const double barSpacing = 2.5;
    const double totalBarStep = barWidth + barSpacing;
    final int maxVisibleBars = (size.width / totalBarStep).floor();
    final centerY = size.height / 2;

    // نأخذ آخر N عينة تناسب العرض
    final int count = math.min(waveform.length, maxVisibleBars);
    final startIndex = waveform.length - count;

    for (int i = 0; i < count; i++) {
      final sample = waveform[startIndex + i];
      final double barHeight = sample.clamp(4.0, size.height * 0.85);

      // في RTL الموجة تبدأ من اليمين وتتحرك لليسار مع تدفق الصوت الجديد
      final double x = isRTL
          ? (size.width - ((count - i) * totalBarStep))
          : (i * totalBarStep);

      // تأثير تموج طفيف إضافي أثناء التسجيل النشط
      final double dynamicWave = isPaused
          ? 0.0
          : math.sin(animationValue * 2 * math.pi + (i * 0.25)) * 2.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY + dynamicWave),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, barPaint);
    }

    // مؤشر التشغيل (playhead) عند الإيقاف المؤقت (paused)
    if (isPaused && playheadPosition != null) {
      final playheadX = playheadPosition!.clamp(0.0, 1.0) * size.width;
      final playheadPaint = Paint()
        ..color = const Color(0xFF1FA855)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(playheadX, 4),
        Offset(playheadX, size.height - 4),
        playheadPaint,
      );

      // دائرة مقبض في المنتصف
      canvas.drawCircle(
        Offset(playheadX, centerY),
        5.5,
        Paint()
          ..color = const Color(0xFF1FA855)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(playheadX, centerY),
        2.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LiveWaveformPainter old) {
    return old.waveform.length != waveform.length ||
        old.isPaused != isPaused ||
        old.animationValue != animationValue ||
        old.playheadPosition != playheadPosition;
  }
}

/// ============================================================================
///  لوحة التسجيل المقفل (WhatsApp Locked Bottom Sheet Panel)
/// ============================================================================
///  - تحوّل سلس بارتفاع متزايد (~200ms easeOut)
///  - لوحة سفلية بيضاء بزوايا علوية دائرية وظل علوي
///  - موجة حية داخل RepaintBoundary
///  - عداد وقت
///  - زر إيقاف مؤقت / استئناف
///  - سلة حذف حمراء دائرية (#E53956)
///  - زر إرسال أخضر دائري (#1FA855)
class WhatsAppLockedPanel extends StatefulWidget {
  final int recordSeconds;
  final List<double> liveWaveform;
  final bool isPaused;
  final bool isPreviewPlaying;
  final double previewProgress; // 0.0 .. 1.0
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onTogglePreview;
  final VoidCallback onDelete;
  final VoidCallback onSend;

  const WhatsAppLockedPanel({
    super.key,
    required this.recordSeconds,
    required this.liveWaveform,
    required this.isPaused,
    this.isPreviewPlaying = false,
    this.previewProgress = 0.0,
    required this.onPause,
    required this.onResume,
    required this.onTogglePreview,
    required this.onDelete,
    required this.onSend,
  });

  @override
  State<WhatsAppLockedPanel> createState() => _WhatsAppLockedPanelState();
}

class _WhatsAppLockedPanelState extends State<WhatsAppLockedPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _waveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض علوي صغير
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // منطقة الموجة الصوتية الحية (RepaintBoundary للأداء 60fps)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _waveAnimController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: LiveWaveformPainter(
                        waveform: widget.liveWaveform,
                        color: const Color(0xFF1FA855),
                        isPaused: widget.isPaused,
                        animationValue: _waveAnimController.value,
                        playheadPosition: widget.isPaused
                            ? widget.previewProgress
                            : null,
                        isRTL: isRTL,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),
          ),

          // عداد الوقت وشارة الإيقاف المؤقت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                if (!widget.isPaused) ...[
                  const WhatsAppRecordingPulseDot(),
                  const SizedBox(width: 8),
                ],
                Text(
                  formatVoiceDuration(widget.recordSeconds),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: chat.inputText,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (widget.isPaused) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FA855).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'متوقف مؤقتاً',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1FA855),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // أزرار التحكم السفلية: حذف (أحمر) - إيقاف/استئناف/معاينة - إرسال (أخضر)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // سلة الحذف الحمراء (#E53956)
                _CircleActionButton(
                  icon: LucideIcons.trash2,
                  iconColor: const Color(0xFFE53956),
                  backgroundColor: const Color(0xFFE53956).withValues(alpha: 0.12),
                  size: 48,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onDelete();
                  },
                  tooltip: 'حذف التسجيل',
                ),

                // أزرار الوسط (إيقاف مؤقت أو استئناف ومعاينة)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isPaused) ...[
                      // زر تشغيل/إيقاف المعاينة الصوتية
                      _CircleActionButton(
                        icon: widget.isPreviewPlaying
                            ? LucideIcons.pause
                            : LucideIcons.play,
                        iconColor: const Color(0xFF1FA855),
                        backgroundColor: const Color(0xFF1FA855).withValues(alpha: 0.12),
                        size: 48,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onTogglePreview();
                        },
                        tooltip: widget.isPreviewPlaying ? 'إيقاف المعاينة' : 'تشغيل المعاينة',
                      ),
                      const SizedBox(width: 12),
                    ],

                    // زر الإيقاف المؤقت أو الاستئناف
                    _CircleActionButton(
                      icon: widget.isPaused ? LucideIcons.mic : LucideIcons.pause,
                      iconColor: widget.isPaused ? Colors.white : const Color(0xFF1FA855),
                      backgroundColor: widget.isPaused
                          ? const Color(0xFF1FA855)
                          : const Color(0xFF1FA855).withValues(alpha: 0.12),
                      size: 48,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (widget.isPaused) {
                          widget.onResume();
                        } else {
                          widget.onPause();
                        }
                      },
                      tooltip: widget.isPaused ? 'استئناف التسجيل' : 'إيقاف مؤقت',
                    ),
                  ],
                ),

                // زر الإرسال الأخضر الدائري (#1FA855)
                _CircleActionButton(
                  icon: LucideIcons.send,
                  iconColor: Colors.white,
                  backgroundColor: const Color(0xFF1FA855),
                  size: 52,
                  shadow: [
                    BoxShadow(
                      color: const Color(0xFF1FA855).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onSend();
                  },
                  tooltip: 'إرسال الرسالة الصوتية',
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// زر دائري تفاعلي مع تأثير اللمس
class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final VoidCallback onPressed;
  final String tooltip;
  final List<BoxShadow>? shadow;

  const _CircleActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.size,
    required this.onPressed,
    required this.tooltip,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, color: iconColor, size: size * 0.44),
          ),
        ),
      ),
    );
  }
}
