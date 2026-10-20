import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/extensions/context_extensions.dart';
import '../core/theme/design_tokens.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  final bool hasGlow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
    this.hasGlow = false,
  });

  factory GlassContainer.frosted({
    Key? key,
    required Widget child,
    double blur = 25.0,
    double opacity = 0.15,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    bool hasGlow = false,
  }) {
    return GlassContainer(
      key: key,
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      border: border,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      hasGlow: hasGlow,
      child: child,
    );
  }

  factory GlassContainer.elevated({
    Key? key,
    required Widget child,
    double blur = 15.0,
    double opacity = 0.1,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    bool hasGlow = false,
  }) {
    return GlassContainer(
      key: key,
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      border: border,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      hasGlow: hasGlow,
      boxShadow: AppShadows.soft,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    // اللون الافتراضي يتكيّف مع الوضع عبر اللوحة (فاتح في الداكن والعكس).
    final baseColor = color ??
        (isDark ? context.textColors.primary : context.textColors.inverse);
    final rad = borderRadius ?? BorderRadius.circular(24);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ]
            : boxShadow,
        borderRadius: rad,
      ),
      child: ClipRRect(
        borderRadius: rad,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withValues(alpha: opacity * 1.5),
                  baseColor.withValues(alpha: opacity * 0.5),
                ],
              ),
              borderRadius: rad,
              border:
                  border ??
                  Border.all(
                    color: baseColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    width: 1.0,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
