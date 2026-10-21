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
import '../core/widgets/super_header.dart'; // تمت الإضافة
import 'floating_bottom_nav.dart';

class _ShellTab {
  final String route;
  final String title;
  final IconData icon;

  /// ★ اسم ملف SVG الممتلئ (Filled Lucide) للحالة المحددة — بلا لاحقة.
  ///   null (زر الكاميرا) = تبقى المفرّغة دائماً لأنه زر إجراء لا يُحدَّد.
  final String? filledAsset;
  final String label;

  // ★ زر إجراء (لا يغيّر الصفحة): مثل الكاميرا — يفتح ورقة خيارات.
  final bool isAction;

  const _ShellTab({
    required this.route,
    required this.title,
    required this.icon,
    this.filledAsset,
    required this.label,
    this.isAction = false,
  });
}

const List<_ShellTab> _tabs = [
  // ★ الترتيب (من اليمين لليسار في RTL):
  //   الرئيسية، الدردشة، البث المباشر، الكاميرا، الريلز، موقعي
  //   (تبويب «المحفظة» حُذف: المحفظة تُفتح من تبويبها داخل صفحة الحساب /profile).
  // ★ الأيقونات Lucide الأصلية + النسخة الممتلئة Filled Lucide (SVG محلي):
  //   المفرّغة عند عدم التحديد، والممتلئة عند التحديد (بأسلوب فيسبوك).
  _ShellTab(
    route: '/home',
    title: 'الرئيسية',
    icon: LucideIcons.house,
    filledAsset: 'house',
    label: 'الرئيسية',
  ),
  _ShellTab(
    route: '/chat',
    title: 'الدردشة والرسائل',
    icon: LucideIcons.messageSquare,
    filledAsset: 'message-square',
    label: 'الدردشة',
  ),
  // ★ البث المباشر: الأيقونة تفتح بوابة «Publiveedit» التعريفية أولاً،
  //   وهي تحوّل تلقائياً إلى صفحة البث (/liveserver) بعد 5 ثوانٍ أو بالتخطي.
  //   بلا نسخة ممتلئة — يبقى Lucide مفرّغاً دائماً (الامتلاء للرئيسية والدردشة فقط).
  _ShellTab(
    route: '/publiveedit',
    title: 'البث المباشر',
    icon: LucideIcons.tvMinimal,
    label: 'البث المباشر',
  ),
  // ★ زر الكاميرا: نفس هوية بقية الأيقونات — يفتح صفحة البحث المستقلة
  //   (بحث بإرفاغ صورة / في الحقل / رسالة للوكيل) بدل ورقة الخيارات.
  //   زر إجراء ⇒ بلا نسخة ممتلئة (يبقى مفرّغاً دائماً).
  _ShellTab(
    route: '__camera_action__',
    title: 'الكاميرا',
    icon: LucideIcons.camera,
    label: 'الكاميرا',
    isAction: true,
  ),
  // ★ الريلز وموقعي: بلا نسخة ممتلئة — تبقى Lucide مفرّغة دائماً.
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

/// ★ مفتاح عام للوصول إلى حالة MainShellScreen من أي مكان في التطبيق
///   للتبديل بين تبويبات Shell (مثل الدردشة) مع الحفاظ على الهيدر والشريط السفلي.
final GlobalKey<_MainShellScreenState> _mainShellKey = GlobalKey();


class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  /// ★ التبديل إلى تبويب الدردشة من أي مكان في التطبيق مع الحفاظ على الهيدر والشريط السفلي.
  static void switchToChat(BuildContext context) {
    final state = _mainShellKey.currentState;
    if (state != null) {
      state.switchToChatTab();
    } else {
      context.push('/chat');
    }
  }

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  /// ★ تحكّم الـ PageView: الصفحة 0 = الرئيسية، الصفحة 1 = الدردشة
  ///   (فهرسة عبر `_shellIndexes` — أي تبويب Shell إضافي未来 يُضاف تلقائياً).
  ///   السحب الأفقي على المحتوى يتنقّل بينهما فقط، والتبويبات المستقلة
  ///   (الكاميرا/الريلز/موقعي) تبقى بـ push خارج الـ PageView.
  late final PageController _pageController;

  /// ★ فهرس تبويب «الرئيسية» (يُشتق من القائمة بدل رقم ثابت).
  static int get _homeTabIndex => _tabs.indexWhere((t) => t.route == '/home');

  /// ★ التبويبات التي تبني محتوى الـ Shell: كل ما عداه صفحات مستقلة
  ///   («الريلز» و«موقعي») تُفتح بـ push ولا تُحفظ كمؤشر نشط.
  ///   زر الإجراء (الكاميرا) لا يُحفظ أبداً كمؤشر ولا يبني محتوى.
  static const Set<String> _standaloneRoutes = {
    '/reels',
    '/my_location',
    '/liveserver',
    '/publiveedit',
  };

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
    // ★ PageView يبدأ على نفس تبويب Shell المحفوظ (فهرسة عبر _shellIndexes).
    _pageController = PageController(
      initialPage: _shellIndexes.indexOf(_currentIndex),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    final tab = _tabs[index];

    // ★ زر الكاميرا (إجراء): يفتح صفحة البحث المستقلة بدل ورقة الخيارات،
    //   ولا يحفظ مؤشراً نشطاً.
    if (tab.isAction) {
      context.push('/search');
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
    // ★ الضغط على أيقونة الشريط يحرّك الـ PageView بنفس اتجاه السحب
    //   (حركة ناعمة 200ms) — فحالة الشريط ومحتوى الصفحة تبقى متزامنة دائماً.
    final page = _shellIndexes.indexOf(index);
    if (page >= 0 && _pageController.hasClients && _pageController.page?.round() != page) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// ★ التبديل العام لتبويب الدردشة (يُستدعى من MainShellScreen.switchToChat).
  void switchToChatTab() {
    final chatIndex = _tabs.indexWhere((t) => t.route == '/chat');
    if (chatIndex >= 0) {
      _onTabSelected(chatIndex);
    }
  }

  /// ★ سحب أفقي على الشريط: تبديل مباشر بين تبويبات Shell
  /// (الرئيسية ⇄ الدردشة) — أي سحبة تُبدّل للآخر، بسهولة سحب الستوري.
  /// (يستخدم نفس `_onTabSelected` ⇒ يحرّك الـ PageView تلقائياً.)
  void _onNavSwipe(int direction) {
    final shell = _shellIndexes.toList()..sort();
    if (shell.length < 2) return;
    // ★ تبويبان فقط ⇒ أي سحبة تنتقل للتبويب الآخر (بلا حساب اتجاه).
    final other = shell.firstWhere(
      (i) => i != _currentIndex,
      orElse: () => _currentIndex,
    );
    if (other == _currentIndex) return;
    _onTabSelected(other);
  }

  /// ★ جسم التبويب: مبني على المسار (لا على رقم ثابت) ⇒ ترتيب التبويبات
  ///   أو إضافتها لا تكسر أي حالة محفوظة.
  Widget _buildBody(int index) {
    switch (_tabs[index].route) {
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
    // ★ ارتفاع منطقة النظام العلوية (البطارية + الوقت + النتوء) — طبقة
    //   الحماية العلوية تُغطيها ب mesh صلب فيمر المحتوى تحتها بلا تشابك.

    final topPad = MediaQuery.paddingOf(context).top;

    // ★ نُخفي العنوان في تبويب «الرئيسية» فقط (حيث يظهر شعار التطبيق بدله).
    final isHomeTab = _currentIndex == _homeTabIndex;
    return Scaffold(
      key: _mainShellKey,
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
      // ★ شريط تلاشي مخفف لأقصى درجة فوق الشريط السفلي فقط — طبقة رقيقة
      // شفافة جداً (مجرد دمج ناعم — بلا أي إحساس بالشادو).
      body: Stack(
        children: [
          // ★ سحب أفقي على المحتوى بين تبويبات Shell فقط (الرئيسية ⇄ الدردشة):
          //   PageView يبني صفحتين فقط من `_shellIndexes` ⇒ التبويبات المستقلة
          //   (الكاميرا/الريلز/موقعي) تبقى بـ push خارجه تماماً كما كانت.
          //   `onPageChanged` يزامن حالة الشريط السفلي مع السحب، و
          //   `allowImplicitScrolling` يحتفظ بحالة كل صفحة (تمرير/مسودات)
          //   عند التنقل ذهاباً وإياباً (سلوك فيسبوك المعتاد).
          PageView(
            controller: _pageController,
            allowImplicitScrolling: true,
            onPageChanged: (page) {
              final index = _shellIndexes[page];
              if (index == _currentIndex) return;
              setState(() => _currentIndex = index);
              AppPrefs.setLastTabIndex(index);
            },
            children: [for (final i in _shellIndexes) _buildBody(i)],
          ),
          // ★ طبقة الحماية العلوية (Status-Bar Scrim): شريط صلب بلون خلفية
          //   التطبيق يغطي منطقة (البطارية + الوقت + النتوء) في الأعلى —
          //   المحتوى المسحوب يدخل تحتها بدل أن يتشابك مع رموز النظام.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPad,
            child: IgnorePointer(child: Container(color: scaffoldBg)),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 12, // ★ كان 28 — رقيق جداً الآن
            child: IgnorePointer(child: _EdgeFadeStrip(fromTop: false)),
          ),
        ],
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        // ★ سحب أفقي على الشريط للتنقل بين الرئيسية ⇄ الدردشة فقط.
        onSwipeTo: _onNavSwipe,
        items: _tabs
            .map(
              (tab) => FloatingNavItem(
                icon: tab.icon,
                filledAsset: tab.filledAsset,
                label: tab.label,
                isAction: tab.isAction,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// ★ شريط تلاشي مخفف لأقصى درجة (Liquid Glass خفيف): لون خلفية الثيم
/// + blur خفيف + تدرج شفافية — طبقة رقيقة للدمج الناعم فقط.
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
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // ★ كان 14 — خفيف الآن
        child: Container(color: baseColor.withValues(alpha: 0.25)), // ★ كان 0.7
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
