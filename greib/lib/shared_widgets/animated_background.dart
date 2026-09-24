import 'dart:math';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

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
    // بقع ضوئية من اللون الرسمي (Ice Blue) بدل البنفسجي القديم.
    final color1 = isDark
        ? AppColors.accentPrimaryContainerDark.withValues(alpha: 0.35)
        : AppColors.accentPrimary.withValues(alpha: 0.45);
    final color2 = isDark
        ? AppColors.accentPrimary.withValues(alpha: 0.16)
        : AppColors.accentPrimaryDark.withValues(alpha: 0.10);

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
