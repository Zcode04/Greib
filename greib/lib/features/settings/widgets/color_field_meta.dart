import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_color_palette.dart';
import '../../../core/theme/theme_presets.dart';

/// ============================================================================
///  color_field_meta — ترتيب حقول الألوان وتصنيفها لعرضها في واجهة التخصيص.
///
///  ★ فئة واحدة = تبويب واحد يعرف: حقوله + الألوان المتاحة له (6 لكل فئة)
///    ⇒ الشاشة لا تكرّر أي منطق.
/// ============================================================================

/// فئات التخصيص الثلاث (تُعرض كتبويبات).
enum ColorGroup {
  backgrounds('الخلفيات', LucideIcons.layers),
  texts('النصوص', LucideIcons.type),
  icons('الأيقونات', LucideIcons.sparkles);

  final String label;
  final IconData icon;

  const ColorGroup(this.label, this.icon);

  /// حقول هذه الفئة بالترتيب المعروض.
  /// ★ اللون الرسمي في مقدّمة الأيقونات لأنه مصدرها (تعديله يسري عليها).
  List<String> get fields => switch (this) {
        ColorGroup.backgrounds => PaletteFieldKeys.backgroundFields,
        ColorGroup.texts => PaletteFieldKeys.textFields,
        ColorGroup.icons => [
            PaletteFieldKeys.accent,
            ...PaletteFieldKeys.iconFields,
          ],
      };

  /// ★ الألوان المتاحة لهذه الفئة — 6 ألوان لكل فئة.
  List<ColorOption> get choices => switch (this) {
        ColorGroup.backgrounds => ColorChoices.backgrounds,
        ColorGroup.texts => ColorChoices.texts,
        ColorGroup.icons => ColorChoices.accents,
      };
}

/// وصف صف لون واحد: العنوان والأيقونة.
class ColorFieldMeta {
  final String title;
  final IconData icon;

  /// true = يُعرض فقط عند تفعيل «تحكم متقدم».
  final bool advanced;

  const ColorFieldMeta(this.title, this.icon, {this.advanced = false});
}

