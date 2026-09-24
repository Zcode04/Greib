import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/travel_model.dart';

class TravelSection extends StatelessWidget {
  final bool isDark;

  const TravelSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final destinations = MockData.mockTravelDestinations;
    return SizedBox(
      height: 240,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, i) => _travelItem(context, destinations[i]),
      ),
    );
  }

  Widget _travelItem(BuildContext context, TravelDestination dest) {
    return GestureDetector(
      onTap: () => context.push('/travel'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  dest.imageUrl,
                  fit: BoxFit.cover,
                  // خلفية بديلة أنيقة بدل مساحة فارغة عند تعذّر تحميل الصورة.
                  errorBuilder: (_, _, _) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.serviceRide.withValues(alpha: 0.45),
                          AppColors.accentPrimaryDark,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.plane,
                        size: 32,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 16,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dest.country,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.tag,
                          color: AppColors.accentPrimary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dest.price} درهم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Top Right - Type badge
              Positioned(
                top: 12,
                right: 12,
                child: GlassContainer.frosted(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  opacity: 0.2,
                  child: Text(
                    'رحلة ذهاب وعودة', // mock label
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
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
