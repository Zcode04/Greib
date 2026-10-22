import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/user_avatar.dart';

/// شريط إجراءات أعلى قسم «رائج» — بالترتيب البصري المطلوب:
/// (search) (تصفح آلي + clock-11) (user)
///
/// ملاحظة الاتجاه: التطبيق RTL، لذا نرتّب الأطفال في الـ Row كالتالي:
/// [user, موسّع(تصفح آلي), search] ليظهر بصرياً من اليمين: user ثم
/// التصفح الآلي في المنتصف ثم search في اليسار.
/// زر user يفتح صفحة الحساب (/profile).
///
/// منطق «تصفح آلي» هو نفس منطق StickyLocationButton السابق (Ticker يمرّر
/// لأسفل الصفحة تلقائياً، يتوقف عند النهاية أو عند سحب المستخدم).
class HomeActionBar extends StatefulWidget {
  const HomeActionBar({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<HomeActionBar> createState() => _HomeActionBarState();
}

class _HomeActionBarState extends State<HomeActionBar>
    with SingleTickerProviderStateMixin {
  static const double _maxStep = 2.4;
  static const double _acceleration = 0.6;

  Ticker? _ticker;
  bool _running = false;

  ScrollController get _controller => widget.scrollController;

  @override
  void didUpdateWidget(covariant HomeActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) _stop();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  bool get _atEnd {
    if (!_controller.hasClients) return true;
    final p = _controller.position;
    return p.pixels >= p.maxScrollExtent - 0.5;
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_controller.hasClients) {
      _stop();
      return;
    }
    if (_atEnd) {
      _stop();
      return;
    }
    final s = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final speed = _maxStep * (1 + _acceleration * (s / 4).clamp(0.0, 1.0));
    final next = _controller.offset + speed;
    _controller.jumpTo(next.clamp(0.0, _controller.position.maxScrollExtent));
  }

  void _onUserScroll() {
    if (!_running) return;
    if (_controller.position.userScrollDirection != ScrollDirection.idle) {
      _stop();
    }
  }

  void _toggle() => _running ? _stop() : _start();

  void _start() {
    if (!mounted || !_controller.hasClients) return;
    if (_atEnd) _controller.jumpTo(0);
    setState(() => _running = true);
    _controller.addListener(_onUserScroll);
    _ticker = createTicker(_onTick)..start();
  }

  void _stop() {
    if (_controller.hasClients) _controller.removeListener(_onUserScroll);
    _ticker?.stop();
    _ticker = null;
    if (mounted && _running) setState(() => _running = false);
    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    // ★ ستايل زجاجي ليلي (مثل الصورة): سطح داكن شفاف + stroke أزرق خفيف + توهج ناعم
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          // ★ زر البروفايل (نفس صورة الهيدر عبر UserAvatar) — يفتح /profile.
          _CircleAvatarButton(
            onTap: () => context.push('/profile'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.full),
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // ★ ليلي: أسود باهت شفاف (زجاجي) — نهاري: كما كان
                    color: isDark
                        ? context.backgroundColors.surface.withValues(alpha: 0.72)
                        : theme.colorScheme.surface.withValues(
                            alpha: _running ? 1.0 : 0.92,
                          ),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      // ★ stroke أزرق زجاجي: أنعم في الحالة العادية، أقوى عند التشغيل
                      color: accent.withValues(alpha: _running ? 0.9 : 0.45),
                      width: _running ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _running ? LucideIcons.pause : LucideIcons.clock11,
                        size: 16,
                        color: accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _running ? 'إيقاف' : 'تصفح آلي',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            icon: LucideIcons.search,
            tooltip: 'البحث',
            onTap: () => context.push('/search'),
          ),
        ],
      ),
    );
  }
}

/// زر بروفايل دائري بنفس هوية أزرار التطبيق (سطح + حد).
/// يعرض صورة المستخدم من UserData ويفتح صفحة الحساب — متسق مع الهيدر.
class _CircleAvatarButton extends StatelessWidget {
  const _CircleAvatarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: Tooltip(
          message: 'الحساب',
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              // ★ ليلي: زجاجي داكن — نهاري: كما كان
              color: isDark
                  ? context.backgroundColors.surface.withValues(alpha: 0.72)
                  : theme.colorScheme.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(
                // ★ stroke أزرق زجاجي خفيف
                color: accent.withValues(alpha: isDark ? 0.45 : 0.25),
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: const UserAvatar(size: 36, iconSize: 18),
          ),
        ),
      ),
    );
  }
}

/// زر أيقونة بسيط: الأيقونة فقط بلا خلفية ولا حد.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          // ★ مساحة لمس مريحة (42×42) مع إظهار الأيقونة فقط.
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 18, color: accent),
          ),
        ),
      ),
    );
  }
}
