import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// ============================================================================
///  CallLogTile — صف مكالمة واحد بستايل واتساب.
///  Avatar + Name + (اتجاه/نوع/وقت/مدة) + زر اتصال.
///  direction: incoming | outgoing | missed
///  callType: voice | video
/// ============================================================================
class CallLogTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String direction;
  final String callType;
  final String time;
  final String? duration;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;

  const CallLogTile({
    super.key,
    required this.name,
    required this.avatar,
    required this.direction,
    required this.callType,
    required this.time,
    this.duration,
    this.onTap,
    this.onCallTap,
  });

  bool get _isMissed => direction == 'missed';
  bool get _isVideo => callType == 'video';

  IconData get _directionIcon {
    switch (direction) {
      case 'incoming':
        return LucideIcons.arrowDownLeft;
      case 'outgoing':
        return LucideIcons.arrowUpRight;
      case 'missed':
      default:
        return LucideIcons.arrowDownLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    // ★ الفائتة حمراء مثل واتساب، والبقية بلون التطبيق.
    final statusColor = _isMissed ? AppColors.error : chat.sendButton;

    return InkWell(
      onTap: onTap,
      child: Padding(
        // ★ نفس شبكة المحادثات: 12 أفقي + 8 عمودي.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: chat.sendButton.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(avatar, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      // ★ الفائتة بلون مميز مثل واتساب.
                      color: _isMissed ? AppColors.error : null,
                      fontWeight: _isMissed ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(_directionIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Icon(
                        _isVideo ? LucideIcons.video : LucideIcons.phone,
                        size: 13,
                        color: chat.mutedText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          duration != null ? '$time · $duration' : time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: chat.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // ★ زر اتصال سريع — يعيد نفس نوع المكالمة.
            IconButton(
              icon: Icon(
                _isVideo ? LucideIcons.video : LucideIcons.phone,
                size: 20,
                color: chat.sendButton,
              ),
              onPressed:
                  onCallTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isVideo
                              ? 'مكالمة فيديو مع $name 📹'
                              : 'مكالمة صوتية مع $name 📞',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
              tooltip: _isVideo ? 'مكالمة فيديو' : 'مكالمة صوتية',
            ),
          ],
        ),
      ),
    );
  }
}
