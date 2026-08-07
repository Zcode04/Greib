import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import '../core/mock_data/mock_data.dart';

class CentralServiceCard extends StatefulWidget {
  final ServiceCategory service;
  final VoidCallback? onTap;

  const CentralServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  State<CentralServiceCard> createState() => _CentralServiceCardState();
}

class _CentralServiceCardState extends State<CentralServiceCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _animatePress(true),
      onTapUp: (_) => _animatePress(false),
      onTapCancel: () => _animatePress(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: service.color.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: service.color.withValues(alpha: 0.05),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        service.color.withValues(alpha: 0.2),
                        service.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: service.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    MockData.getIconByName(service.iconName),
                    color: service.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  service.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  service.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _animatePress(bool isPressed) {
    setState(() {
      _scale = isPressed ? 0.95 : 1.0;
    });
  }
}

class ServicesGrid extends StatelessWidget {
  final List<ServiceCategory> services;
  final Function(ServiceCategory)? onServiceTap;

  const ServicesGrid({
    super.key,
    required this.services,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return CentralServiceCard(
          service: service,
          onTap: onServiceTap != null
              ? () => onServiceTap!(service)
              : () => Navigator.pushNamed(context, service.route),
        );
      },
    );
  }
}