import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:greib_menk/features/communication_and_support/widgets/voice_edit/wav_codec.dart';
import 'package:greib_menk/features/communication_and_support/widgets/voice_edit/voice_audio_editor.dart';
/// ينشئ ملف WAV اصطناعي PCM 16-bit غير مضغوط للاختبار.
Future<String> createTestWav({
  required int sampleRate,
  required int durationSeconds,
  String? path,
}) async {
  final p = path ??
      '${Directory.systemTemp.path}/test_wav_${DateTime.now().millisecondsSinceEpoch}.wav';
  final channels = 1;
  final bitsPerSample = 16;
  final bytesPerSample = bitsPerSample ~/ 8;
  final blockAlign = channels * bytesPerSample;
  final byteRate = sampleRate * blockAlign;
  final dataSize = sampleRate * durationSeconds * blockAlign;
  final riffSize = 36 + dataSize;

  final bytes = <int>[]
    ..addAll('RIFF'.codeUnits)
    ..addAll([riffSize & 0xFF, (riffSize >> 8) & 0xFF,
        (riffSize >> 16) & 0xFF, (riffSize >> 24) & 0xFF])
    ..addAll('WAVE'.codeUnits)
    ..addAll('fmt '.codeUnits)
    ..addAll([16, 0, 0, 0]) // fmt chunk size
    ..addAll([1, 0]) // audio format = PCM
    ..addAll([channels & 0xFF, channels >> 8])
    ..addAll([sampleRate & 0xFF, (sampleRate >> 8) & 0xFF,
        (sampleRate >> 16) & 0xFF, (sampleRate >> 24) & 0xFF])
    ..addAll([byteRate & 0xFF, (byteRate >> 8) & 0xFF,
        (byteRate >> 16) & 0xFF, (byteRate >> 24) & 0xFF])
    ..addAll([blockAlign & 0xFF, blockAlign >> 8])
    ..addAll([bitsPerSample & 0xFF, bitsPerSample >> 8])
    ..addAll('data'.codeUnits)
    ..addAll([dataSize & 0xFF, (dataSize >> 8) & 0xFF,
        (dataSize >> 16) & 0xFF, (dataSize >> 24) & 0xFF])
    ..addAll(List<int>.filled(dataSize, 0));

  final f = File(p);
  await f.writeAsBytes(bytes);
  return p;
}

void main() {
  testWidgets('trim middle segment of a synthetic WAV',
      timeout: const Timeout(Duration(seconds: 60)), (tester) async {
    final dir = Directory.systemTemp;
    final input = '${dir.path}/trim_input_${DateTime.now().millisecondsSinceEpoch}.wav';
    await createTestWav(sampleRate: 16000, durationSeconds: 4, path: input);

    final info = WavCodec.readHeader(input);
    expect(info.bitsPerSample, 16);
    expect(info.channels, 1);
    expect(info.dataSize, equals(16000 * 4 * 2));
    expect(info.duration.inSeconds, 4);

    final output = '${dir.path}/trim_output_${DateTime.now().millisecondsSinceEpoch}.wav';
    final result = await VoiceAudioEditor.trim(
      inputPath: input,
      outputPath: output,
      startSec: 1.0,
      endSec: 3.0,
    );

    final trimmed = WavCodec.readHeader(output);
    expect(trimmed.dataSize, equals(16000 * 2 * 2)); // 2 ثانية
    expect(result.duration.inSeconds, 2);
    expect(result.startSample, 16000);
    expect(result.endSample, 32000);

    // تنظيف
    await File(input).delete();
    await File(output).delete();
  });

  testWidgets('trim rejects invalid ranges',
      timeout: const Timeout(Duration(seconds: 60)), (tester) async {
    final dir = Directory.systemTemp;
    final input = '${dir.path}/trim_invalid_${DateTime.now().millisecondsSinceEpoch}.wav';
    await createTestWav(sampleRate: 8000, durationSeconds: 1, path: input);

    // البداية >= النهاية
    await expectLater(
      VoiceAudioEditor.trim(
        inputPath: input,
        outputPath: '${dir.path}/out_a.wav',
        startSec: 1.0,
        endSec: 0.5,
      ),
      throwsA(isA<Exception>()),
    );

    // أقصر من 50ms
    await expectLater(
      VoiceAudioEditor.trim(
        inputPath: input,
        outputPath: '${dir.path}/out_b.wav',
        startSec: 0.0,
        endSec: 0.01,
      ),
      throwsA(isA<Exception>()),
    );

    await File(input).delete();
  });
}
