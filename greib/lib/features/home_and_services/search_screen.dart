import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/mock_data/mock_data.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/super_header.dart';
import '../services/data/services_repository.dart';
import '../visual_search/visual_search_analysis_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _recentSearches = [
    'توصيل طلبات',
    'عيادة أسنان',
    'فندق 5 نجوم',
    'سيارة إيجار',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
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

  void _clearQuery() {
    _searchController.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  bool _busy = false;

  /// ★ البحث بإرفاق صورة: يختار صورة من المعرض ثم يفتح شاشة البحث البصري
  ///   مع تمرير نص الحقل (إن وُجد) كسياق إضافي للتحليل.
  Future<void> _pickImageAndSearch() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      setState(() => _busy = false);
      if (f == null) return;
      final q = _searchController.text.trim();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VisualSearchAnalysisScreen(
            imageFile: File(f.path),
            sourceLabel: 'المعرض',
            textQuery: q.isEmpty ? null : q,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر فتح المعرض — حاول مجدداً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchField(theme, isDark),
                const SizedBox(height: AppSpacing.xl),
                if (query.isEmpty)
                  _buildWelcome(context, theme, isDark)
                else
                  _buildResults(context, theme, isDark, query),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ★ حقل بحث دائري (pill): حواف دائرية بالكامل + أيقونات بيضاء بلا خلفية.
  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _focusNode.unfocus(),
      cursorColor: AppColors.accentPrimary,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'ابحث عن خدمة أو نشاط...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon:
            const Icon(LucideIcons.search, size: 20, color: Colors.white),
        suffixIcon: _searchController.text.isEmpty
            ? const Icon(LucideIcons.mic, size: 18, color: Colors.white)
            : IconButton(
                onPressed: _clearQuery,
                tooltip: 'مسح البحث',
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.white),
              ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide(
            color: isDark ? AppColors.outline : AppColors.lightOutline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// ★ ثلاث طرق للبحث: إرفاق صورة، البحث في الحقل، أو إرسال رسالة للوكيل.
  Widget _buildSearchMethods(ThemeData theme, bool isDark) {
    return Column(
      children: [
        _SearchMethodCard(
          icon: LucideIcons.imagePlus,
          title: 'إرفاق صورة والبحث',
          subtitle: 'اختر صورة من المعرض لتحليلها وإيجاد ما يطابقها',
          highlight: true,
          busy: _busy,
          onTap: _pickImageAndSearch,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SearchMethodCard(
          icon: LucideIcons.textSearch,
          title: 'البحث في الحقل',
          subtitle: 'اكتب اسم الخدمة أو المنتج في الأعلى للبحث فوراً',
          onTap: () => _focusNode.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SearchMethodCard(
          icon: LucideIcons.bot,
          title: 'رسالة للوكيل',
          subtitle: 'اطلب من المساعد الذكي «الحاذق» أن يبحث عنك',
          onTap: () => context.push('/alhadheq'),
        ),
      ],
    );
  }

  Widget _buildWelcome(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: LucideIcons.sparkles,
          title: 'مرحباً بك في البحث',
          subtitle: 'اكتشف كل خدماتك بسرعة وسهولة',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSearchMethods(theme, isDark),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionTitle(
          icon: LucideIcons.clock3,
          title: 'عمليات البحث الأخيرة',
          subtitle: 'تابع من حيث توقفت',
          trailing: TextButton(
            onPressed: () => setState(_recentSearches.clear),
            child: const Text('مسح الكل'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _recentSearches
              .map(
                (search) =>
                    _SearchChip(label: search, onTap: () => _setQuery(search)),
              )
              .toList(),
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

  /// ★ عنوان قسم مبسّط: أيقونة بيضاء بلا خلفية + عنوان + وصف فرعي.
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
        Icon(icon, size: 20, color: Colors.white),
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
          const Icon(LucideIcons.searchX, size: 40, color: Colors.white),
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
            'جرّب كلمة أخرى أو اختر خدمة من التصنيفات أعلاه.',
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

class _SearchMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
  final bool busy;

  const _SearchMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: highlight
                  ? AppColors.accentPrimary.withValues(alpha: 0.45)
                  : (isDark ? AppColors.outline : AppColors.lightOutline),
              width: highlight ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              const Icon(LucideIcons.history, size: 15, color: Colors.white),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          ),
        ),
      ),
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
          Icon(
            MockData.getIconByName(service.iconName),
            color: Colors.white,
            size: 24,
          ),
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
          const Icon(LucideIcons.chevronLeft, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}
