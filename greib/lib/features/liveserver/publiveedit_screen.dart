// features/liveserver/publiveedit_screen.dart
//
// صفحة «Publiveedit» — شاشة تعريفية قبل الدخول إلى البث المباشر.
// ★ تُفتح من أيقونة «البث المباشر» (المسار /publiveedit).
// ★ مؤقّت 5 ثوانٍ + تخطي يدوي/تلقائي نحو صفحة اختيار وضع البث (/live-mode).
// ★ الضغط المستمر على الصفحة يُوقف المؤقّت للقراءة، ورفع الإصبع يستأنفه.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/super_header.dart';

/// PubliveeditScreen — بوابة البث المباشر (المسار /publiveedit).
class PubliveeditScreen extends StatefulWidget {
  const PubliveeditScreen({super.key});

  @override
  State<PubliveeditScreen> createState() => _PubliveeditScreenState();
}

class _PubliveeditScreenState extends State<PubliveeditScreen> {
  static const int _totalSeconds = 5;

  int _remaining = _totalSeconds;
  Timer? _timer;
  bool _navigated = false;

  /// ★ هل إصبع المستخدم ضاغط الآن على الصفحة؟ (وضع القراءة ⇒ المؤقّت متوقف).
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _navigated) return;
      // ★ أثناء الضغط المستمر: لا تنقص العدّاد (يتوقف للقراءة).
      if (_holding) return;
      if (_remaining <= 1) {
        _goLive();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// ★ الانتقال إلى صفحة اختيار وضع البث (زرّان) مع استبدال الصفحة
  ///   حتى لا يعود زر الرجوع إلى هذه البوابة التعريفية.
  void _goLive() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timer?.cancel();
    context.pushReplacement('/live-mode');
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Publiveedit',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 30,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'بوابتك الى تجربة البث التفاعلية',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDescCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: const Text(
        'هنا يمكنك التفاعل والمباشرة بالشراء بنفسك في الوقت اللحظي، '
        'من مزودي الخدمة المتواجدين في البث المباشر لحظة بلحظة.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return const Column(
      children: [
        _FeatureRow(
          icon: LucideIcons.messageSquare,
          title: 'تفاعل لحظي',
          subtitle: 'علق واسال اثناء البث ويصلك الرد مباشرة.',
        ),
        SizedBox(height: 10),
        _FeatureRow(
          icon: LucideIcons.shoppingBag,
          title: 'شراء مباشر',
          subtitle: 'اشتر بنفسك من مزود الخدمة وهو يبث امامك.',
        ),
        SizedBox(height: 10),
        _FeatureRow(
          icon: LucideIcons.users,
          title: 'تواصل مع المزودين',
          subtitle: 'تابع مزودي الخدمة المتواجدين لحظة بلحظة.',
        ),
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _remaining / _totalSeconds,
                strokeWidth: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  // ★ لون مميز أثناء الإيقاف المؤقت (كهرماني) ليعرف المستخدم
                  //   أن العدّاد متوقف الآن وسيستأنف برفع الإصبع.
                  _holding ? Colors.amber : scheme.primary,
                ),
              ),
              Text(
                '$_remaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          // ★ نص الحالة يتبدّل حسب الضغط: توقف للقراءة / عدّ تنازلي.
          _holding
              ? 'المؤقت متوقف — ارفع اصبعك للمتابعة'
              : 'سيتم تحويلك تلقائياً خلال $_remaining ثوان',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_holding) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.hand,
                size: 14,
                color: Colors.amber.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                'اضغط باستمرار على الصفحة للقراءة',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCtaButtons(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _goLive,
            icon: const Icon(LucideIcons.play, size: 20),
            label: const Text(
              'دخول البث الان',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _goLive,
            child: Text(
              'تخطي',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const SuperHeader(title: 'البث المباشر', showBackButton: true),
      // ★ كاشف الضغط على كامل الصفحة:
      //   - بدء اللمس (onPointerDown) ⇒ إيقاف المؤقّت للقراءة.
      //   - رفع الإصبع / إلغاء اللمس ⇒ استئناف المؤقّت.
      //   - الأزرار خارج منطقة الإيقاف (تبقى قابلة للنقر دائماً).
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Listener(
                onPointerDown: (_) {
                  if (!_holding && mounted) {
                    setState(() => _holding = true);
                  }
                },
                onPointerUp: (_) {
                  if (_holding && mounted) {
                    setState(() => _holding = false);
                  }
                },
                onPointerCancel: (_) {
                  if (_holding && mounted) {
                    setState(() => _holding = false);
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: _PulsingLiveBadge()),
                      const SizedBox(height: 16),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildDescCard(),
                      const SizedBox(height: 14),
                      _buildFeatures(),
                      const SizedBox(height: 26),
                      _buildCountdown(context),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: _buildCtaButtons(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// سطر ميزة: ايقونة + عنوان + وصف.
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
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
