import 'dart:io';

const _asciiRiff = 'RIFF';
const _asciiWave = 'WAVE';
const _asciiFmt = 'fmt ';
const _asciiData = 'data';

/// خطأ في تحليل/كتابة ملف WAV.
class WavCodecException implements Exception {
  final String message;
  WavCodecException(this.message);
  @override
  String toString() => 'WavCodecException: $message';
}

/// معلومات رأس ملف WAV بصيغة PCM (غير مضغوط).
class WavInfo {
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final int byteRate;
  final int blockAlign;
  final int dataOffset;   // موضع بداية بيانات الصوت داخل الملف
  final int dataSize;     // عدد بايتات الصوت الخام
  final Duration duration;
  final List<int> header; // 44 بايت الأول (رأس WAV قياسي)

  WavInfo({
    required this.sampleRate,
    required this.channels,
    required this.bitsPerSample,
    required this.byteRate,
    required this.blockAlign,
    required this.dataOffset,
    required this.dataSize,
    required this.header,
  }) : duration = Duration(
          microseconds:
              (dataSize ~/ (byteRate == 0 ? 1 : byteRate)) * 1000000,
        );

  /// عدد بايتات لكل عينة على قناة واحدة (بالتجّبة 2 ل PCM 16-bit).
  int get bytesPerSample => bitsPerSample ~/ 8;

  /// عدد بايتات لكل إطار (جميع القنوات).
  int get frameSize => channels * bytesPerSample;

  /// عدد العينات الإجمالية (لكل قناة).
  int get totalSamples => dataSize ~/ frameSize;
}

/// قارئ وكاتب لملفات WAV PCM 16 بت (بدون أي حزمة خارجية).
class WavCodec {
  /// يقرأ رأس WAV وي Validate أن الصيغة PCM 16-bit صالحة.
  static WavInfo readHeader(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw WavCodecException('الملف غير موجود: $path');
    }
    final bytes = file.readAsBytesSync();
    if (bytes.length < 44) {
      throw WavCodecException('الملف أقصر من رأس WAV صالح (44 بايت)');
    }
    if (String.fromCharCodes(bytes.sublist(0, 4)) != _asciiRiff) {
      throw WavCodecException('الرأس ليس RIFF (ليست صيغة WAV)');
    }
    if (String.fromCharCodes(bytes.sublist(8, 12)) != _asciiWave) {
      throw WavCodecException('الصيغة ليست WAVE');
    }
    if (String.fromCharCodes(bytes.sublist(12, 16)) != _asciiFmt) {
      throw WavCodecException('القسم fmt مفقود');
    }

    final audioFormat = bytes[20] | (bytes[21] << 8);
    if (audioFormat != 1) {
      throw WavCodecException(
        'الدعم مقتصر على PCM غير مضغوط (audioFormat=$audioFormat)',
      );
    }
    final channels = bytes[22] | (bytes[23] << 8);
    final sampleRate = _readUint32le(bytes, 24);
    final byteRate = _readUint32le(bytes, 28);
    final blockAlign = bytes[32] | (bytes[33] << 8);
    final bitsPerSample = bytes[34] | (bytes[35] << 8);
    if (bitsPerSample != 16) {
      throw WavCodecException(
        'الدعم مقتصر على 16 بت لكل عينة (bitsPerSample=$bitsPerSample)',
      );
    }

    final dataIdx = _findChunk(bytes, _asciiData);
    if (dataIdx == -1) {
      throw WavCodecException('القسم data مفقود');
    }
    final dataOffset = dataIdx + 8;
    final dataSize = _readUint32le(bytes, dataIdx + 4);

    return WavInfo(
      sampleRate: sampleRate,
      channels: channels,
      bitsPerSample: bitsPerSample,
      byteRate: byteRate,
      blockAlign: blockAlign,
      dataOffset: dataOffset,
      dataSize: dataSize,
      header: bytes.sublist(0, dataOffset),
    );
  }

  static int _readUint32le(List<int> bytes, int offset) =>
      bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);

  /// يجد موضع قسم (chunk) معين في ملف WAV مع احترام الحشو (padding).
  static int _findChunk(List<int> bytes, String id) {
    var i = 12; // بعد "RIFF" + الحجم + "WAVE"
    while (i + 8 <= bytes.length) {
      if (String.fromCharCodes(bytes.sublist(i, i + 4)) == id) {
        return i;
      }
      final chunkSize = _readUint32le(bytes, i + 4);
      i += 8 + chunkSize;
      if (i % 2 == 1) i++; // بايت تحصين إذا كان الحجم فردياً
    }
    return -1;
  }

  /// يقص segment من [startSec] إلى [endSec] من [inputPath] ويحفظه في [outputPath].
  /// يقطع البيانات فقط ويرأس الملف nuevo برؤوس WAV صحيحة.
  static void trim(
    String inputPath,
    String outputPath, {
    required double startSec,
    required double endSec,
  }) {
    final info = readHeader(inputPath);
    final allBytes = File(inputPath).readAsBytesSync();

    final frameSize = info.frameSize;
    if (frameSize == 0) {
      throw WavCodecException('حجم الإطار صفر في الملف الأصلي');
    }

    final totalSec = info.totalSamples / info.sampleRate;
    if (startSec < 0) startSec = 0;
    if (endSec > totalSec) endSec = totalSec;
    if (endSec - startSec < 0.05) {
      throw WavCodecException(
        'نطاق القص قصير جداً (أقل من 50 ميلي ثانية)',
      );
    }
    if (startSec >= endSec) {
      throw WavCodecException('نهاية القص يجب أن تكون بعد بدايته');
    }

    final startSample =
        (startSec * info.sampleRate).round().clamp(0, info.totalSamples);
    final endSample =
        (endSec * info.sampleRate).round().clamp(0, info.totalSamples);
    final startByte = info.dataOffset + startSample * frameSize;
    final endByte = info.dataOffset + endSample * frameSize;
    if (endByte > allBytes.length) {
      throw WavCodecException('نطاق القص يتجاوز حجم الملف الفعلي');
    }

    final trimmed = allBytes.sublist(startByte, endByte);
    final newDataSize = trimmed.length;
    final newRiffSize = 36 + newDataSize;

    final out = <int>[];
    out.addAll(info.header.sublist(0, 4)); // RIFF
    out.addAll(_uint32le(newRiffSize)); // ChunkSize
    out.addAll(info.header.sublist(8, 12)); // WAVE
    out.addAll(info.header.sublist(12, 36)); // كامل قسم fmt
    out.addAll(_ascii(_asciiData));
    out.addAll(_uint32le(newDataSize));
    out.addAll(trimmed);

    final outFile = File(outputPath);
    outFile.createSync(recursive: true);
    outFile.writeAsBytesSync(out);
  }

  static List<int> _ascii(String s) => s.codeUnits;
  static List<int> _uint32le(int v) => [
        v & 0xFF,
        (v >> 8) & 0xFF,
        (v >> 16) & 0xFF,
        (v >> 24) & 0xFF,
      ];
}