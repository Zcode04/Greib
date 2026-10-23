import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../extensions/context_extensions.dart';
import '../storage/app_prefs.dart';
import '../theme/app_color_palette.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';
import '../theme/theme_presets.dart';
import '../../shared_widgets/app_button.dart';

/// ThemePickerGate — بوابة اختيار الثيم عند أول فتح (قبل LocationGate، مرة واحدة).
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
          : ThemePickerScreen(key: const ValueKey('picker'), onDone: _finish),
    );
  }
}

/// ThemePickerScreen — كاروسيل الثيمات. الثيم يُطبَّق لحظياً أثناء التنقّل.
class ThemePickerScreen extends StatefulWidget {
  final VoidCallback onDone;
  const ThemePickerScreen({super.key, required this.onDone});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen> {
  static final List<String> _allFields = [
    PaletteFieldKeys.accent,
    ...PaletteFieldKeys.backgroundFields,
    ...PaletteFieldKeys.textFields,
    ...PaletteFieldKeys.iconFields,
  ];

  static Map<String, int> _mapOf(AppColorPalette palette) => {
    for (final field in _allFields) field: palette.colorFor(field).toARGB32(),
  };

  /// نسبة أبعاد الهاتف المصغّر.
  static const double _aspect = 190 / 300;

  /// الهامش الأفقي حول كل هاتف داخل الصفحة.
  static const double _slidePad = 8;

  PageController? _pageCtrl;
  PageController get _page => _pageCtrl!;
  int _index = 0;
  bool _touched = false;

  /// ارتفاع الهاتف نسبةً لارتفاع الشاشة (بين 340 و 420).
  double _phoneHeight = 380;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pageCtrl != null) return;

    final size = MediaQuery.sizeOf(context);
    _phoneHeight = (size.height * 0.46).clamp(340.0, 420.0);

    // ★ عرض الصفحة يُحسب من حجم الهاتف نفسه كي يكبر الهاتف فعلاً
    //   ويظهر جزء من الهاتف المجاور على الجانبين.
    final phoneWidth = _phoneHeight * _aspect;
    final fraction = ((phoneWidth + _slidePad * 2) / size.width).clamp(
      0.45,
      0.80,
    );
    _pageCtrl = PageController(viewportFraction: fraction);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final active = ThemePresets.activeFor(context.palette);
      if (active == null) return;
      final i = ThemePresets.all.indexOf(active);
      if (i > 0) {
        _page.jumpToPage(i);
        setState(() => _index = i);
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl?.dispose();
    super.dispose();
  }

  void _applyTheme(int index) {
    final preset = ThemePresets.all[index];
    context.paletteController.applyPalette(
      preset.paletteFor(preset.prefersDark),
      isDark: preset.prefersDark,
    );
    context.read<ThemeController>().setDarkMode(preset.prefersDark);
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _index = index;
      _touched = true;
    });
    _applyTheme(index);
  }

  void _jumpTo(int i) {
    _page.animateToPage(
      i,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _confirm() async {
    HapticFeedback.mediumImpact();
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
          // توهّج علوي خفيف
          Positioned(
            top: -160,
            left: -40,
            right: -40,
            height: 420,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.85,
                    colors: [
                      context.accentColor.withValues(alpha: 0.20),
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
                // ★ الكتلة الوسطى: عنوان + هاتف + مؤشر بمسافات صغيرة ثابتة،
                //   متمركزة رأسياً ⇒ لا فراغات كبيرة بينها.
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اختر الثيم الذي يناسبك',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineMedium.copyWith(
                            color: context.textColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'اسحب لاستعراض المظاهر',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textColors.secondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          height: _phoneHeight,
                          child: AnimatedBuilder(
                            animation: _page,
                            builder: (context, _) {
                              final page =
                                  (_page.hasClients &&
                                      _page.position.haveDimensions)
                                  ? (_page.page ?? _index.toDouble())
                                  : _index.toDouble();
                              return PageView.builder(
                                controller: _page,
                                itemCount: total,
                                onPageChanged: _onPageChanged,
                                clipBehavior: Clip.none,
                                itemBuilder: (context, i) {
                                  final t = (1 - (page - i).abs()).clamp(
                                    0.0,
                                    1.0,
                                  );
                                  return GestureDetector(
                                    onTap: () => _jumpTo(i),
                                    child: _ThemeSlide(
                                      preset: ThemePresets.all[i],
                                      t: t,
                                      aspect: _aspect,
                                      padding: _slidePad,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Dots(count: total, index: _index),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
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

/// هاتف واحد: بلا نصوص ولا شارات — الحدّ البارز يكفي للدلالة على الاختيار.
class _ThemeSlide extends StatelessWidget {
  final ThemePreset preset;
  final double t;
  final double aspect;
  final double padding;

  const _ThemeSlide({
    required this.preset,
    required this.t,
    required this.aspect,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final p = preset.palette;
    final scale = 0.86 + 0.14 * t;
    final opacity = 0.5 + 0.5 * t;

    return Center(
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: AspectRatio(
              aspectRatio: aspect,
              child: Container(
                decoration: BoxDecoration(
                  color: p.background.primary,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withValues(alpha: 0.28 * t),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                // ★ الحدّ يُرسم فوق المحتوى فلا يُقصّ عند الزوايا
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Color.lerp(p.background.outline, p.accent, t)!,
                    width: 1 + 1.5 * t,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 190,
                    height: 300,
                    child: _ThemeMock(palette: p),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// معاينة مبسّطة: شريط علوي + بطاقة رئيسية + بطاقة واحدة + شريط تنقّل.
class _ThemeMock extends StatelessWidget {
  final AppColorPalette palette;
  const _ThemeMock({required this.palette});

  @override
  Widget build(BuildContext context) {
    final p = palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      color: p.background.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _dot(p.accent, 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(p.text.primary, 0.55, 6),
                    const SizedBox(height: 4),
                    _bar(p.text.tertiary, 0.35, 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
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
                  _bar(p.text.onAccent, 0.6, 7),
                  const SizedBox(height: 5),
                  _bar(p.text.onAccent.withValues(alpha: 0.7), 0.4, 5),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: p.background.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: p.background.outline),
            ),
            child: Row(
              children: [
                _dot(p.accent, 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(p.text.primary, 0.7, 6),
                      const SizedBox(height: 4),
                      _bar(p.text.secondary, 0.45, 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
                _dot(p.accent, 16),
                _dot(p.icon.muted, 12),
                _dot(p.icon.muted, 12),
                _dot(p.icon.muted, 12),
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

  Widget _bar(Color color, double widthFactor, double height) =>
      FractionallySizedBox(
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

/// مؤشّر الصفحات.
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
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 24 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index
                  ? context.accentColor
                  : context.textColors.tertiary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
      ],
    );
  }
}