import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/mock_data/mock_data.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/header.dart';

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

  final List<_SearchCategory> _categories = const [
    _SearchCategory(
      label: 'المطاعم',
      query: 'طعام',
      icon: LucideIcons.utensils,
      color: AppColors.serviceFood,
    ),
    _SearchCategory(
      label: 'التوصيل',
      query: 'توصيل',
      icon: LucideIcons.package,
      color: AppColors.serviceCourier,
    ),
    _SearchCategory(
      label: 'الصيدلية',
      query: 'صيدلية',
      icon: LucideIcons.stethoscope,
      color: AppColors.servicePharmacy,
    ),
    _SearchCategory(
      label: 'التسوق',
      query: 'تسوق',
      icon: LucideIcons.shoppingBag,
      color: AppColors.serviceShopping,
    ),
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

  List<ServiceCategory> get _results {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];

    return MockData.services
        .where(
          (service) => '${service.title} ${service.subtitle}'
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
        appBar: const Header(
          title: 'البحث',
          showBackButton: true,
          showSearchButton: false,
          showNotifications: false,
          showDarkModeToggle: false,
        ),
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

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _focusNode.unfocus(),
      decoration: InputDecoration(
        hintText: 'ابحث عن خدمة أو نشاط...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: const Icon(LucideIcons.search, size: 22),
        suffixIcon: _searchController.text.isEmpty
            ? const Icon(LucideIcons.mic, size: 20)
            : IconButton(
                onPressed: _clearQuery,
                tooltip: 'مسح البحث',
                icon: const Icon(LucideIcons.x, size: 19),
              ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(
            color: isDark ? AppColors.outline : AppColors.lightOutline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(
            color: isDark ? AppColors.outline : AppColors.lightOutline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(
            color: AppColors.accentPrimaryDark,
            width: 1.5,
          ),
        ),
      ),
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
        const SizedBox(height: AppSpacing.xxl),
        _buildSectionTitle(
          icon: LucideIcons.layoutGrid,
          title: 'تصفح حسب الفئة',
          subtitle: 'اختصارات سريعة للخدمات الأكثر استخداماً',
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = AppSpacing.md;
            final cardWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _categories
                  .map(
                    (category) => SizedBox(
                      width: cardWidth,
                      child: _CategoryCard(
                        category: category,
                        onTap: () => _setQuery(category.query),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.accentPrimaryDark.withValues(alpha: 0.22),
                      AppColors.accentPrimary.withValues(alpha: 0.08),
                    ]
                  : [AppColors.accentPrimaryLight, AppColors.lightSurface],
            ),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.accentPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.lightbulb,
                  color: AppColors.onAccentPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'نصيحة: استخدم كلمات مثل «توصيل» أو «صيدلية» للوصول إلى النتيجة بشكل أسرع.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightText,
                    height: 1.6,
                  ),
                ),
              ),
            ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentPrimary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 19, color: AppColors.accentPrimaryDark),
        ),
        const SizedBox(width: AppSpacing.md),
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
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.searchX,
              size: 30,
              color: AppColors.accentPrimaryDark,
            ),
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
              const Icon(LucideIcons.history, size: 15),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _SearchCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: category.color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: service.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(_iconForService(service), color: service.color),
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
          Icon(
            LucideIcons.chevronLeft,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  IconData _iconForService(ServiceCategory service) {
    switch (service.id) {
      case 'food':
        return LucideIcons.utensils;
      case 'pharmacy':
        return LucideIcons.stethoscope;
      case 'courier':
      case 'delivery':
        return LucideIcons.package;
      case 'ride':
        return LucideIcons.car;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'tourism':
        return LucideIcons.palmtree;
      case 'cinema':
        return LucideIcons.film;
      case 'banking':
        return LucideIcons.wallet;
      case 'maps':
        return LucideIcons.map;
      default:
        return LucideIcons.layoutGrid;
    }
  }
}

class _SearchCategory {
  final String label;
  final String query;
  final IconData icon;
  final Color color;

  const _SearchCategory({
    required this.label,
    required this.query,
    required this.icon,
    required this.color,
  });
}
