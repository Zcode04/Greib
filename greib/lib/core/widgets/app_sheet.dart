import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../theme/design_tokens.dart';

/// ============================================================================
///  showAppSheet — ورقة سفلية موحّدة لكل Flows الحجز/الاختيار في التطبيق
///  (BottomSheet-First UX): انتقال سريع دون مغادرة الشاشة الحالية.
///  الاستخدام:
///    await showAppSheet(context, builder: (_) => LocationPickerSheet());
/// ============================================================================
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
    ),
    builder: (sheetContext) {
      // نمط مقبض السحب الموحّد أعلى الورقة.
      // ★ لون المقبض من اللوحة الديناميكية (يتبع الوضع والتخصيص).
      final handle = Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: sheetContext.textColors.tertiary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
      );

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            handle,
            Flexible(child: builder(sheetContext)),
          ],
        ),
      );
    },
  );
}