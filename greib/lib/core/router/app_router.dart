import 'package:go_router/go_router.dart';

import '../permissions/permissions.dart';
import '../../features/auth/auth_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboards/admin_dashboard_screen.dart';
import '../../features/dashboards/agent_dashboard_screen.dart';
import '../../features/communication_and_support/notifications_screen.dart';
import '../../features/communication_and_support/support_tickets_screen.dart';
import '../../features/location_and_tracking/tracking_screen.dart';
import '../../features/location_and_tracking/maps_screen.dart';
import '../../features/home_and_services/search_screen.dart';
import '../../features/services/presentation/provider_profile_page.dart';
import '../../features/services/presentation/service_details_page.dart';
import '../../shared_widgets/coming_soon_screen.dart';
import '../../shared_widgets/main_shell_screen.dart';

/// ============================================================================
///  AppRouter — خريطة التنقل المجمعة والمنظمة + حماية الصلاحيات.
/// ============================================================================
class AppRouter {
  /// مسارات متاحة قبل تسجيل الدخول.
  static const _publicRoutes = {'/login'};

  /// بادئة مسار صفحة الخدمة الواحد (Path Parameter).
  static const String _serviceRoutePrefix = '/service/';

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
  };

  static String? resolveRedirect(String location) {
    if (_publicRoutes.contains(location)) return null;

    final auth = AuthService.instance;
    if (!auth.isLoggedIn) return '/login';

    // صفحة الخدمة الواحدة: أي مسار يبدأ بـ /service/ يُعتبر معروفاً
    // لأن موضع الـ :id يتغيّر حسب الخدمة المختارة.
    if (location.startsWith(_serviceRoutePrefix)) return null;

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
      // ===== مسار واحد لكل الخدمات: /service/:id =====
      // إضافة خدمة جديدة = إضافة عنصر في assets/data/services.json فقط،
      // بدون أي تعديل في هذا الملف (Single Route / Parameterized Route).
      GoRoute(
        path: '/service/:id',
        name: 'serviceDetails',
        builder: (context, state) =>
            ServiceDetailsPage(serviceId: state.pathParameters['id'] ?? ''),
      ),
      // ===== صفحة مقدم الخدمة: /provider/:id (معرّف = serviceId + _p + فهرس) =====
      GoRoute(
        path: '/provider/:id',
        name: 'providerProfile',
        builder: (context, state) =>
            ProviderProfilePage(providerId: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
}
