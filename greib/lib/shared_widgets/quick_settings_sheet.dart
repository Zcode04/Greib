import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/mock_data/mock_data.dart';
import '../core/theme/design_tokens.dart';

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

  /// قائمة البنود الرئيسية.
  Widget _buildMenu(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: widget.items.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 68,
        endIndent: AppSpacing.lg,
        color: theme.dividerColor,
      ),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return ListTile(
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
            child: Icon(item.icon, size: 18, color: theme.colorScheme.primary),
          ),
          title: Text(
            item.label,
            style: AppTypography.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          subtitle: item.subtitle == null
              ? null
              : Text(
                  item.subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
          trailing: Icon(
            LucideIcons.chevronLeft,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: item.enabled ? (item.onTap ?? _openSections) : null,
        );
      },
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
