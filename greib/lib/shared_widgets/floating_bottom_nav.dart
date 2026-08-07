// shared_widgets/floating_bottom_nav.dart
//
// شريط تنقل سفلي عائم بنفس تأثير الصورة المرفقة:
// - شريط داكن نصف شفاف بحواف دائرية كاملة
// - أيقونات جانبية عادية
// - زر دائري مرتفع (Floating) بلون نيون مع توهج (glow) في المنتصف يمثل "الرئيسية"
//
// الاستخدام:
//   Scaffold(
//     body: ...,
//     extendBody: true, // مهم حتى يطفو الشريط فوق المحتوى
//     bottomNavigationBar: FloatingBottomNav(
//       currentIndex: 0,
//       onTap: (i) => ...,
//       items: const [
//         FloatingNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'استكشف'),
//         FloatingNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'الطلبات'),
//         FloatingNavItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'المفضلة'),
//         FloatingNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'المحادثات'),
//       ],
//       centerIcon: Icons.home_rounded,
//       onCenterTap: () => ...,
//     ),
//   )

import 'package:flutter/material.dart';
import '../core/theme/dark_palette.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class FloatingBottomNav extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// أيقونة الزر الدائري العائم في المنتصف (مثل زر "الرئيسية" الأخضر في الصورة)
  final IconData centerIcon;
  final VoidCallback onCenterTap;
  final bool isCenterActive;

  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.centerIcon,
    required this.onCenterTap,
    this.isCenterActive = true,
  }) : assert(items.length >= 2 && items.length <= 4,
            'استخدم بين 2 و4 عناصر جانبية ليبقى الشكل متوازناً حول الزر المركزي');

  @override
  Widget build(BuildContext context) {
    final half = (items.length / 2).ceil();
    final leftItems = items.sublist(0, half);
    final rightItems = items.sublist(half);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // --- الشريط الداكن ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: DarkPalette.surfaceVariant.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ..._buildIcons(leftItems, 0),
                    const SizedBox(width: 64), // فراغ لمكان الزر العائم
                    ..._buildIcons(rightItems, leftItems.length),
                  ],
                ),
              ),
            ),

            // --- الزر الدائري النيون العائم ---
            Positioned(
              bottom: 22,
              child: GestureDetector(
                onTap: onCenterTap,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isCenterActive
                          ? [DarkPalette.neon, DarkPalette.neonDark]
                          : [DarkPalette.surface, DarkPalette.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: DarkPalette.background, width: 4),
                    boxShadow: isCenterActive
                        ? [DarkPalette.neonGlow()]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                  ),
                  child: Icon(
                    centerIcon,
                    color: isCenterActive ? Colors.black : DarkPalette.textSecondary,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIcons(List<FloatingNavItem> group, int startIndex) {
    return List.generate(group.length, (i) {
      final index = startIndex + i;
      final selected = index == currentIndex;
      final item = group[i];
      return Expanded(
        child: InkResponse(
          onTap: () => onTap(index),
          radius: 28,
          child: Icon(
            selected ? item.activeIcon : item.icon,
            color: selected ? DarkPalette.neon : DarkPalette.textMuted,
            size: 24,
          ),
        ),
      );
    });
  }
}