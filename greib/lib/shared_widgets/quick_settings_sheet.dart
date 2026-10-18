import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/mock_data/mock_data.dart';
import '../core/storage/app_prefs.dart';
import '../core/theme/theme_controller.dart';
import '../core/widgets/app_sheet.dart';
import '../core/widgets/draggable_sheet_body.dart';

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
///  QuickSettingsSheet — ورقة زر ⋮ في الهيدر.
///
///  ★ نفس تصميم ورقة صور المنشور (_showPostImagesSheet):
///    بلا عنوان علوي، فقط الأزرار — InkWell + padding vertical 16،
///    أيقونة 24 + مسافة 16 + نص 16 w600 بلون onSurface،
///    داخل DraggableSheetBody قابل للسحب.
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
    return showAppSheet<void>(
      context,
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

    return DraggableSheetBody(
      initialExtent: 0.45,
      snapSizes: const [0.35, 0.45, 0.6, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _showSections
                ? _buildSections(context, theme, scrollController)
                : _buildMenu(context, theme, scrollController),
          ),
        ],
      ),
    );
  }

  /// صف واحد — نفس ستايل ورقة صور المنشور:
  /// InkWell + padding vertical 16، أيقونة 24 + مسافة 16 + نص 16 w600.
  Widget _sheetRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final sheetText = Theme.of(context).colorScheme.onSurface;
    final sub = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: sheetText),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: sheetText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: sub, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  /// قائمة البنود الرئيسية + بند «الوضع الليلي» (نُقل من الهيدر إلى هنا).
  Widget _buildMenu(
    BuildContext context,
    ThemeData theme,
    ScrollController scrollController,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          // ★ بند «الحاذق» — المساعد الذكي (AI).
          _sheetRow(
            context,
            icon: LucideIcons.sparkles,
            label: 'الحاذق',
            subtitle: 'المساعد الذكي (AI)',
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push('/alhadheq');
            },
          ),
          for (int i = 0; i < widget.items.length; i++)
            _sheetRow(
              context,
              icon: widget.items[i].icon,
              label: widget.items[i].label,
              subtitle: widget.items[i].subtitle,
              onTap: widget.items[i].enabled
                  ? (widget.items[i].onTap ?? _openSections)
                  : () {},
            ),
        // ★ بند «البحث» — كان أيقونة في الهيدر، ونُقل هنا مثل الوضع الليلي.
          _sheetRow(
            context,
            icon: LucideIcons.search,
            label: 'البحث',
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push('/search');
            },
          ),
        // ★ مبدّل الوضع الليلي/النهاري — كان أيقونة في الهيدر، ونُقل هنا.
          _sheetRow(
            context,
            icon: isDark ? LucideIcons.moon : LucideIcons.sun,
            label: 'الوضع الليلي',
            subtitle: isDark
                ? 'مُفعّل — اضغط للتبديل إلى النهاري'
                : 'مُطفأ — اضغط للتبديل إلى الليلي',
            onTap: () => context.read<ThemeController>().toggleTheme(),
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  context.read<ThemeController>().toggleTheme(),
            ),
          ),
        // ★ بند «التحكم في الألوان» — يفتح صفحة تخصيص الخلفية/النصوص/الأيقونات.
        _sheetRow(
          context,
          icon: LucideIcons.palette,
          label: 'التحكم في الألوان',
          subtitle: 'تخصيص الخلفية والنصوص والأيقونات',
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push('/color-settings');
          },
        ),
        _sheetRow(
          context,
          icon: LucideIcons.map,
          label: 'الخرائط الحقيقية',
          subtitle: AppPrefs.useRealMaps
              ? 'مفعّلة — GPS وخريطة OSM حقيقية'
              : 'مطفأة — الوضع الوهمي للعروض',
          onTap: () async {
            await AppPrefs.setUseRealMaps(!AppPrefs.useRealMaps);
            if (context.mounted) setState(() {});
          },
          trailing: Switch(
            value: AppPrefs.useRealMaps,
            onChanged: (v) async {
              await AppPrefs.setUseRealMaps(v);
              if (context.mounted) setState(() {});
            },
          ),
        ),
      ],
    );
  }

  /// نفس أقسام الشريط في الرئيسية (الكل، الإلكترونيات، …) كقائمة قابلة للتمرير.
  Widget _buildSections(
    BuildContext context,
    ThemeData theme,
    ScrollController scrollController,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        _sheetRow(
          context,
          icon: LucideIcons.chevronRight,
          label: 'رجوع',
          onTap: _closeSections,
        ),
        ..._sections.map(
          (section) => _sheetRow(
            context,
            icon: section['id'] == 'all'
                ? LucideIcons.layoutGrid
                : LucideIcons.chevronLeft,
            label: section['label']!,
            onTap: () => _selectSection(section),
            trailing: section['id'] == _selectedSectionId
                ? Icon(
                    LucideIcons.check,
                    size: 20,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
