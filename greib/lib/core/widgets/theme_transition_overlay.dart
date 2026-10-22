import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/color_palette_controller.dart';
import '../theme/theme_controller.dart';

/// ============================================================================
///  ThemeTransitionOverlay — انتقال احترافي وسلس عند تبديل الوضع الليلي/النهاري
///
///  ◆ لماذا لا نستخدم أنيميشن الثيم المدمج في MaterialApp؟
///    الأنيميشن المدمج (`AnimatedTheme`) ينتج ثيماً وسيطة كل إطار عبر
///    `ThemeData.lerp` على ThemeData ضخم (ColorScheme + 14 نمط نصي + ثيمات
///    فرعية) ⇒ إطارات ثقيلة تُقرأ كتقطّع/توقّف لحظي، خصوصاً في الدردشة.
///
///  ◆ الحل هنا:
///    1) تبديل الثيم **فوري** (`AnimationStyle.noAnimation` في main.dart)
///       ⇒ صفر تكلفة على كل إطار.
///    2) طبقة حجاب بلون خلفية الوضع **القديم** تُرسم فوق كل الشاشة (وكذلك فوق
///       أي ورقة سفلية/نافذة مفتوحة لأنها داخل Navigator)، ثم تتلاشى تدريجياً
///       ⇒ العين تقرأها كتلاشٍ متقاطع ناعم بين الوضعين.
///
///  ★ الطبقة بلا `Opacity` (تستخدم قناة الشفافية في اللون مباشرة) ⇒ بلا
///    `saveLayer` ⇒ كلفة رسم شبه معدومة، و`IgnorePointer` حتى لا تحجب اللمس.
/// ============================================================================
class ThemeTransitionOverlay extends StatefulWidget {
  const ThemeTransitionOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  /// مدة كافية ليُلاحظ المستخدم التغيير، وقصيرة لتبقى الاستجابة فورية.
  static const Duration _duration = Duration(milliseconds: 420);
  static const Curve _curve = Curves.easeOutCubic;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  late final ThemeController _themeController =
      context.read<ThemeController>();
  late final ColorPaletteController _paletteController =
      context.read<ColorPaletteController>();

  bool _isDark = false;
  Color _veil = const Color(0x00000000);

  @override
  void initState() {
    super.initState();
    _isDark = _themeController.isDarkMode;
    _themeController.addListener(_onThemeChanged);
    _controller.addStatusListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    final next = _themeController.isDarkMode;
    if (next == _isDark) return;
    // ★ الحجاب بلون خلفية الوضع الذي كان معروضاً قبل الضغط (الوضع القديم)،
    //   فيبدأ المشهد مطابقاً تماماً لما رآه المستخدم ثم يتلاشى إلى الوضع الجديد.
    _veil = _paletteController.paletteFor(_isDark).background.primary;
    _isDark = next;
    // إعادة التشغيل من الصفر ⇒ يبقى الحجاب معتماً في إطار التبديل نفسه.
    _controller.forward(from: 0);
  }

  void _onStatusChanged(AnimationStatus status) {
    // إعادة بناء أخيرة عند الاكتمال لإزالة الحجاب من الشجرة.
    if (status == AnimationStatus.completed && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // ★ عزل محتوى التطبيق في طبقة رسم مستقلة: أثناء التلاشي تتغيّر شفافية
      //   الحجاب وحده (عملية دمج بسيطة) بدل إعادة رسم الشجرة كاملة كل إطار.
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        // لا حجاب إلا أثناء الانتقال.
        final double progress =
            _controller.isAnimating ? _curve.transform(_controller.value) : 1;
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.topLeft,
          children: [
            child!,
            if (progress < 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: _veil.withValues(alpha: 1 - progress),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
