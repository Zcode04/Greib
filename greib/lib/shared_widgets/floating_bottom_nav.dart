// shared_widgets/floating_bottom_nav.dart
//
// شريط تنقل سفلي عائم — المصدر الوحيد للتنقل السفلي في التطبيق
// (تم حذف floating_nav.dart المكرر)
//
// المميزات:
// • حاوية زجاجية شفافة مع blur وحواف دائرية
// • العنصر المحدد: خلفية بنفسجية مضيئة + animation سلس
// • الأيقونات من مكتبة Lucide
//
// الاستخدام (في MainShellScreen فقط):
//   bottomNavigationBar: FloatingBottomNav(
//     currentIndex: _currentNavIndex,
//     onTap: (i) => ...,
//     items: const [
//       FloatingNavItem(icon: LucideIcons.wallet,        label: 'المحفظة'),
//       FloatingNavItem(icon: LucideIcons.messageCircle, label: 'المحادثات'),
//       FloatingNavItem(icon: LucideIcons.home,          label: 'الرئيسية'),
//       FloatingNavItem(icon: LucideIcons.heart,         label: 'المفضلة'),
//       FloatingNavItem(icon: LucideIcons.user,          label: 'البروفايل'),
//     ],
//   )

import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FloatingNavItem {
  final IconData icon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.label,
  });
}

class FloatingBottomNav extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(
          items.length >= 2 && items.length <= 5,
          'استخدم بين 2 و5 عناصر ليبقى الشكل متوازناً',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceCard.withValues(alpha: 0.85)
                  : AppColors.lightSurface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: isDark
                    ? AppColors.outline.withValues(alpha: 0.6)
                    : AppColors.lightOutline,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                if (isDark)
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = index == currentIndex;

                return Expanded(
                  child: _NavTile(
                    item: item,
                    selected: selected,
                    isDark: isDark,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final FloatingNavItem item;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.accentPrimaryLight : AppColors.accentPrimary;
    final inactiveColor = isDark ? AppColors.textTertiary : AppColors.lightTextSecondary;
    final iconColor = selected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- حاوية الأيقونة مع تأثير بصري عند التحديد ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: selected ? 44 : 40,
            height: selected ? 32 : 28,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accentPrimary.withValues(alpha: isDark ? 0.2 : 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(item.icon, color: iconColor, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 3),
          // --- النص ---
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: iconColor,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}