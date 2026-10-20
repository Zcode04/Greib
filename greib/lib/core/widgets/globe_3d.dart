import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// Globe3D — الكرة الأرضية 3D الأصلية (الوضع العادي قبل المكتبات).
/// الخريطة الحقيقية اختيارية فقط عبر زر «نمط الخريطة».
class Globe3D extends StatelessWidget {
  final double size;
  const Globe3D({super.key, this.size = 128});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size, width: size,
      child: const _SpinningGlobe());
  }
}

/// بطاقة العالم الكاملة (خلفية + شبكة + كرة) — نفس تصميم الأصل.
class GlobeCard extends StatelessWidget {
  final bool isDark;
  const GlobeCard({super.key, required this.isDark});
  @override
  Widget build(BuildContext context) {
    // ★ كل الألوان من اللوحة المركزية (Color Palette) عبر السياق.
    final tint = context.iconColors.primary;
    return AspectRatio(
      aspectRatio: 1.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.2, -0.2),
                  radius: 1.1,
                  colors: [
                    tint.withValues(alpha: 0.18),
                    context.backgroundColors.primary,
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _GlobeGridPainter(
                  line: context.textColors.secondary.withValues(alpha: 0.28)),
              ),
            ),
            const Center(child: _SpinningGlobe()),
          ],
        ),
      ),
    );
  }
}

class _GlobeGridPainter extends CustomPainter {
  final Color line;
  const _GlobeGridPainter({required this.line});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(_GlobeGridPainter old) => old.line != line;
}

class _SpinningGlobe extends StatefulWidget {
  const _SpinningGlobe();
  @override
  State<_SpinningGlobe> createState() => _SpinningGlobeState();
}

class _SpinningGlobeState extends State<_SpinningGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this, duration: const Duration(seconds: 18))..repeat();
  static const List<List<double>> pins = [
    [25.2, 55.3], [24.7, 46.7], [30.0, 31.2], [31.2, 34.8],
    [33.5, 36.3], [21.4, 39.8], [15.4, 44.2],
  ];
  @override
  void dispose() { _spin.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 128, width: 128,
      child: AnimatedBuilder(animation: _spin,
        builder: (context, _) => CustomPaint(
          painter: _GlobePainter(
            turns: _spin.value,
            brand: context.accentColor,
            background: context.backgroundColors.primary,
            grid: context.textColors.onMedia,
            success: context.iconColors.success,
          ),
        )));
  }
}

class _GlobePainter extends CustomPainter {
  final double turns;

  /// ★ لون الكرة من اللوحة المركزية (يسري مع تغيير الهوية فوراً).
  final Color brand;

  /// ★ لون الخلفية من اللوحة المركزية.
  final Color background;

  /// ★ لون خطوط الشبكة فوق الكرة (لون "على الوسائط").
  final Color grid;

  /// ★ لون دبابيس السفر من اللوحة المركزية.
  final Color success;

  const _GlobePainter({
    required this.turns,
    required this.brand,
    required this.background,
    required this.grid,
    required this.success,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sphere = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.35, -0.4), radius: 1.0,
        colors: [brand, background],
        stops: const [0.0, 1.0]).createShader(rect);
    canvas.drawCircle(center, radius, sphere);
    final line = Paint()
      ..color = grid.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final phase = turns * 2 * math.pi;
    for (final lat in [-60.0, -30.0, 0.0, 30.0, 60.0]) {
      final dy = radius * math.sin(lat * math.pi / 180);
      final w = radius * math.cos(lat * math.pi / 180);
      canvas.drawOval(Rect.fromCenter(center: center.translate(0, dy),
        width: w * 2, height: math.max(w * 0.28, radius * 0.16)), line);
    }
    for (var i = 0; i < 6; i++) {
      final lon = (i / 6) * 2 * math.pi + phase;
      final w = radius * math.cos(lon).abs();
      if (w < 1) continue;
      canvas.drawOval(Rect.fromCenter(center: center,
        width: w * 2, height: radius * 2), line);
    }
    canvas.drawCircle(center, radius, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = grid.withValues(alpha: 0.25));
    final refLat = _SpinningGlobeState.pins.first[0];
    final refLon = _SpinningGlobeState.pins.first[1];
    for (final pin in _SpinningGlobeState.pins) {
      final x = ((pin[1] - refLon) * math.cos(pin[0] * math.pi / 180)) / 90 * radius;
      final y = ((refLat - pin[0]) / 90) * radius;
      final p = center.translate(x, y);
      if ((p - center).distance > radius * 0.94) continue;
      canvas.drawCircle(p, 2.4, Paint()..color = success);
    }
  }
  @override
  bool shouldRepaint(_GlobePainter old) =>
      old.turns != turns ||
      old.brand != brand ||
      old.background != background ||
      old.grid != grid ||
      old.success != success;
}
