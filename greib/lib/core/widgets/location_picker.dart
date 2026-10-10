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
/// تعرض «موريتانيا» كدولة محددة، ثم جميع الولايات والمقاطعات مرتبة
/// (كل ولاية تليها مقاطعاتها) بتحميل تدريجي: 5 عناصر أولاً وزر
/// «عرض المزيد» يجلب المزيد حتى نهاية القائمة.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  /// عدد العناصر التي تظهر في البداية وفي كل ضغطة «عرض المزيد».
  static const int _pageSize = 5;

  int _visibleCount = _pageSize;

  /// قائمة مسطّحة مرتبة: كل ولاية تليها مقاطعاتها مباشرة.
  static final List<_PlaceEntry> _entries = [
    for (final r in MauritaniaRegions.regions) ...[
      _PlaceEntry(
        name: r.nameAr,
        subtitle: 'ولاية · العاصمة: ${r.capitalAr}',
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
            children: [
              Text(
                'اختر الدولة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _arabCountries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final (flag, name) = _arabCountries[index];
                    final isMauritania = name == 'موريتانيا';
                    return Material(
                      color: isMauritania
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: isMauritania
                            ? () => Navigator.of(sheetContext).pop()
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Text(flag, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isMauritania
                                        ? null
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (isMauritania)
                                Icon(
                                  LucideIcons.check,
                                  size: 18,
                                  color: theme.colorScheme.onSurface,
                                )
                              else
                                Text(
                                  'قريباً',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
      },
    );
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

  /// صف كبسولة لملخص الموقع: «المقاطعة: كنكوصة» / «الولاية: لعصابة» / «الدولة: موريتانيا».
  Widget _summaryPill(
    ThemeData theme, {
    required String label,
    required String value,
    IconData? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Text(
                '$label: ',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = context.watch<LocationController>();

    // موقع المستخدم الفعلي: GPS الحي إن وُجد، وإلا مركز المدينة المختارة.
    final point = location.activeLatLng;
    final nearestRegion = MauritaniaRegions.nearestRegion(point);
    final nearestDistrict =
        MauritaniaRegions.nearestDistrict(nearestRegion, point);

    // «الأقرب لمنطقتك»: كل الولايات والمقاطعات مرتبة حسب المسافة من الموقع.
    const distCalc = Distance();
    double kmTo(_PlaceEntry e) => distCalc.as(
        LengthUnit.Kilometer, point, LatLng(e.lat, e.lng));
    final sorted = List<_PlaceEntry>.from(_entries)
      ..sort((a, b) => kmTo(a).compareTo(kmTo(b)));
    final shown = sorted.take(_visibleCount).toList();

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
              'اختر موقعك',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // ★ زر GPS الحقيقي.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: location.isLocating
                  ? null
                  : () async {
                      await context
                          .read<LocationController>()
                          .locateMe();
                      if (context.mounted) context.pop();
                    },
              icon: location.isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.locateFixed, size: 18),
              label: Text(location.isLocating
                  ? 'جارٍ تحديد موقعك…'
                  : 'استخدم موقعي الحالي 📍'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // ★ ملخص الموقع الحالي من الإحداثيات: مقاطعة ← ولاية ← دولة.
          Text(
            'موقعك الحالي هو:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (nearestDistrict != null) ...[
            _summaryPill(
              theme,
              label: 'المقاطعة',
              value: nearestDistrict.nameAr,
              onTap: () => _select(
                context,
                _entries.firstWhere(
                  (e) => !e.isRegion && e.name == nearestDistrict.nameAr,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _summaryPill(
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
          const SizedBox(height: AppSpacing.sm),
          _summaryPill(
            theme,
            label: 'الدولة',
            value: 'موريتانيا 🇲🇷',
            trailing: LucideIcons.chevronDown,
            onTap: () => _showCountriesSheet(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'الأقرب لمنطقتك:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: shown.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                // زر «عرض المزيد» كآخر عنصر في القائمة.
                if (index == shown.length) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showMore,
                      icon: const Icon(LucideIcons.chevronDown, size: 18),
                      label: Text(
                        'عرض المزيد (${_entries.length - _visibleCount} متبقٍ)',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  );
                }

                final entry = shown[index];
                final selected = entry.name == location.cityName;

                return Material(
                  color: selected
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    onTap: () => _select(context, entry),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${entry.subtitle} · ${entry.lat.toStringAsFixed(4)}، ${entry.lng.toStringAsFixed(4)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(
                              LucideIcons.check,
                              size: 20,
                              color: theme.colorScheme.onSurface,
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
