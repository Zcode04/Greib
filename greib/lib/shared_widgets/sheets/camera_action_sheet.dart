// Bottom sheet: visual search (text + capture/attach then analysis screen).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../../features/visual_search/visual_search_analysis_screen.dart';

Future<void> showCameraActionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.backgroundColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _VisualSearchSheet(),
  );
}

class _VisualSearchSheet extends StatefulWidget {
  const _VisualSearchSheet();
  @override
  State<_VisualSearchSheet> createState() => _VisualSearchSheetState();
}

class _VisualSearchSheetState extends State<_VisualSearchSheet> {
  final TextEditingController _query = TextEditingController();
  bool _busy = false;
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.camera);
      if (!mounted) return;
      setState(() => _busy = false);
      if (f == null) return;
      _open(File(f.path), 'الكاميرا');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذّر فتح الكاميرا — تعمل على هاتف حقيقي، تحقق من الأذونات',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _attach() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final f = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      setState(() => _busy = false);
      if (f == null) return;
      _open(File(f.path), 'المعرض');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر فتح المعرض — حاول مجدداً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _open(File img, String src) {
    final q = _query.text.trim();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualSearchAnalysisScreen(
          imageFile: img,
          sourceLabel: src,
          textQuery: q.isEmpty ? null : q,
        ),
      ),
    );
  }

  void _searchText() {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualSearchAnalysisScreen(textQuery: q),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final textColor = context.textColors.primary;
    final secondary = context.textColors.secondary;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.scanSearch, size: 20, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البحث البصري',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'ابحث بالكتابة أو بالصورة مثل العدسات الذكية',
                        style: TextStyle(fontSize: 12, color: secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchText(),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج، مكان، خدمة...',
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 20,
                  color: secondary,
                ),
                filled: true,
                fillColor: context.backgroundColors.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _opt(
              context,
              icon: LucideIcons.camera,
              title: 'التقاط صورة والبحث عنها',
              sub: 'كاميرا الهاتف الفعلية (تعمل على هاتف حقيقي)',
              hl: true,
              tap: _capture,
            ),
            _opt(
              context,
              icon: LucideIcons.imagePlus,
              title: 'إرفاق صورة والبحث عنها',
              sub: 'اختر صورة من المعرض لتحليلها',
              hl: false,
              tap: _attach,
            ),
            if (_query.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _searchText,
                    icon: const Icon(LucideIcons.search, size: 18),
                    label: const Text('بحث بالنص'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _opt(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String sub,
    required bool hl,
    required VoidCallback tap,
  }) {
    final accent = context.accentColor;
    final textColor = context.textColors.primary;
    return ListTile(
      enabled: !_busy,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hl
              ? accent.withValues(alpha: 0.15)
              : context.backgroundColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: hl ? accent : textColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      ),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: tap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
