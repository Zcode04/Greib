import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../theme/color_palette_controller.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';

/// ============================================================================
///  showAppSheet — ورقة سفلية موحّدة لكل Flows الحجز/الاختيار في التطبيق
///  (BottomSheet-First UX): انتقال سريع دون مغادرة الشاشة الحالية.
///  الاستخدام:
///    await showAppSheet(context, builder: (_) => LocationPickerSheet());
///
///  ★ لماذا نُعيد بناء الثيم داخل الورقة؟
///    Flutter يُجمّد ثيم الـ modal route عند الفتح: يرث الورقة عبر
///    `InheritedTheme.capture` (صورة ثابتة) ويُبنى محتوى الـ route مرة واحدة
///    ويُخزَّن لون `backgroundColor` كقيمة ثابتة ⇒ أي تبديل للوضع الليلي/النهاري
///    والورقة مفتوحة لا يظهر عليها إلا بعد الإغلاق وإعادة الفتح.
///    الحل: نلفّ محتوى الورقة بثيم **حيّ** مبنيّ من المتحكمات، ونرسم السطح
///    بلون اللوحة الحيّ ⇒ التحديث يصبح لحظياً مع الصفحة.
/// ============================================================================
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    useSafeArea: true,
    // ★ شفاف (لون لا يتبع الثيم) ⇒ لا يتأثر بتجميد لون الـ route؛
    //   اللون الحقيقي يُرسم من المادة الحيّة داخل الورقة أدناه.
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
    ),
    builder: (_) {
      return Consumer2<ThemeController, ColorPaletteController>(
        builder: (context, themeController, paletteController, _) {
          final isDark = themeController.isDarkMode;
          final palette = paletteController.paletteFor(isDark);

          return Theme(
            // ★ نفس ثيم MaterialApp لكن حيّ ⇒ النصوص والأيقونات والمفاتيح
            //   داخل الورقة تتحدّث فوراً مع تبديل الوضع أو تعديل اللوحة.
            data: isDark ? AppTheme.darkTheme(palette) : AppTheme.lightTheme(palette),
            child: Material(
              // ★ سطح الورقة بلون اللوحة الحيّ (بدل اللون المجمّد لحظة الفتح).
              color: palette.background.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.xxl),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // نمط مقبض السحب الموحّد أعلى الورقة (لونه من اللوحة الحيّة).
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(
                        top: AppSpacing.md,
                        bottom: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: palette.text.tertiary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadii.full),
                      ),
                    ),
                    Flexible(child: builder(context)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}