import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../../core/permissions/permissions.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_service.dart';
import '../../core/widgets/header_collapse_state.dart';
import '../../shared_widgets/latest_products_carousel.dart';
import '../../shared_widgets/section_header.dart';
import '../../shared_widgets/animated_list_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Widgets
// ★ HomeScrollStrip مخفي مؤقتاً (شريط "رائج الآن" فوق القصص) — الملف محفوظ
//   في `widgets/home_scroll_strip.dart` لإعادة استخدامه لاحقاً.
// ignore: unused_import
import 'widgets/home_scroll_strip.dart';
import 'widgets/home_action_bar.dart';
// حفظ المنطق: الاستيراد محفوظ لإعادة زر «تصفح آلي» لاحقاً (مخفي مؤقتاً).
// ignore: unused_import
import 'widgets/sticky_location_button.dart';
// ملاحظة: `widgets/sticky_tabs_bar.dart` غير مستخدم مؤقتاً (التبويبات مخفية) —
// الملف محفوظ مع بياناته (MockData.productCategories) للاستخدام لاحقاً.
import 'widgets/trending_stories.dart';
import 'widgets/home_categories_tab_bar.dart';
import 'widgets/spotlight_carousel.dart';
import 'widgets/doctors_row.dart';
import 'widgets/quick_actions.dart';
import '../../features/services/data/services_repository.dart';
import '../../core/models/service_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tabsKey = GlobalKey();
  bool _showStickyTabs = false;

  /// ★ مؤقت أمان: حدث idle لا يصل دائماً عند التوقف (قصور ذاتي) —
  /// هذا المؤقت يضمن العودة بعد 150ms من آخر حركة تمرير.
  Timer? _idleTimer;

  void _scheduleIdleRestore() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      // فقط إذا توقفت الحركة فعلاً (لا تمرير نشط الآن).
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        return;
      }
      if (HeaderCollapseState.collapsed.value ||
          HeaderCollapseState.navCompact.value) {
        HeaderCollapseState.restoreNow();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // إعادة الهيدر لحجمه الكامل عند مغادرة الشاشة.
    HeaderCollapseState.collapsed.value = false;
    HeaderCollapseState.navCompact.value = false;
    super.dispose();
  }

  // ★ نظام الاتجاه النقي: أسفل = إخفاء، توقف/أعلى = إظهار فوري.
  // - تمرير لأسفل (reverse) → إخفاء الهيدر + تصغير السفلي.
  // - توقف (idle) → عودة فورية للهيدر + السفلي (بلا مؤقتات).
  // - سحب عكسي (forward) → عودة فورية + إخفاء التبويبات اللاصقة.
  void _onScroll() {
    final dir = _scrollController.position.userScrollDirection;
    // التوقف: عودة فورية لكل شيء (إلغاء أي سلسلة إخفاء معلقة).
    if (dir == ScrollDirection.idle) {
      if (HeaderCollapseState.collapsed.value ||
          HeaderCollapseState.navCompact.value) {
        HeaderCollapseState.restoreNow();
      }
      return;
    }
    if (dir == ScrollDirection.forward) {
      // سحب عكسي (للأعلى): عودة فورية لكل شيء + إخفاء التبويبات.
      _idleTimer?.cancel();
      HeaderCollapseState.restoreNow();
      if (_showStickyTabs) {
        setState(() => _showStickyTabs = false);
      }
      return;
    }
    // تمرير لأسفل نشط فقط: إخفاء الهيدر + تصغير السفلي (المحددة فقط).
    if (!_scrollController.hasClients) return;
    // ★ أي حركة لأسفل تلغي العودة المجدولة وتجدول فحص التوقف من جديد.
    _scheduleIdleRestore();
    final offset = _scrollController.offset;
    if (offset > 24 && !HeaderCollapseState.collapsed.value) {
      HeaderCollapseState.collapsed.value = true;
    }
    if (offset > 24 && !HeaderCollapseState.navCompact.value) {
      HeaderCollapseState.navCompact.value = true;
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

    // ★ منشورات التدفّق: نُدرج منشوراً احترافياً قبل قسم «الأحدث» وآخر بعده
    //   لجعل تدفّق الواجهة أكثر احترافية (نفس تصميم «المميز عندنا»).
    //   نختار منشورين مختلفين (يفضّل من خدمتين مختلفتين) لتنويع المحتوى،
    //   ونتخطّى الإدراج بأمان إن لم تتوفّر منشورات كافية.
    final allPosts = ServicesRepository.instance.allPosts;
    ServicePostEntry? preLatestPost;
    ServicePostEntry? postLatestPost;
    if (allPosts.isNotEmpty) {
      preLatestPost = allPosts.first;
      if (allPosts.length > 1) {
        // منشور مختلف عن الأول (يفضّل خدمة أخرى) ⇒ تنويع في التدفّق.
        postLatestPost = allPosts.firstWhere(
          (e) => e.service.id != preLatestPost!.service.id,
          orElse: () => allPosts[1],
        );
      }
    }

    return Scaffold(
      // ★ خلفية ديناميكية: تتغير فوراً مع «التحكم في الألوان» (/color-settings).
      backgroundColor: context.backgroundColors.primary,
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
                AnimatedListItem(
                  index: 0,
                  child: HomeActionBar(scrollController: _scrollController),
                ),
                const SizedBox(height: 14),
                AnimatedListItem(
                  index: 0,
                  child: TrendingStoriesSection(isDark: isDark),
                ),
                const SizedBox(height: 28),

                // ★ تبويبات الـ 14 قسم بين "رائج" و"الأحدث".
                const AnimatedListItem(index: 1, child: HomeCategoriesTabBar()),
                const SizedBox(height: 28),

                // ★ منشور واحد قبل قسم «الأحدث» (تدفّق أكثر احترافية).
                //   نستخدم نفس SpotlightSection بوضع «منشور واحد» ⇒ نفس
                //   التصميم والأبعاد (تمديد لحواف الشاشة) مطابقة 100%.
                if (preLatestPost != null) ...[
                  AnimatedListItem(
                    index: 2,
                    child: SpotlightSection(
                      isDark: isDark,
                      horizontalBleed: 20,
                      singleEntry: preLatestPost,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                AnimatedListItem(
                  index: 1,
                  child: SectionHeader(
                    title: 'الأحدث',
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
                // ★ تقريب عمودي: 28 → 8 بين «الأحدث» والبوست التالي.
                const SizedBox(height: 8),

                // ★ منشور آخر بعد قسم «الأحدث» (منشور مختلف ⇒ تنويع).
                if (postLatestPost != null) ...[
                  AnimatedListItem(
                    index: 2,
                    child: SpotlightSection(
                      isDark: isDark,
                      horizontalBleed: 20,
                      singleEntry: postLatestPost,
                    ),
                  ),
                  // ★ تقريب عمودي: 28 → 8 قبل «المميز عندنا».
                  const SizedBox(height: 8),
                ],

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
                // ★ تقريب عمودي: 28 → 8 بين «المميز» و«الأطباء».
                const SizedBox(height: 8),

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
          // ★ تدرج علوي مخفف لأقصى درجة: طبقة رقيقة شفافة جداً (مجرد
          //   دمج ناعم مع الهيدر الشفاف — بلا أي إحساس بالشادو).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 48, // ★ كان 180 — رقيق جداً الآن
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // ★ ديناميكي: يتبع لون الخلفية المختار من «التحكم في الألوان».
                      context.backgroundColors.primary.withValues(
                        alpha: 0.35,
                      ), // ★ كان صلباً (1.0)
                      context.backgroundColors.primary.withValues(
                        alpha: 0.0,
                      ), // شفاف في النهاية
                    ],
                    stops: const [0.0, 1.0], // ★ تلاشي مباشر بلا منطقة صلبة
                  ),
                ),
              ),
            ),
          ),
          // ★ زر «تصفح آلي» مخفي مؤقتاً من الواجهة — المنطق محفوظ كاملاً في
          //   `widgets/sticky_location_button.dart` (StickyLocationButton)
          //   لإعادة استخدامه لاحقاً. للإعادة: أزل التعليق عن السطر التالي.
          // StickyLocationButton(scrollController: _scrollController),
        ],
      ),
    );
  }
}
