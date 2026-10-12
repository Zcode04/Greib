import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// صف محادثة واحد (Chat Row): Avatar + Name + LastMessage + Time + Badge.
class ConversationTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final int unread;
  final bool online;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    required this.onTap,
    this.unread = 0,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        // ★ 12 أفقي + 8 عمودي — نفس خط البحث/الشيبس/المقفلة، ارتفاع صف ~72.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  // ★ 52 أفاتار متوازن — بين 48 المضغوط و56 الكبير.
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: chat.sendButton.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: TextStyle(fontSize: unread > 0 ? 26 : 22),
                    ),
                  ),
                ),
                if (online)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: chat.onlineDot,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // ★ 12 بين الأفاتار والنص — متناسق مع الشبكة.
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ★ ضغط عمودي: الاسم والرسالة ملتصقان مثل واتساب.
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            // ★ 15 حجم اسم واتساب بدل 16 الافتراضي.
                            fontSize: 15,
                            fontWeight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          // ★ 11 حجم وقت واتساب الصغير.
                          fontSize: 11,
                          color: unread > 0
                              ? chat.sendButton
                              : chat.recordingWaveUnplayed,
                          fontWeight: unread > 0
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  // ★ بدون SizedBox هنا — الاسم فوق الرسالة مباشرة.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            // ★ 13 حجم رسالة واتساب بدل 14.
                            fontSize: 13,
                            color: unread > 0
                                ? chat.inputText
                                : chat.recordingWaveUnplayed,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      // ★ 6 فجوة واتساب بدل 8.
                      const SizedBox(width: 6),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: BoxDecoration(
                            color: chat.sendButton,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: TextStyle(
                                color: chat.sendIcon,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        Icon(
                          LucideIcons.checkCheck,
                          size: 16,
                          color: chat.sendButton,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
