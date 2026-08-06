import 'package:flutter/material.dart';
import '../core/mock_data/mock_data.dart';

// بطاقة خدمة مركزية تُستخدم في الصفحة الرئيسية
class CentralServiceCard extends StatelessWidget {
  final ServiceCategory service;
  final VoidCallback? onTap;

  const CentralServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // حاوية الأيقونة
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  MockData.getIconByName(service.iconName),
                  color: service.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              // عنوان الخدمة
              Text(
                service.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              // وصف الخدمة
              Text(
                service.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شبكة بطاقات الخدمات
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
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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