/// ★ خريطة الحقول: العنوان + الأيقونة لكل حقل — مصدر واحد تستخدمه الواجهة.
const Map<String, ColorFieldMeta> kColorFieldMeta = {
  // ---------------------------- الخلفيات والطبقات ----------------------------
  PaletteFieldKeys.backgroundPrimary:
      ColorFieldMeta('خلفية الشاشة', LucideIcons.square),
  PaletteFieldKeys.backgroundSurface:
      ColorFieldMeta('الأسطح والبطاقات', LucideIcons.layoutGrid),
  PaletteFieldKeys.backgroundSurfaceElevated:
      ColorFieldMeta('الأسطح المرتفعة', LucideIcons.squareStack),
  PaletteFieldKeys.backgroundSecondary:
      ColorFieldMeta('خلفية ثانوية', LucideIcons.box),
  PaletteFieldKeys.backgroundOutline:
      ColorFieldMeta('الحدود والفواصل', LucideIcons.frame),
  PaletteFieldKeys.backgroundOverlay:
      ColorFieldMeta('الطبقة العليا', LucideIcons.copy, advanced: true),
  PaletteFieldKeys.backgroundScrim:
      ColorFieldMeta('حجاب التعتيم', LucideIcons.blend, advanced: true),
  PaletteFieldKeys.backgroundMediaScrim:
      ColorFieldMeta('تعتيم الصور', LucideIcons.image, advanced: true),

  // --------------------------------- النصوص ---------------------------------
  PaletteFieldKeys.textPrimary:
      ColorFieldMeta('النص الأساسي', LucideIcons.letterText),
  PaletteFieldKeys.textSecondary:
      ColorFieldMeta('النص الثانوي', LucideIcons.textQuote),
  PaletteFieldKeys.textTertiary:
      ColorFieldMeta('النص الباهت', LucideIcons.baseline),
  PaletteFieldKeys.textLink: ColorFieldMeta('الروابط', LucideIcons.link),
  PaletteFieldKeys.textInverse:
      ColorFieldMeta('النص المعكوس', LucideIcons.contrast, advanced: true),
  PaletteFieldKeys.textOnAccent:
      ColorFieldMeta('فوق اللون الرسمي', LucideIcons.highlighter, advanced: true),
  PaletteFieldKeys.textDisabled:
      ColorFieldMeta('النص المعطّل', LucideIcons.ban, advanced: true),
  PaletteFieldKeys.textOnMedia:
      ColorFieldMeta('النص فوق الصور', LucideIcons.eye, advanced: true),

  // -------------------------------- الأيقونات --------------------------------
  PaletteFieldKeys.accent: ColorFieldMeta('اللون الرسمي', LucideIcons.palette),
  PaletteFieldKeys.iconPrimary:
      ColorFieldMeta('الأيقونة الأساسية', LucideIcons.sparkles),
  PaletteFieldKeys.iconActive:
      ColorFieldMeta('الأيقونة النشطة', LucideIcons.star),
  PaletteFieldKeys.iconSecondary:
      ColorFieldMeta('الأيقونة الثانوية', LucideIcons.circleDot),
  PaletteFieldKeys.iconMuted:
      ColorFieldMeta('الأيقونة الباهتة', LucideIcons.droplet),
  PaletteFieldKeys.iconInactive:
      ColorFieldMeta('الأيقونة غير النشطة', LucideIcons.circleOff),
  PaletteFieldKeys.iconOnBackground:
      ColorFieldMeta('فوق الخلفية', LucideIcons.crop),
  PaletteFieldKeys.iconOnAccent:
      ColorFieldMeta('فوق اللون الرسمي', LucideIcons.badgeCheck),
  PaletteFieldKeys.iconDisabled:
      ColorFieldMeta('الأيقونة المعطّلة', LucideIcons.slash, advanced: true),
  PaletteFieldKeys.iconOnMedia:
      ColorFieldMeta('فوق الصور', LucideIcons.aperture, advanced: true),
  PaletteFieldKeys.iconSuccess:
      ColorFieldMeta('النجاح', LucideIcons.circleCheck, advanced: true),
  PaletteFieldKeys.iconWarning:
      ColorFieldMeta('التحذير', LucideIcons.triangleAlert, advanced: true),
  PaletteFieldKeys.iconError:
      ColorFieldMeta('الخطأ', LucideIcons.circleAlert, advanced: true),
  PaletteFieldKeys.iconInfo:
      ColorFieldMeta('المعلومة', LucideIcons.info, advanced: true),
};

/// يُرجع وصف الحقل، أو بديلاً آمناً إن لم يكن معرّفاً.
ColorFieldMeta metaFor(String field) =>
    kColorFieldMeta[field] ?? const ColorFieldMeta('لون', LucideIcons.circleDot);

/// ★ حقول تُختار من الألوان المحايدة (فاتح/داكن) لا من اللهجات:
///   الحقول التي تُقرأ «فوق» شيء آخر أو تعمل كطبقة تعتيم.
const Set<String> kNeutralChoiceFields = {
  PaletteFieldKeys.textInverse,
  PaletteFieldKeys.textOnAccent,
  PaletteFieldKeys.textOnMedia,
  PaletteFieldKeys.iconOnAccent,
  PaletteFieldKeys.iconOnBackground,
  PaletteFieldKeys.iconOnMedia,
  PaletteFieldKeys.backgroundOverlay,
  PaletteFieldKeys.backgroundScrim,
  PaletteFieldKeys.backgroundMediaScrim,
};

/// الألوان المتاحة لحقل: محايدة لحقول الطبقات/فوق-اللون، وإلا ألوان فئته.
List<ColorOption> choicesForField(String field, ColorGroup group) =>
    kNeutralChoiceFields.contains(field) ? ColorChoices.texts : group.choices;
