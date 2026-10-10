import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../location/place_model.dart';
import '../location/places_service.dart';
import '../theme/design_tokens.dart';

/// PlaceSearchSheet — بحث حقيقي مع debounce ونتائج بإحداثيات.
class PlaceSearchSheet extends StatefulWidget {
  final LatLng? near;
  const PlaceSearchSheet({super.key, this.near});

  static Future<PlaceModel?> show(BuildContext context, {LatLng? near}) {
    return showModalBottomSheet<PlaceModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PlaceSearchSheet(near: near),
    );
  }

  @override
  State<PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends State<PlaceSearchSheet> {
  final _ctrl = TextEditingController();
  List<PlaceModel> _results = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    PlacesService.instance.searchDebounced(
      '',
      (r, l) => mounted ? setState(() {
        _results = r;
        _loading = l;
      }) : null,
      near: widget.near,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    PlacesService.instance.searchDebounced(
      q,
      (r, l) => mounted ? setState(() {
        _results = r;
        _loading = l;
      }) : null,
      near: widget.near,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'ابحث عن مكان… (برج خليفة، مارينا…)',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: _results.isEmpty && !_loading
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'لا نتائج — جرّب اسماً آخر',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = _results[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                          child: Icon(LucideIcons.mapPin,
                              size: 18,
                              color: theme.colorScheme.primary),
                        ),
                        title: Text(p.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          p.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: p.distanceKm == null
                            ? null
                            : Text(
                                p.distanceLabel(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        onTap: () => Navigator.pop(context, p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
