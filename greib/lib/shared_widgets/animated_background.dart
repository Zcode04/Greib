import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color1 = isDark ? const Color(0xFF4C1D95).withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.1);
    final color2 = isDark ? const Color(0xFF7C5CFC).withValues(alpha: 0.2) : Colors.purple.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + 50 * sin(_controller.value * 2 * pi),
              left: -100 + 50 * cos(_controller.value * 2 * pi),
              child: _Blob(color: color1, size: 400),
            ),
            Positioned(
              bottom: -150 + 70 * cos(_controller.value * 2 * pi),
              right: -50 + 60 * sin(_controller.value * 2 * pi),
              child: _Blob(color: color2, size: 500),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
