// features/liveserver/live_mode_screen.dart
//
// صفحة «اختيار وضع البث» — أول ما يظهر للمستخدم عند الضغط على أيقونة البث.
// ★ تعرض زرّين للاختيار بينهما:
//   1) الاتصال المباشر بالتاجر  ⇒ /liveserver (ميزة الاتصال/البث).
//   2) التاجر يعرض منتجاته       ⇒ /live-products (ميزة قيد التطوير).
// ★ لا تُنفّذ أي منطق بث حقيقي — مجرّد بوابة اختيار (سيُطوّر لاحقاً).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/super_header.dart';

/// LiveModeScreen — بوابة اختيار طريقة البث (المسار /live-mode).
class LiveModeScreen extends StatelessWidget {
  const LiveModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const SuperHeader(title: 'البث المباشر', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: _PulsingLiveBadge()),
              const SizedBox(height: 22),
              const Text(
                'كيف تريد متابعة البث؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اختر طريقة الدخول المناسبة لك للمتابعة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _ModeCard(
                icon: LucideIcons.video,
                title: 'الاتصال المباشر بالتاجر',
                subtitle: 'ابدأ مكالمة مباشرة وتفاعل مع التاجر لحظة بلحظة.',
                gradient: const [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                onTap: () => context.push('/live-merchants'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: LucideIcons.shoppingBag,
                title: 'التاجر يعرض منتجاته',
                subtitle: 'استعرض المنتجات التي يعرضها التاجر أثناء البث.',
                gradient: const [Color(0xFF6D28D9), Color(0xFFDB2777)],
                onTap: () => context.push('/live-products'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة اختيار كبيرة قابلة للنقر (أيقونة + عنوان + وصف + سهم).
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradient.first.withValues(alpha: 0.24),
                gradient.last.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: gradient.first.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronLeft,
                color: Colors.white.withValues(alpha: 0.55),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شارة «مباشر LIVE» نابضة.
class _PulsingLiveBadge extends StatefulWidget {
  const _PulsingLiveBadge();

  @override
  State<_PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<_PulsingLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.45).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.tvMinimal, size: 15, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'مباشر LIVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
