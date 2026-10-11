import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// ============================================================================
///  معاينة الرد المقتبس فوق شريط الإدخال — بأسلوب WhatsApp الدقيق
/// ============================================================================
class ComposerReplyPreview extends StatelessWidget {
  final Map<String, dynamic> quoted;
  final VoidCallback onCancel;

  const ComposerReplyPreview({
    super.key,
    required this.quoted,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final content = (quoted['content'] as String? ?? '').trim();
    final sender = (quoted['sender'] as String? ?? 'رسالة').trim();
    final isImage = quoted['isImage'] as bool? ?? false;
    final isVoice = quoted['isVoice'] as bool? ?? false;
    final isDocument = quoted['isDocument'] as bool? ?? false;
    final imagePath = quoted['imagePath'] as String?;

    IconData? typeIcon;
    String label = content;
    if (isVoice) {
      typeIcon = LucideIcons.mic;
      label = 'رسالة صوتية';
    } else if (isImage) {
      typeIcon = LucideIcons.image;
      label = content.isEmpty ? 'صورة' : content;
    } else if (isDocument) {
      typeIcon = LucideIcons.fileText;
      label = quoted['fileName'] as String? ?? 'مستند';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: chat.quotedBackgroundTheirs,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // الخط الجانبي الملون البارز (Accent Bar)
            Container(
              width: 4.5,
              color: chat.quotedBar,
            ),
            const SizedBox(width: AppSpacing.sm),

            // تفاصيل الرسالة المقتبسة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sender,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: chat.quotedTitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (typeIcon != null) ...[
                          Icon(typeIcon, size: 14, color: chat.quotedBodyTheirs),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            label.isEmpty ? '...' : label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: chat.quotedBodyTheirs,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // مصغرة الصورة إن وجدت في الرسالة المقتبسة
            if (isImage && imagePath != null && File(imagePath).existsSync())
              Padding(
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Image.file(
                    File(imagePath),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // زر الإلغاء
            IconButton(
              icon: Icon(LucideIcons.x, color: chat.composerIcon, size: 18),
              splashRadius: 18,
              onPressed: () {
                HapticFeedback.lightImpact();
                onCancel();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
///  لوحة إرفاق الوسائط بأسلوب WhatsApp الحقيقي (WhatsApp Attachment Panel)
/// ============================================================================
///  ★ شبكة أنيقة من الأيقونات الدائرية الملونة وظلال خافتة وتسميات واضحة.
class WhatsAppAttachmentPanel extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onVideo;
  final VoidCallback onDocument;
  final VoidCallback onAudio;
  final VoidCallback onContact;
  final VoidCallback? onLocation;

  const WhatsAppAttachmentPanel({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onVideo,
    required this.onDocument,
    required this.onAudio,
    required this.onContact,
    this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final pal = context.attachmentPalette;

    return Container(
      decoration: BoxDecoration(
        color: chat.attachmentSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب العلوي
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: chat.attachmentSheetHandle.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md + 4),

          // الصف الأول: مستند، كاميرا، معرض
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachmentOption(
                context,
                color: pal.document,
                icon: LucideIcons.fileText,
                label: 'مستند',
                onTap: onDocument,
              ),
              _buildAttachmentOption(
                context,
                color: pal.camera,
                icon: LucideIcons.camera,
                label: 'كاميرا',
                onTap: onCamera,
              ),
              _buildAttachmentOption(
                context,
                color: pal.gallery,
                icon: LucideIcons.image,
                label: 'المعرض',
                onTap: onGallery,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // الصف الثاني: صوت، موقع، جهة اتصال
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachmentOption(
                context,
                color: pal.audio,
                icon: LucideIcons.headphones,
                label: 'صوت',
                onTap: onAudio,
              ),
              _buildAttachmentOption(
                context,
                color: pal.location,
                icon: LucideIcons.mapPin,
                label: 'الموقع',
                onTap: onLocation ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ميزة مشاركة الموقع قيد التطوير')),
                  );
                },
              ),
              _buildAttachmentOption(
                context,
                color: pal.contact,
                icon: LucideIcons.user,
                label: 'جهة اتصال',
                onTap: onContact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final chat = context.chatColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الزر الدائري الملون مع ظل وتدرج خفيف
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.95),
                      color,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                label,
                style: TextStyle(
                  color: chat.attachmentLabel,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
