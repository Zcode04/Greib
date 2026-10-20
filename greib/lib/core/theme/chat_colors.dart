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

  /// لون نص/أيقونة باهتة عام داخل المحادثة.
  final Color mutedText;
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
    required this.mutedText,
    required this.recordingTrash,
    required this.recordingCancelBackground,
    required this.tickRead,
    required this.tickSent,
    required this.onlineDot,
  });

  /// يبني ألوان الدردشة من اللوحة المركزية — المصدر الوحيد للحقيقة.
  /// ★ مطابقة واتساب (Dark Mode) بنسبة 100% — قيم مأخوذة من واتساب الحقيقي:
  ///   - خلفية المحادثة (#0B141A) — أسود مزرق مطفي وليس أسود خالص.
  ///   - فقاعة مرسّلة (#005C4B) — أخضر واتساب الداكن المطفي.
  ///   - فقاعة مستلمة (#1F2C34) — رمادي مزرق داكن.
  ///   - زر الإرسال (#00A884) — أخضر واتساب الداكن.
  ///   - التوقيت والميتا (#8696A0) — رمادي واتساب الرسمي.
  ///   - علامة القراءة الزرقاء (#53BDEB) — أزرق واتساب الرسمي.
  factory AppChatColors.fromPalette(AppColorPalette p) {
    final bool isDark = p.isDark;
    // ★ ألوان واتساب الرسمية — داكن وفاتح (القيم الرسمية من واتساب):
    //  داكن: خلفية #0B141A ، مرسّلة #005C4B ، مستلمة #1F2C34.
    //  فاتح: خلفية #EFEAE2 ، مرسّلة #D9FDD3 ، مستلمة #FFFFFF.
    const Color waBgDark = Color(0xFF0B141A);
    const Color waMineDark = Color(0xFF005C4B);
    const Color waTheirsDark = Color(0xFF1F2C34);
    const Color waSendDark = Color(0xFF1FA855); // أخضر واتساب الرسمي
    const Color waBgLight = Color(0xFFEFEAE2);
    const Color waMineLight = Color(0xFFD9FDD3);
    const Color waTheirsLight = Color(0xFFFFFFFF);
    const Color waSendLight = Color(0xFF1FA855);
    const Color waTick = Color(0xFF53BDEB); // علامة القراءة الزرقاء الرسمية
    const Color waTrash = Color(0xFFE53956); // أحمر واتساب الرسمي للإلغاء/الحذف
    final Color waBg = isDark ? waBgDark : waBgLight;
    final Color waBubbleMine = isDark ? waMineDark : waMineLight;
    final Color waBubbleTheirs = isDark ? waTheirsDark : waTheirsLight;
    final Color waSend = isDark ? waSendDark : waSendLight;
    const Color waOnline = Color(0xFF1FA855); // نقطة الاتصال
    final Color waTime = isDark
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781); // التوقيت الرسمي
    final Color waSurface = isDark
        ? const Color(0xFF1F2C34)
        : const Color(0xFFF0F2F5); // سطح حقل الإدخال
    final Color waText = isDark ? Colors.white : const Color(0xFF111B21);
    final Color waMuted = isDark
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781);

    return AppChatColors(
      // ★ خلفية المحادثة طبيعية صلبة (#000000) — بدون نقش/خلفية خاصة.
      conversationBackground: waBg,
      // إلغاء النقوش تمامًا (شفاف) ليصبح الخلفية لونًا طبيعيًا واحدًا.
      doodleColor: Colors.transparent,
      bubbleMine: waBubbleMine,
      bubbleTheirs: waBubbleTheirs,
      bubbleMineText: waText,
      bubbleTheirsText: waText,
      bubbleMineTime: waTime,
      bubbleTheirsTime: waTime,
      senderName: waText,
      quotedBackgroundMine: waBubbleMine.withValues(alpha: 0.12),
      quotedBackgroundTheirs: waSurface,
      quotedBar: waSend,
      quotedTitle: waSend,
      quotedBodyMine: waText.withValues(alpha: 0.75),
      quotedBodyTheirs: waMuted,
      composerBackground: waSurface,
      composerBorder: waMuted.withValues(alpha: 0.3),
      inputField: waSurface,
      inputHint: waMuted,
      inputText: waText,
      composerIcon: waMuted,
      micButton: waSurface,
      micIcon: waText,
      sendButton: waSend,
      sendIcon: Colors.white,
      attachmentSheet: waSurface,
      attachmentSheetHandle: waMuted,
      attachmentIconBackground: waSurface,
      attachmentLabel: waText,
      recordingBackground: waSurface,
      recordingTimer: waText,
      // ★ لون الموجة المشغَّلة = الأزرق الرسمي لواتساب (#53BDEB) — نفس لون علامة القراءة.
      recordingWavePlayed: waTick,
      // ★ الموجة غير المشغَّلة: باهتة في الوضع الداكن، ورمادية مقروءة في النهاري.
      recordingWaveUnplayed: isDark
          ? Colors.white.withValues(alpha: 0.25)
          : const Color(0xFF8696A0).withValues(alpha: 0.35),
      // ★ لون نص/أيقونة باهتة عام داخل المحادثة (ليس خاصاً بالموجة).
      mutedText: waMuted,
      recordingTrash: waTrash,
      recordingCancelBackground: waTrash.withValues(alpha: 0.1),
      tickRead: waTick,
      tickSent: waMuted,
      onlineDot: waOnline,
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
    Color? mutedText,
    Color? recordingTrash,
    Color? recordingCancelBackground,
    Color? tickRead,
    Color? tickSent,
    Color? onlineDot,
  }) {
    return AppChatColors(
      conversationBackground:
          conversationBackground ?? this.conversationBackground,
      doodleColor: doodleColor ?? this.doodleColor,
      bubbleMine: bubbleMine ?? this.bubbleMine,
      bubbleTheirs: bubbleTheirs ?? this.bubbleTheirs,
      bubbleMineText: bubbleMineText ?? this.bubbleMineText,
      bubbleTheirsText: bubbleTheirsText ?? this.bubbleTheirsText,
      bubbleMineTime: bubbleMineTime ?? this.bubbleMineTime,
      bubbleTheirsTime: bubbleTheirsTime ?? this.bubbleTheirsTime,
      senderName: senderName ?? this.senderName,
      quotedBackgroundMine: quotedBackgroundMine ?? this.quotedBackgroundMine,
      quotedBackgroundTheirs:
          quotedBackgroundTheirs ?? this.quotedBackgroundTheirs,
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
      attachmentSheetHandle:
          attachmentSheetHandle ?? this.attachmentSheetHandle,
      attachmentIconBackground:
          attachmentIconBackground ?? this.attachmentIconBackground,
      attachmentLabel: attachmentLabel ?? this.attachmentLabel,
      recordingBackground: recordingBackground ?? this.recordingBackground,
      recordingTimer: recordingTimer ?? this.recordingTimer,
      recordingWavePlayed: recordingWavePlayed ?? this.recordingWavePlayed,
      recordingWaveUnplayed:
          recordingWaveUnplayed ?? this.recordingWaveUnplayed,
      mutedText: mutedText ?? this.mutedText,
      recordingTrash: recordingTrash ?? this.recordingTrash,
      recordingCancelBackground:
          recordingCancelBackground ?? this.recordingCancelBackground,
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
      conversationBackground: l(
        conversationBackground,
        other.conversationBackground,
      ),
      doodleColor: l(doodleColor, other.doodleColor),
      bubbleMine: l(bubbleMine, other.bubbleMine),
      bubbleTheirs: l(bubbleTheirs, other.bubbleTheirs),
      bubbleMineText: l(bubbleMineText, other.bubbleMineText),
      bubbleTheirsText: l(bubbleTheirsText, other.bubbleTheirsText),
      bubbleMineTime: l(bubbleMineTime, other.bubbleMineTime),
      bubbleTheirsTime: l(bubbleTheirsTime, other.bubbleTheirsTime),
      senderName: l(senderName, other.senderName),
      quotedBackgroundMine: l(quotedBackgroundMine, other.quotedBackgroundMine),
      quotedBackgroundTheirs: l(
        quotedBackgroundTheirs,
        other.quotedBackgroundTheirs,
      ),
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
      attachmentSheetHandle: l(
        attachmentSheetHandle,
        other.attachmentSheetHandle,
      ),
      attachmentIconBackground: l(
        attachmentIconBackground,
        other.attachmentIconBackground,
      ),
      attachmentLabel: l(attachmentLabel, other.attachmentLabel),
      recordingBackground: l(recordingBackground, other.recordingBackground),
      recordingTimer: l(recordingTimer, other.recordingTimer),
      recordingWavePlayed: l(recordingWavePlayed, other.recordingWavePlayed),
      recordingWaveUnplayed: l(
        recordingWaveUnplayed,
        other.recordingWaveUnplayed,
      ),
      mutedText: l(mutedText, other.mutedText),
      recordingTrash: l(recordingTrash, other.recordingTrash),
      recordingCancelBackground: l(
        recordingCancelBackground,
        other.recordingCancelBackground,
      ),
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

  /// ألوان أنواع المستندات — دلالية ثابتة ومتناسقة مع بقية المرفقات.
  final Color documentPdf;
  final Color documentWord;
  final Color documentSheet;
  final Color documentSlides;
  final Color documentArchive;
  final Color documentAudio;
  final Color documentFallback;

  const ChatAttachmentPalette({
    required this.camera,
    required this.gallery,
    required this.video,
    required this.document,
    required this.audio,
    required this.contact,
    required this.location,
    required this.documentPdf,
    required this.documentWord,
    required this.documentSheet,
    required this.documentSlides,
    required this.documentArchive,
    required this.documentAudio,
    required this.documentFallback,
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
      documentPdf: p.icon.error,
      documentWord: const Color(0xFF3B82F6),
      documentSheet: p.icon.success,
      documentSlides: const Color(0xFFF59E0B),
      documentArchive: const Color(0xFF8B5CF6),
      documentAudio: const Color(0xFF06B6D4),
      documentFallback: p.text.tertiary,
    );
  }

  ChatAttachmentPalette copyWith({
    Color? camera,
    Color? gallery,
    Color? video,
    Color? document,
    Color? audio,
    Color? contact,
    Color? location,
    Color? documentPdf,
    Color? documentWord,
    Color? documentSheet,
    Color? documentSlides,
    Color? documentArchive,
    Color? documentAudio,
    Color? documentFallback,
  }) {
    return ChatAttachmentPalette(
      camera: camera ?? this.camera,
      gallery: gallery ?? this.gallery,
      video: video ?? this.video,
      document: document ?? this.document,
      audio: audio ?? this.audio,
      contact: contact ?? this.contact,
      location: location ?? this.location,
      documentPdf: documentPdf ?? this.documentPdf,
      documentWord: documentWord ?? this.documentWord,
      documentSheet: documentSheet ?? this.documentSheet,
      documentSlides: documentSlides ?? this.documentSlides,
      documentArchive: documentArchive ?? this.documentArchive,
      documentAudio: documentAudio ?? this.documentAudio,
      documentFallback: documentFallback ?? this.documentFallback,
    );
  }

  ChatAttachmentPalette lerp(ChatAttachmentPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ChatAttachmentPalette(
      camera: l(camera, other.camera),
      gallery: l(gallery, other.gallery),
      video: l(video, other.video),
      document: l(document, other.document),
      audio: l(audio, other.audio),
      contact: l(contact, other.contact),
      location: l(location, other.location),
      documentPdf: l(documentPdf, other.documentPdf),
      documentWord: l(documentWord, other.documentWord),
      documentSheet: l(documentSheet, other.documentSheet),
      documentSlides: l(documentSlides, other.documentSlides),
      documentArchive: l(documentArchive, other.documentArchive),
      documentAudio: l(documentAudio, other.documentAudio),
      documentFallback: l(documentFallback, other.documentFallback),
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
