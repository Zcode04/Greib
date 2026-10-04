import 'package:flutter/gestures.dart' show Drag;
import 'package:flutter/material.dart';

/// ============================================================================
///  DraggableSheetBody — جسم ورقة سفلية ديناميكي (Draggable):
///  ارتفاعه نسبة من الشاشة ويتغيّر مع السحب — للأعلى تكبير (حتى 92%)
///  مع Snap عند مواضع محددة، وللأسفل تصغير حتى الإغلاق.
///
///  `builder` يستلم `ScrollController` الخاص بالورقة لربطه بالقائمة
///  الداخلية فتمرّر وتوسّع الورقة في آنٍ معاً.
///
///  الاستخدام:
///    DraggableSheetBody(
///      initialExtent: 0.6,
///      builder: (context, controller) => ListView(..., controller: controller),
///    )
/// ============================================================================
class DraggableSheetBody extends StatelessWidget {
  const DraggableSheetBody({
    super.key,
    required this.builder,
    this.initialExtent = 0.5,
    this.snapSizes = const [0.32, 0.42, 0.5, 0.6, 0.7, 0.8, 0.92],
  });

  final Widget Function(BuildContext context, ScrollController controller)
  builder;
  final double initialExtent;
  final List<double> snapSizes;

  static const double _kMinExtent = 0.32;
  static const double _kMaxExtent = 0.92;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialExtent,
      minChildSize: _kMinExtent,
      maxChildSize: _kMaxExtent,
      // ★ Snap: يتوقف عند المواضع المحددة (تجربة احترافية).
      snap: true,
      snapSizes: snapSizes,
      builder: (context, controller) => builder(context, controller),
    );
  }
}

/// ============================================================================
///  SheetDragArea — منطقة سحب داخل الورقة (مثل رأسها):
///  تنشئ نشاط سحب حقيقي على نفس `ScrollController` الخاص بـ
///  `DraggableScrollableSheet`، فيصبح السحب للأعلى توسّعاً ولأسفل
///  تصغيراً/إغلاقاً — تماماً كالسحب على القوائم نفسها.
///
///  الاستخدام:
///    SheetDragArea(
///      controller: scrollController,
///      child: Padding(..., child: Text('رأس الورقة')),
///    )
/// ============================================================================
class SheetDragArea extends StatefulWidget {
  const SheetDragArea({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<SheetDragArea> createState() => _SheetDragAreaState();
}

class _SheetDragAreaState extends State<SheetDragArea> {
  Drag? _drag;

  @override
  void dispose() {
    _drag?.cancel();
    _drag = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ★ عرض كامل ⇒ منطقة السحب تغطي كل عرض الرأس.
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onVerticalDragStart: (details) {
          _drag = widget.controller.position.drag(details, () => _drag = null);
        },
        onVerticalDragUpdate: (details) {
          _drag?.update(
            DragUpdateDetails(
              delta: Offset(0, details.delta.dy),
              primaryDelta: details.delta.dy,
              globalPosition: details.globalPosition,
              sourceTimeStamp: details.sourceTimeStamp,
            ),
          );
        },
        onVerticalDragEnd: (details) {
          _drag?.end(details);
          _drag = null;
        },
        onVerticalDragCancel: () {
          _drag?.cancel();
          _drag = null;
        },
        child: widget.child,
      ),
    );
  }
}
