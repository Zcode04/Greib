import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_service.dart';
import '../../core/widgets/header_collapse_state.dart';
import '../../shared_widgets/animated_background.dart';
import '../../shared_widgets/latest_products_carousel.dart';
import '../../shared_widgets/section_header.dart';
import '../../shared_widgets/animated_list_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Widgets
import 'widgets/home_scroll_strip.dart';
import 'widgets/sticky_location_button.dart';
// ملاحظة: `widgets/sticky_tabs_bar.dart` غير مستخدم مؤقتاً (التبويبات مخفية) —
// الملف محفوظ مع بياناته (MockData.productCategories) للاستخدام لاحقاً.
import 'widgets/trending_stories.dart';
import 'widgets/home_categories_tab_bar.dart';
import 'widgets/spotlight_carousel.dart';
import 'widgets/doctors_row.dart';
import 'widgets/quick_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tabsKey = GlobalKey();
  bool _showStickyTabs = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // إعادة الهيدر لحجمه الكامل عند مغادرة الشاشة.
    HeaderCollapseState.collapsed.value = false;
    super.dispose();
  }

  // ★ السلوك المطلوب:
  // - تمرير لأسفل (reverse) + تجاوز موضع التبويبات → تظهر وتبقى ظاهرة.
  // - التوقف (idle) → لا يتغير أي شيء (تبقى على حالتها).
  // - سحب عكسي للأعلى (forward) فقط → تختفي + الهيدر يكبر.
  void _onScroll() {
    final dir = _scrollController.position.userScrollDirection;
    // التوقف: لا تلمس الحالة أبداً — كانت هذه هي الثغرة (كانت تعيد
    // الحساب بالموضع فتخفي التبويب عند رفع الإصبع).
    if (dir == ScrollDirection.idle) return;
    if (dir == ScrollDirection.forward) {
      // سحب عكسي (للأعلى): تكبير الهيدر + إخفاء التبويبات (مرة واحدة).
      if (HeaderCollapseState.collapsed.value) {
        HeaderCollapseState.collapsed.value = false;
      }
      if (_showStickyTabs) {
        setState(() => _showStickyTabs = false);
      }
      return;
    }
    // تمرير لأسفل فقط: القرار حسب الموضع — يظهر عند التجاوز ويبقى.
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    if (offset > 24 && !HeaderCollapseState.collapsed.value) {
      HeaderCollapseState.collapsed.value = true;
    }
    final ctx = _tabsKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos = box.localToGlobal(Offset.zero).dy;
    final shouldShow = pos < 150;
    if (shouldShow != _showStickyTabs) {
      setState(() => _showStickyTabs = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthService.instance.currentRole;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.lightBackground,
      // القائمة الجانبية (Drawer) انتقلت إلى MainShellScreen — مصدر واحد للتنقل.
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            clipBehavior: Clip.none,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 24,
              20,
              110,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AnimatedListItem(index: 0, child: HomeScrollStrip()),
                const SizedBox(height: 14),
                AnimatedListItem(
                  index: 0,
                  child: TrendingStoriesSection(isDark: isDark),
                ),
                const SizedBox(height: 28),

                // ★ تبويبات الـ 14 قسم بين "رائج" و"الأحدث".
                const AnimatedListItem(
                  index: 1,
                  child: HomeCategoriesTabBar(),
                ),
                const SizedBox(height: 14),

                AnimatedListItem(
                  index: 1,
                  child: SectionHeader(
                    title: 'الأحدث',
                    icon: LucideIcons.badgePlus,
                    iconColor: AppColors.accentFor(isDark),
                    showAction: false,
                  ),
                ),
                // مرجع التمرير: التبويبات اللاصقة تظهر عند تجاوز هذا القسم.
                AnimatedListItem(
                  key: _tabsKey,
                  index: 1,
                  child: const LatestProductsCarousel(),
                ),
                const SizedBox(height: 28),

                AnimatedListItem(
                  index: 1,
                  child: SectionHeader(
                    title: 'المميز عندنا',
                    // بلا أيقونة، والجملة في منتصف السطر.
                    centerTitle: true,
                    showAction: false,
                  ),
                ),
                AnimatedListItem(
                  index: 1,
                  child: SpotlightSection(isDark: isDark),
                ),
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
          // تأثير التدرج (Gradient Fade) أعلى المحتوى لدمجه مع الخلفية
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height:
                180, // ارتفاع ثابت وكبير نسبياً لضمان ظهوره تحت الهيدر الشفاف
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark ? AppColors.background : AppColors.lightBackground,
                      isDark
                          ? AppColors.background
                          : AppColors.lightBackground, // لون صلب في البداية
                      (isDark
                              ? AppColors.background
                              : AppColors.lightBackground)
                          .withOpacity(0.0), // شفاف في النهاية
                    ],
                    stops: const [
                      0.0,
                      0.4,
                      1.0,
                    ], // يبدأ صلباً ثم يتلاشى للشفافية
                  ),
                ),
              ),
            ),
          ),
          // ★ زر الموقع: يظهر في مكانه الثابت دائماً (بدون نسخة ثانية
          //   داخل شريط لاصق). فتح ورقة تغيير الموقع تتم منه.
          //   ملاحظة: `StickyTabsBar` (شريط الـ 14 تبويب) لم يُعرض مؤقتاً،
          //   وملفه وبياناته محفوظة للاستخدام لاحقاً.
          const StickyLocationButton(),
        ],
      ),
    );
  }
}
