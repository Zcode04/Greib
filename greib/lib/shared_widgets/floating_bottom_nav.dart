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
import '../core/widgets/header_collapse_state.dart';
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
      child: ValueListenableBuilder<bool>(
        valueListenable: HeaderCollapseState.navCompact,
        builder: (context, compact, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: HeaderCollapseState.navShellHidden,
            builder: (context, shellHidden, _) {
              // ★ الأمر أبسط: نفس الأيقونة تبقى دائماً — فقط الخلفية
              // الكبيرة (اللون + الحد + الظل) تتلاشى وتبقى الدائرة بلا تكرار.
              final hideShell = shellHidden && compact;
              final selectedItem = items[currentIndex];
              if (hideShell) {
                return SizedBox(
                  height: 68,
                  child: Center(
                    child: _DotOnly(
                      item: selectedItem,
                      isDark: isDark,
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: hideShell ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: hideShell,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: hideShell ? 0 : 16,
                                sigmaY: hideShell ? 0 : 16),
                            child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                // ★ الحجم ثابت دائماً (68) — الاحترافية = ثبات الـ layout
                // + تلاشي المحتوى فقط، بلا تقلص يكسر التناسق.
                height: 68,
                decoration: BoxDecoration(
                  color: surface.withValues(
                      alpha: hideShell ? 0.0 : 0.85),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: hideShell
                        ? Colors.transparent
                        : (isDark
                            ? outline.withValues(alpha: 0.6)
                            : outline),
                    width: 1,
                  ),
                  boxShadow: hideShell
                      ? const []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: isDark ? 0.5 : 0.12),
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
                    final selected =
                        !item.isAction && index == currentIndex;
                    // ★ الأنيميشن السابق القوي (تقلص العرض) لكن بـ AnimatedFlex —
                    // لا عروض ثابتة تكسر الـ constraints: الغير نشطة تنكمش
                    // تدريجياً (تلاشي + انزلاق + تقلص flex)، والمحددة تتوسع.
                    return _AnimatedFlex(
                      flex: compact ? (selected ? 1 : 0) : 1,
                      duration: const Duration(milliseconds: 280),
                      child: ClipRect(
                        child: AnimatedOpacity(
                          duration: selected
                              ? const Duration(milliseconds: 200)
                              : const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          opacity: compact && !selected ? 0.0 : 1.0,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            offset: compact && !selected
                                ? const Offset(0, 0.35)
                                : Offset.zero,
                            child: IgnorePointer(
                              ignoring: compact && !selected,
                              // ★ التدفق: أثناء التقلص المحددة Pill
                              // (دائرة + اسم بعد 180ms ثم يختفي بعد 1200ms)،
                              // وبعد اختفاء الخلفية تحل محلها الدائرة المستقلة.
                              child: selected && compact && !hideShell
                                  ? _SelectedPill(
                                      item: item,
                                      selected: selected,
                                      isDark: isDark,
                                      onTap: () => onTap(index),
                                    )
                                  : _NavTile(
                                      item: item,
                                      selected: selected,
                                      isDark: isDark,
                                      onTap: () => onTap(index),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                          ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (compact && !hideShell)
                      _HideChain(
                        key: ValueKey(currentIndex),
                        active: true,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AnimatedFlex extends StatelessWidget {
  final int flex;
  final Duration duration;
  final Widget child;

  const _AnimatedFlex({
    required this.flex,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // ★ Flexible يقبل flex صحيحاً فقط — نحرك بالألف (1000 مقابل 1)
    // فيتداخل التلاشي + الانزلاق مع تقلص حقيقي ناعم بلا كسر constraints.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1000, end: flex == 0 ? 1 : 1000),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Flexible(
          flex: value.round().clamp(1, 1000),
          fit: FlexFit.tight,
          child: child!,
        );
      },
      child: child,
    );
  }
}

class _SelectedPill extends StatefulWidget {
  final FloatingNavItem item;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _SelectedPill({
    required this.item,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SelectedPill> createState() => _SelectedPillState();
}

class _SelectedPillState extends State<_SelectedPill> {
  bool _showLabel = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _showLabel = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showLabel = false);
      });
    });
  }

  @override
  void dispose() {
    // ★ العودة الفورية/المجدولة تتولى التصفير فلا نصفّر هنا
    // (التصفير عند الإزالة كان يلغي التسلسل) — فقط نلغي مؤقت العودة
    // المجدول إلذي قد يعيد إظهار الشريط مبكراً.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = context.iconColors.active;
    final accent = context.accentColor;
    final iconColor =
        widget.isDark ? Colors.white : activeColor;

    final body = Semantics(
      label: widget.item.label,
      button: true,
      selected: true,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ★ الدائرة تحتوي الأيقونة فقط — الاسم خارجها.
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(
                      alpha: widget.isDark ? 0.2 : 0.12),
                ),
                child: Center(
                  child: NavIcon(
                    outlined: widget.item.icon,
                    filledAsset: widget.item.filledAsset,
                    selected: true,
                    color: iconColor,
                    size: 26,
                  ),
                ),
              ),
              // ★ الاسم خارج الدائرة — يظهر بعد التأخير بتلاشي + انزلاق.
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: _showLabel
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          AnimatedOpacity(
                            duration:
                                const Duration(milliseconds: 220),
                            opacity: _showLabel ? 1.0 : 0.0,
                            child: AnimatedSlide(
                              duration: const Duration(
                                  milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              offset: _showLabel
                                  ? Offset.zero
                                  : const Offset(-0.3, 0),
                              child: Text(
                                widget.item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: iconColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
    return body;
  }
}

/// ★ محرك السلسلة الثابت: يعيش طوال فترة التقلص
/// (بخلاف Pill الصف الذي يُزال) — يدفع
/// الخلفية الكبيرة ثم الدائرة للاختفاء النهائي.
class _HideChain extends StatefulWidget {
  final bool active;
  const _HideChain({super.key, required this.active});
  @override
  State<_HideChain> createState() => _HideChainState();
}

class _HideChainState extends State<_HideChain> {
  bool _dead = false;

  @override
  void initState() {
    super.initState();
    // ★ الاسم يختفي بعد 1380ms من بدء التقلص →
    // الأيقونة + الخلفية يختفيان معاً بعد 300ms
    // (تجربة موحدة) — أي تمرير جديد يعيد السلسلة من الصفر.
    Future.delayed(const Duration(milliseconds: 1680), () {
      if (_dead || !mounted || !widget.active) return;
      if (!HeaderCollapseState.navCompact.value) return;
      HeaderCollapseState.navShellHidden.value = true;
      HeaderCollapseState.navDotHidden.value = true;
    });
  }

  @override
  void dispose() {
    _dead = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// ★ الدائرة الأخيرة: أيقونة واحدة بلا اسم وبلا مؤقتات.
class _DotOnly extends StatelessWidget {
  final FloatingNavItem item;
  final bool isDark;
  const _DotOnly({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final activeColor = context.iconColors.active;
    final accent = context.accentColor;
    final iconColor = isDark ? Colors.white : activeColor;
    return ValueListenableBuilder<bool>(
      valueListenable: HeaderCollapseState.navDotHidden,
      builder: (context, dotHidden, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: dotHidden ? 0.0 : 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            scale: dotHidden ? 0.6 : 1.0,
            child: IgnorePointer(
              ignoring: dotHidden,
              child: GestureDetector(
                onTap: HeaderCollapseState.restoreNow,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(
                        alpha: isDark ? 0.2 : 0.12),
                  ),
                  child: Center(
                    child: NavIcon(
                      outlined: item.icon,
                      filledAsset: item.filledAsset,
                      selected: true,
                      color: iconColor,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
