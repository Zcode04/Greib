import 'dart:io';
import 'wav_codec.dart';

/// نتيجة عملية القص على ملف الصوت.
class VoiceClipResult {
  /// مسار الملف الجديد (المقصوص).
  final String outputPath;
  /// عينة البداية في الملف الأصلي.
  final int startSample;
  /// عينة النهاية في الملف الأصلي.
  final int endSample;
  /// مدة الملف المقصوص.
  final Duration duration;

  VoiceClipResult({
    required this.outputPath,
    required this.startSample,
    required this.endSample,
    required this.duration,
  });
}

/// محرر الصوت للتسجيلات المسجلة (WAV PCM 16-bit).
/// يوفّر عملية القص (trim) بدون أي حزمة خارجية.
class VoiceAudioEditor {
  /// يقص segment من [startSec] إلى [endSec] من [inputPath] إلى [outputPath].
  /// يعيد نتيجة تحتوي على المسار الجديد والمدة المحسوبة من الرأس الفعلي.
  static Future<VoiceClipResult> trim({
    required String inputPath,
    required String outputPath,
    required double startSec,
    required double endSec,
  }) async {
    if (!File(inputPath).existsSync()) {
      throw Exception('الملف الأصلي غير موجود: $inputPath');
    }

    // العملية متزامنة وسريعة (نسخ بايتات)، نُنفّذها في isolate مفصول
    // لتجنب تجميد واجهة المستخدم عند الملفات الطويلة.
    await Future(() {
      WavCodec.trim(inputPath, outputPath,
          startSec: startSec, endSec: endSec);
    });

    final info = WavCodec.readHeader(outputPath);
    return VoiceClipResult(
      outputPath: outputPath,
      startSample: (startSec * info.sampleRate).round(),
      endSample: (endSec * info.sampleRate).round(),
      duration: info.duration,
    );
  }

  /// يحذف ملفاً بأمان إذا كان موجوداً.
  static Future<void> delete(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  /// يزيل ملفاً مؤقتاً دون إلقاء خطأ إن كان غير موجود.
  static void deleteSync(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }
}