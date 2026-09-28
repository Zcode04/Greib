import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/mock_data/mock_data.dart';
import '../core/permissions/permissions.dart';
import '../core/storage/app_prefs.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/auth_service.dart';
import '../features/communication_and_support/chat_screen.dart';
import '../features/home_and_services/home_screen.dart';
import '../features/wallet_and_finance/wallet_screen.dart';
import '../core/widgets/super_header.dart'; // تمت الإضافة
import 'floating_bottom_nav.dart';
import 'profile_widget.dart';

class _ShellTab {
  final String route;
  final String title;
  final IconData icon;
  final String label;

  const _ShellTab({
    required this.route,
    required this.title,
    required this.icon,
    required this.label,
  });
}

const List<_ShellTab> _tabs = [
  _ShellTab(
    route: '/profile',
    title: 'حسابي',
    icon: LucideIcons.user,
    label: 'حسابي',
  ),
  _ShellTab(
    route: '/wallet',
    title: 'المحفظة الرقمية',
    icon: LucideIcons.wallet,
    label: 'المحفظة',
  ),
  _ShellTab(
    route: '/home',
    title: 'الرئيسية',
    icon: LucideIcons.house,
    label: 'الرئيسية',
  ),
  _ShellTab(
    route: '/chat',
    title: 'الدردشة والرسائل',
    icon: LucideIcons.messageSquare,
    label: 'الدردشة',
  ),
  _ShellTab(
    route: '/search',
    title: 'البحث',
    icon: LucideIcons.search,
    label: 'البحث',
  ),
];

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  /// ★ فهرس تبويب «الرئيسية» (يُشتق من القائمة بدل رقم ثابت).
  static int get _homeTabIndex =>
      _tabs.indexWhere((t) => t.route == '/home');

  /// ★ عدد التبويبات التي تبني محتوى الـ Shell (بدون «البحث»).
  ///   «البحث» يفتح صفحة مستقلة، فلا يُحفظ كمؤشر نشط.
  int get _shellTabCount => _tabs.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = AppPrefs.lastTabIndex.clamp(0, _shellTabCount - 1);
  }

  void _onTabSelected(int index) {
    final tab = _tabs[index];

    // ★ البحث صفحة مستقلة (خارج الـ Shell): نفتحها بدل تبديل التبويب.
    if (tab.route == '/search') {
      context.push(tab.route);
      return;
    }

    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    AppPrefs.setLastTabIndex(index);
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        final user = AuthService.instance.currentUser;
        final profile = MockData.demoProfiles.firstWhere(
          (p) => p.email == user?.email || p.phone == user?.phone,
          orElse: () => MockData.demoProfiles.first,
        );
        return ProfileWidget(profile: profile);
      case 1:
        return const WalletScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const ChatListScreen();
      default:
        return const HomeScreen();
    }
  }

  /// ★ الإجراءات الإضافية فقط — البحث والإشعارات ومبدّل الوضع الليلي يضيفها
  /// `Header` مدمجة (وقبلها يُضاف عدّاد الإشعارات تلقائياً)، لذلك لا نعيد
  /// إضافتها هنا حتى لا تظهر أزرار مكررة أعلى كل صفحة في الهيكل الرئيسي.
  List<HeaderAction> _buildHeaderActions(BuildContext context) {
    final auth = AuthService.instance;
    final isGuest = !auth.isLoggedIn;
    final currentRole = auth.currentRole;

    return [
      if (!isGuest && currentRole != null && currentRole != UserRole.user)
        HeaderAction(
          icon: PermissionService.roleIcon(currentRole),
          tooltip: 'لوحة التحكم (${PermissionService.roleLabel(currentRole)})',
          onPressed: () {
            final targetRoute = PermissionService.homeRouteForRole(currentRole);
            context.push(targetRoute);
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = _tabs[_currentIndex];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? AppColors.background : AppColors.lightBackground;

    // ★ نُخفي العنوان في تبويب «الرئيسية» فقط (حيث يظهر شعار التطبيق بدله).
    final isHomeTab = _currentIndex == _homeTabIndex;
    return Scaffold(
      backgroundColor: scaffoldBg,
      // ★ المحتوى يبدأ تحت الهيدر (مسافة عمودية) ولا يتداخل معه —
      // يمتد فقط خلف الشريط السفلي العائم.
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: SuperHeader(
        title: isHomeTab ? null : activeTab.title,
        extraActions: _buildHeaderActions(context).map((a) {
          return IconButton(
            icon: Badge(
              isLabelVisible: a.badgeCount > 0,
              label: Text('${a.badgeCount}'),
              child: Icon(a.icon, size: 18),
            ),
            tooltip: a.tooltip,
            onPressed: a.onPressed,
          );
        }).toList(),
      ),
      // ★ شريط تلاشي واحد فوق الشريط السفلي فقط — العلوي حُذف لأن
      // المحتوى لم يعد يمر خلف الهيدر (مسافة عمودية نظيفة بدل التداخل).
      body: Stack(
        children: [
          _buildBody(_currentIndex),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 28,
            child: IgnorePointer(
              child: _EdgeFadeStrip(
                fromTop: false,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: _tabs
            .map(
              (tab) => FloatingNavItem(
                icon: tab.icon,
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// ★ شريط تلاشي زجاجي رفيع (Liquid Glass): لون خلفية الثيم الحالي + blur
/// + تدرج شفافية في طرفه، يوضع على حافة المحتوى فقط.
class _EdgeFadeStrip extends StatelessWidget {
  final bool fromTop;

  const _EdgeFadeStrip({
    required this.fromTop,
  });

  @override
  Widget build(BuildContext context) {
    // ★ يقرأ لون الخلفية من الثيم الحالي مباشرة (يتحدث مع الوضع الليلي).
    final baseColor = Theme.of(context).scaffoldBackgroundColor;
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
          end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
          colors: const [Colors.black, Colors.transparent],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(color: baseColor.withValues(alpha: 0.7)),
      ),
    );
  }
}

class HeaderAction {
  final IconData icon;
  final String tooltip;
  final int badgeCount;
  final VoidCallback onPressed;

  const HeaderAction({
    required this.icon,
    required this.tooltip,
    this.badgeCount = 0,
    required this.onPressed,
  });
}