import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class FloatingNav extends StatelessWidget {
  final int currentIndex;
  final List<FloatingNavItem> items;
  final Function(int)? onTap;

  const FloatingNav({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceCard.withValues(alpha: 0.92)
            : AppColors.lightSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(
          color: isDark ? AppColors.outline : AppColors.lightOutline,
          width: 1,
        ),
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap?.call(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentPrimary : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected ? AppShadows.glowGreen : null,
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: isSelected ? Colors.black : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class FloatingNavScaffold extends StatelessWidget {
  final int currentIndex;
  final List<FloatingNavItem> items;
  final Widget child;
  final Function(int)? onNavTap;

  const FloatingNavScaffold({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.child,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.lg,
            child: Center(
              child: FloatingNav(
                currentIndex: currentIndex,
                items: items,
                onTap: onNavTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}