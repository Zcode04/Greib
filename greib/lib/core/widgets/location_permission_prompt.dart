import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../location/location_service.dart';
import '../extensions/context_extensions.dart';

/// ============================================================================
///  LocationPermissionPrompt — Dialog احترافي يشرح سبب طلب الموقع ثم يطلبه.
///
///  الاستخدام:
///    final granted = await LocationPermissionPrompt.request(context);
/// ============================================================================
class LocationPermissionPrompt extends StatefulWidget {
  const LocationPermissionPrompt({super.key});

  /// يعرض الـ dialog ويعيد true إذا مُنح الإذن.
  static Future<bool> request(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LocationPermissionPrompt(),
    );
    return result ?? false;
  }

  @override
  State<LocationPermissionPrompt> createState() =>
      _LocationPermissionPromptState();
}

class _LocationPermissionPromptState extends State<LocationPermissionPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _allow() async {
    setState(() => _loading = true);
    final granted = await LocationService.instance.ensurePermission();
    if (mounted) Navigator.of(context).pop(granted);
  }

  void _skip() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    // اللوحة المركزية تتكفّل بالوضعين ⇒ لا حاجة لِفحص السطوع هنا.
    final bg   = context.backgroundColors.surface;
    final tint = context.iconColors.primary;
    final text = context.textColors.primary;
    final sub  = context.textColors.secondary;
    final onAccent = context.textColors.onAccent;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── أيقونة GPS نابضة ──
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tint.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: tint.withValues(alpha: 0.25),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(LucideIcons.locateFixed, size: 42, color: tint),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'الوصول إلى موقعك',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لعرض الخريطة الحية بموقعك الحقيقي وإيجاد أقرب الخدمات إليك، نحتاج إذن الوصول إلى موقعك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: sub,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            // ── ميزات سريعة ──
            _featureRow(tint, LucideIcons.map, 'خريطة حية بموقعك الدقيق'),
            _featureRow(tint, LucideIcons.store, 'أقرب المتاجر والمحلات'),
            _featureRow(tint, LucideIcons.car, 'التوصيل بأسرع وقت'),
            const SizedBox(height: 24),
            // ── زر السماح ──
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: tint,
                  foregroundColor: onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _loading ? null : _allow,
                icon: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: onAccent,
                        ),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: Text(
                  _loading ? 'جارٍ التحقق…' : 'السماح بالوصول',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ── زر "لاحقاً" ──
            TextButton(
              onPressed: _skip,
              child: Text(
                'لاحقاً',
                style: TextStyle(color: sub, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(Color tint, IconData icon, String label) {
    final sub = context.textColors.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: tint),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: sub, fontSize: 13)),
        ],
      ),
    );
  }
}
