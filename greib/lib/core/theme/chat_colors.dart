import 'package:flutter/material.dart';

import 'app_color_palette.dart';

/// ============================================================================
///  ألوان الدردشة — Chat Colors (مشتقة من اللوحة المركزية)
/// ============================================================================
///  ★ امتداد مركزي لكل ألوان صفحة الدردشة بأسلوب WhatsApp، مشتق بالكامل
///    من [AppColorPalette] — أي تغيير في اللوحة يسري فوراً هنا.
///  ◆ بصري فقط: لا منطق بيانات هنا إطلاقاً.
///
@immutable
class AppChatColors extends ThemeExtension<AppChatColors> {
  final Color conversationBackground;
  final Color doodleColor;
  final Color bubbleMine;
  final Color bubbleTheirs;
  final Color bubbleMineText;
  final Color bubbleTheirsText;
  final Color bubbleMineTime;
  final Color bubbleTheirsTime;
  final Color senderName;
  final Color quotedBackgroundMine;
  final Color quotedBackgroundTheirs;
  final Color quotedBar;
  final Color quotedTitle;
  final Color quotedBodyMine;
  final Color quotedBodyTheirs;
  final Color composerBackground;
  final Color composerBorder;
  final Color inputField;
  final Color inputHint;
  final Color inputText;
  final Color composerIcon;
  final Color micButton;
  final Color micIcon;
  final Color sendButton;
  final Color sendIcon;
  final Color attachmentSheet;
  final Color attachmentSheetHandle;
  final Color attachmentIconBackground;
  final Color attachmentLabel;
  final Color recordingBackground;
  final Color recordingTimer;
  final Color recordingWavePlayed;
  final Color recordingWaveUnplayed;
  final Color recordingTrash;
  final Color recordingCancelBackground;
  final Color tickRead;
  final Color tickSent;
  final Color onlineDot;

  const AppChatColors({
    required this.conversationBackground,
    required this.doodleColor,
    required this.bubbleMine,
    required this.bubbleTheirs,
    required this.bubbleMineText,
    required this.bubbleTheirsText,
    required this.bubbleMineTime,
    required this.bubbleTheirsTime,
    required this.senderName,
    required this.quotedBackgroundMine,
    required this.quotedBackgroundTheirs,
    required this.quotedBar,
    required this.quotedTitle,
    required this.quotedBodyMine,
    required this.quotedBodyTheirs,
    required this.composerBackground,
    required this.composerBorder,
    required this.inputField,
    required this.inputHint,
    required this.inputText,
    required this.composerIcon,
    required this.micButton,
    required this.micIcon,
    required this.sendButton,
    required this.sendIcon,
    required this.attachmentSheet,
    required this.attachmentSheetHandle,
    required this.attachmentIconBackground,
    required this.attachmentLabel,
    required this.recordingBackground,
    required this.recordingTimer,
    required this.recordingWavePlayed,
    required this.recordingWaveUnplayed,
    required this.recordingTrash,
    required this.recordingCancelBackground,
    required this.tickRead,
    required this.tickSent,
    required this.onlineDot,
  });

  /// يبني ألوان الدردشة من اللوحة المركزية — المصدر الوحيد للحقيقة.
  factory AppChatColors.fromPalette(AppColorPalette p) {
    final bool isDark = p.isDark;
    final Color accent = p.accent;
    const Color danger = Color(0xFFEF4444);
    const Color readBlue = Color(0xFF38BDF8);
    const Color onlineGreen = Color(0xFF10B981);
    return AppChatColors(
      conversationBackground: p.background.primary,
      doodleColor: p.text.tertiary.withValues(alpha: isDark ? 0.06 : 0.08),
      bubbleMine: accent,
      bubbleTheirs: p.background.surface,
      bubbleMineText: p.text.onAccent,
      bubbleTheirsText: p.text.primary,
      bubbleMineTime: p.text.onAccent.withValues(alpha: 0.7),
      bubbleTheirsTime: p.text.tertiary,
      senderName: accent,
      quotedBackgroundMine: p.text.onAccent.withValues(alpha: 0.12),
      quotedBackgroundTheirs: p.background.surfaceElevated,
      quotedBar: accent,
      quotedTitle: accent,
      quotedBodyMine: p.text.onAccent.withValues(alpha: 0.75),
      quotedBodyTheirs: p.text.secondary,
      composerBackground: p.background.surfaceElevated,
      composerBorder: p.background.outline.withValues(alpha: 0.2),
      inputField: p.background.surface,
      inputHint: p.text.tertiary,
      inputText: p.text.primary,
      composerIcon: p.text.secondary,
      micButton: p.background.surface,
      micIcon: p.text.primary,
      sendButton: accent,
      sendIcon: p.text.onAccent,
      attachmentSheet: p.background.surfaceElevated,
      attachmentSheetHandle: p.text.tertiary,
      attachmentIconBackground: p.background.surface,
      attachmentLabel: p.text.primary,
      recordingBackground: p.background.surfaceElevated,
      recordingTimer: p.text.primary,
      recordingWavePlayed: accent,
      recordingWaveUnplayed: p.text.tertiary.withValues(alpha: 0.4),
      recordingTrash: danger,
      recordingCancelBackground: danger.withValues(alpha: 0.1),
      tickRead: readBlue,
      tickSent: p.text.tertiary,
      onlineDot: onlineGreen,
    );
  }

