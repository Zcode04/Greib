import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../permissions/permissions.dart';
import '../theme/app_colors.dart';
import '../widgets/super_header.dart';
import '../../shared_widgets/account_tabs_page.dart';
import '../../features/auth/auth_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboards/admin_dashboard_screen.dart';
import '../../features/dashboards/agent_dashboard_screen.dart';
import '../../features/communication_and_support/notifications_screen.dart';
import '../../features/communication_and_support/support_tickets_screen.dart';
import '../../features/communication_and_support/chat_screen.dart';
import '../../features/communication_and_support/alhadheq_chat_screen.dart';
import '../../features/location_and_tracking/tracking_screen.dart';
import '../../features/location_and_tracking/maps_screen.dart';
import '../../features/location_and_tracking/my_location_screen.dart';
import '../../features/home_and_services/search_screen.dart';
import '../../features/home_and_services/reels_screen.dart';
import '../../features/liveserver/liveserver_screen.dart';
import '../../features/services/presentation/account_connections_page.dart';
import '../../features/services/presentation/account_profile_page.dart';
import '../../features/services/presentation/service_details_page.dart';
import '../../features/settings/color_settings_screen.dart';
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

  /// بادئة مسار صفحة الحساب/المتجر (Path Parameter).
  static const String _accountRoutePrefix = '/account/';

  /// مسارات داخلية رئيسية معروفة.
  static final Set<String> _knownRoutes = {
    '/home',
    '/notifications',
    '/tracking',
    '/orders',
    '/search',
    '/reels',
    // ★ صفحة «البث المباشر» (Live Server) — تُفتح من تبويب الشريط السفلي.
    '/liveserver',
    '/settings',
    '/doctors',
    '/support',
    '/maps',
    // ★ صفحة «موقعي» (العالم + الأقرب إليك) — تفتح من تبويب الشريط السفلي.
    '/my_location',
    '/wallet',
    '/favorites',
    '/profile',
    '/chat',
    '/alhadheq',
    '/shopping',
    // ★ صفحة «التحكم في الألوان» — تخصيص الخلفية/النصوص/الأيقونات.
    '/color-settings',
  };

  // ★ دخول مباشر: لا يُعاد توجيه غير المسجّلين إلى شاشة تسجيل الدخول كـ
  //   Route مستقل. بدلاً من ذلك يُفتح التطبيق مباشرة على /home وتظهر نموذج
  //   تسجيل الدخول كـ *إشعار اخافي* (modal) فوق الواجهة يمكن إغلاقه —
  //   ويُظهر مرة واحدة لكل جلسة عند عدم تسجيل الدخول. التطوير الكامل للهوية
  //   يُؤوّد لاحقاً.
  static String? resolveRedirect(String location) {
    if (_publicRoutes.contains(location)) return null;

    final auth = AuthService.instance;
    // (تمت إزالة إعادة التوجيه الإجبارية إلى /login — الدخول الآن مباشر.)

    // صفحة الخدمة الواحدة: أي مسار يبدأ بـ /service/ يُعتبر معروفاً
    // لأن موضع الـ :id يتغيّر حسب الخدمة المختارة.
    if (location.startsWith(_serviceRoutePrefix)) return null;

    // ★ نفس المنطق لصفحات البروفايل: /account/:id
    //   (بادئة + معرّف متغيّر ⇒ لا يمكن listingها في _knownRoutes).
    //   كانت هذه المسارات محجوبة وتُعاد إلى /home، فصارت مفتوحة الآن.
    if (location.startsWith(_accountRoutePrefix)) return null;

    if (_knownRoutes.contains(location)) return null;
    if (PermissionService.canAccess(auth.currentRole, location)) return null;

    return '/home';
  }

  static String? _guard(GoRouterState state) =>
      resolveRedirect(state.matchedLocation);

  /// الراوتر المستخدم في التطبيق.
  static final GoRouter router = createRouter();

  static GoRouter createRouter({String initialLocation = '/home'}) => GoRouter(
        initialLocation: initialLocation,
        redirect: (context, state) => _guard(state),
        routes: [
          // ★ /login كـ modal (fullscreenDialog) يظهر فوق الواجهة كإشعار
          //   اخافي بدلاً من شاشة مستقلة تحلّ محل الواجهة — يُمكن إغلاقه
          //   أو التخطيه بدلاً من منع الدخول.
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: const LoginScreen(),
            ),
          ),
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
      GoRoute(path: '/reels', builder: (context, state) => const ReelsScreen()),
      // ★ صفحة «البث المباشر» (Live Server) — تُفتح من تبويب الشريط السفلي.
      GoRoute(
        path: '/liveserver',
        builder: (context, state) => const LiveserverScreen(),
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
      // ★ صفحة الدردشة مستقلة: تُفتح من زر «تواصل الآن» في قسم «موقعي»
      //   (تبويب الدردشة في الشريط السفلي يعرض نفس الشاشة داخل الـ Shell).
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      // ★ صفحة المساعد الذكي «الحاذق» (AI Chat)
      GoRoute(
        path: '/alhadheq',
        builder: (context, state) => const AlhadheqChatScreen(),
      ),
      GoRoute(
        path: '/my_location',
        builder: (context, state) => const MyLocationScreen(),
      ),
      // ★ صفحة الحساب: كانت تبويباً في الشريط السفلي، والآن تُفتح من أيقونة
      //   الحساب في الهيدر (تبويب «موقعي» حلّ مكانها في الشريط).
      //   ★ الصفحة تحوي تبويبين: «الملف الشخصي» و«المحفظة» (AccountTabsPage).
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.background
                : AppColors.lightBackground,
            appBar: SuperHeader(showBackButton: true),
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: const AccountTabsPage(),
          );
        },
      ),
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
      // ★ صفحة التحكم في الألوان (تخصيص اللوحة المركزية فورياً).
      GoRoute(
        path: '/color-settings',
        builder: (context, state) => const ColorSettingsScreen(),
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
      // ===== صفحة الحساب/المتجر: /account/:id (معرّف = serviceId + :: + البذرة) =====
      // تُفتح بالضغط على صورة أي بروفايل في شريط «الحسابات» أسفل صفحة الخدمة.
      GoRoute(
        path: '/account/:id',
        name: 'accountProfile',
        builder: (context, state) =>
            AccountProfilePage(accountId: state.pathParameters['id'] ?? ''),
      ),
      // ===== شبكة علاقات الحساب: /account/:id/connections =====
      // ?tab=0 (المتابِعون) | 1 (يتابع) | 2 (متابِعون مشتركون).
      GoRoute(
        path: '/account/:id/connections',
        name: 'accountConnections',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return AccountConnectionsPage(
            accountId: state.pathParameters['id'] ?? '',
            initialTab: tab,
          );
        },
      ),
    ],
  );
}
