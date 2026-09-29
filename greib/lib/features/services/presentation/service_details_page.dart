import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/mock_data/mock_data.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared_widgets/app_button.dart';
import '../../../shared_widgets/smart_image.dart';
import '../data/services_repository.dart';

/// ============================================================================
///  ServiceDetailsPage — صفحة تفاصيل الخدمة (Single Route).
///
///  تُستدعى عبر المسار الواحد:  /service/:id
///  مثال:  context.push('/service/food')
///
///  كل شيء فيها يأتي من ServicesRepository ← assets/data/services.json
///  لذلك الصفحة واحدة تخدم كل الخدمات، ويتغيّر الشكل حسب بيانات كل خدمة.
/// ============================================================================
class ServiceDetailsPage extends StatelessWidget {
  /// معرّف الخدمة القادم من المسار (Path Parameter).
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final service = ServicesRepository.instance.byId(serviceId);

    // معرّف غير معروف — حماية بدل كراش.
    if (service == null) return const _ServiceNotFound();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = service.color;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ---------- الخلفية مع توهج لون الخدمة ----------
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            accent.withValues(alpha: 0.08),
                            AppColors.backgroundPrimary,
                            AppColors.backgroundPrimary,
                          ]
                        : [
                            accent.withValues(alpha: 0.06),
                            AppColors.lightBackground,
                            AppColors.lightBackground,
                          ],
                  ),
                ),
              ),
            ),

            // ---------- المحتوى ----------
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, service, isDark),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme, service),
                          const SizedBox(height: AppSpacing.lg),
                          _buildChips(service),
                          const SizedBox(height: AppSpacing.xl),
                          _buildDescription(theme, service),
                          if (service.imageUrls.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xl),
                            _buildGallery(service),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          _buildActions(context, accent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================ AppBar + Hero ============================
  Widget _buildAppBar(
    BuildContext context,
    ServiceCategory service,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor:
          isDark ? AppColors.backgroundPrimary : AppColors.lightBackground,
      leading: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceCard.withValues(alpha: 0.9)
              : AppColors.lightSurface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.outline : AppColors.lightOutline,
          ),
        ),
        child: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 18),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                service.color.withValues(alpha: 0.25),
                service.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppRadii.xxl),
            ),
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.xxl),
                border: Border.all(
                  color: service.color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: AppShadows.brandGlow,
              ),
              child: Icon(
                MockData.getIconByName(service.iconName),
                size: 56,
                color: service.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================ العنوان ============================
  Widget _buildHeader(ThemeData theme, ServiceCategory service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          service.subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // =================== صف السعر / الوقت / التقييم ===================
  Widget _buildChips(ServiceCategory service) {
    final chips = <Widget>[
      if (service.price != null)
        _DetailChip(
          icon: LucideIcons.wallet,
          label: service.price!,
          color: service.color,
        ),
      if (service.deliveryTime != null) ...[
        const SizedBox(width: AppSpacing.sm),
        _DetailChip(
          icon: LucideIcons.clock,
          label: service.deliveryTime!,
          color: AppColors.info,
        ),
      ],
      if (service.rating != null) ...[
        const SizedBox(width: AppSpacing.sm),
        _DetailChip(
          icon: LucideIcons.star,
          label: service.rating!,
          color: AppColors.warning,
        ),
      ],
    ];

    if (chips.isEmpty) return const SizedBox.shrink();
    return Row(children: chips);
  }

  // ============================ الوصف ============================
  Widget _buildDescription(ThemeData theme, ServiceCategory service) {
    if (service.description.isEmpty) return const SizedBox.shrink();
    return Text(
      service.description,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ============================ معرض الصور ============================
  Widget _buildGallery(ServiceCategory service) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: service.imageUrls.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) => ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: SmartImage(
            src: service.imageUrls[i],
            placeholder: Container(
              width: 200,
              color: service.color.withValues(alpha: 0.1),
              child: Icon(
                LucideIcons.image,
                color: service.color,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================ الأزرار ============================
  Widget _buildActions(BuildContext context, Color accent) {
    return Column(
      children: [
        // زر «اطلب الآن» — السلوك مؤقت (وهمي) حتى ربط الخدمات السحابية.
        AppButton(
          label: 'اطلب الآن',
          icon: LucideIcons.arrowRight,
          onPressed: () => context.push('/tracking'),
        ),
        const SizedBox(height: AppSpacing.md),
        // زر «أضف للمفضلة» — السلوك مؤقت (وهمي) حتى ربط التخزين الحقيقي.
        AppButton(
          label: 'أضف للمفضلة',
          icon: LucideIcons.heart,
          isOutlined: true,
          onPressed: () => context.push('/search'),
        ),
      ],
    );
  }
}

// ============================ شريحة التفاصيل ============================
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ خدمة غير موجودة ============================
class _ServiceNotFound extends StatelessWidget {
  const _ServiceNotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundPrimary : AppColors.lightBackground,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.searchX,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'الخدمة غير موجودة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'ربما تم تغيير الرابط أو حذف الخدمة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
