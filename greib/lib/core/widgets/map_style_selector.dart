import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../extensions/context_extensions.dart';
import '../location/map_config.dart';
import '../storage/app_prefs.dart';
import '../theme/app_colors.dart';

/// ============================================================================
///  MapStyleSelector — شريط اختيار نمط الخريطة (3 أوضاع: عادي/داكن/أقمار).
///
///  الاستخدام:
///    MapStyleSelector(
///      current: MapConfig.providerFromIndex(AppPrefs.mapStyleIndex),
///      onChanged: (kind) { ... setState(...) },
///    )
///
///  أو عبر Bottom Sheet:
///    MapStyleSelector.show(context).then((kind) { ... });
/// ============================================================================
class MapStyleSelector extends StatelessWidget {
  final MapProviderKind current;
  final ValueChanged<MapProviderKind> onChanged;

  const MapStyleSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  /// يعرض Bottom Sheet ويعيد الاختيار.
  static Future<MapProviderKind?> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ★ خلفية الورقة من اللوحة المركزية (Color Palette).
    final bg = context.backgroundColors.surface;

    return showModalBottomSheet<MapProviderKind>(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        MapProviderKind picked =
            MapConfig.providerFromIndex(AppPrefs.mapStyleIndex);
        return StatefulBuilder(builder: (ctx, setSt) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: ctx.backgroundColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'نمط الخريطة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ctx.textColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StyleTile(
                      label: 'عادي',
                      icon: LucideIcons.map,
                      kind: MapProviderKind.osm,
                      selected: picked == MapProviderKind.osm,
                      isDark: isDark,
                      color: ctx.accentColor,
                      onTap: () => setSt(() => picked = MapProviderKind.osm),
                    ),
                    const SizedBox(width: 10),
                    _StyleTile(
                      label: 'داكن',
                      icon: LucideIcons.moon,
                      kind: MapProviderKind.osmDark,
                      selected: picked == MapProviderKind.osmDark,
                      isDark: isDark,
                      color: const Color(0xFF8B5CF6), // لون نمط الخريطة الداكنة (خارج اللوحة)
                      onTap: () =>
                          setSt(() => picked = MapProviderKind.osmDark),
                    ),
                    const SizedBox(width: 10),
                    _StyleTile(
                      label: 'أقمار',
                      icon: LucideIcons.satellite,
                      kind: MapProviderKind.satellite,
                      selected: picked == MapProviderKind.satellite,
                      isDark: isDark,
                      color: AppColors.success,
                      onTap: () =>
                          setSt(() => picked = MapProviderKind.satellite),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ctx.accentColor,
                    foregroundColor: ctx.textColors.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await AppPrefs.setMapStyleIndex(picked.index);
                    if (ctx.mounted) Navigator.of(ctx).pop(picked);
                  },
                  child: const Text(
                    'تطبيق',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _StyleTile(
          label: 'عادي',
          icon: LucideIcons.map,
          kind: MapProviderKind.osm,
          selected: current == MapProviderKind.osm,
          isDark: isDark,
          color: context.accentColor,
          onTap: () => onChanged(MapProviderKind.osm),
        ),
        const SizedBox(width: 8),
        _StyleTile(
          label: 'داكن',
          icon: LucideIcons.moon,
          kind: MapProviderKind.osmDark,
          selected: current == MapProviderKind.osmDark,
          isDark: isDark,
          color: const Color(0xFF8B5CF6), // لون نمط الخريطة الداكنة (خارج اللوحة)
          onTap: () => onChanged(MapProviderKind.osmDark),
        ),
        const SizedBox(width: 8),
        _StyleTile(
          label: 'أقمار',
          icon: LucideIcons.satellite,
          kind: MapProviderKind.satellite,
          selected: current == MapProviderKind.satellite,
          isDark: isDark,
          color: AppColors.success,
          onTap: () => onChanged(MapProviderKind.satellite),
        ),
      ],
    );
  }
}

// ── بطاقة نمط واحد ──────────────────────────────────────────────────────────
class _StyleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final MapProviderKind kind;
  final bool selected;
  final bool isDark;
  final Color color;
  final VoidCallback onTap;

  const _StyleTile({
    required this.label,
    required this.icon,
    required this.kind,
    required this.selected,
    required this.isDark,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ★ ألوان البلاطة من اللوحة المركزية (Color Palette) عبر السياق.
    final bg   = context.backgroundColors.surfaceElevated;
    final text = context.textColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.14) : bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: selected ? color : text),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? color : text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
