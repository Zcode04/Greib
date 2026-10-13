// features/liveserver/liveserver_screen.dart
//
// صفحة «البث المباشر» (Live Server) — محاكاة واجهة بث مباشر بين شخصين.
//
// ★ تُفتح من أيقونة «البث المباشر» في الشريط السفلي (المسار /liveserver).
// ★ زر الرجوع يعتمد على هيدر SuperHeader الموجود أعلى الصفحة فقط (لا تكرار).
// ★ هذه محاكاة واجهة (UI Mock) — سيتم تطويرها لاحقاً بربط بث/قنوات حقيقية.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/super_header.dart';

/// ============================================================================
///  LiveserverScreen — محاكاة بث مباشر بين شخصين (المسار /liveserver).
/// ============================================================================
class LiveserverScreen extends StatefulWidget {
  const LiveserverScreen({super.key});

  @override
  State<LiveserverScreen> createState() => _LiveserverScreenState();
}

class _LiveserverScreenState extends State<LiveserverScreen> {
  // ★ حالات أزرار التحكّم السفلية (تفاعلية).
  bool _micOn = true;
  bool _camOn = true;

  // ★ مؤقّت مدة البث (يُحتسب أثناء وجود الصفحة).
  late int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17), // خلفية داكنة تناسب البث
      extendBody: true,
      extendBodyBehindAppBar: true,
      // ★ زر الرجوع يأتي من الهيدر فقط (SuperHeader) — بدون أي تكرار.
      appBar: const SuperHeader(
        title: 'البث المباشر',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            children: [
              // --- الشاشة الرئيسية (الشخص الأول) ---
              Expanded(
                flex: 3,
                child: _PersonFeed(
                  name: 'المُذيع',
                  role: 'يبثّ الآن',
                  gradient: const [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  micOn: _micOn,
                  camOn: _camOn,
                ),
              ),
              const SizedBox(height: 12),
              // --- شاشة الضيف (الشخص الثاني) — أصغر ---
              Expanded(
                flex: 2,
                child: _PersonFeed(
                  name: 'الضيف',
                  role: 'انضم إلى البث',
                  gradient: const [Color(0xFF6D28D9), Color(0xFFDB2777)],
                  micOn: true,
                  camOn: true,
                ),
              ),
              const SizedBox(height: 16),
              // --- شريط المعلومات (مشاهدون + المؤقّت) + شارة LIVE ---
              _LiveInfoBar(time: _formattedTime, viewers: 128),
              const SizedBox(height: 16),
              // --- أزرار التحكّم ---
              _ControlBar(
                micOn: _micOn,
                camOn: _camOn,
                onToggleMic: () => setState(() => _micOn = !_micOn),
                onToggleCam: () => setState(() => _camOn = !_camOn),
                onEnd: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
///  شاشة شخص واحد (محاكاة بث): خلفية متدرّجة + صورة رمزية + شارة الحالة.
/// ============================================================================
class _PersonFeed extends StatelessWidget {
  final String name;
  final String role;
  final List<Color> gradient;
  final bool micOn;
  final bool camOn;

  const _PersonFeed({
    required this.name,
    required this.role,
    required this.gradient,
    required this.micOn,
    required this.camOn,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ★ تظليل سفلي لقراءة النص.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
            // ★ الصورة الرمزية في المنتصف.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Icon(
                      LucideIcons.circleUser,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // ★ شارة «الكاميرا مطفأة» عند إيقاف الكاميرا.
            if (!camOn)
              const Center(
                child: Icon(
                  LucideIcons.videoOff,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
            // ★ حالة المايك أسفل الشاشة.
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  micOn ? LucideIcons.mic : LucideIcons.micOff,
                  size: 16,
                  color: micOn ? Colors.white : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// ============================================================================
///  شارة «مباشر LIVE» نابضة + عدّاد المشاهدين + المؤقّت.
/// ============================================================================
class _LiveInfoBar extends StatelessWidget {
  final String time;
  final int viewers;

  const _LiveInfoBar({required this.time, required this.viewers});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ★ شارة LIVE النابضة.
        const _PulsingLiveBadge(),
        // ★ عدّاد المشاهدات.
        _InfoChip(
          icon: LucideIcons.eye,
          text: '$viewers',
        ),
        // ★ مؤقّت مدة البث.
        _InfoChip(
          icon: LucideIcons.dot,
          text: time,
          ltr: true,
        ),
      ],
    );
  }
}

/// شارة «مباشر» مع نبض (باستخدام AnimationController داخلي).
class _PulsingLiveBadge extends StatefulWidget {
  const _PulsingLiveBadge();

  @override
  State<_PulsingLiveBadge> createState() => _PulsingLiveBadgeState();
}

class _PulsingLiveBadgeState extends State<_PulsingLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
            child: const Icon(LucideIcons.radio, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Text(
            'مباشر',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// رقاقة معلومات صغيرة (أيقونة + نص) بخلفية شبه شفافة.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool ltr;

  const _InfoChip({required this.icon, required this.text, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            textDirection: ltr ? TextDirection.ltr : null,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


/// ============================================================================
///  أزرار التحكّم السفلية (مايك / كاميرا / إنهاء).
/// ============================================================================
class _ControlBar extends StatelessWidget {
  final bool micOn;
  final bool camOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onEnd;

  const _ControlBar({
    required this.micOn,
    required this.camOn,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleControl(
          icon: micOn ? LucideIcons.mic : LucideIcons.micOff,
          active: micOn,
          tooltip: micOn ? 'كتم المايك' : 'تشغيل المايك',
          onTap: onToggleMic,
        ),
        const SizedBox(width: 20),
        _CircleControl(
          icon: camOn ? LucideIcons.video : LucideIcons.videoOff,
          active: camOn,
          tooltip: camOn ? 'إيقاف الكاميرا' : 'تشغيل الكاميرا',
          onTap: onToggleCam,
        ),
        const SizedBox(width: 20),
        // ★ زر إنهاء البث (أحمر دائم).
        _CircleControl(
          icon: LucideIcons.phoneOff,
          active: true,
          isDestructive: true,
          tooltip: 'إنهاء البث',
          onTap: onEnd,
        ),
      ],
    );
  }
}

/// زر تحكّم دائري مع تغيّر الخلفية حسب الحالة.
class _CircleControl extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDestructive;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleControl({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive
        ? AppColors.error
        : (active
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.08));

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.white
                : (active ? Colors.white : Colors.white54),
            size: 24,
          ),
        ),
      ),
    );
  }
}

