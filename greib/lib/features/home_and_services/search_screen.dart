import 'dart:io';

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
      // بحث نصي: نُسجّل العملية في السجل ثم نُنهي الكتابة.
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
                        // يسمح بتوسيط الترحيب عمودياً كما في تطبيقات الدردشة.
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
    // اقتراحات سريعة فوق الحقل في الحالة الابتدائية فقط.
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

  /// ★ حقل مطابق لتصميم منصات الدردشة بالذكاء الاصطناعي (صفّان):
  ///   الصف العلوي: النص. الصف السفلي: كاميرا + صور في البداية، وفي النهاية
  ///   مايك + دائرة (موجة صوتية زرقاء، أو سهم إرسال عند وجود محتوى).
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

  /// ★ ترحيب مركزي بأسلوب تطبيقات الدردشة.
  Widget _buildWelcome(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ابحث لحظيًا عن كل ما في ذهنك،\nسواء على المستوى المحلي أو العالمي!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'في مختلف المجالات',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
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

/// ★ الدائرة الأخيرة في الصف السفلي: موجة صوتية زرقاء، أو سهم إرسال.
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
    // دائرة الإرسال فقط تُملأ بلون؛ أما وضع الصوت (موجة الصوت) فيظهر بلا خلفية
    // ليطابق أيقونات الشريط الأخرى (الكاميرا/الصور/المايك) ويوحّد تجربة المستخدم.
    final bg =
        canSend ? (isDark ? Colors.white : Colors.black) : Colors.transparent;
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

/// أيقونة موجة صوتية (audio-lines) مرسومة يدوياً، تأخذ لون بقية أيقونات الشريط.
class _WaveformIcon extends StatelessWidget {
  final Color color;

  const _WaveformIcon({this.color = const Color(0xFF2F9BFF)});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(22, 18),
    painter: _WaveformPainter(color),
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

/// اقتراح سريع فوق الحقل (بحث بالصوت / صور).
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

/// معاينة الصورة المرفقة مع زر إزالة (كما في تطبيقات الدردشة).
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
