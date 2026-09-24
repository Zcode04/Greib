import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_service.dart';
import '../../shared_widgets/animated_background.dart';
import '../../shared_widgets/featured_products_section.dart';
import '../../shared_widgets/glass_container.dart';
import '../../shared_widgets/section_header.dart';
import '../../shared_widgets/animated_list_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Widgets
import 'widgets/hero_banner.dart';
import 'widgets/spotlight_carousel.dart';
import 'widgets/services_grid.dart';
import 'widgets/hotels_section.dart';
import 'widgets/travel_section.dart';
import 'widgets/doctors_row.dart';
import 'widgets/orders_list.dart';
import 'widgets/quick_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isServicesGridView = false;

  @override
  Widget build(BuildContext context) {

    final role = AuthService.instance.currentRole;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      // القائمة الجانبية (Drawer) انتقلت إلى MainShellScreen — مصدر واحد للتنقل.
      body: Stack(
        children: [
          const AnimatedBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedListItem(index: 0, child: HeroBanner(isDark: isDark)),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 1,
                  child: SectionHeader(
                    title: 'المميز عندنا',
                    icon: LucideIcons.sparkles,
                    iconColor: AppColors.accentFor(isDark),
                    showAction: false,
                  ),
                ),
                AnimatedListItem(index: 1, child: SpotlightSection(isDark: isDark)),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 2,
                  child: SectionHeader(
                    title: 'الفنادق المختارة',
                    icon: LucideIcons.hotel,
                    iconColor: AppColors.serviceTourism,
                    onActionTap: () => context.push('/tourism'),
                  ),
                ),
                AnimatedListItem(index: 2, child: HotelsSection(isDark: isDark)),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 3,
                  child: SectionHeader(
                    title: 'وجهات سفر مميزة',
                    icon: LucideIcons.plane,
                    iconColor: AppColors.serviceRide,
                    onActionTap: () => context.push('/travel'),
                  ),
                ),
                AnimatedListItem(index: 3, child: TravelSection(isDark: isDark)),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 4,
                  child: SectionHeader(
                    title: 'تعرف على أطبائنا',
                    icon: LucideIcons.stethoscope,
                    iconColor: AppColors.info,
                    onActionTap: () => context.push('/doctors'),
                  ),
                ),
                AnimatedListItem(index: 4, child: DoctorsRow(isDark: isDark)),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SectionHeader(
                          title: 'ولدينا المزيد',
                          icon: LucideIcons.layoutGrid,
                          iconColor: AppColors.accentFor(isDark),
                          showAction: false,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(
                            () => _isServicesGridView = !_isServicesGridView),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isServicesGridView ? 'عرض أقل' : 'عرض المزيد',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.accentPrimary
                                      : AppColors.accentPrimaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isServicesGridView
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown,
                                size: 14,
                                color: isDark
                                    ? AppColors.accentPrimary
                                    : AppColors.accentPrimaryDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedListItem(
                  index: 5,
                  child: ServicesGridSection(isDark: isDark, isGridView: _isServicesGridView),
                ),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 6,
                  child: SectionHeader(
                    title: 'منتجات مختارة لك',
                    icon: LucideIcons.shoppingBag,
                    iconColor: AppColors.serviceShopping,
                    onActionTap: () => context.push('/shopping'),
                  ),
                ),
                const AnimatedListItem(index: 6, child: FeaturedProductsSection()),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 7,
                  child: SectionHeader(
                    title: 'طلباتك الحالية',
                    icon: LucideIcons.package,
                    iconColor: AppColors.warning,
                    actionTitle: 'كل الطلبات',
                    onActionTap: () => context.push('/orders'),
                  ),
                ),
                AnimatedListItem(index: 7, child: OrdersList(isDark: isDark)),

                if (role == UserRole.admin || role == UserRole.agent) ...[
                  const SizedBox(height: 28),
                  AnimatedListItem(
                    index: 8,
                    child: SectionHeader(
                      title: 'صفحات سريعة',
                      icon: LucideIcons.settings,
                      iconColor: AppColors.textSecondary,
                      showAction: false,
                    ),
                  ),
                  AnimatedListItem(index: 8, child: QuickActions(role: role)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

}