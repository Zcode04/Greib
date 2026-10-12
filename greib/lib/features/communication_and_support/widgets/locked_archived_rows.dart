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
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.lock, size: 40, color: theme.hintColor),
              const SizedBox(height: 12),
              Text(
                'الدردشات المقفلة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اسحب أي محادثة لليسار لقفلها ببصمتك — لا توجد دردشات مقفلة بعد.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showArchivedSheet(
    BuildContext context,
    ThemeData theme,
    dynamic chat,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.archive, size: 40, color: theme.hintColor),
              const SizedBox(height: 12),
              Text(
                'الدردشات المؤرشفة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'المحادثات المؤرشفة تبقى مخفية هنا — لا توجد عناصر مؤرشفة بعد.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: chat.composerIcon),
            const SizedBox(width: 16),
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
