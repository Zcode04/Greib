import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Smoke test for the WhatsApp-style voice feature on a REAL device/simulator.
///
/// Verifies the exact flow the chat screen uses:
///   permission → start (same RecordConfig) → amplitude stream → stop →
///   file exists & non-empty → pause/resume behaviour → playback via audioplayers.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const config = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 128000,
    sampleRate: 44100,
    numChannels: 1,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.mic,
    ),
    iosConfig: IosRecordConfig(),
  );

  Future<String> newPath(String tag) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/smoke_${tag}_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  testWidgets('record → stop → file → playback works', (tester) async {
    // 1) Microphone permission — exactly what the chat screen relies on.
    var status = await Permission.microphone.status;
    // ignore: avoid_print
    print('SMOKE mic status before: $status');
    // في الأتمتة قد تكون التثيرة جديدة والإذن مرفوضاً مؤقتاً — ننتظر منحه من الماك.
    var waited = 0;
    while (!status.isGranted && waited < 60) {
      await Future<void>.delayed(const Duration(seconds: 2));
      waited += 2;
      status = await Permission.microphone.status;
      // ignore: avoid_print
      print('SMOKE mic status after ${waited}s: $status');
    }
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      // ignore: avoid_print
      print('SMOKE mic status after request: $status');
    }
    expect(
      status.isGranted,
      isTrue,
      reason: 'Microphone permission must be granted on this simulator '
          '(xcrun simctl privacy booted grant microphone <bundle-id>)',
    );

    final recorder = AudioRecorder();
    final path = await newPath('basic');
    // ignore: avoid_print
    print('SMOKE target path: $path');

    // 2) Start — the exact call chat_screen._startRecording makes.
    try {
      await recorder.start(config, path: path);
      // ignore: avoid_print
      print('SMOKE recorder.start OK');
    } catch (e, st) {
      // ignore: avoid_print
      print('SMOKE recorder.start FAILED: $e\n$st');
      fail('record.start() threw on this simulator: $e');
    }
    expect(await recorder.isRecording(), isTrue, reason: 'isRecording() after start');

    // 3) Amplitude stream (drives the live waveform).
    final amps = <double>[];
    final ampSub = recorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((a) => amps.add(a.current), onError: (Object e) {
      // ignore: avoid_print
      print('SMOKE amplitude stream error: $e');
    });
    await Future<void>.delayed(const Duration(seconds: 3));
    final maxAmp = amps.isEmpty ? 'none' : amps.reduce((a, b) => a > b ? a : b);
    // ignore: avoid_print
    print('SMOKE amplitude samples: ${amps.length} (max: $maxAmp, last: ${amps.isEmpty ? 'none' : amps.last})');

    // 4) Stop — chat_screen relies on the returned path being non-null.
    await ampSub.cancel();
    final stoppedPath = await recorder.stop();
    // ignore: avoid_print
    print('SMOKE stop() returned: $stoppedPath');
    expect(stoppedPath, isNotNull, reason: 'stop() must return the recording path');

    final file = File(stoppedPath!);
    expect(await file.exists(), isTrue, reason: 'recorded file must exist');
    final size = await file.length();
    // ignore: avoid_print
    print('SMOKE recorded file size: $size bytes');
    expect(size, greaterThan(0), reason: 'recorded file must not be empty');

    // 5) Playback through audioplayers (same DeviceFileSource as the UI).
    final player = AudioPlayer();
    var completed = false;
    final completeSub = player.onPlayerComplete.listen((_) => completed = true);
    try {
      await player.play(DeviceFileSource(stoppedPath));
      await Future<void>.delayed(const Duration(seconds: 2));
      final state = player.state;
      final pos = await player.getCurrentPosition();
      // ignore: avoid_print
      print('SMOKE playback state: $state, position: $pos, complete fired: $completed');
      expect(
        state,
        PlayerState.playing,
        reason: 'audioplayers must actually play the recorded file',
      );
      expect(pos, greaterThan(Duration.zero), reason: 'playback position must advance');
    } catch (e, st) {
      // ignore: avoid_print
      print('SMOKE playback FAILED: $e\n$st');
      fail('Playback of recorded file failed: $e');
    }
    await completeSub.cancel();
    await player.stop();
    await player.dispose();
    await recorder.dispose();
  });


  testWidgets('pause → partial file playable? → resume keeps same file?', (tester) async {
    final recorder = AudioRecorder();
    final path = await newPath('pause');

    await recorder.start(config, path: path);
    await Future<void>.delayed(const Duration(seconds: 2));

    // Pause exactly like a native pause would (before fd432a8 used this).
    try {
      await recorder.pause();
      // ignore: avoid_print
      print('SMOKE native pause() OK, isRecording: ${await recorder.isRecording()}');
    } catch (e) {
      // ignore: avoid_print
      print('SMOKE native pause() FAILED: $e');
      fail('record.pause() threw: $e');
    }

    // Can we play the PAUSED (not yet stopped) file? This decides whether
    // chat_screen can use native pause/resume + preview playback.
    final partialFile = File(path);
    final partialSize = await partialFile.exists() ? await partialFile.length() : 0;
    // ignore: avoid_print
    print('SMOKE paused partial file size: $partialSize');

    String? pausePlayResult;
    final player = AudioPlayer();
    try {
      await player.setSource(DeviceFileSource(path));
      await player.resume();
      await Future<void>.delayed(const Duration(seconds: 1));
      final state = player.state;
      final pos = await player.getCurrentPosition();
      pausePlayResult = 'state=$state pos=$pos';
    } catch (e) {
      pausePlayResult = 'ERROR: $e';
    } finally {
      await player.stop();
      await player.dispose();
    }
    // ignore: avoid_print
    print('SMOKE paused-file playback: $pausePlayResult');

    // Resume + finish — does stop() still return the SAME path (single file)?
    try {
      await recorder.resume();
      // ignore: avoid_print
      print('SMOKE native resume() OK, isRecording: ${await recorder.isRecording()}');
    } catch (e) {
      // ignore: avoid_print
      print('SMOKE native resume() FAILED: $e');
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    final stoppedPath = await recorder.stop();
    // ignore: avoid_print
    print('SMOKE stop() after pause+resume returned: $stoppedPath (started as $path)');
    expect(stoppedPath, isNotNull);

    final file = File(stoppedPath!);
    final size = await file.exists() ? await file.length() : 0;
    // ignore: avoid_print
    print('SMOKE final file size after pause+resume: $size bytes');
    expect(size, greaterThan(0));

    // Full playback after pause/resume.
    final player2 = AudioPlayer();
    try {
      await player2.play(DeviceFileSource(stoppedPath));
      await Future<void>.delayed(const Duration(seconds: 2));
      final state = player2.state;
      final pos = await player2.getCurrentPosition();
      // ignore: avoid_print
      print('SMOKE final playback state: $state pos: $pos');
      expect(state, PlayerState.playing);
    } catch (e) {
      // ignore: avoid_print
      print('SMOKE final playback FAILED: $e');
      fail('Playback after pause+resume failed: $e');
    } finally {
      await player2.stop();
      await player2.dispose();
      await recorder.dispose();
    }
  });
}
