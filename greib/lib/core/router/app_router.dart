import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../mock_data/mock_data.dart';
import '../permissions/permissions.dart';
import '../theme/design_tokens.dart';
import '../../features/auth/auth_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboards/admin_dashboard_screen.dart';
import '../../features/dashboards/agent_dashboard_screen.dart';
import '../../features/communication_and_support/notifications_screen.dart';
import '../../features/communication_and_support/support_tickets_screen.dart';
import '../../features/location_and_tracking/tracking_screen.dart';
import '../../features/location_and_tracking/maps_screen.dart';
import '../../features/home_and_services/search_screen.dart';
import '../../shared_widgets/coming_soon_screen.dart';
import '../../shared_widgets/detail_page_template.dart';
import '../../shared_widgets/main_shell_screen.dart';

/// ============================================================================
///  AppRouter — خريطة التنقل المجمعة والمنظمة + حماية الصلاحيات.
/// ============================================================================
class AppRouter {
  /// مسارات متاحة قبل تسجيل الدخول.
  static const _publicRoutes = {'/login'};

  /// مسارات داخلية رئيسية معروفة.
  static final Set<String> _knownRoutes = {
    '/home',
    '/notifications',
    '/tracking',
    '/orders',
    '/search',
    '/settings',
    '/doctors',
    '/support',
    '/maps',
    '/wallet',
    '/favorites',
    '/profile',
    '/chat',
    '/shopping',
    ...MockData.services.map((service) => service.route),
  };

  static String? resolveRedirect(String location) {
    if (_publicRoutes.contains(location)) return null;

    final auth = AuthService.instance;
    if (!auth.isLoggedIn) return '/login';

    if (_knownRoutes.contains(location)) return null;
    if (PermissionService.canAccess(auth.currentRole, location)) return null;

    return '/home';
  }

  static String? _guard(GoRouterState state) =>
      resolveRedirect(state.matchedLocation);

  /// الراوتر المستخدم في التطبيق.
  static final GoRouter router = createRouter();

  static GoRouter createRouter({String initialLocation = '/login'}) => GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) => _guard(state),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/admin_dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/agent_dashboard',
        builder: (context, state) => const AgentDashboardScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportTicketsScreen(),
      ),
      GoRoute(path: '/maps', builder: (context, state) => const MapsScreen()),
      // صفحات عامة مؤقتة: تمنع الكراش عند فتح أقسام ما زالت قيد التطوير.
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ComingSoonScreen(
          title: 'التسوق',
          subtitle: 'قسم المنتجات والعروض سيتوفر قريباً.',
          route: '/shopping',
        ),
      ),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => const ComingSoonScreen(
          title: 'الأطباء',
          subtitle: 'قائمة الأطباء والحجوزات ستتوفر قريباً.',
          route: '/doctors',
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const ComingSoonScreen(
          title: 'طلباتك',
          subtitle: 'سجل الطلبات الكامل سيتوفر قريباً.',
          route: '/orders',
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ComingSoonScreen(
          title: 'الإعدادات',
          subtitle: 'صفحة الإعدادات ستتوفر قريباً.',
          route: '/settings',
        ),
      ),
      // جميع مسارات الخدمات الأخرى تفتح صفحة تفصيلية عامة مبنية من MockData.
      ...MockData.services
          .where(
            (s) =>
                s.route != '/maps' &&
                s.route != '/shopping' &&
                s.route != '/notifications' &&
                s.route != '/tracking' &&
                s.route != '/support' &&
                s.route != '/search' &&
                s.route != '/home',
          )
          .map(
            (s) => GoRoute(
              path: s.route,
              builder: (context, state) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return DetailPageTemplate(
                  title: s.title,
                  subtitle: s.subtitle,
                  icon: MockData.getIconByName(s.iconName),
                  accentColor: s.color,
                  description:
                      'خدمة ${s.title} (${s.subtitle}) متاحة الآن كصفحة تجريبية ضمن النسخة الحالية. سيتم ربط الحجز والدفع هنا لاحقاً.',
                  primaryActionLabel: 'اطلب الآن',
                  secondaryActionLabel: 'أضف للمفضلة',
                  onPrimaryAction: () => context.push('/tracking'),
                  onSecondaryAction: () => context.push('/search'),
                  extraContent: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: s.color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.badgeCheck, size: 18, color: s.color),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            isDark
                                ? 'صفحة الخدمة تعمل بدون كراش في الوضع الليلي والنهاري.'
                                : 'صفحة الخدمة تعمل بدون كراش في الوضع النهاري والليلي.',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    ],
  );
}
