import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';

class HeroBanner extends StatelessWidget {
  final bool isDark;

  const HeroBanner({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer.frosted(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(28),
      color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
      opacity: 0.2,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اكتشف خدماتنا\nالجديدة',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.onAccentPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('استكشف الآن',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Icon(
              LucideIcons.sparkles,
              color: isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark,
              size: 72,
            ),
          ),
        ],
      ),
    );
  }
}
