// features/liveserver/liveserver_screen.dart
//
// صفحة «البث المباشر» (Live Server) — نسخة أولية مؤقتة (واجهة فقط).
//
// ★ تُفتح من أيقونة «البث المباشر» في الشريط السفلي (المسار /liveserver).
// ★ سيتم تطويرها لاحقاً (مشغّل بث مباشر، قائمة القنوات، التفاعل... إلخ).
// ★ الآن تعرض شاشة «قريباً» موحّدة مع زر رجوع.

import 'package:flutter/material.dart';

import '../../core/widgets/super_header.dart';
import '../../shared_widgets/coming_soon_screen.dart';

/// ============================================================================
///  LiveserverScreen — صفحة البث المباشر (المسار /liveserver).
/// ============================================================================
class LiveserverScreen extends StatelessWidget {
  const LiveserverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // ★ هيدر موحّد مع زر رجوع (مطابق لبقية الصفحات المستقلة).
      appBar: SuperHeader(
        title: 'البث المباشر',
        showBackButton: true,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: ComingSoonScreen(
        title: 'البث المباشر',
        subtitle: 'خدمة البث المباشر (Live Server) قيد التطوير وستتوفر قريباً.',
        route: '/liveserver',
      ),
    );
  }
}
