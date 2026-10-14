import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ============================================================================
///  NavIcon — أيقونة شريط التنقل بنسختين (بأسلوب فيسبوك):
///    - غير محددة: أيقونة Lucide المفرّغة (IconData).
///    - محددة:     النسخة الممتلئة Filled Lucide (ملف SVG محلي).
///
///  ملفات SVG في: `assets/icons/filled/<name>.svg`
///  (مصدرها مشروع Filled Lucide المجاني برخصة ISC — نفس روح Lucide).
///  كلها `fill="currentColor"` ⇒ تتلوّن بلون الأيقونة تلقائياً.
///
///  الانتقال بين النسختين ناعم (تلاشي + تكبير خفيف 180ms).
/// ============================================================================
class NavIcon extends StatelessWidget {
  /// أيقونة Lucide المفرّغة (الحالة غير المحددة).
  final IconData outlined;

  /// اسم ملف SVG الممتلئ (الحالة المحددة)، بلا لاحقة .svg.
  /// null = لا توجد نسخة ممتلئة (زر إجراء كالكاميرا) ⇒ تبقى المفرّغة دائماً.
  final String? filledAsset;

  /// هل التبويب محدد حالياً؟
  final bool selected;

  /// لون الأيقونة (يُمرَّر للنسختين معاً).
  final Color color;

  /// حجم الأيقونة.
  final double size;

  const NavIcon({
    super.key,
    required this.outlined,
    this.filledAsset,
    required this.selected,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final showFilled = selected && filledAsset != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: showFilled
          ? SvgPicture.asset(
              'assets/icons/filled/$filledAsset.svg',
              key: const ValueKey('filled'),
              width: size,
              height: size,
              // ★ currentColor في الملف ⇒ يأخذ هذا اللون تلقائياً.
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          : Icon(
              outlined,
              key: const ValueKey('outlined'),
              color: color,
              size: size,
            ),
    );
  }
}
