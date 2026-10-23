import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../extensions/context_extensions.dart';
import '../storage/app_prefs.dart';
import '../theme/app_color_palette.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';
import '../theme/theme_presets.dart';
import '../../shared_widgets/app_button.dart';

/// ============================================================================
///  ThemePickerGate — بوابة اختيار الثيم عند أول فتح للتطبيق.
///
///  ★ تُعرض **قبل** بوابة إذن الموقع (LocationGate)، أي قبل أن يرى المستخدم
///    أي شاشة أخرى: يختار مظهره المناسب أولاً، ثم يُطلب منه تحديد موقعه.
///  ★ تُعرض مرة واحدة فقط (تُحفظ في AppPrefs) فلا تظهر مجدداً بعد الاختيار.
///  ★ التحويل بين البوابتين يتم بتلاشٍ متقاطع ناعم (AnimatedSwitcher).
/// ============================================================================
class ThemePickerGate extends StatefulWidget {
  final Widget child;
  const ThemePickerGate({super.key, required this.child});

  @override
  State<ThemePickerGate> createState() => _ThemePickerGateState();
}

class _ThemePickerGateState extends State<ThemePickerGate> {
  bool _seen = AppPrefs.themePickerSeen;

  Future<void> _finish() async {
    await AppPrefs.setThemePickerSeen(true);
    if (!mounted) return;
    setState(() => _seen = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _seen
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : ThemePickerScreen(
              key: const ValueKey('picker'),
              onDone: _finish,
            ),
    );
  }
}

