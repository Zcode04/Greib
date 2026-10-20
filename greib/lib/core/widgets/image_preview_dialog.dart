import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/mock_data/mock_data.dart';
import '../../core/models/service_model.dart';
import '../../core/extensions/context_extensions.dart';

/// ============================================================================
///  ImagePreviewDialog — معاينة صور البطاقة:
///  شاشة كاملة سوداء مع PageView للتنقل بين الصور، عدّاد «2/3»،
///  زر إغلاق، وتكبير/تصغير بالنقر (InteractiveViewer).
///  تدعم روابط الشبكة ومسارات الأصول المحلية معاً.
///
///  الاستخدام:
///    showGeneralDialog(
///      context: context,
///      barrierDismissible: true,
///      pageBuilder: (_, _, _) =>
///          ImagePreviewDialog(images: images, service: service),
///    );
/// ============================================================================
class ImagePreviewDialog extends StatefulWidget {
  const ImagePreviewDialog({
    super.key,
    required this.images,
    required this.service,
  });

  final List<String> images;
  final ServiceCategory service;

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog>
    with SingleTickerProviderStateMixin {
  late final PageController _page = PageController(initialPage: 0);
  late int _index = 0;

  final TransformationController _zoom = TransformationController();
  late final AnimationController _zoomAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  Animation<Matrix4>? _zoomTween;
  bool _zoomed = false;
  Size _viewport = Size.zero;

  Offset? _pressAt;
  DateTime? _pressedAt;

  static const double _kTapSlop = 12;
  static const Duration _kTapWindow = Duration(milliseconds: 350);

  void _onPointerDown(PointerDownEvent event) {
    _pressAt = event.position;
    _pressedAt = DateTime.now();
  }

  void _onPointerUp(PointerUpEvent event) {
    final start = _pressAt;
    final at = _pressedAt;
    _pressAt = null;
    _pressedAt = null;
    if (start == null || at == null) return;
    final moved = (event.position - start).distance;
    final held = DateTime.now().difference(at);
    if (moved < _kTapSlop && held < _kTapWindow) _toggleZoom();
  }

  @override
  void initState() {
    super.initState();
    _zoomAnim.addListener(() {
      final tween = _zoomTween;
      if (tween != null) _zoom.value = tween.value;
    });
  }

  /// تكبير/تصغير ناعم حول مركز العرض.
  void _animateZoomTo(bool zoomIn) {
    final target = zoomIn ? 2.5 : 1.0;
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    final end = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(target, target, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);

    _zoomTween = Matrix4Tween(
      begin: _zoom.value.clone(),
      end: end,
    ).animate(CurvedAnimation(parent: _zoomAnim, curve: Curves.easeOutCubic));

    setState(() => _zoomed = zoomIn);
    _zoomAnim
      ..reset()
      ..forward();
  }

  void _toggleZoom() => _animateZoomTo(!_zoomed);

  @override
  void dispose() {
    _zoomAnim.dispose();
    _page.dispose();
    _zoom.dispose();
    super.dispose();
  }

  Widget _fallback() => Center(
    child: Icon(
      MockData.getIconByName(widget.service.iconName),
      size: 72,
      color: widget.service.color,
    ),
  );

  Widget _image(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _viewport = Size(constraints.maxWidth, constraints.maxHeight);
          return _buildStack(context);
        },
      ),
    );
  }

  Widget _buildStack(BuildContext context) {
    final many = widget.images.length > 1;
    // محتوى فوق الصور ⇒ ألوان "على الوسائط" (فاتحة دائماً فوق طبقة تعتيم).
    final onMedia = context.textColors.onMedia;
    final iconOnMedia = context.iconColors.onMedia;
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          child: PageView.builder(
            controller: _page,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              if (_zoomed) _animateZoomTo(false);
              setState(() => _index = i);
            },
            itemBuilder: (context, i) => InteractiveViewer(
              transformationController: _zoom,
              minScale: 1,
              maxScale: 4,
              panEnabled: _zoomed,
              onInteractionEnd: (_) => setState(
                () => _zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01,
              ),
              child: Center(child: _image(widget.images[i])),
            ),
          ),
        ),
        // عدّاد الصور.
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 8,
          start: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: onMedia.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: TextStyle(color: onMedia, fontSize: 12),
            ),
          ),
        ),
        // شعار التطبيق + أزرار التحكم.
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 4,
          end: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'گريب منك',
                style: TextStyle(
                  color: onMedia,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _toggleZoom,
                icon: Icon(
                  _zoomed ? LucideIcons.zoomOut : LucideIcons.zoomIn,
                  color: iconOnMedia,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: iconOnMedia),
              ),
            ],
          ),
        ),
        // مؤشرات الصور (نقاط سفلية).
        if (many)
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: onMedia.withValues(
                      alpha: i == _index ? 1 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
