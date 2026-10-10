import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../location/location_controller.dart';
import '../location/mauritania_regions.dart';
import '../theme/design_tokens.dart';
import 'app_sheet.dart';

/// عنصر واحد في قائمة الاختيار — ولاية أو مقاطعة.
class _PlaceEntry {
  final String name;
  final String subtitle;
  final double lat;
  final double lng;
  final bool isRegion;
  final MrRegion region;

  const _PlaceEntry({
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lng,
    required this.isRegion,
    required this.region,
  });
}

/// LocationPickerSheet — اختيار المدينة + موقع GPS الحقيقي.
/// تُفتح من SuperHeader وتُحدّث LocationController مباشرة.
///
/// البنية: عنوان ← زر GPS ← بطاقة «موقعك الحالي» (دولة/ولاية/مقاطعة)
/// ← قائمة «الأقرب إليك» مع المسافة، بتحميل تدريجي (3 عناصر + عرض المزيد).
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  static const int _pageSize = 3;
  static const double _cardRadius = 18;

  int _visibleCount = _pageSize;

  /// قائمة مسطّحة مرتبة: كل ولاية تليها مقاطعاتها مباشرة.
  static final List<_PlaceEntry> _entries = [
    for (final r in MauritaniaRegions.regions) ...[
      _PlaceEntry(
        name: r.nameAr,
        subtitle: 'ولاية · العاصمة ${r.capitalAr}',
        lat: r.lat,
        lng: r.lng,
        isRegion: true,
        region: r,
      ),
      for (final d in r.districts)
        _PlaceEntry(
          name: d.nameAr,
          subtitle: 'مقاطعة · ولاية ${r.nameAr}',
          lat: d.lat,
          lng: d.lng,
          isRegion: false,
          region: r,
        ),
    ],
  ];

  bool get _hasMore => _visibleCount < _entries.length;

  void _showMore() {
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, _entries.length);
    });
  }

  /// الدول العربية — موريتانيا فعّالة حالياً، والباقي قيد التطوير لاحقاً.
  static const List<(String, String)> _arabCountries = [
    ('🇲🇷', 'موريتانيا'),
    ('🇸🇦', 'السعودية'),
    ('🇦🇪', 'الإمارات'),
    ('🇶🇦', 'قطر'),
    ('🇰🇼', 'الكويت'),
    ('🇧🇭', 'البحرين'),
    ('🇴🇲', 'عُمان'),
    ('🇾🇪', 'اليمن'),
    ('🇮🇶', 'العراق'),
    ('🇸🇾', 'سوريا'),
    ('🇱🇧', 'لبنان'),
    ('🇯🇴', 'الأردن'),
    ('🇵🇸', 'فلسطين'),
    ('🇪🇬', 'مصر'),
    ('🇸🇩', 'السودان'),
    ('🇱🇾', 'ليبيا'),
    ('🇹🇳', 'تونس'),
    ('🇩🇿', 'الجزائر'),
    ('🇲🇦', 'المغرب'),
    ('🇩🇯', 'جيبوتي'),
    ('🇸🇴', 'الصومال'),
    ('🇰🇲', 'جزر القمر'),
  ];

  // ───────────────────────── مكوّنات مساعدة ─────────────────────────

  Widget _sectionLabel(ThemeData theme, String text, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  /// صف داخل بطاقة «موقعك الحالي».
  Widget _hierarchyRow(
    ThemeData theme, {
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      overlayColor: WidgetStatePropertyAll(
        theme.colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }

  String _distanceLabel(double km) {
    if (km < 1) return 'أقل من 1 كم';
    if (km < 100) return '${km.toStringAsFixed(0)} كم';
    return '${(km / 10).round() * 10} كم';
  }

  void _select(BuildContext context, _PlaceEntry entry) {
    final city = AppCity(
      name: entry.name,
      areas: [entry.region.nameAr, entry.region.capitalAr],
      lat: entry.lat,
      lng: entry.lng,
      mrRegion: entry.region,
    );
    context.read<LocationController>().setCity(city);
    context.pop();
  }

  // ───────────────────────── شاشة الدول ─────────────────────────

  void _showCountriesSheet(BuildContext context) {
    final theme = Theme.of(context);
    showAppSheet(
      context,
      scrollControlled: false,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'اختر الدولة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_cardRadius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _arabCountries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final (flag, name) = _arabCountries[index];
                      final active = name == 'موريتانيا';
                      return InkWell(
                        onTap: active
                            ? () => Navigator.of(sheetContext).pop()
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 2,
                          ),
                          child: Row(
                            children: [
                              Text(flag, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? null
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.45),
                                  ),
                                ),
                              ),
                              if (!active)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    'قريباً',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── البناء ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = context.watch<LocationController>();

    // موقع المستخدم الفعلي: GPS الحي إن وُجد، وإلا مركز المدينة المختارة.
    final point = location.activeLatLng;
    final nearestRegion = MauritaniaRegions.nearestRegion(point);
    final nearestDistrict =
        MauritaniaRegions.nearestDistrict(nearestRegion, point);

    // ترتيب كل الأماكن حسب المسافة (تُحسب مرة واحدة لكل عنصر).
    const distCalc = Distance();
    final km = <_PlaceEntry, double>{
      for (final e in _entries)
        e: distCalc.as(LengthUnit.Kilometer, point, LatLng(e.lat, e.lng)),
    };
    final sorted = List<_PlaceEntry>.from(_entries)
      ..sort((a, b) => km[a]!.compareTo(km[b]!));
    final shown = sorted.take(_visibleCount).toList();

    final ink = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── العنوان ──
          Center(
            child: Column(
              children: [
                Text(
                  'اختر موقعك',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'لنعرض لك الأقرب إليك أولاً',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── زر GPS: لون الحبر بدل الأزرق ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                foregroundColor: theme.colorScheme.surface,
                disabledBackgroundColor: ink.withValues(alpha: 0.12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: location.isLocating
                  ? null
                  : () async {
                      await context.read<LocationController>().locateMe();
                      if (context.mounted) context.pop();
                    },
              icon: location.isLocating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ink.withValues(alpha: 0.5),
                      ),
                    )
                  : const Icon(LucideIcons.locateFixed, size: 18),
              label: Text(
                location.isLocating
                    ? 'جارٍ تحديد موقعك…'
                    : 'استخدم موقعي الحالي',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── بطاقة موقعك الحالي: دولة ← ولاية ← مقاطعة ──
          _sectionLabel(theme, 'موقعك الحالي'),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_cardRadius),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  _hierarchyRow(
                    theme,
                    label: 'الدولة',
                    value: 'موريتانيا 🇲🇷',
                    trailing: LucideIcons.chevronDown,
                    onTap: () => _showCountriesSheet(context),
                  ),
                  _hierarchyRow(
                    theme,
                    label: 'الولاية',
                    value: nearestRegion.nameAr,
                    onTap: () => _select(
                      context,
                      _entries.firstWhere(
                        (e) => e.isRegion && e.name == nearestRegion.nameAr,
                      ),
                    ),
                  ),
                  if (nearestDistrict != null) ...[
                      _hierarchyRow(
                      theme,
                      label: 'المقاطعة',
                      value: nearestDistrict.nameAr,
                      onTap: () => _select(
                        context,
                        _entries.firstWhere(
                          (e) =>
                              !e.isRegion && e.name == nearestDistrict.nameAr,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(
            height: 1,
            thickness: 1,
            color: ink.withValues(alpha: 0.12),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── الأقرب إليك ──
          _sectionLabel(
            theme,
            'الأقرب إليك',
            trailing: '${_entries.length} موقعاً',
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: shown.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                // زر «عرض المزيد» كآخر عنصر.
                if (index == shown.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _showMore,
                        icon: const Icon(LucideIcons.chevronDown, size: 18),
                        label: Text(
                          'عرض المزيد · ${_entries.length - _visibleCount} متبقٍ',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ink,
                          side: BorderSide.none,
                          backgroundColor: ink.withValues(alpha: 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final entry = shown[index];

                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    overlayColor: WidgetStatePropertyAll(
                      ink.withValues(alpha: 0.08),
                    ),
                    onTap: () => _select(context, entry),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                            Text(
                              _distanceLabel(km[entry]!),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}