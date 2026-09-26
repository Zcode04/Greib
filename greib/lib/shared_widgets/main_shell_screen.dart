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
    route: '/wallet',
    title: 'المحفظة الرقمية',
    icon: LucideIcons.wallet,
    label: 'المحفظة',
  ),
  _ShellTab(
    route: '/profile',
    title: 'حسابي',
    icon: LucideIcons.user,
    label: 'حسابي',
  ),
];

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = AppPrefs.lastTabIndex.clamp(0, _tabs.length - 1);
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    AppPrefs.setLastTabIndex(index);
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ChatListScreen();
      case 2:
        return const WalletScreen();
      case 3:
        final user = AuthService.instance.currentUser;
        final profile = MockData.demoProfiles.firstWhere(
          (p) => p.email == user?.email || p.phone == user?.phone,
          orElse: () => MockData.demoProfiles.first,
        );
        return ProfileWidget(profile: profile);
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

    // استخدم SuperHeader بدلاً من Header العادي إذا كنا في الشاشة الرئيسية (index 0)
    // هذا سيعطي تجربة "Super App" مع زر الموقع، الإشعارات المتطورة، والبحث المدمج.
    return Scaffold(
      backgroundColor: scaffoldBg,
      // ★ المحتوى يمتد خلف الشريط السفلي العائم فقط حتى يعمل التلاشي عليه.
      extendBody: true,
      appBar: SuperHeader(
        title: _currentIndex == 0 ? null : activeTab.title,
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
      // ★ طبقتا تلاشي زجاجي رفيعتان داخل المحتوى (لا تمس الهيدر ولا الشريط):
      // واحدة تحت الهيدر مباشرة وواحدة فوق الشريط السفلي، حتى يذوب
      // المحتوى المار خلفهما بسلاسة بدل القطع الحاد.
      body: Stack(
        children: [
          _buildBody(_currentIndex),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 28,
            child: IgnorePointer(
              child: _EdgeFadeStrip(
                fromTop: true,
              ),
            ),
          ),
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