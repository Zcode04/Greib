import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/design_tokens.dart';

/// ============================================================================
///  SuperAppGrid — شبكة الخدمات السريعة (8 خانات) على غرار Careem/Grab:
///   أيقونة ملونة + اسم الخدمة → تفتح الميزة مباشرة.
/// ============================================================================

class _QuickTile {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class SuperAppGrid extends StatelessWidget {
  const SuperAppGrid({super.key});

  static const List<_QuickTile> _tiles = [
    _QuickTile(
      label: 'طعام',
      icon: LucideIcons.utensils,
      color: AppColors.serviceFood,
      route: '/food',
    ),
    _QuickTile(
      label: 'الصيدلية',
      icon: LucideIcons.pill,
      color: AppColors.servicePharmacy,
      route: '/pharmacy',
    ),
    _QuickTile(
      label: 'المواصلات',
      icon: LucideIcons.car,
      color: AppColors.serviceRide,
      route: '/ride',
    ),
    _QuickTile(
      label: 'التسوق',
      icon: LucideIcons.shoppingCart,
      color: AppColors.serviceShopping,
      route: '/shopping',
    ),
    _QuickTile(
      label: 'السياحة',
      icon: LucideIcons.palmtree,
      color: AppColors.serviceTourism,
      route: '/tourism',
    ),
    _QuickTile(
      label: 'السفر',
      icon: LucideIcons.plane,
      color: AppColors.serviceTravel,
      route: '/travel',
    ),
    _QuickTile(
      label: 'المحفظة',
      icon: LucideIcons.wallet,
      color: AppColors.accentPrimary,
      route: '/wallet',
    ),
    _QuickTile(
      label: 'كل الخدمات',
      icon: LucideIcons.layoutGrid,
      color: AppColors.accentPrimaryDark,
      route: '/services',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) => _QuickTileView(tile: _tiles[index]),
    );
  }
}

class _QuickTileView extends StatelessWidget {
  final _QuickTile tile;

  const _QuickTileView({required this.tile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: () => context.push(tile.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tile.color.withValues(alpha: isDark ? 0.18 : 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: tile.color.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(tile.icon, size: 22, color: tile.color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tile.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}