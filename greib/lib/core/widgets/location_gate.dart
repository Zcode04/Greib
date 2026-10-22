import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../extensions/context_extensions.dart';
import '../location/location_controller.dart';
import '../location/location_service.dart';
import '../theme/design_tokens.dart';

/// LocationGate — بوابة إذن الموقع الدقيق عند أول فتح.
///
/// ★ يُعرض مرة واحدة حتى يمنح المستخدم الإذن أو يتجاوزه صراحة.
/// بعده يصبح التطبيق صلباً: اسم المنطقة + إحداثياتها ظاهران دائماً.
class LocationGate extends StatefulWidget {
  final Widget child;
  const LocationGate({super.key, required this.child});

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate> {
  bool _checked = false;
  bool _granted = false;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await LocationService.instance.hasPermission();
    if (!mounted) return;
    setState(() {
      _checked = true;
      _granted = ok;
    });
    if (ok) {
      await context.read<LocationController>().locateMe();
    }
  }

  Future<void> _request() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    final ok = await LocationService.instance.ensurePermission();
    if (!mounted) return;
    setState(() => _requesting = false);
    if (ok) {
      setState(() => _granted = true);
      await context.read<LocationController>().locateMe();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_granted) return widget.child;
    return _PermissionSheet(
      requesting: _requesting,
      onAllow: _request,
      onSkip: () => setState(() => _granted = true),
    );
  }
}

class _PermissionSheet extends StatelessWidget {
  final bool requesting;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const _PermissionSheet({
    required this.requesting,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.mapPin,
                    size: 44, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 28),
              Text('حدّد موقعك بدقة',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text(
                'نحتاج إذن الوصول للموقع الدقيق لعرض منطقتك '
                '(الولاية والمقاطعة) بجانب إحداثياتها، '
                'وترشيح الأقرب إليك في موريتانيا.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: requesting ? null : onAllow,
                icon: requesting
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.textColors.onAccent))
                    : const Icon(LucideIcons.locateFixed, size: 20),
                label: Text(requesting
                    ? 'جارٍ طلب الإذن…'
                    : 'السماح بالوصول الدقيق'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadii.lg),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSkip,
                child: const Text('المتابعة بدون موقع (نواكشوط)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
