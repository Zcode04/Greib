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
    final chat = context.chatColors;
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: chat.recordingTrash,
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
///  رسام الموجة الصوتية الحية بأسلوب واتساب الحقيقي (WhatsApp Live Waveform)
/// ============================================================================
///  - أعمدة رأسية نحيفة (2.2px) ذات نهايات دائرية (Radius 1.5) مطابقة لفقاعة الصوت
///  - تتوسط المحور الرأسي تماماً بدون أي تموج جيبي مصطنع
///  - تدفق الصوت الحي من جانب المؤقت نحو الطرف الآخر بانسيابية تامة
///  - خط هادئ من النقاط الدائرية (3px) للمسار القادم
///  - مؤشر تشغيل (scrubber dot) سماوي #53BDEB عند المعاينة بعد الإيقاف المؤقت
class LiveWaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color liveBarColor;
  final Color unplayedBarColor;
  final Color playedBarColor;
  final bool isPaused;
  final double? playheadPosition; // 0.0 .. 1.0
  final bool isRTL;

  const LiveWaveformPainter({
    required this.waveform,
    required this.liveBarColor,
    required this.unplayedBarColor,
    required this.playedBarColor,
    required this.isPaused,
    this.playheadPosition,
    this.isRTL = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const double barWidth = 2.2;
    const double barSpacing = 2.0;
    const double totalBarStep = barWidth + barSpacing; // 4.2px
    final int maxVisibleBars = (size.width / totalBarStep).floor();
    if (maxVisibleBars <= 0) return;

    final double centerY = size.height / 2;
    final int count = waveform.length;

    // عدد الأشرطة المسجلة الفعلية
    final int recordedBars = math.min(count, maxVisibleBars);

    // في RTL: مؤشر الوقت يقع على اليمين، وتتدفق العينات الأحدث (المدخل الصوتي الجديد)
    // مباشرة بجوار المؤقت وتتحرك نحو اليسار مثل شريط تسجيل واتساب تماماً.
    for (int i = 0; i < maxVisibleBars; i++) {
      final bool hasAudio = i < recordedBars;
      // العينة 0 هي الأحدث في الطرف الأقرب للمؤقت
      final double sample = hasAudio
          ? waveform[waveform.length - 1 - i]
          : 3.0; // نقطة أساسية هادئة للمسار القادم

      final double barHeight = sample.clamp(3.0, size.height * 0.85);

      // حساب إحداثي X الدقيق دون أي تجاوز خارج الحاوية
      final double x = isRTL
          ? (size.width - barWidth - (i * totalBarStep))
          : (i * totalBarStep);

      // تحديد لون الشريط (متوافق 100% مع الثيم وفقاعة الصوت)
      Color currentBarColor;
      if (isPaused && playheadPosition != null) {
        final double progress = playheadPosition!.clamp(0.0, 1.0);
        // أثناء الاستماع للمعاينة: التشغيل يبدأ من العينة الأقدم إلى الأحدث
        final double barFraction = recordedBars > 1
            ? (recordedBars - 1 - i) / (recordedBars - 1)
            : 0.0;
        final bool isPlayed = barFraction <= progress;
        currentBarColor = isPlayed ? playedBarColor : unplayedBarColor;
      } else {
        currentBarColor = hasAudio ? liveBarColor : unplayedBarColor;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          centerY - (barHeight / 2),
          barWidth,
          barHeight,
        ),
        const Radius.circular(1.5),
      );

      final paint = Paint()
        ..color = currentBarColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);
    }

    // نقطة التمرير السفلية (Scrubber dot) بلون أزرق سماوي #53BDEB عند الإيقاف المؤقت
    if (isPaused && playheadPosition != null && recordedBars > 0) {
      final double progress = playheadPosition!.clamp(0.0, 1.0);
      final double oldestX = isRTL
          ? (size.width - barWidth - ((recordedBars - 1) * totalBarStep))
          : 0.0;
      final double newestX = isRTL
          ? (size.width - barWidth)
          : ((recordedBars - 1) * totalBarStep);

      final double playheadX =
          oldestX + (newestX - oldestX) * progress + (barWidth / 2);

      // ظل خفيف للنقطة
      canvas.drawCircle(
        Offset(playheadX, centerY),
        4.5,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // دائرة المقبض الزرقاء السماوية #53BDEB
      canvas.drawCircle(
        Offset(playheadX, centerY),
        4.0,
        Paint()
          ..color = playedBarColor
          ..style = PaintingStyle.fill,
      );

      // مركز أبيض نقي
      canvas.drawCircle(
        Offset(playheadX, centerY),
        1.6,
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
        old.playheadPosition != playheadPosition ||
        old.liveBarColor != liveBarColor ||
        old.unplayedBarColor != unplayedBarColor ||
        old.playedBarColor != playedBarColor;
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

class _WhatsAppLockedPanelState extends State<WhatsAppLockedPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chat = context.chatColors;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // ألوان لوحة التسجيل حسب الثيم الحقيقي للتطبيق (ليلي / نهاري)
    final panelBg = isDark ? const Color(0xFF1F2C34) : Colors.white;
    final handleColor = isDark
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.black.withValues(alpha: 0.15);
    final timerTextColor = isDark ? Colors.white : const Color(0xFF111B21);

    // ألوان الموجات الصوتية مطابقة تماماً لفقاعة رسالة الصوت في واتساب
    const Color waveCyan = Color(0xFF53BDEB);
    final Color waveInactive = isDark
        ? Colors.white.withValues(alpha: 0.30)
        : const Color(0xFF8696A0).withValues(alpha: 0.38);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.09),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض علوي صغير أنيق
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // سطر المؤقت والموجات الصوتية الحية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // النقطة الحمراء النابضة (أثناء التسجيل فقط)
                if (!widget.isPaused) ...[
                  const WhatsAppRecordingPulseDot(),
                  const SizedBox(width: 8),
                ],

                // زر تشغيل/إيقاف المعاينة الصوتية يظهر بجانب الموجة عند الإيقاف المؤقت (كما في واتساب تماماً)
                if (widget.isPaused) ...[
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTogglePreview();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          widget.isPreviewPlaying
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          size: 18,
                          color: timerTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // عداد الوقت
                Text(
                  formatVoiceDuration(widget.recordSeconds),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: timerTextColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),

                const SizedBox(width: 12),

                // الموجات الصوتية الحية (بنفس أعمدة ونسب فقاعة الصوت)
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: LiveWaveformPainter(
                          waveform: widget.liveWaveform,
                          liveBarColor: waveCyan,
                          unplayedBarColor: waveInactive,
                          playedBarColor: waveCyan,
                          isPaused: widget.isPaused,
                          playheadPosition: widget.isPaused
                              ? widget.previewProgress
                              : null,
                          isRTL: isRTL,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─────────────────────────────────────────────────────────────
          // أزرار التحكم السفلية — تصميم واتساب الأصيل
          // ─────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: widget.isPaused
                // ── حالة الإيقاف المؤقت ──────────────────────────────
                // يسار: زر إرسال أخضر بسهم
                // وسط:  أيقونة مايك + نص "استئناف"
                // يمين: سلة حذف حمراء
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الإرسال — يسار (سهم < مثل واتساب)
                      _CircleActionButton(
                        icon: LucideIcons.chevronLeft,
                        iconColor: chat.sendIcon,
                        backgroundColor: chat.sendButton,
                        size: 52,
                        shadow: [
                          BoxShadow(
                            color: chat.sendButton.withValues(alpha: 0.35),
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

                      // زر الاستئناف في الوسط — كبسولة واتساب الأنيقة مع المايك وكلمة "استئناف"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onResume();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.mic,
                                color: isDark ? Colors.white : const Color(0xFF111B21),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'استئناف',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF111B21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // سلة الحذف — يمين
                      _CircleActionButton(
                        icon: LucideIcons.trash2,
                        iconColor: chat.recordingTrash,
                        backgroundColor:
                            chat.recordingTrash.withValues(alpha: 0.15),
                        size: 52,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onDelete();
                        },
                        tooltip: 'حذف التسجيل',
                      ),
                    ],
                  )
                // ── حالة التسجيل النشط ───────────────────────────────
                // يسار: سلة حذف
                // وسط:  زر إيقاف مؤقت
                // يمين: زر إرسال أخضر
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // سلة الحذف — يسار
                      _CircleActionButton(
                        icon: LucideIcons.trash2,
                        iconColor: chat.recordingTrash,
                        backgroundColor:
                            chat.recordingTrash.withValues(alpha: 0.12),
                        size: 48,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onDelete();
                        },
                        tooltip: 'حذف التسجيل',
                      ),

                      // زر الإيقاف المؤقت — وسط
                      _CircleActionButton(
                        icon: LucideIcons.pause,
                        iconColor: chat.sendButton,
                        backgroundColor:
                            chat.sendButton.withValues(alpha: 0.12),
                        size: 48,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onPause();
                        },
                        tooltip: 'إيقاف مؤقت',
                      ),

                      // زر الإرسال — يمين
                      _CircleActionButton(
                        icon: LucideIcons.send,
                        iconColor: chat.sendIcon,
                        backgroundColor: chat.sendButton,
                        size: 52,
                        shadow: [
                          BoxShadow(
                            color: chat.sendButton.withValues(alpha: 0.35),
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
