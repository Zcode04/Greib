import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../location/location_controller.dart';
import '../location/location_service.dart';
import '../location/place_model.dart';
import '../theme/design_tokens.dart';
import 'place_search_sheet.dart';
import 'real_map_view.dart';

class ConfirmLocationSheet extends StatefulWidget {
  const ConfirmLocationSheet({super.key});
  static Future<PlaceModel?> show(BuildContext context) {
    return showModalBottomSheet<PlaceModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const ConfirmLocationSheet(),
    );
  }
  @override
  State<ConfirmLocationSheet> createState() => _ConfirmLocationSheetState();
}

class _ConfirmLocationSheetState extends State<ConfirmLocationSheet> {
  final _mapKey = GlobalKey<RealMapViewState>();
  LatLng? _center;
  String _address = 'جارٍ تحديد موقعك...';
  bool _busy = false;
  Marker? _picked;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loc = context.read<LocationController>();
    final p = await loc.locateMe();
    if (!mounted) return;
    setState(() {
      _center = p;
      _address = loc.currentAddress.isEmpty ? 'دبي، الإمارات' : loc.currentAddress;
    });
    _mapKey.currentState?.moveTo(p, zoom: 15);
  }

  Future<void> _onCenter(LatLng p) async {
    _center = p;
    if (_busy) return;
    _busy = true;
    final addr = await LocationService.instance.reverseGeocode(p);
    _busy = false;
    if (mounted) setState(() => _address = addr);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = _center;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('حدّد موقعك',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
            IconButton(onPressed: () async {
              final picked = await PlaceSearchSheet.show(context, near: _center);
              if (picked == null || !mounted) return;
              setState(() { _center = picked.latLng; _address = picked.address; });
              _mapKey.currentState?.moveTo(picked.latLng, zoom: 16);
            }, icon: const Icon(LucideIcons.search)),
          ]),
          const SizedBox(height: 8),
          if (center == null)
            const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))
          else
            RealMapView(key: _mapKey, initialCenter: center,
              initialZoom: 15, height: 260,
              extraMarkers: _picked == null ? const [] : [_picked!],
              onCenterChanged: _onCenter),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppRadii.lg)),
            child: Row(children: [
              Icon(LucideIcons.mapPin, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(_address, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700))),
            ])),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () async {
                final p = await context.read<LocationController>().locateMe();
                _mapKey.currentState?.moveTo(p, zoom: 15);
                setState(() => _center = p);
              },
              icon: const Icon(LucideIcons.locateFixed, size: 18),
              label: const Text('موقعي'))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: FilledButton(
              onPressed: _center == null ? null : () {
                final c = _center!;
                final place = PlaceModel(name: 'موقع محدد', address: _address,
                  lat: c.latitude, lng: c.longitude,
                  cityName: context.read<LocationController>().cityName);
                context.read<LocationController>().confirmPlace(place);
                Navigator.pop(context, place);
              },
              child: const Text('تأكيد الموقع',
                style: TextStyle(fontWeight: FontWeight.w800)))),
          ]),
        ],
      ),
    );
  }
}
