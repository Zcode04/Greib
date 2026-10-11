import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/mock_data/mock_data.dart';
import '../core/theme/design_tokens.dart';
import '../core/storage/app_prefs.dart';
import '../core/theme/theme_controller.dart';

class QuickSettingsItem {
  final String label;
  final IconData icon;
  final String? subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const QuickSettingsItem({
    required this.label,
    required this.icon,
    this.subtitle,
    this.enabled = true,
    this.onTap,
  });
}

/// ============================================================================
///  QuickSettingsSheet — ورقة سفلية تلتصق بحافة الشاشة السفلية بعرض كامل،
///  قابلة للتمرير، وكل بند يحمل أيقونته ونصه فقط (الحقول تُطوَّر لاحقاً).
///  الضغط على «الأقسام» يعرض نفس أقسام شريط الأقسام في الرئيسية (الكل…).
/// ============================================================================
class QuickSettingsSheet extends StatefulWidget {
  final List<QuickSettingsItem> items;

  const QuickSettingsSheet({super.key, this.items = const []});

  /// البنود الافتراضية — أيقونة ونص فقط.
  static List<QuickSettingsItem> get defaultItems => const [
    QuickSettingsItem(label: 'الأقسام', icon: LucideIcons.layoutGrid),
  ];

  static Future<void> show(
    BuildContext context, {
    List<QuickSettingsItem>? items,
  }) {
    final resolved = (items == null || items.isEmpty) ? defaultItems : items;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      builder: (_) => QuickSettingsSheet(items: resolved),
    );
  }

  @override
  State<QuickSettingsSheet> createState() => _QuickSettingsSheetState();
}

class _QuickSettingsSheetState extends State<QuickSettingsSheet> {
  /// نفس بيانات شريط الأقسام في الرئيسيةHomeCategoriesTabBar.
  List<Map<String, String>> get _sections => MockData.productCategories;

  /// null = شاشة القائمة، غير null = شاشة الأقسام.
  bool _showSections = false;
  String _selectedSectionId = 'all';

  void _openSections() => setState(() => _showSections = true);

  void _closeSections() => setState(() => _showSections = false);

  void _selectSection(Map<String, String> section) {
    setState(() {
      _selectedSectionId = section['id']!;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ★ نُبقي الورقة متجاوبة مع تبديل النمط أثناء فتحها.
    context.watch<ThemeController>();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                if (_showSections)
                  IconButton(
                    icon: Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                    tooltip: 'رجوع',
                    visualDensity: VisualDensity.compact,
                    onPressed: _closeSections,
                  )
                else
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      LucideIcons.layoutGrid,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _showSections ? 'الأقسام' : 'الإعدادات السريعة',
                    style: AppTypography.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          Flexible(
            child: _showSections ? _buildSections(theme) : _buildMenu(theme),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// قائمة البنود الرئيسية + بند «الوضع الليلي» (نُقل من الهيدر إلى هنا).
  Widget _buildMenu(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ★ بند «الحاذق» — المساعد الذكي (AI).
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              'الحاذق',
              style: AppTypography.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              'المساعد الذكي (AI)',
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push('/alhadheq');
            },
          ),
          Divider(
            height: 1,
            indent: 68,
            endIndent: AppSpacing.lg,
            color: theme.dividerColor,
          ),
          for (int i = 0; i < widget.items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 68,
                endIndent: AppSpacing.lg,
                color: theme.dividerColor,
              ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  widget.items[i].icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                widget.items[i].label,
                style: AppTypography.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              subtitle: widget.items[i].subtitle == null
                  ? null
                  : Text(
                      widget.items[i].subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
              trailing: Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onTap: widget.items[i].enabled ? (widget.items[i].onTap ?? _openSections) : null,
            ),
          ],
        // ★ بند «البحث» — كان أيقونة في الهيدر، ونُقل هنا مثل الوضع الليلي.
        Divider(height: 1, indent: 68, endIndent: AppSpacing.lg, color: theme.dividerColor),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              LucideIcons.search,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            'البحث',
            style: AppTypography.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          trailing: Icon(
            LucideIcons.chevronLeft,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push('/search');
          },
        ),
        // ★ مبدّل الوضع الليلي/النهاري — كان أيقونة في الهيدر، ونُقل هنا.
        Divider(height: 1, indent: 68, endIndent: AppSpacing.lg, color: theme.dividerColor),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          value: isDark,
          onChanged: (_) => context.read<ThemeController>().toggleTheme(),
          secondary: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              isDark ? LucideIcons.moon : LucideIcons.sun,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            'الوضع الليلي',
            style: AppTypography.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            isDark ? 'مُفعّل — اضغط للتبديل إلى النهاري' : 'مُطفأ — اضغط للتبديل إلى الليلي',
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // ★ بند «التحكم في الألوان» — يظهر أسفل الوضع الليلي مباشرة.
        // ★ معطّل مؤقتاً: غير قابل للاستجابة عند النقر، وزر «غير متاح في
        //   منطقتك» يظهر مكان سهم التنقل (يُفعَّل لاحقاً).
        Divider(height: 1, indent: 68, endIndent: AppSpacing.lg, color: theme.dividerColor),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          enabled: false, // ★ لا يستجيب للنقر
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              LucideIcons.palette,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            'التحكم في الألوان',
            style: AppTypography.titleMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            'تخصيص الخلفية والنصوص والأيقونات',
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: OutlinedButton(
            // ★ زر معطّل: يوضّح أن الميزة غير مفعّلة في المنطقة حالياً.
            onPressed: null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 30),
              side: BorderSide(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              textStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
            ),
            child: const Text('غير متاح في منطقتك'),
          ),
        ),
        Divider(height: 1, indent: 68, endIndent: AppSpacing.lg, color: theme.dividerColor),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          value: AppPrefs.useRealMaps,
          onChanged: (v) async {
            await AppPrefs.setUseRealMaps(v);
            if (context.mounted) setState(() {});
          },
          secondary: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadii.sm)),
            child: Icon(LucideIcons.map, size: 18, color: theme.colorScheme.primary),
          ),
          title: Text('الخرائط الحقيقية', style: AppTypography.titleMedium.copyWith(color: theme.colorScheme.onSurface, fontSize: 15)),
          subtitle: Text(AppPrefs.useRealMaps ? 'مفعّلة — GPS وخريطة OSM حقيقية' : 'مطفأة — الوضع الوهمي للعروض',
            style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
      ],
    ),
  );
}

  /// نفس أقسام الشريط في الرئيسية (الكل، الإلكترونيات، …) كقائمة قابلة للتمرير.
  Widget _buildSections(ThemeData theme) {
    final accent = theme.colorScheme.primary;
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: _sections.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 68,
        endIndent: AppSpacing.lg,
        color: theme.dividerColor,
      ),
      itemBuilder: (context, index) {
        final section = _sections[index];
        final isSelected = section['id'] == _selectedSectionId;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isSelected ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: isSelected ? Border.all(color: accent, width: 1.5) : null,
            ),
            child: Icon(
              index == 0 ? LucideIcons.layoutGrid : LucideIcons.chevronLeft,
              size: 18,
              color: accent,
            ),
          ),
          title: Text(
            section['label']!,
            style: AppTypography.titleMedium.copyWith(
              color: isSelected ? accent : theme.colorScheme.onSurface,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          trailing: isSelected
              ? Icon(LucideIcons.check, size: 18, color: accent)
              : null,
          onTap: () => _selectSection(section),
        );
      },
    );
  }
}
