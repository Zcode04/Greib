import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/design_tokens.dart';

/// شريط قابل للتمرير: "رائج الآن" فقط — يختفي عند التمرير.
/// (زر الموقع صار ثابتاً أعلى الشاشة — انظر StickyLocationButton)
class HomeScrollStrip extends StatelessWidget {
  const HomeScrollStrip({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(LucideIcons.flame, color: Color(0xFFFF6B35), size: 20), // لون زخرفي للهب (خارج اللوحة)
      const SizedBox(width: AppSpacing.sm),
      Text('رائج الآن', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: context.textColors.primary)),
    ]);
  }
}
