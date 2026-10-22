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
import '../../core/extensions/context_extensions.dart';
import '../../core/widgets/super_header.dart';
import '../services/data/services_repository.dart';
import '../visual_search/visual_search_analysis_screen.dart';
import 'search_history_screen.dart';
import 'search_history_store.dart';

enum _SearchPhase { idle, thinking, done }

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

  _SearchPhase _phase = _SearchPhase.idle;
  String _submittedQuery = '';
  List<ServiceCategory> _found = const [];
  int _runId = 0;

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

  /// إرسال: صورة ← شاشة البحث البصري، نص ← تفكير ذكي ثم النتائج.
  Future<void> _submit() async {
    final file = _attachment;
    final q = _searchController.text.trim();

    if (file == null) {
      if (q.isNotEmpty) _runTextSearch(q);
      return;
    }

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

  Future<void> _runTextSearch(String q) async {
    final id = ++_runId;
    SearchHistoryStore.instance.add(q);
    _focusNode.unfocus();
    _searchController.clear();
    setState(() {
      _submittedQuery = q;
      _found = const [];
      _welcomeDone = false;
      _phase = _SearchPhase.thinking;
    });

    // مدة "التفكير" (أطول قليلاً من خطوات الأنميشن الأربع = 3000ms).
    await Future.delayed(const Duration(milliseconds: 3300));
    if (!mounted || id != _runId) return;
    setState(() {
      _found = _searchServices(q);
      _phase = _SearchPhase.done;
    });
  }

  void _resetSearch() {
    _runId++;
    setState(() {
      _phase = _SearchPhase.idle;
      _submittedQuery = '';
      _found = const [];
    });
  }

  List<ServiceCategory> _searchServices(String q) {
    final words = q
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();
    if (words.isEmpty) return const [];

    return ServicesRepository.instance.all.where((s) {
      final hay = '${s.title} ${s.subtitle} ${s.description}'.toLowerCase();
      return words.any(hay.contains);
    }).take(8).toList();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundColors.primary,
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
                      child: _buildBody(context, theme, isDark),
                    ),
                  ),
                ),
              ),
              _buildBottomInputBar(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── شريط الإدخال ─────────────────────────

  Widget _buildBottomInputBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      color: context.backgroundColors.primary,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToolbar(theme),
            const SizedBox(height: AppSpacing.sm),
            _buildSearchField(context, theme),
          ],
        ),
      ),
    );
  }

  /// ★ شريط الأدوات فوق الحقل: رقائق سريعة + أيقونات الإجراءات،
  /// فيبقى الحقل نفسه خفيفاً (نص + زر إرسال فقط) وأكثر احترافية.
  Widget _buildToolbar(ThemeData theme) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _BarIconButton(
              icon: LucideIcons.squarePen,
              tooltip: 'محادثة جديدة',
              color: muted,
              size: 20,
              buttonSize: 34,
              onTap: _resetSearch,
            ),
            const SizedBox(width: 2),
            _BarIconButton(
              icon: LucideIcons.folderClock,
              tooltip: 'سجل البحث',
              color: muted,
              size: 20,
              buttonSize: 34,
              onTap: _openHistory,
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickChip(
              icon: LucideIcons.camera,
              label: 'الكاميرا',
              onTap: () => _pickMedia(ImageSource.camera),
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickChip(
              icon: LucideIcons.image,
              label: 'صور',
              onTap: _busy ? null : () => _pickMedia(ImageSource.gallery),
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickChip(
              icon: LucideIcons.mic,
              label: 'بحث بالصوت',
              onTap: _startVoiceSearch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, ThemeData theme) {
    final focused = _focusNode.hasFocus;
    final canSend =
        _searchController.text.trim().isNotEmpty || _attachment != null;
    final muted = theme.colorScheme.onSurfaceVariant;
    final textStyle = theme.textTheme.bodyLarge ?? const TextStyle();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: focused
              ? context.accentColor
              : context.backgroundColors.outline,
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
              cursorColor: context.accentColor,
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
                _ActionCircle(
                  canSend: canSend,
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

  Widget _buildBody(BuildContext context, ThemeData theme, bool isDark) {
    if (_phase == _SearchPhase.idle) {
      return Center(child: _buildWelcome(context, theme, isDark));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UserBubble(key: ValueKey('q$_runId'), text: _submittedQuery),
        const SizedBox(height: AppSpacing.xl),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: KeyedSubtree(
            key: ValueKey('$_phase$_runId'),
            child: _phase == _SearchPhase.thinking
                ? _AiThinking(query: _submittedQuery)
                : _buildResults(context, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, ThemeData theme) {
    final results = _found;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: LucideIcons.sparkles,
          title: results.isEmpty
              ? 'لم أجد نتائج مطابقة'
              : 'وجدت لك ${results.length} نتائج',
          subtitle: 'حسب بحثك عن «$_submittedQuery»',
          trailing: _BarIconButton(
            icon: LucideIcons.rotateCcw,
            tooltip: 'بحث جديد',
            color: muted,
            onTap: _resetSearch,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (results.isEmpty)
          _buildEmptyResults(theme, _submittedQuery)
        else
          for (var i = 0; i < results.length; i++)
            _FadeInUp(
              delay: Duration(milliseconds: 80 * i),
              child: Column(
                children: [
                  _ServiceResultTile(service: results[i]),
                  if (i < results.length - 1)
                    Divider(
                      height: 1,
                      color: context.backgroundColors.outline,
                    ),
                ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: context.textColors.primary,
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

  Widget _buildEmptyResults(ThemeData theme, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(
              LucideIcons.searchX,
              size: 40,
              color: context.textColors.primary,
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
  final double buttonSize;
  final String? tooltip;

  const _BarIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 20,
    this.buttonSize = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: buttonSize,
      height: buttonSize,
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
  final Color iconColor;
  final VoidCallback onSend;
  final VoidCallback onVoice;

  const _ActionCircle({
    required this.canSend,
    required this.iconColor,
    required this.onSend,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    // ★ الدائرة الممتلئة تتبع اللون المقابل للخلفية (تتكيّف مع الوضع تلقائياً).
    final bg = canSend ? context.textColors.primary : Colors.transparent;
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
                      color: context.backgroundColors.primary,
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
  final Color? color;

  const _WaveformIcon({this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(22, 18),
        painter: _WaveformPainter(color ?? context.accentColor),
      );
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
    final fg = context.textColors.primary;
    return Material(
      color: context.backgroundColors.surface,
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
              color: context.backgroundColors.outline,
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
                color: context.backgroundColors.mediaScrim,
                shape: BoxShape.circle,
                border: Border.all(color: context.backgroundColors.outline),
              ),
              child: Icon(
                LucideIcons.x,
                size: 13,
                color: context.textColors.onMedia,
              ),
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
    final fg = context.textColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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

/// ★ تظهر النتائج بصعود وتلاشي متتابع.
class _FadeInUp extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _FadeInUp({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    final total = delay.inMilliseconds + 450;
    final begin = delay.inMilliseconds / total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      child: child,
      builder: (_, v, child) {
        final t = Interval(begin, 1, curve: Curves.easeOutCubic).transform(v);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
        );
      },
    );
  }
}

/// فقاعة رسالة المستخدم (كما في تطبيقات الدردشة).
class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: _FadeInUp(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: context.backgroundColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(text, style: theme.textTheme.bodyLarge),
        ),
      ),
    );
  }
}


/// ★ رد الذكاء الاصطناعي أثناء التفكير: كرة نابضة، نص لامع متبدّل،
/// وخطوات تظهر تباعاً (سبينر ← علامة صح).
class _AiThinking extends StatefulWidget {
  final String query;

  const _AiThinking({required this.query});

  @override
  State<_AiThinking> createState() => _AiThinkingState();
}

class _AiThinkingState extends State<_AiThinking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();
  Timer? _timer;
  int _step = 0;

  List<String> get _steps => [
        'أحلّل طلبك «${widget.query}»',
        'أبحث في الخدمات المتاحة',
        'أقارن العروض والخيارات القريبة',
        'أرتّب أفضل النتائج لك',
      ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (!mounted) return;
      if (_step < _steps.length) setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  Widget _orb(BuildContext context, Color bg, Color fg) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final a = _c.value * 2 * math.pi;
        return Transform.scale(
          scale: 1 + 0.08 * math.sin(a),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: a,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          context.accentColor,
                          const Color(0xFF8E7BFF),
                          const Color(0xFF2FD1FF),
                          context.accentColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.accentColor.withValues(alpha: 0.35),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
                ),
                Icon(LucideIcons.sparkles, size: 15, color: fg),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = context.backgroundColors.primary;
    final fg = context.textColors.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final steps = _steps;
    final title = _step == 0
        ? 'أفكر… انتظر قليلاً'
        : steps[(_step - 1).clamp(0, steps.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _orb(context, bg, fg),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                layoutBuilder: (current, previous) => Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [...previous, if (current != null) current],
                ),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: AnimatedBuilder(
                  key: ValueKey(title),
                  animation: _c,
                  builder: (_, __) {
                    final x = _c.value * 3 - 1;
                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (r) => LinearGradient(
                        begin: Alignment(x - 0.6, 0),
                        end: Alignment(x + 0.6, 0),
                        colors: [muted, fg, muted],
                      ).createShader(r),
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < steps.length; i++)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: i <= _step ? 1 : 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: i <= _step ? Offset.zero : const Offset(0, 0.4),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: i < _step
                          ? Icon(
                              LucideIcons.check,
                              size: 16,
                              color: context.accentColor,
                            )
                          : i == _step
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: muted,
                                )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: i < _step ? muted : fg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

