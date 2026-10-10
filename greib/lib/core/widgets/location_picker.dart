import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../location/location_controller.dart';
import '../theme/design_tokens.dart';
import 'confirm_location_sheet.dart';

/// LocationPickerSheet — اختيار المدينة + موقع GPS الحقيقي.
/// تُفتح من SuperHeader وتُحدّث LocationController مباشرة.
class LocationPickerSheet extends StatelessWidget {
  const LocationPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = context.watch<LocationController>();

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
              'اختر ولايتك',
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
          // عنوان GPS الحالي + زر الخريطة.
          if (location.hasGpsFix && location.currentAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                onTap: () async {
                  context.pop();
                  await ConfirmLocationSheet.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin,
                          size: 16,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location.currentAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(LucideIcons.chevronLeft,
                          size: 16,
                          color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: LocationController.cities.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final city = LocationController.cities[index];
                final selected = city.name == location.cityName;

                return Material(
                  color: selected
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    onTap: () {
                      context.read<LocationController>().setCity(city);
                      context.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.mapPin,
                              size: 19,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  // ★ اسم العاصمة + إحداثيات ثابتة بجانبها.
                                  '${city.areas.isNotEmpty ? city.areas.first : ''} · ${city.lat.toStringAsFixed(4)}، ${city.lng.toStringAsFixed(4)}',
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
                              color: theme.colorScheme.primary,
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