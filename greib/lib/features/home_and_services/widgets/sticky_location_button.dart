import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/location_picker.dart';

/// زر ثابت أعلى يسار الشاشة — "تصفح آلي" مع أيقونة circle-gauge.
///
/// الضغط الأول يبدأ تمريراً تلقائياً متواصلاً لأسفل صفحة الرئيسية،
/// والضغط مرة ثانية يوقفه. يتوقف تلقائياً عند الوصول لأسفل الصفحة،
/// أو إذا سحب المستخدم بنفسه، أو عند مغادرة الشاشة.
class StickyLocationButton extends StatefulWidget {
  const StickyLocationButton({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<StickyLocationButton> createState() => _StickyLocationButtonState();
}

class _StickyLocationButtonState extends State<StickyLocationButton>
    with SingleTickerProviderStateMixin {
  /// سرعة التمرير بالبكسل لكل إطار (~16ms) عند السرعة القصوى.
  static const double _maxStep = 2.4;

  /// معامل التسارع: كلما طال التمرير زادت السرعة تدريجياً.
  static const double _acceleration = 0.6;

  Ticker? _ticker;
  bool _running = false;

  ScrollController get _controller => widget.scrollController;

  @override
  void didUpdateWidget(covariant StickyLocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _stop();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  bool get _atEnd {
    if (!_controller.hasClients) return true;
    final position = _controller.position;
    return position.pixels >= position.maxScrollExtent - 0.5;
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
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final speed = _maxStep * (1 + _acceleration * (seconds / 4).clamp(0.0, 1.0));
    final next = _controller.offset + speed;
    final target = _controller.position.maxScrollExtent;
    _controller.jumpTo(next.clamp(0.0, target));
  }

  /// السحب اليدوي يلغي التمرير التلقائي (احتراماً لتدخل المستخدم).
  void _onUserScroll() {
    if (!_running) return;
    if (_controller.position.userScrollDirection != ScrollDirection.idle) {
      _stop();
    }
  }

  void _toggle() => _running ? _stop() : _start();

  void _start() {
    if (!mounted || !_controller.hasClients) return;
    if (_atEnd) {
      // في أسفل الصفحة: نعيد للأعلى أولاً ثم نبدأ.
      _controller.jumpTo(0);
    }
    setState(() {
      _running = true;
    });
    _controller.addListener(_onUserScroll);
    _ticker = createTicker(_onTick)..start();
  }

  void _stop() {
    if (_controller.hasClients) {
      _controller.removeListener(_onUserScroll);
    }
    _ticker?.stop();
    _ticker = null;
    if (mounted && _running) {
      setState(() => _running = false);
    }
    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.full),
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(
                    alpha: _running ? 1.0 : 0.92,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  border: Border.all(
                    color: accent.withValues(alpha: _running ? 0.9 : 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _running ? 0.2 : 0.12),
                      blurRadius: _running ? 16 : 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _running ? LucideIcons.pause : LucideIcons.circleGauge,
                      size: 14,
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
      ),
    );
  }
}

/// كبسولة الموقع (المدينة) — تُستخدم أيضاً داخل شريط الأقسام.
class LocationPill extends StatelessWidget {
  const LocationPill({super.key, this.compact = false});

  final bool compact;

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = context.watch<LocationController>().cityName;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: () => _open(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 5 : 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.mapPin,
                size: compact ? 12 : 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (compact
                              ? theme.textTheme.labelSmall
                              : theme.textTheme.labelMedium)
                          ?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevronDown,
                size: compact ? 12 : 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
