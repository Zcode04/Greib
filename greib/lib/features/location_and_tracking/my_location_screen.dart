import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/super_header.dart';
import '../home_and_services/widgets/map_explore_section.dart';

/// ============================================================================
///  MyLocationScreen — صفحة «موقعي».
///
///  ★ تفتح من تبويب «موقعي» في الشريط السفلي، وتعرض نفس مكوّن
///  [MapExploreSection] المستخدَم في الصفحة الرئيسية (بحث + بطاقة العالم
///  ثلاثية الأبعاد + تبويبات المتاجر/المحلات/التكاسي الأقرب إليك).
/// ============================================================================
class MyLocationScreen extends StatelessWidget {
  const MyLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.lightBackground,
      appBar: SuperHeader(showBackButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 24,
          20,
          110,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [MapExploreSection(isDark: isDark)],
        ),
      ),
    );
  }
}

/// أيقونة التبويب في الشريط السفلي (مصدر واحد مع `_ShellTab`).
const IconData kMyLocationIcon = LucideIcons.mapPinned;
