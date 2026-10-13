import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/mock_data/mock_data.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/super_header.dart';
import '../services/data/services_repository.dart';
import '../visual_search/visual_search_analysis_screen.dart';
import 'search_history_screen.dart';
import 'search_history_store.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// الوسائط المرفقة (صورة) بانتظار الإرسال.
  File? _attachment;
  String _attachmentSource = 'المعرض';
  bool _busy = false;

  /// تُصبح true بعد انتهاء كشف الجملة الأولى، فتظهر الاقتراحات.
  bool _welcomeDone = false;

  /// اقتراحات البحث السريع (عدّلها حسب خدماتك).
  static const _suggestions = ['عروض اليوم', 'توصيل سريع', 'خدمات الصيانة'];

  /// جمل الترحيب المتناوبة (اجعل كل جملة سطرين ليبقى الارتفاع ثابتاً).
  static const _sentences = [
    'ابحث لحظيًا عن كل ما في ذهنك،\nسواء على المستوى المحلي أو العالمي!',
    'اعثر على الخدمة المناسبة\nفي ثوانٍ معدودة',
    'ارفع صورة أي منتج\nوسنجد لك ما يشبهه',
    'تحدّث بصوتك\nوسنبحث عنك فورًا',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _searchController.value = _searchController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() {});
  }

  // ───────────────────────── الوسائط ─────────────────────────

  /// يختار صورة (من المعرض أو الكاميرا) ويرفقها بالحقل كمعاينة.
  Future<void> _pickMedia(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final f = await ImagePicker().pickImage(source: source, imageQuality: 90);
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (f != null) {
          _attachment = File(f.path);
          _attachmentSource = source == ImageSource.camera
              ? 'الكاميرا'
              : 'المعرض';
        }
      });
      if (f != null) _focusNode.requestFocus();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر الوصول إلى الوسائط — حاول مجدداً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeAttachment() => setState(() => _attachment = null);

  /// ★ البحث الصوتي — نقطة ربط جاهزة.
  ///   لتفعيله أضف حزمة speech_to_text وضع النص الناتج عبر _setQuery(...).
  void _startVoiceSearch() {
    _focusNode.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('البحث الصوتي قيد التفعيل'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// إرسال: إن وُجدت صورة تُفتح شاشة البحث البصري، وإلا نُنهي الكتابة.
  Future<void> _submit() async {
    final file = _attachment;
    if (file == null) {
      final q = _searchController.text.trim();
      if (q.isNotEmpty) SearchHistoryStore.instance.add(q);
      _focusNode.unfocus();
      return;
    }
    final q = _searchController.text.trim();
    if (q.isNotEmpty) SearchHistoryStore.instance.add(q);
    _focusNode.unfocus();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualSearchAnalysisScreen(
          imageFile: file,
          sourceLabel: _attachmentSource,
          textQuery: q.isEmpty ? null : q,
        ),
      ),
    );
    if (mounted) setState(() => _attachment = null);
  }

  /// يفتح صفحة «سجل البحث»، ويعيد الاستعلام المختار لحقل البحث.
  void _openHistory() {
    Navigator.of(context)
        .push<String>(
          MaterialPageRoute(builder: (_) => const SearchHistoryScreen()),
        )
        .then((query) {
          if (!mounted || query == null || query.isEmpty) return;
          _setQuery(query);
        });
  }

  // ───────────────────────── النتائج ─────────────────────────

  List<ServiceCategory> get _results {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];

    return ServicesRepository.instance.all
        .where(
          (service) =>
              '${service.title} ${service.subtitle} ${service.description}'
                  .toLowerCase()
                  .contains(query),
        )
        .take(8)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = _searchController.text.trim();

    // عند الخروج من الترحيب يُعاد تشغيل الأنميشن في المرة القادمة.
    if (query.isNotEmpty) _welcomeDone = false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.background
            : AppColors.lightBackground,
        appBar: const SuperHeader(title: 'البحث', showBackButton: true),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - AppSpacing.md * 2,
                      ),
                      child: query.isEmpty
                          ? Center(child: _buildWelcome(context, theme, isDark))
                          : _buildResults(context, theme, isDark, query),
                    ),
                  ),
                ),
              ),
              _buildBottomInputBar(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── شريط الإدخال ─────────────────────────

  Widget _buildBottomInputBar(ThemeData theme, bool isDark) {
    final focused = _focusNode.hasFocus;
    final hasText = _searchController.text.trim().isNotEmpty;
    final showSuggestions = !focused && !hasText && _attachment == null;

    Widget above = const SizedBox(width: double.infinity);
    if (showSuggestions) {
      above = Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _QuickChip(
              icon: LucideIcons.mic,
              label: 'بحث بالصوت',
              onTap: _startVoiceSearch,
            ),
            _QuickChip(
              icon: LucideIcons.image,
              label: 'صور',
              onTap: _busy ? null : () => _pickMedia(ImageSource.gallery),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      color: isDark ? AppColors.background : AppColors.lightBackground,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: KeyedSubtree(
                  key: ValueKey(showSuggestions ? 'chips' : 'none'),
                  child: above,
                ),
              ),
            ),
            _buildSearchField(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    final focused = _focusNode.hasFocus;
    final canSend =
        _searchController.text.trim().isNotEmpty || _attachment != null;
    final muted = theme.colorScheme.onSurfaceVariant;
    final textStyle = theme.textTheme.bodyLarge ?? const TextStyle();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: focused
              ? (isDark ? Colors.white24 : Colors.black26)
              : (isDark ? AppColors.outline : AppColors.lightOutline),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_attachment != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _AttachmentPreview(
                file: _attachment!,
                onRemove: _removeAttachment,
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              _attachment != null ? 12 : 18,
              20,
              6,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
              cursorColor: AppColors.accentPrimary,
              style: textStyle,
              decoration: InputDecoration(
                hintText: _attachment != null
                    ? 'أضف وصفاً للصورة (اختياري)...'
                    : 'ابحث عن أي شيء...',
                hintStyle: textStyle.copyWith(color: muted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                const Spacer(),
                _BarIconButton(
                  icon: LucideIcons.history,
                  tooltip: 'سجل البحث',
                  color: muted,
                  size: 20,
                  onTap: _openHistory,
                ),
                _BarIconButton(
                  icon: LucideIcons.camera,
                  tooltip: 'التقاط صورة',
                  color: muted,
                  size: 20,
                  onTap: () => _pickMedia(ImageSource.camera),
                ),
                _BarIconButton(
                  icon: LucideIcons.image,
                  tooltip: 'صور',
                  color: muted,
                  size: 20,
                  onTap: () => _pickMedia(ImageSource.gallery),
                ),
                _BarIconButton(
                  icon: LucideIcons.mic,
                  tooltip: 'بحث بالصوت',
                  color: muted,
                  size: 20,
                  onTap: _startVoiceSearch,
                ),
                const SizedBox(width: 4),
                _ActionCircle(
                  canSend: canSend,
                  isDark: isDark,
                  iconColor: muted,
                  onSend: _submit,
                  onVoice: _startVoiceSearch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── المحتوى ─────────────────────────

  /// ★ ترحيب: جمل متناوبة تُكشف كلمةً كلمة، ويتوقف التكرار عند الضغط على الحقل.
  Widget _buildWelcome(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LoopingReveal(
          texts: _sentences,
          active: !_focusNode.hasFocus,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.5,
          ),
          onFirstDone: () {
            if (mounted) setState(() => _welcomeDone = true);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_welcomeDone)
          _StaggeredChips(
            labels: _suggestions,
            onTap: (s) {
              _setQuery(s);
              _focusNode.requestFocus();
            },
          )
        else
          // يحجز المساحة كي لا يقفز التصميم عند ظهور الاقتراحات.
          const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildResults(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String query,
  ) {
    final results = _results;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: LucideIcons.listFilter,
          title: 'نتائج البحث',
          subtitle: results.isEmpty
              ? 'لم نعثر على نتائج مطابقة'
              : '${results.length} خدمة متاحة لك',
        ),
        const SizedBox(height: AppSpacing.lg),
        if (results.isEmpty)
          _buildEmptyResults(theme, isDark, query)
        else
          ...results.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ServiceResultTile(service: service),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildEmptyResults(ThemeData theme, bool isDark, String query) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: isDark ? AppColors.outline : AppColors.lightOutline,
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.searchX,
            size: 40,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'لم نجد خدمة مطابقة لـ «$query»',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'جرّب كلمة أخرى أو أرفق صورة للبحث بها.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════ مكوّنات مساعدة ═════════════════════════

/// ★ جمل متناوبة: كشف كلمةً كلمة ← ثبات ← اختفاء (صعود + بلور) ← الجملة التالية.
/// يتوقف التكرار عندما تصبح active = false (المستخدم ضغط على الحقل).
class _LoopingReveal extends StatefulWidget {
  final List<String> texts;
  final bool active;
  final TextStyle? style;
  final VoidCallback? onFirstDone;
  final int firstChunk;
  final Duration step;
  final Duration itemDuration;
  final Duration hold;
  final Duration exit;

  const _LoopingReveal({
    required this.texts,
    required this.active,
    this.style,
    this.onFirstDone,
    this.firstChunk = 2,
    this.step = const Duration(milliseconds: 150),
    this.itemDuration = const Duration(milliseconds: 650),
    this.hold = const Duration(milliseconds: 2200),
    this.exit = const Duration(milliseconds: 550),
  });

  @override
  State<_LoopingReveal> createState() => _LoopingRevealState();
}

class _LoopingRevealState extends State<_LoopingReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  int _index = 0;
  List<List<String>> _lines = const [];
  int _revealMs = 1;
  int _totalMs = 1;
  bool _fired = false;

  double get _revealFrac => _revealMs / _totalMs;

  void _prepare() {
    _lines = widget.texts[_index]
        .split('\n')
        .map((l) => l.trim().split(RegExp(r'\s+')))
        .toList();
    final words = _lines.fold<int>(0, (s, l) => s + l.length);
    final chunks = (words - widget.firstChunk + 1).clamp(1, words).toInt();
    _revealMs =
        widget.step.inMilliseconds * (chunks - 1) +
        widget.itemDuration.inMilliseconds;
    _totalMs =
        _revealMs + widget.hold.inMilliseconds + widget.exit.inMilliseconds;
    _c.duration = Duration(milliseconds: _totalMs);
  }

  @override
  void initState() {
    super.initState();
    _prepare();
    if (!widget.active) _c.value = _revealFrac;
    _c.addStatusListener(_onStatus);
    _c.addListener(_checkFirst);
    if (widget.active) {
      _c.forward(from: 0);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fireFirst());
    }
  }

  void _fireFirst() {
    if (_fired || !mounted) return;
    _fired = true;
    widget.onFirstDone?.call();
  }

  void _checkFirst() {
    if (!_fired && _c.value >= _revealFrac) _fireFirst();
  }

  void _onStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed || !widget.active || !mounted) return;
    setState(() {
      _index = (_index + 1) % widget.texts.length;
      _prepare();
    });
    _c.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _LoopingReveal old) {
    super.didUpdateWidget(old);
    if (old.active == widget.active) return;
    if (widget.active) {
      // استئناف من حيث توقفت (ثبات ← اختفاء ← الجملة التالية).
      _c.forward();
    } else {
      // إيقاف: أكمل الجملة الحالية حتى تظهر كاملة ثم اثبت.
      _c.animateTo(
        _revealFrac,
        duration: const Duration(milliseconds: 450),
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _word(String w, int index, double ms) {
    final chunk = (index - (widget.firstChunk - 1)).clamp(0, 1 << 20).toInt();
    final startMs = chunk * widget.step.inMilliseconds;
    final t = Curves.easeOutCubic.transform(
      ((ms - startMs) / widget.itemDuration.inMilliseconds)
          .clamp(0.0, 1.0)
          .toDouble(),
    );

    Widget child = Text(w, style: widget.style);
    if (t < 1) {
      final sigma = 6 * (1 - t);
      child = ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: TileMode.decal,
        ),
        child: child,
      );
    }
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final ms = _c.value * _totalMs;
        final exitStart = _revealMs + widget.hold.inMilliseconds;
        final e = Curves.easeInCubic.transform(
          ((ms - exitStart) / widget.exit.inMilliseconds)
              .clamp(0.0, 1.0)
              .toDouble(),
        );

        var i = 0;
        Widget content = Column(
          children: [
            for (final line in _lines)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 7,
                runSpacing: 2,
                children: [for (final w in line) _word(w, i++, ms)],
              ),
          ],
        );

        if (e > 0) {
          content = ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 8 * e,
              sigmaY: 8 * e,
              tileMode: TileMode.decal,
            ),
            child: content,
          );
        }
        return Opacity(
          opacity: 1 - e,
          child: Transform.translate(
            offset: Offset(0, -12 * e),
            child: content,
          ),
        );
      },
    );
  }
}

