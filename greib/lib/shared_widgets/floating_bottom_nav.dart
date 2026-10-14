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
import '../core/extensions/context_extensions.dart';
import '../core/theme/design_tokens.dart';
import 'nav_icon.dart';

class FloatingNavItem {
  final IconData icon;
  final String label;

  /// عدد الشارات (رسائل/إشعارات غير مقروءة). صفر أو null = بلا شارة.
  final int? badgeCount;

  /// ★ زر إجراء (مثل الكاميرا): نفس تصميم بقية الأيقونات تماماً
  /// للحفاظ على هوية موحدة — الفرق فقط في السلوك (يفتح ورقة/إجراء)
  /// بدل التنقل لصفحة وتحديد التبويب.
  final bool isAction;

  /// ★ اسم ملف SVG الممتلئ (Filled Lucide) للحالة المحددة — بلا لاحقة.
  ///   null = بلا نسخة ممتلئة (زر إجراء كالكاميرا) ⇒ تبقى المفرّغة دائماً.
  ///   الملفات في: assets/icons/filled/
  final String? filledAsset;

  const FloatingNavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
    this.isAction = false,
    this.filledAsset,
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
         items.length >= 2 && items.length <= 8,
         'استخدم بين 2 و8 عناصر ليبقى الشكل متوازناً',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // ★ الأسطح والحدود واللون الرسمي من اللوحة الديناميكية.
    final surface = context.backgroundColors.surface;
    final outline = context.backgroundColors.outline;
    final accent = context.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: isDark ? outline.withValues(alpha: 0.6) : outline,
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
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                // ★ زر الإجراء (الكاميرا): نفس تصميم _NavTile تماماً
                // لهوية موحدة — لكنه لا يأخذ حالة «محدد» أبداً.
                final selected = !item.isAction && index == currentIndex;

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
    // ★ ألوان الأيقونة النشِطة/غير النشِطة من اللوحة الديناميكية.
    final activeColor = context.iconColors.active;
    final inactiveColor = context.iconColors.inactive;
    final accent = context.accentColor;
    // ★ مع النسخة الممتلئة (SVG) نعود للألوان الأصلية الهادئة:
    //   المحدد بلون نشط (لا أبيض) لأن الامتلاء نفسه يميّزه — بأسلوب فيسبوك.
    //   ★ استثناء: في الوضع الليلي الأيقونة المحددة (house/message) بيضاء
    //   لتباين أوضح على الخلفية الداكنة.
    final iconColor = selected
        ? (isDark ? Colors.white : activeColor)
        : inactiveColor;

    return Semantics(
      label: item.label,
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- حاوية الأيقونة مع تأثير بصري عند التحديد ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: selected ? 54 : 46,
              height: selected ? 54 : 46,
              decoration: BoxDecoration(
                // ★ خلفية دائرية كاملة (العرض = الارتفاع + shape = circle).
                shape: BoxShape.circle,
                color: selected
                    ? accent.withValues(alpha: isDark ? 0.2 : 0.12)
                    : Colors.transparent,
              ),
              child: Center(
                child: AnimatedScale(
                  scale: selected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ★ النسختان: Lucide مفرّغة / Filled Lucide ممتلئة (SVG).
                      NavIcon(
                        outlined: item.icon,
                        filledAsset: item.filledAsset,
                        selected: selected,
                        color: iconColor,
                      ),
                      _buildBadge(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// شارة العدد (رسائل/إشعارات غير مقروءة) أعلى أيقونة التبويب.
  Widget _buildBadge(BuildContext context) {
    final count = item.badgeCount ?? 0;
    if (count <= 0) return const SizedBox.shrink();

    return Positioned(
      top: -7,
      left: -9,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        constraints: const BoxConstraints(minWidth: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: context.backgroundColors.surface,
            width: 1.5,
          ),
        ),
        child: Text(
          count > 9 ? '+9' : '$count',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
