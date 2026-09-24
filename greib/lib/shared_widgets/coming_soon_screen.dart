import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/design_tokens.dart';
import 'app_button.dart';

/// صفحة تفصيلية عامة مؤقتة لأي مسار غير مُنفّذ بعد.
/// تمنع الكراش / الشاشة الفارغة عند الضغط على أزرار مثل:
/// عرض الكل، الفنادق، السفر، الأطباء، الطلبات، الخدمات...
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? route;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accentFor(isDark);

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Icon(LucideIcons.rocket, size: 36, color: accent),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle ?? 'هذه الصفحة ستتوفر قريباً ضمن النسخة الحالية.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              if (route != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  route!,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'رجوع للرئيسية',
                icon: LucideIcons.house,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