/// ★ اقتراحات بحث سريعة تظهر بتتابع (صعود + تلاشي + تكبير خفيف).
class _StaggeredChips extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<String> onTap;

  const _StaggeredChips({required this.labels, required this.onTap});

  @override
  State<_StaggeredChips> createState() => _StaggeredChipsState();
}

class _StaggeredChipsState extends State<_StaggeredChips>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 400 + 90 * widget.labels.length),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.labels.length;
    final total = 400 + 90 * n;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < n; i++)
          AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final s = i * 90 / total;
              final t = Interval(
                s,
                (s + 400 / total).clamp(0.0, 1.0),
                curve: Curves.easeOutBack,
              ).transform(_c.value);
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - t)),
                  child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
                ),
              );
            },
            child: _QuickChip(
              icon: LucideIcons.search,
              label: widget.labels[i],
              onTap: () => widget.onTap(widget.labels[i]),
            ),
          ),
      ],
    );
  }
}

/// زر أيقونة دائري 44×44 داخل شريط الإدخال.
class _BarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;
  final String? tooltip;

  const _BarIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 20,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// ★ الدائرة الأخيرة في الصف السفلي: موجة صوتية، أو سهم إرسال.
class _ActionCircle extends StatelessWidget {
  final bool canSend;
  final bool isDark;
  final Color iconColor;
  final VoidCallback onSend;
  final VoidCallback onVoice;

