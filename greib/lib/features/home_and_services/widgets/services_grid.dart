import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/service_model.dart';

class ServicesGridSection extends StatelessWidget {
  final bool isDark;
  final bool isGridView;

  const ServicesGridSection({
    super.key,
    required this.isDark,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context) {
    final services = MockData.services;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isGridView
          ? _buildServicesGrid(context, services)
          : _buildServicesHorizontalList(context, services),
    );
  }

  Widget _buildServicesHorizontalList(BuildContext context, List<ServiceCategory> services) {
    return SizedBox(
      key: const ValueKey('services_row'),
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => SizedBox(
          width: 158,
          child: _serviceBigCard(context, services[i]),
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<ServiceCategory> services) {
    return GridView.builder(
      key: const ValueKey('services_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, i) => _serviceBigCard(context, services[i]),
    );
  }

  Widget _serviceBigCard(BuildContext context, ServiceCategory s) {
    final accentColor = isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      opacity: isDark ? 0.05 : 0.08,
      child: InkWell(
        onTap: () => context.push(s.route),
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.14 : 0.12),
                shape: BoxShape.circle,
              ),
              child: s.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        s.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          MockData.getIconByName(s.iconName),
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    )
                  : Icon(MockData.getIconByName(s.iconName),
                      color: accentColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              s.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
