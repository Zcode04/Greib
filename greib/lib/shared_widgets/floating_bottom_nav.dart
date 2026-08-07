// shared_widgets/floating_bottom_nav.dart
//
// شريط تنقل سفلي عائم:
// - شريط داكن نصف شفاف بحواف دائرية كاملة
// - جميع الأيقونات موحّدة الشكل والحجم (بدون زر مرتفع/دائري في المنتصف)
// - الأيقونات من مكتبة Lucide (lucide_icons_flutter)
// - العنصر المُحدَّد يتميّز بلون النيون فقط (وليس بارتفاع مختلف)
//
// أضف الحزمة في pubspec.yaml:
//   dependencies:
//     lucide_icons_flutter: ^3.1.15
//
// الاستخدام:
//   Scaffold(
//     body: ...,
//     extendBody: true, // مهم حتى يطفو الشريط فوق المحتوى
//     bottomNavigationBar: FloatingBottomNav(
//       currentIndex: 0,
//       onTap: (i) => ...,
//       items: const [
//         FloatingNavItem(icon: LucideIcons.compass, label: 'استكشف'),
//         FloatingNavItem(icon: LucideIcons.receipt, label: 'الطلبات'),
//         FloatingNavItem(icon: LucideIcons.home, label: 'الرئيسية'),
//         FloatingNavItem(icon: LucideIcons.heart, label: 'المفضلة'),
//         FloatingNavItem(icon: LucideIcons.messageCircle, label: 'المحادثات'),
//       ],
//     ),
//   )

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
  }) : assert(items.length >= 2 && items.length <= 5,
            'استخدم بين 2 و5 عناصر ليبقى الشكل متوازناً');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBarColor = isDark
        ? AppColors.surfaceVariant.withValues(alpha: 0.92)
        : AppColors.lightSurface.withValues(alpha: 0.92);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.lightOutline;
    final accentColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final inactiveColor = isDark ? AppColors.textMuted : AppColors.lightTextTertiary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: navBarColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            final color = selected ? accentColor : inactiveColor;

            return Expanded(
              child: InkResponse(
                onTap: () => onTap(index),
                radius: 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}