  const _ActionCircle({
    required this.canSend,
    required this.isDark,
    required this.iconColor,
    required this.onSend,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    final bg = canSend
        ? (isDark ? Colors.white : Colors.black)
        : Colors.transparent;
    return Tooltip(
      message: canSend ? 'إرسال' : 'وضع الصوت',
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: canSend ? onSend : onVoice,
          child: SizedBox(
            width: 42,
            height: 42,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: canSend
                  ? Icon(
                      LucideIcons.arrowUp,
                      key: const ValueKey('send'),
                      size: 20,
                      color: isDark ? Colors.black : Colors.white,
                    )
                  : Center(
                      key: const ValueKey('wave'),
                      child: _WaveformIcon(color: iconColor),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// أيقونة موجة صوتية (audio-lines) مرسومة يدوياً.
class _WaveformIcon extends StatelessWidget {
  final Color color;

  const _WaveformIcon({this.color = const Color(0xFF2F9BFF)});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(22, 18), painter: _WaveformPainter(color));
}

class _WaveformPainter extends CustomPainter {
  final Color color;

  _WaveformPainter(this.color);

  static const _bars = [0.35, 0.6, 0.95, 0.7, 1.0, 0.55, 0.4];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final step = size.width / (_bars.length - 1);
    for (var i = 0; i < _bars.length; i++) {
      final x = i * step;
      final h = size.height * _bars[i];
      final top = (size.height - h) / 2;
      canvas.drawLine(Offset(x, top + 1), Offset(x, top + h - 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// اقتراح سريع (شريحة).
class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fg = isDark ? Colors.white : theme.colorScheme.onSurface;
    return Material(
      color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(
              color: isDark ? AppColors.outline : AppColors.lightOutline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// معاينة الصورة المرفقة مع زر إزالة.
class _AttachmentPreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            cacheWidth: 216,
          ),
        ),
        PositionedDirectional(
          top: -6,
          end: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(LucideIcons.x, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceResultTile extends StatelessWidget {
  final ServiceCategory service;

  const _ServiceResultTile({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fg = isDark ? Colors.white : theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isDark ? AppColors.outline : AppColors.lightOutline,
        ),
      ),
      child: Row(
        children: [
          Icon(MockData.getIconByName(service.iconName), color: fg, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  service.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(LucideIcons.chevronLeft, size: 18, color: fg),
        ],
      ),
    );
  }
}