/// ============================================================================
///  ThemePickerScreen — كاروسيل الثيمات الجاهزة (شاشة أول فتح).
///
///  ★ الثيم يُطبَّق **لحظياً** أثناء التنقّل في الكاروسيل ⇒ المستخدم يرى مظهره
///    الحقيقي على الشاشة نفسها قبل أن يقرّر.
/// ============================================================================
class ThemePickerScreen extends StatefulWidget {
  final VoidCallback onDone;
  const ThemePickerScreen({super.key, required this.onDone});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen> {
  /// كل حقول اللوحة — تُحفظ عند التثبيت كي يُستعاد الثيم بنفس الشكل.
  static final List<String> _allFields = [
    PaletteFieldKeys.accent,
    ...PaletteFieldKeys.backgroundFields,
    ...PaletteFieldKeys.textFields,
    ...PaletteFieldKeys.iconFields,
  ];

  static Map<String, int> _mapOf(AppColorPalette palette) => {
        for (final field in _allFields) field: palette.colorFor(field).toARGB32(),
      };

  final PageController _page = PageController(viewportFraction: 0.76);
  int _index = 0;

  /// هل تنقّل المستخدم في الكاروسيل واختار ثيماً بنفسه؟ (يُحفظ عند التثبيت فقط).
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    // نُبرز الثيم المطابق للمظهر الحالي (مهم للفروع النشِطة)، بلا فرض أي تغيير.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final active = ThemePresets.activeFor(context.palette);
      if (active == null) return;
      final i = ThemePresets.all.indexOf(active);
      if (i > 0) _page.jumpToPage(i);
    });
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  /// يطبّق الثيم رقم [index] لحظياً على كامل التطبيق (قبل الحفظ).
  void _applyTheme(int index) {
    final preset = ThemePresets.all[index];
    context.paletteController.applyPalette(
      preset.paletteFor(preset.prefersDark),
      isDark: preset.prefersDark,
    );
    context.read<ThemeController>().setDarkMode(preset.prefersDark);
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      _touched = true;
    });
    _applyTheme(index);
  }

  /// يثبّت الثيم المختار: يحفظه محلياً ثم يعبُر لبوابة الموقع.
  Future<void> _confirm() async {
    // نحفظ فقط إذا اختار المستخدم ثيماً صراحةً — فلا نُطمس تخصيص قائم بلا داعٍ.
    if (_touched) {
      final preset = ThemePresets.all[_index];
      final derived = preset.paletteFor(preset.prefersDark);
      await AppPrefs.setPaletteOverrides(
        _mapOf(derived),
        isDark: preset.prefersDark,
      );
    }
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final total = ThemePresets.all.length;

    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      body: Stack(
        children: [
          // ---- توهّج علوي ناعم بلون الثيم الحالي ----
          Positioned(
            top: -140,
            left: 0,
            right: 0,
            height: 340,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [
                      context.accentColor.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _Header(index: _index, total: total),
                Expanded(
                  child: PageView.builder(
                    controller: _page,
                    itemCount: total,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, i) {
                      return _ThemeSlide(
                        preset: ThemePresets.all[i],
                        active: i == _index,
                        focused: (_index - i).abs() <= 1,
                      );
                    },
                  ),
                ),
                _Dots(count: total, index: _index),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: AppButton(
                    label: 'ابدأ الاستخدام',
                    icon: LucideIcons.check,
                    onPressed: _confirm,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ترويسة الشاشة: رسالة الترحيب + طلب اختيار الثيم.
class _Header extends StatelessWidget {
  final int index;
  final int total;

  const _Header({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(
            'مرحباً بك في گريب منك',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.accentColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'اختر الثيم الذي يناسبك',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: context.textColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'اسحب لاستعراض المظاهر — التطبيق يتغيّر أمامك مباشرة. '
            'يمكنك تغييره لاحقاً من الإعدادات.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.textColors.secondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${index + 1} / $total',
            style: AppTypography.bodySmall.copyWith(
              color: context.textColors.tertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة ثيم واحدة داخل الكاروسيل: معاينة حقيقية + الاسم والوصف.
class _ThemeSlide extends StatelessWidget {
  final ThemePreset preset;
  final bool active;
  final bool focused;

  const _ThemeSlide({
    required this.preset,
    required this.active,
    required this.focused,
  });

  @override
  Widget build(BuildContext context) {
    final p = preset.palette;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: active ? AppSpacing.sm : AppSpacing.lg,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 240),
        opacity: focused ? 1 : 0.45,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          decoration: BoxDecoration(
            color: p.background.primary,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            border: Border.all(
              color: active ? context.accentColor : p.background.outline,
              width: active ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: p.background.primary.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(child: _ThemeMock(palette: p)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: p.background.surface,
                  border: Border(
                    top: BorderSide(color: p.background.outline),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(preset.icon, size: 16, color: p.accent),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            preset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              color: p.text.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (active)
                          Icon(LucideIcons.checkCircle2,
                              size: 18, color: p.accent),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: p.text.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// معاينة حقيقية لمظهر الثيم — شاشة مصغّرة مبنية من لوحة الثيم نفسه.
class _ThemeMock extends StatelessWidget {
  final AppColorPalette palette;

  const _ThemeMock({required this.palette});

  @override
  Widget build(BuildContext context) {
    final p = palette;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: p.background.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- شريط علوي: أفاتار + عنوان + أيقونة ----
          Row(
            children: [
              _dot(p.accent, 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(p.text.primary, 0.55, 7),
                    const SizedBox(height: 4),
                    _bar(p.text.tertiary, 0.35, 5),
                  ],
                ),
              ),
              _dot(p.background.surfaceElevated, 22),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ---- بطاقة رئيسية بتدرّج اللون الرسمي ----
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [p.accent, p.accentDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _bar(p.text.onAccent, 0.6, 8),
                  const SizedBox(height: 6),
                  _bar(p.text.onAccent.withValues(alpha: 0.7), 0.4, 6),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ---- بطاقة سطح بنصين ----
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: p.background.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: p.background.outline),
            ),
            child: Row(
              children: [
                _dot(p.accent, 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(p.text.primary, 0.7, 7),
                      const SizedBox(height: 5),
                      _bar(p.text.secondary, 0.45, 5),
                    ],
                  ),
                ),
                _dot(p.background.surfaceElevated, 24),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ---- شريط تنقّل سفلي مع عنصر نشط ----
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: p.background.surface,
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(color: p.background.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dot(p.accent, 18),
                _dot(p.icon.muted, 14),
                _dot(p.icon.muted, 14),
                _dot(p.icon.muted, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  /// شريط نصّي وهمي بعرض نسبي من مساحة الأب.
  Widget _bar(Color color, double widthFactor, double height) => FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
        ),
      );
}

/// مؤشّر الصفحات: نقاط بسيطة، النقطة النشطة تتحوّل إلى شريط بلون الثيم.
class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index
                  ? context.accentColor
                  : context.backgroundColors.outline,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
      ],
    );
  }
}
