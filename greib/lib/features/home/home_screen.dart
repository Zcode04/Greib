import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/mock_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---- حالة بطاقة Spotlight القابلة للتمرير ----
  final PageController _spotlightController =
      PageController(viewportFraction: 0.84);
  int _spotlightIndex = 0;
  final Set<String> _favoriteServiceIds = {};
  bool _isGridView = false; // لبطاقة Spotlight
  bool _isServicesGridView = false; // لصف "ولدينا المزيد"

  // ---- حالة قسم الكاتالوج (اكتشف كل ما نوفره) ----
  bool _isCatalogExpanded = false;
  static const int _catalogCollapsedCount = 4; // عدد الكروت الظاهرة أول مرة

  @override
  void dispose() {
    _spotlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final role = AuthService.instance.currentRole;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(user, isDark),
            const SizedBox(height: 28),

            _sectionTitle('  المميز عندنا', isDark),
            const SizedBox(height: 12),
            _buildSpotlightCard(isDark),
            const SizedBox(height: 28),

            _sectionTitle('تعرف على أطبائنا', isDark),
            const SizedBox(height: 12),
            _buildDoctorsRow(isDark),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('ولدينا المزيد ', isDark),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(
                      () => _isServicesGridView = !_isServicesGridView),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.accentPrimaryLight
                              : AppColors.accentPrimary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isServicesGridView ? 'عرض أقل' : 'عرض المزيد',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.accentPrimaryLight
                                : AppColors.accentPrimary,
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
                              ? AppColors.accentPrimaryLight
                              : AppColors.accentPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildServicesRow(isDark),
            const SizedBox(height: 28),

            _sectionTitle('اكتشف كل ما نوفره', isDark),
            const SizedBox(height: 14),
            _buildCatalogSection(isDark),
            const SizedBox(height: 28),

            _sectionTitle('طلباتك الحالية', isDark),
            const SizedBox(height: 14),
            ..._buildOrdersList(isDark),

            if (role == UserRole.admin || role == UserRole.agent) ...[
              const SizedBox(height: 28),
              _sectionTitle('صفحات سريعة', isDark),
              const SizedBox(height: 14),
              _buildQuickActions(context, role),
            ],
          ],
        ),
      ),
    );
  }



  // ---------------------------------------------------------------------
  // Hero Banner — تصميم "حر" بدون Card/Container محيط: الصورة تطفو
  // مباشرة فوق خلفية الشاشة (بدون حواف، بدون تعتيم، بدون ظل)
  // ---------------------------------------------------------------------
  Widget _buildHeroBanner(user, bool isDark) {
    final titleColor = isDark ? AppColors.textPrimary : AppColors.lightText;

    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // ---- النص والزر (يمين الشاشة لأن الاتجاه RTL) ----
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 170,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اكتشف خدماتنا\nالجديدة',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.accentPrimaryLight
                        : AppColors.accentPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('استكشف الآن',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),

          // ---- الصورة حرة تمامًا، بدون أي إطار أو صندوق ----
          Positioned(
            left: -30, // نسمح لها بالخروج قليلاً عن حواف الشاشة لإحساس أكثر حرية
            top: -10,
            bottom: -10,
            child: Image.asset(
              'assets/images/hero.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Spotlight card (البطاقة المميزة الكبيرة)
  // ---------------------------------------------------------------------
  Widget _buildSpotlightCard(bool isDark) {
    final services = MockData.services;
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isGridView
              ? _buildSpotlightGrid(services, isDark)
              : _buildSpotlightCarousel(services, isDark),
        ),
        const SizedBox(height: 10),
        // مؤشر النقاط يظهر فقط في وضع الكاروسيل
        if (!_isGridView)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(services.length, (i) {
              final active = i == _spotlightIndex;
              final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? neonColor
                      : (isDark ? Colors.white24 : AppColors.lightOutline),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        const SizedBox(height: 12),
        // زر التبديل
      
      ],
    );
  }

  Widget _buildSpotlightCarousel(List services, bool isDark) {
    return SizedBox(
      key: const ValueKey('carousel'),
      height: 232,
      child: PageView.builder(
        controller: _spotlightController,
        itemCount: services.length,
        onPageChanged: (i) => setState(() => _spotlightIndex = i),
        itemBuilder: (context, i) {
          final s = services[i];
          return AnimatedScale(
            scale: i == _spotlightIndex ? 1.0 : 0.93,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: i == _spotlightIndex ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 220),
              child: _spotlightItem(s, isDark),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpotlightGrid(List services, bool isDark) {
    return GridView.builder(
      key: const ValueKey('grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) => _spotlightItem(services[i], isDark),
    );
  }

  Widget _spotlightItem(dynamic service, bool isDark) {
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
    final isFav = _favoriteServiceIds.contains(service.id as String);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? AppColors.neonGlow(blur: 30, alpha: 0.12)
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.pushNamed(context, service.route as String),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بديل "صورة الحذاء بزاوية جذابة": أيقونة الخدمة داخل
            // كتلة ملونة مائلة قليلاً لإعطاء نفس الإحساس البصري
            Expanded(
              child: Center(
                child: Transform.rotate(
                  angle: -0.16,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: neonColor.withValues(alpha: isDark ? 0.14 : 0.16),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Transform.rotate(
                      angle: 0.16, // نعيد الأيقونة نفسها لوضعها المستقيم
                      child: Icon(
                        MockData.getIconByName(service.iconName as String),
                        color: neonColor,
                        size: 46,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.title as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // بديل السعر الأخضر: نص الخدمة الفرعي بنفس لون Neon
                Expanded(
                  child: Text(
                    service.subtitle as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: neonColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // أيقونة القلب (المفضلة)
                _spotlightIconButton(
                  icon: isFav ? LucideIcons.heart : LucideIcons.heart,
                  iconColor: isFav
                      ? AppColors.error
                      : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                  filledBackground: isFav
                      ? AppColors.error.withValues(alpha: 0.12)
                      : null,
                  onTap: () => setState(() {
                    if (isFav) {
                      _favoriteServiceIds.remove(service.id as String);
                    } else {
                      _favoriteServiceIds.add(service.id as String);
                    }
                  }),
                ),
                const SizedBox(width: 8),
                // أيقونة السلة/الإجراء (بلون Neon المميز)
                _spotlightIconButton(
                  icon: LucideIcons.shoppingBag,
                  iconColor: isDark ? Colors.black : Colors.white,
                  filledBackground: neonColor,
                  onTap: () => Navigator.pushNamed(context, service.route as String),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _spotlightIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
    Color? filledBackground,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filledBackground ?? Colors.transparent,
          border: filledBackground == null
              ? Border.all(color: iconColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Services row (مثل صف "Stores" الدائري في الصورة)
  // ---------------------------------------------------------------------
  Widget _buildServicesRow(bool isDark) {
    final services = MockData.services;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isServicesGridView
          ? _buildServicesGrid(services, isDark)
          : _buildServicesHorizontalList(services, isDark),
    );
  }

  Widget _buildServicesHorizontalList(List services, bool isDark) {
    return SizedBox(
      key: const ValueKey('services_row'),
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) => _serviceCircleItem(services[i], isDark),
      ),
    );
  }

  Widget _buildServicesGrid(List services, bool isDark) {
    return GridView.builder(
      key: const ValueKey('services_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, i) => _serviceCircleItem(services[i], isDark),
    );
  }

  Widget _serviceCircleItem(dynamic s, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, s.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariant : AppColors.lightSurface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.lightOutline),
            ),
            child: Icon(MockData.getIconByName(s.iconName),
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                size: 22),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              s.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Doctors row (بروفيلات أطباء دائرية أفقية)
  // ---------------------------------------------------------------------
  Widget _buildDoctorsRow(bool isDark) {
    final doctors = MockData.mockDoctors;
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) => _doctorCircleItem(doctors[i], isDark),
      ),
    );
  }

  Widget _doctorCircleItem(DoctorProfile doctor, bool isDark) {
    final specialtyColor = MockData.getSpecialtyColor(doctor.specialty);
    final shortName = doctor.name.replaceFirst('د. ', '');

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/doctor_profile',
        arguments: doctor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                specialtyColor.withValues(alpha: isDark ? 0.15 : 0.12),
            backgroundImage: NetworkImage(doctor.avatar),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              shortName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Catalog Section (شبكة كروت بأسلوب متجر: صورة/أيقونة + شارة + سعر)
  // مع زر "عرض المزيد" أسفل الكروت
  // ---------------------------------------------------------------------
  Widget _buildCatalogSection(bool isDark) {
    final services = MockData.services;
    if (services.isEmpty) return const SizedBox.shrink();

    final bool canExpand = services.length > _catalogCollapsedCount;
    final visibleServices = _isCatalogExpanded
        ? services
        : services.take(_catalogCollapsedCount).toList();

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, i) => _catalogCard(visibleServices[i], isDark),
          ),
        ),
        if (canExpand) ...[
          const SizedBox(height: 18),
          _buildShowMoreButton(isDark),
        ],
      ],
    );
  }

  Widget _catalogCard(dynamic service, bool isDark) {
    final accentColor = isDark ? AppColors.accentPrimaryLight : AppColors.accentPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: AppColors.catalogCardGradientLight,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? AppColors.violetGlow(blur: 20, alpha: 0.10)
            : [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, service.route as String),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- منطقة الأيقونة + شارة "مميز" ----
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: isDark ? 0 : 0.14),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        MockData.getIconByName(service.iconName as String),
                        color: isDark ? accentColor : Colors.white,
                        size: 54,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مميز',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---- النص السفلي ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.subtitle as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? accentColor
                          : Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // زر "عرض المزيد" بتصميم كبسولة بارزة، يظهر تحت كروت الكاتالوج
  // ---------------------------------------------------------------------
  Widget _buildShowMoreButton(bool isDark) {
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => setState(() => _isCatalogExpanded = !_isCatalogExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: neonColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: neonColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCatalogExpanded ? 'عرض أقل' : 'عرض المزيد',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                duration: const Duration(milliseconds: 280),
                turns: _isCatalogExpanded ? 0.5 : 0,
                child: Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Orders list (بطاقات بنفس شكل بطاقة المنتج في الصورة)
  // ---------------------------------------------------------------------
  List<Widget> _buildOrdersList(bool isDark) {
    final orders = MockData.demoOrders;
    final neonColor = isDark ? AppColors.neon : AppColors.accentPrimaryDark;

    if (orders.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text('لا توجد طلبات حالية',
                style: TextStyle(
                    color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary)),
          ),
        ),
      ];
    }

    return orders.take(3).map((order) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.white10 : AppColors.lightOutline),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, '/tracking'),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: neonColor.withValues(alpha: isDark ? 0.1 : 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(MockData.getIconByName(order.serviceType),
                    color: neonColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.pickupLocation} → ${order.deliveryLocation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.lightTextTertiary,
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(order.status, isDark),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'قيد الانتظار';
      case 'assigned':
        color = AppColors.info;
        label = 'تم التعيين';
      case 'in_transit':
        color = isDark ? AppColors.neon : AppColors.accentPrimaryDark;
        label = 'في الطريق';
      case 'delivered':
        color = isDark ? AppColors.textMuted : AppColors.lightTextTertiary;
        label = 'تم التسليم';
      case 'cancelled':
        color = AppColors.error;
        label = 'ملغي';
      default:
        color = isDark ? AppColors.textMuted : AppColors.lightTextTertiary;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  // ---------------------------------------------------------------------
  // Quick actions (تظهر فقط للأدوار الإدارية، بقية الوصول أصبح عبر الـ navbar)
  // ---------------------------------------------------------------------
  Widget _buildQuickActions(BuildContext context, UserRole? role) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (role == UserRole.admin)
          _chip(LucideIcons.shieldCheck, 'لوحة المشرفين', AppColors.error,
              () => Navigator.pushNamed(context, '/admin_dashboard')),
        if (role == UserRole.agent || role == UserRole.admin)
          _chip(LucideIcons.bike, 'لوحة الوكلاء', AppColors.info,
              () => Navigator.pushNamed(context, '/agent_dashboard')),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(text,
        style: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.lightText,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ));
  }
}