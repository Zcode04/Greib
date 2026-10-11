import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// معاينة المستند قبل الإرسال — بأسلوب WhatsApp.
class DocumentPreviewSheet extends StatefulWidget {
  final String filePath;
  final String fileName;
  final TextEditingController captionController;
  final VoidCallback onCancel;
  final ValueChanged<String> onSend;

  const DocumentPreviewSheet({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.captionController,
    required this.onCancel,
    required this.onSend,
  });

  @override
  State<DocumentPreviewSheet> createState() => _DocumentPreviewSheetState();
}

class _DocumentPreviewSheetState extends State<DocumentPreviewSheet> {
  String _ext(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0) return 'ملف';
    return name.substring(i + 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final theme = Theme.of(context);
    final ext = _ext(widget.fileName);
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: chat.attachmentSheet,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: chat.attachmentSheetHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.x, color: chat.composerIcon),
                onPressed: widget.onCancel,
              ),
              Text('معاينة المستند', style: theme.textTheme.titleMedium),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _fileCard(chat, theme, ext),
          const SizedBox(height: AppSpacing.md),
          _captionField(chat),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: chat.sendButton,
                foregroundColor: chat.sendIcon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
              icon: const Icon(LucideIcons.send),
              label: const Text('إرسال'),
              onPressed: () => widget.onSend(
                widget.captionController.text.trim(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileCard(AppChatColors chat, ThemeData theme, String ext) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: chat.inputField,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: chat.composerBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: chat.sendButton.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(LucideIcons.fileText, color: chat.sendButton, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ext,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: chat.inputHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _captionField(AppChatColors chat) {
    return TextField(
      controller: widget.captionController,
      textAlign: TextAlign.right,
      maxLines: 2,
      style: TextStyle(color: chat.inputText),
      decoration: InputDecoration(
        hintText: 'أضف تعليقاً (اختياري)...',
        hintStyle: TextStyle(color: chat.inputHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: chat.inputField,
      ),
    );
  }
}
