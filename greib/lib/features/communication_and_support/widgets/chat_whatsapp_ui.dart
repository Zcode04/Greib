import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';

/// ============================================================================
///  خلفية المحادثة بلون طبيعي صلب (بدون نقش Doodle / خلفية خاصة)
/// ============================================================================
///  ★ خلفية نقية بلا أي نقوش أو أنماط، ولونها مشتق من اللوحة المركزية
///    (الثيم) فيتبدّل مع الوضع الليلي/النهاري وأي ثيم يختاره المستخدم.
class ChatDoodleBackground extends StatelessWidget {
  final Widget child;

  const ChatDoodleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return Container(
      color: chat.conversationBackground,
      child: child,
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