  @override
  AppChatColors copyWith({
    Color? conversationBackground,
    Color? doodleColor,
    Color? bubbleMine,
    Color? bubbleTheirs,
    Color? bubbleMineText,
    Color? bubbleTheirsText,
    Color? bubbleMineTime,
    Color? bubbleTheirsTime,
    Color? senderName,
    Color? quotedBackgroundMine,
    Color? quotedBackgroundTheirs,
    Color? quotedBar,
    Color? quotedTitle,
    Color? quotedBodyMine,
    Color? quotedBodyTheirs,
    Color? composerBackground,
    Color? composerBorder,
    Color? inputField,
    Color? inputHint,
    Color? inputText,
    Color? composerIcon,
    Color? micButton,
    Color? micIcon,
    Color? sendButton,
    Color? sendIcon,
    Color? attachmentSheet,
    Color? attachmentSheetHandle,
    Color? attachmentIconBackground,
    Color? attachmentLabel,
    Color? recordingBackground,
    Color? recordingTimer,
    Color? recordingWavePlayed,
    Color? recordingWaveUnplayed,
    Color? recordingTrash,
    Color? recordingCancelBackground,
    Color? tickRead,
    Color? tickSent,
    Color? onlineDot,
  }) {
    return AppChatColors(
      conversationBackground: conversationBackground ?? this.conversationBackground,
      doodleColor: doodleColor ?? this.doodleColor,
      bubbleMine: bubbleMine ?? this.bubbleMine,
      bubbleTheirs: bubbleTheirs ?? this.bubbleTheirs,
      bubbleMineText: bubbleMineText ?? this.bubbleMineText,
      bubbleTheirsText: bubbleTheirsText ?? this.bubbleTheirsText,
      bubbleMineTime: bubbleMineTime ?? this.bubbleMineTime,
      bubbleTheirsTime: bubbleTheirsTime ?? this.bubbleTheirsTime,
      senderName: senderName ?? this.senderName,
      quotedBackgroundMine: quotedBackgroundMine ?? this.quotedBackgroundMine,
      quotedBackgroundTheirs: quotedBackgroundTheirs ?? this.quotedBackgroundTheirs,
      quotedBar: quotedBar ?? this.quotedBar,
      quotedTitle: quotedTitle ?? this.quotedTitle,
      quotedBodyMine: quotedBodyMine ?? this.quotedBodyMine,
      quotedBodyTheirs: quotedBodyTheirs ?? this.quotedBodyTheirs,
      composerBackground: composerBackground ?? this.composerBackground,
      composerBorder: composerBorder ?? this.composerBorder,
      inputField: inputField ?? this.inputField,
      inputHint: inputHint ?? this.inputHint,
      inputText: inputText ?? this.inputText,
      composerIcon: composerIcon ?? this.composerIcon,
      micButton: micButton ?? this.micButton,
      micIcon: micIcon ?? this.micIcon,
      sendButton: sendButton ?? this.sendButton,
      sendIcon: sendIcon ?? this.sendIcon,
      attachmentSheet: attachmentSheet ?? this.attachmentSheet,
      attachmentSheetHandle: attachmentSheetHandle ?? this.attachmentSheetHandle,
      attachmentIconBackground: attachmentIconBackground ?? this.attachmentIconBackground,
      attachmentLabel: attachmentLabel ?? this.attachmentLabel,
      recordingBackground: recordingBackground ?? this.recordingBackground,
      recordingTimer: recordingTimer ?? this.recordingTimer,
      recordingWavePlayed: recordingWavePlayed ?? this.recordingWavePlayed,
      recordingWaveUnplayed: recordingWaveUnplayed ?? this.recordingWaveUnplayed,
      recordingTrash: recordingTrash ?? this.recordingTrash,
      recordingCancelBackground: recordingCancelBackground ?? this.recordingCancelBackground,
      tickRead: tickRead ?? this.tickRead,
      tickSent: tickSent ?? this.tickSent,
      onlineDot: onlineDot ?? this.onlineDot,
    );
  }

