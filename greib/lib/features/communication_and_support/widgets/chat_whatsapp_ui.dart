import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';

/// ============================================================================
///  خلفية المحادثة بنقش Doodle خفيف بأسلوب WhatsApp الأصيل
/// ============================================================================
///  ★ بصري فقط: يرسم أشكال Doodle لطيفة وخافتة فوق لون الخلفية المركزي.
///  ◆ اللون من [AppChatColors.doodleColor] ⇒ يتغير مع اللوحة تلقائياً.
class ChatDoodleBackground extends StatelessWidget {
  final Widget child;

  const ChatDoodleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return Container(
      color: chat.conversationBackground,
      child: CustomPaint(
        painter: _WhatsAppDoodlePainter(color: chat.doodleColor),
        child: child,
      ),
    );
  }
}

/// ============================================================================
///  ذيل فقاعة الرسالة المنحني بأسلوب WhatsApp الدقيق
/// ============================================================================
///  ★ يرسم ذيل الفقاعة بانحناءة ناعمة مطابقة لواتساب.
class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isMine;

  const BubbleTailPainter({required this.color, required this.isMine});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    if (isMine) {
      // الذيل الأيمن (رسائلي): ينطلق من أعلى زاوية الفقاعة بانحناءة للخارج
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.65,
        0,
        size.height,
      );
      path.close();
    } else {
      // الذيل الأيسر (رسائل الطرف الآخر)
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.65,
        size.width,
        size.height,
      );
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubbleTailPainter old) =>
      old.color != color || old.isMine != isMine;
}

/// ============================================================================
///  علامات الصح المزدوجة بأسلوب واتساب (Double Blue / Sent Ticks)
/// ============================================================================
class WhatsAppTicks extends StatelessWidget {
  final bool isRead;
  final double size;

  const WhatsAppTicks({
    super.key,
    this.isRead = true,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final color = isRead ? chat.tickRead : chat.tickSent;
    return Icon(
      LucideIcons.checkCheck,
      size: size,
      color: color,
    );
  }
}

/// رسام نقوش Doodle خفيفة مستوحاة من خلفية واتساب الشهيرة
class _WhatsAppDoodlePainter extends CustomPainter {
  final Color color;
  const _WhatsAppDoodlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    const cellW = 84.0;
    const cellH = 84.0;
    final cols = (size.width / cellW).ceil() + 1;
    final rows = (size.height / cellH).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * cellW + ((r % 2 == 1) ? cellW / 2 : 0.0);
        final cy = r * cellH;

        if (cx > size.width + 30 || cy > size.height + 30) continue;

        final patternType = (r * 3 + c) % 6;
        switch (patternType) {
          case 0:
            // فقاعة كلام صغيرة
            _drawChatBubble(canvas, Offset(cx, cy), strokePaint);
            break;
          case 1:
            // نجمة رباعية / لمعة
            _drawSparkle(canvas, Offset(cx, cy), strokePaint);
            break;
          case 2:
            // دائرة مجوفة صغيرة مع نقطة
            canvas.drawCircle(Offset(cx, cy), 3.5, strokePaint);
            canvas.drawCircle(Offset(cx, cy), 1.0, fillPaint);
            break;
          case 3:
            // موجة صوتية خفيفة
            _drawWave(canvas, Offset(cx, cy), strokePaint);
            break;
          case 4:
            // قلب صغير
            _drawHeart(canvas, Offset(cx, cy), strokePaint);
            break;
          case 5:
            // ثلاث نقاط متدرجة
            canvas.drawCircle(Offset(cx - 3.5, cy), 1.2, fillPaint);
            canvas.drawCircle(Offset(cx, cy), 1.6, fillPaint);
            canvas.drawCircle(Offset(cx + 3.5, cy), 1.2, fillPaint);
            break;
        }
      }
    }
  }

  void _drawChatBubble(Canvas canvas, Offset center, Paint paint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 12, height: 9),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);
    // ذيل صغير
    final path = Path()
      ..moveTo(center.dx - 2, center.dy + 4.5)
      ..lineTo(center.dx - 5, center.dy + 7)
      ..lineTo(center.dx + 1, center.dy + 4.5);
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    const r = 5.0;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx, center.dy + r)
      ..moveTo(center.dx - r, center.dy)
      ..lineTo(center.dx + r, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawWave(Canvas canvas, Offset center, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - 5, center.dy)
      ..quadraticBezierTo(center.dx - 2.5, center.dy - 3, center.dx, center.dy)
      ..quadraticBezierTo(center.dx + 2.5, center.dy + 3, center.dx + 5, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    const w = 4.0;
    path.moveTo(center.dx, center.dy + 3);
    path.cubicTo(
      center.dx - w, center.dy,
      center.dx - w, center.dy - 3,
      center.dx, center.dy - 2,
    );
    path.cubicTo(
      center.dx + w, center.dy - 3,
      center.dx + w, center.dy,
      center.dx, center.dy + 3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WhatsAppDoodlePainter old) =>
      old.color != color;
}
