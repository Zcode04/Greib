import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/permissions/permissions.dart';
import '../core/extensions/context_extensions.dart';
import '../core/storage/app_prefs.dart';
import '../features/auth/auth_service.dart';
import '../features/communication_and_support/alhadheq_chat_screen.dart';
import '../features/communication_and_support/chat_screen.dart';
import '../features/home_and_services/home_screen.dart';
import '../features/wallet_and_finance/wallet_screen.dart';
import '../core/widgets/super_header.dart'; // تمت الإضافة
import 'floating_bottom_nav.dart';
import 'sheets/camera_action_sheet.dart';

class _ShellTab {
  final String route;
  final String title;
  final IconData icon;
  final String label;

  /// ★ زر إجراء (لا يغيّر الصفحة): مثل الكاميرا — يفتح ورقة خيارات.
  final bool isAction;

  const _ShellTab({
    required this.route,
    required this.title,
    required this.icon,
    required this.label,
    this.isAction = false,
  });
}

const List<_ShellTab> _tabs = [
  // ★ الترتيب الجديد (من اليمين لليسار في RTL):
  //   الرئيسية، الدردشة، الكاميرا، المحفظة، الريلز، موقعي
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
  // ★ زر الكاميرا: نفس هوية بقية الأيقونات — يفتح ورقة خيارات
  //   (التقاط/تسجيل/معرض)، وقابل للتوسعة لاحقاً لشاشة نشر كاملة.
  _ShellTab(
    route: '__camera_action__',
    title: 'الكاميرا',
    icon: LucideIcons.camera,
    label: 'الكاميرا',
    isAction: true,
  ),
  _ShellTab(
    route: '/wallet',
    title: 'المحفظة الرقمية',
    icon: LucideIcons.wallet,
    label: 'المحفظة',
  ),
  _ShellTab(
    route: '/reels',
    title: 'الريلز',
    icon: LucideIcons.clapperboard,
    label: 'Reels',
  ),
  _ShellTab(
    route: '/my_location',
    title: 'موقعي',
    icon: LucideIcons.mapPinned,
    label: 'موقعي',
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
  static int get _homeTabIndex => _tabs.indexWhere((t) => t.route == '/home');

  /// ★ التبويبات التي تبني محتوى الـ Shell: كل ما عداه صفحات مستقلة
  ///   («الريلز» و«موقعي») تُفتح بـ push ولا تُحفظ كمؤشر نشط.
  ///   زر الإجراء (الكاميرا) لا يُحفظ أبداً كمؤشر ولا يبني محتوى.
  static const Set<String> _standaloneRoutes = {'/reels', '/my_location'};

  /// ★ فهارس التبويبات التي تبني محتوى الـ Shell (فهارس داخل `_tabs`).
  ///   صفحة مستقلة («موقعي»/«الريلز»/«الحاذق») ولا يحفظ مؤشراً نشطاً.
  ///   أزرار الإجراء (الكاميرا) مستثناة أيضاً.
  static final List<int> _shellIndexes = [
    for (var i = 0; i < _tabs.length; i++)
      if (!_standaloneRoutes.contains(_tabs[i].route) && !_tabs[i].isAction) i,
  ];

  @override
  void initState() {
    super.initState();
    // ★ المؤشر المحفوظ يقتصر على فهارس الـ Shell ⇒ لا يقف أبداً على تبويب
    //   مستقل («موقعي»/«الريلز») بعد إعادة فتح التطبيق.
    final saved = AppPrefs.lastTabIndex;
    _currentIndex = _shellIndexes.contains(saved)
        ? saved
        : _shellIndexes.firstWhere(
            (i) => _tabs[i].route == '/home',
            orElse: () => _shellIndexes.first,
          );
  }

  void _onTabSelected(int index) {
    final tab = _tabs[index];

    // ★ زر الإجراء (الكاميرا): يفتح ورقة الخيارات ولا يغيّر الصفحة
    //   ولا يحفظ مؤشراً — جاهز للتوسعة لاحقاً (شاشة نشر كاملة).
    if (tab.isAction) {
      showCameraActionSheet(context);
      return;
    }

    // ★ الصفحات المستقلة («الريلز»، «موقعي»، «الحاذق») تُفتح بـ push ولا تحفظ مؤشراً.
    if (_standaloneRoutes.contains(tab.route)) {
      context.push(tab.route);
      return;
    }

    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    AppPrefs.setLastTabIndex(index);
  }

  /// ★ جسم التبويب: مبني على المسار (لا على رقم ثابت) ⇒ ترتيب التبويبات
  ///   أو إضافتها لا تكسر أي حالة محفوظة.
  Widget _buildBody(int index) {
    switch (_tabs[index].route) {
      case '/wallet':
        return const WalletScreen();
      case '/home':
        return const HomeScreen();
      case '/chat':
        return const ChatListScreen();
      case '/alhadheq':
        return const AlhadheqChatScreen();
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
    // ★ خلفية الـ Scaffold من اللوحة الديناميكية (تتبع الوضع والتخصيص).
    final scaffoldBg = context.backgroundColors.primary;

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
        // ★ زر (+) يفتح ورقة «خدمات قادمة» (السلوك الافتراضي — بدون onAccount).
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
            child: IgnorePointer(child: _EdgeFadeStrip(fromTop: false)),
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
                isAction: tab.isAction,
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

  const _EdgeFadeStrip({required this.fromTop});

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