  @override
  AppChatColors lerp(covariant AppChatColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppChatColors(
      conversationBackground: l(conversationBackground, other.conversationBackground),
      doodleColor: l(doodleColor, other.doodleColor),
      bubbleMine: l(bubbleMine, other.bubbleMine),
      bubbleTheirs: l(bubbleTheirs, other.bubbleTheirs),
      bubbleMineText: l(bubbleMineText, other.bubbleMineText),
      bubbleTheirsText: l(bubbleTheirsText, other.bubbleTheirsText),
      bubbleMineTime: l(bubbleMineTime, other.bubbleMineTime),
      bubbleTheirsTime: l(bubbleTheirsTime, other.bubbleTheirsTime),
      senderName: l(senderName, other.senderName),
      quotedBackgroundMine: l(quotedBackgroundMine, other.quotedBackgroundMine),
      quotedBackgroundTheirs: l(quotedBackgroundTheirs, other.quotedBackgroundTheirs),
      quotedBar: l(quotedBar, other.quotedBar),
      quotedTitle: l(quotedTitle, other.quotedTitle),
      quotedBodyMine: l(quotedBodyMine, other.quotedBodyMine),
      quotedBodyTheirs: l(quotedBodyTheirs, other.quotedBodyTheirs),
      composerBackground: l(composerBackground, other.composerBackground),
      composerBorder: l(composerBorder, other.composerBorder),
      inputField: l(inputField, other.inputField),
      inputHint: l(inputHint, other.inputHint),
      inputText: l(inputText, other.inputText),
      composerIcon: l(composerIcon, other.composerIcon),
      micButton: l(micButton, other.micButton),
      micIcon: l(micIcon, other.micIcon),
      sendButton: l(sendButton, other.sendButton),
      sendIcon: l(sendIcon, other.sendIcon),
      attachmentSheet: l(attachmentSheet, other.attachmentSheet),
      attachmentSheetHandle: l(attachmentSheetHandle, other.attachmentSheetHandle),
      attachmentIconBackground: l(attachmentIconBackground, other.attachmentIconBackground),
      attachmentLabel: l(attachmentLabel, other.attachmentLabel),
      recordingBackground: l(recordingBackground, other.recordingBackground),
      recordingTimer: l(recordingTimer, other.recordingTimer),
      recordingWavePlayed: l(recordingWavePlayed, other.recordingWavePlayed),
      recordingWaveUnplayed: l(recordingWaveUnplayed, other.recordingWaveUnplayed),
      recordingTrash: l(recordingTrash, other.recordingTrash),
      recordingCancelBackground: l(recordingCancelBackground, other.recordingCancelBackground),
      tickRead: l(tickRead, other.tickRead),
      tickSent: l(tickSent, other.tickSent),
      onlineDot: l(onlineDot, other.onlineDot),
    );
  }
}

/// قراءة ألوان الدردشة من السياق — مشتقة دائماً من اللوحة المركزية.
extension ChatColorsContext on BuildContext {
  AppChatColors get chatColors {
    final ext = Theme.of(this).extension<AppChatColors>();
    if (ext != null) return ext;
    final palette =
        Theme.of(this).extension<AppColorPalette>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? AppColorPalette.dark()
            : AppColorPalette.light());
    return AppChatColors.fromPalette(palette);
  }
}

/// ألوان خيارات المرفقات — الأولى من اللوحة والبقية دلالية ثابتة ومتناسقة.
class ChatAttachmentPalette {
  final Color camera;
  final Color gallery;
  final Color video;
  final Color document;
  final Color audio;
  final Color contact;
  final Color location;

  const ChatAttachmentPalette({
    required this.camera,
    required this.gallery,
    required this.video,
    required this.document,
    required this.audio,
    required this.contact,
    required this.location,
  });

  factory ChatAttachmentPalette.fromPalette(AppColorPalette p) {
    return ChatAttachmentPalette(
      camera: p.accent,
      gallery: const Color(0xFF8B5CF6),
      video: const Color(0xFFEC4899),
      document: const Color(0xFF3B82F6),
      audio: const Color(0xFFF59E0B),
      contact: const Color(0xFF06B6D4),
      location: const Color(0xFF10B981),
    );
  }
}

extension ChatAttachmentContext on BuildContext {
  ChatAttachmentPalette get attachmentPalette {
    final palette =
        Theme.of(this).extension<AppColorPalette>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? AppColorPalette.dark()
            : AppColorPalette.light());
    return ChatAttachmentPalette.fromPalette(palette);
  }
}

