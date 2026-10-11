import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:greib_menk/core/theme/app_color_palette.dart';
import 'package:greib_menk/core/theme/app_theme.dart';
import 'package:greib_menk/core/theme/color_palette_controller.dart';

/// ============================================================================
///  اختبارات لوحة الألوان المركزية (Color Palette / Theme Configuration)
///
///  تتحقق من:
///   1) وجود الفئات الثلاث (نصوص / خلفيات / أيقونات) بقيمها الافتراضية.
///   2) عمل AppColorPalette كـ ThemeExtension يُقرأ عبر Theme.of(context).
///   3) سريان تغيير الألوان عبر ColorPaletteController على الثيم فوراً.
/// ============================================================================
void main() {
  group('AppColorPalette - الفئات واللوحات الافتراضية', () {
    test('لوحة داكنة: ألوان النصوص والخلفيات والأيقونات معرّفة', () {
      final p = AppColorPalette.dark();

      expect(p.text.primary, isNotNull);
      expect(p.text.secondary, isNotNull);
      expect(p.text.onAccent, isNotNull);

      expect(p.background.primary, isNotNull);
      expect(p.background.surface, isNotNull);
      expect(p.background.outline, isNotNull);

      expect(p.icon.primary, isNotNull);
      expect(p.icon.active, isNotNull);
      expect(p.icon.inactive, isNotNull);

      expect(p.isDark, isTrue);
      expect(p.accent, isNotNull);
    });

    test('لوحة نهارية: تختلف عن الداكنة', () {
      final dark = AppColorPalette.dark();
      final light = AppColorPalette.light();

      expect(light.isDark, isFalse);
      expect(light.text.primary, isNot(equals(dark.text.primary)));
      expect(light.background.primary, isNot(equals(dark.background.primary)));
    });

    test('copyWith يرجع نسخة معدّلة دون تغيير الأصل', () {
      const custom = Color(0xFF00FF00);
      final base = AppColorPalette.dark();
      final updated = base.copyWith(accent: custom);

      expect(updated.accent, custom);
      expect(base.accent, isNot(custom)); // الأصل لم يتغيّر (immutability)
    });

    test('withAccent يطبّق اللون الرسمي على اللوحة والأيقونات', () {
      const custom = Color(0xFFFF0000);
      final base = AppColorPalette.dark();
      final themed = base.withAccent(custom);

      expect(themed.accent, custom);
      expect(themed.background.accent, custom);
      expect(themed.icon.primary, custom);
      expect(themed.icon.active, custom);
    });

    test('lerp يمزج بين لوحتين', () {
      final a = AppColorPalette.dark(accent: const Color(0xFF000000));
      final b = AppColorPalette.dark(accent: const Color(0xFFFFFFFF));
      final mid = a.lerp(b, 0.5);

      expect(mid.accent, isNotNull);
    });
  });

  group('AppColorPalette كـ ThemeExtension', () {
    testWidgets('يُقرأ من Theme.of(context) بعد بناء الثيم', (tester) async {
      final palette = AppColorPalette.dark();
      late BuildContext ctx;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(palette),
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final fromTheme = Theme.of(ctx).extension<AppColorPalette>();
      expect(fromTheme, isNotNull);
      expect(fromTheme!.accent, palette.accent);
    });
  });

  group('ColorPaletteController - التخصيص الديناميكي', () {
    test('يعيد الإشعار عند تغيير اللون الرسمي', () {
      final controller = ColorPaletteController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setAccent(const Color(0xFF123456), isDark: true);

      expect(notifications, 1);
      expect(controller.darkPalette.accent, const Color(0xFF123456));
      expect(controller.lightPalette.accent, isNot(const Color(0xFF123456)));
    });

    test('يعدّل حقل نص مفرد ويبقي بقية الحقول', () {
      final controller = ColorPaletteController();
      const custom = Color(0xFFABCDEF);

      controller.updateTextPrimary(custom, isDark: false);

      expect(controller.lightPalette.text.primary, custom);
      expect(controller.lightPalette.text.secondary, isNotNull);
    });

    test('resetAll يعيد اللوحتين للافتراضي', () {
      final controller = ColorPaletteController();
      final defaultAccent = controller.darkPalette.accent;

      controller.setAccent(const Color(0xFF654321), isDark: true);
      expect(controller.darkPalette.accent, const Color(0xFF654321));

      controller.resetAll();
      expect(controller.darkPalette.accent, defaultAccent);
    });

    testWidgets('تغيير اللون يسري فوراً على الثيم المبني', (tester) async {
      final controller = ColorPaletteController();
      const custom = Color(0xFF00FFCC);

      final themeBefore = AppTheme.darkTheme(controller.darkPalette);
      expect(themeBefore.colorScheme.primary, isNot(custom));

      controller.setAccent(custom, isDark: true);
      final themeAfter = AppTheme.darkTheme(controller.darkPalette);

      // الثيم الجديد (الذي يبنيه MaterialApp) يحمل اللون الجديد فوراً.
      expect(themeAfter.colorScheme.primary, custom);
      expect(themeAfter.extension<AppColorPalette>()!.accent, custom);

      // ويظهر فعلياً في MaterialApp عبر Theme.of(context).
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          theme: themeAfter,
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(Theme.of(ctx).colorScheme.primary, custom);
    });
  });
}
