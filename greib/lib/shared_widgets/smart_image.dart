import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// ============================================================================
///  SmartImage — صورة ذكية تتعامل مع مصدرين بنفس الودجت (Single Widget).
///
///  • "assets/..."  ➜  Image.asset  (صورة محلية داخل التطبيق)
///  • "http(s)://"  ➜  Image.network (صورة من الإنترنت)
///  • أي قيمة أخرى أو فشل التحميل ➜  أيقونة بديلة (Fallback)
///
///  الفائدة: ملف الـ JSON (SSOT) يستطيع أن يحتوي النوعين بدون أي شرط في الواجهة.
/// ============================================================================
class SmartImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Widget? placeholder;
  final int? cacheWidth;

  const SmartImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.cacheWidth,
  });

  /// هل المسار صورة محلية داخل حزمة التطبيق (Local Asset)؟
  static bool isAsset(String path) =>
      !path.startsWith('http://') && !path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final path = src;

    if (path == null || path.trim().isEmpty) {
      return placeholder ?? const _Fallback();
    }

    final errorBuilder = (BuildContext _, Object __, StackTrace? ___) =>
        placeholder ?? const _Fallback();

    if (isAsset(path)) {
      return Image.asset(
        path,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: errorBuilder,
      );
    }

    return Image.network(
      path,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: errorBuilder,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.image,
        size: 28,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
