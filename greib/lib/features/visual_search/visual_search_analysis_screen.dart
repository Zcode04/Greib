// Visual search analysis screen - AI-style flow with mock results.
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/widgets/super_header.dart';

class VisualSearchAnalysisScreen extends StatefulWidget {
  final File? imageFile;
  final String? sourceLabel;
  final String? textQuery;
  const VisualSearchAnalysisScreen({
    super.key,
    this.imageFile,
    this.sourceLabel,
    this.textQuery,
  });
  @override
  State<VisualSearchAnalysisScreen> createState() => _VSState();
}

class _VSState extends State<VisualSearchAnalysisScreen> {
  static const phases = [
    'أقرأ الصورة وأجهزها للتحليل...',
    'أستخرج العناصر والألوان والأشكال...',
    'اطابق العناصر مع قاعدة الخدمات...',
    'أرتب النتائج الأقرب إليك...',
  ];
  int _phase = 0;
  bool _done = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) return;
      if (_phase < phases.length - 1) {
        setState(() => _phase++);
      } else {
        _timer?.cancel();
        setState(() => _done = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: const SuperHeader(title: 'البحث البصري', showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _Preview(
              imageFile: widget.imageFile,
              sourceLabel: widget.sourceLabel,
              textQuery: widget.textQuery,
            ),
            const SizedBox(height: 14),
            if (!_done)
              _Analyzing(phase: _phase)
            else
              const Column(
                children: [_Detected(), SizedBox(height: 12), _Matches()],
              ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final File? imageFile;
  final String? sourceLabel;
  final String? textQuery;
  const _Preview({this.imageFile, this.sourceLabel, this.textQuery});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageFile != null)
            Image.file(imageFile!, fit: BoxFit.cover)
          else
            Container(
              color: context.accentColor.withValues(alpha: 0.1),
              child: Icon(
                LucideIcons.scanSearch,
                size: 64,
                color: context.accentColor,
              ),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sourceLabel != null ? 'من $sourceLabel' : 'بحث بالنص',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          if (textQuery != null && textQuery!.isNotEmpty)
            Positioned(
              bottom: 10,
              right: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textQuery!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Analyzing extends StatelessWidget {
  final int phase;
  const _Analyzing({required this.phase});
  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'أحلل الصورة الآن...',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (phase + 1) / 4,
              minHeight: 6,
              backgroundColor: accent.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _VSState.phases[phase],
              key: ValueKey(phase),
              style: TextStyle(
                fontSize: 13,
                color: context.textColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Detected extends StatelessWidget {
  const _Detected();
  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    const objs = ['حذاء رياضي', 'لون أبيض', 'خامة جلدية', 'رباط كلاسيكي'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.backgroundColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 18, color: accent),
              const SizedBox(width: 6),
              const Text(
                'الصورة تحتوي على:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in objs)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    o,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'أبحث لك الآن عن أقرب المنتجات والخدمات المطابقة...',
            style: TextStyle(fontSize: 12, color: context.textColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _Matches extends StatelessWidget {
  const _Matches();
  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    const names = [
      'متجر الخطوة الرياضية',
      'سوق غريب المركزي',
      'خدمة البحث عن منتج',
    ];
    const descs = [
      'حذاء مشابه - توصيل ساعتين',
      'نفس التصميم بعدة ألوان',
      'نوصله لك من أي متجر',
    ];
    const prices = ['1,250 أوقية', '980 أوقية', 'حسب الطلب'];
    const scores = ['96%', '91%', '88%'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نتائج مطابقة (تجريبية)',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < names.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.backgroundColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.backgroundColors.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.store, size: 22, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        names[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        descs[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textColors.secondary,
                        ),
                      ),
                      Text(
                        prices[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    scores[i],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
