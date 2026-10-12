import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';

/// ============================================================================
///  LockedAndArchivedRows — صفّا «الدردشات المقفلة» و«مؤرشفة» مثل واتساب.
///  يظهران فوق القائمة مباشرة (بعد الفلاتر)، بأيقونة + عدّاد.
/// ============================================================================
class LockedAndArchivedRows extends StatelessWidget {
  final int lockedCount;
  final int archivedCount;
  final VoidCallback? onLockedTap;
  final VoidCallback? onArchivedTap;

  const LockedAndArchivedRows({
    super.key,
    this.lockedCount = 0,
    this.archivedCount = 0,
    this.onLockedTap,
    this.onArchivedTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WhatsAppMetaRow(
          icon: LucideIcons.lock,
          title: 'الدردشات المقفلة',
          trailing: lockedCount > 0 ? '$lockedCount' : null,
          onTap: onLockedTap ?? () => _showLockedSheet(context, theme, chat),
        ),
        _WhatsAppMetaRow(
          icon: LucideIcons.archive,
          title: 'مؤرشفة',
          trailing: archivedCount > 0 ? '$archivedCount' : null,
          onTap:
              onArchivedTap ?? () => _showArchivedSheet(context, theme, chat),
        ),
      ],
    );
  }

  static void _showLockedSheet(
    BuildContext context,
    ThemeData theme,
    dynamic chat,
  ) {
    _showBrowOnlySheet(
      context: context,
      theme: theme,
      icon: LucideIcons.lock,
      title: 'الدردشات المقفلة',
    );
  }

  static void _showArchivedSheet(
    BuildContext context,
    ThemeData theme,
    dynamic chat,
  ) {
    _showBrowOnlySheet(
      context: context,
      theme: theme,
      icon: LucideIcons.archive,
      title: 'الدردشات المؤرشفة',
    );
  }

  /// ★ ورقة احترافية موحدة: هذه الميزة متوفرة في تطبيق براو الأصلي فقط —
  ///   وليست في «گريب منك»، ولا يمكن أن تعمل هنا. مع زر تحميل من المتاجر.
  static void _showBrowOnlySheet({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
  }) {
    final chat = context.chatColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: chat.sendButton.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: chat.sendButton),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هذه الميزة متوفرة في تطبيق براو الأصلي فقط، وليست في تطبيق گريب منك — ولا يمكن أن تعمل هنا.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.6,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: const Text('تحميل تطبيق براو من المتاجر'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('يمكنك تنزيله من الموقع الرسمي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صف ميتا واحد بأسلوب واتساب: أيقونة يسار + نص + عدّاد.
class _WhatsAppMetaRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _WhatsAppMetaRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        // ★ 12 أفقي مثل البحث/الشيبس — خط محاذاة عمودي واحد.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: chat.composerIcon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: chat.sendButton,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
