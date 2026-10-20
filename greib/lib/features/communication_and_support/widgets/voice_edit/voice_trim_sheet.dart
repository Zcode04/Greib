import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/chat_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'wav_codec.dart';
import 'voice_audio_editor.dart';

/// شيت سفلي احترافي لتقليم التسجيل الصوتي بأسلوب منصات التواصل الاجتماعي.
/// شريط أفقي مع مقبضين قابلين للسحب من الطرفين لتحديد الجزء المراد إبقاءه.
class VoiceTrimSheet extends StatefulWidget {
  final String audioPath;
  final void Function(String trimmedPath, Duration duration) onTrimmed;
  final VoidCallback onCancel;

  const VoiceTrimSheet({
    super.key,
    required this.audioPath,
    required this.onTrimmed,
    required this.onCancel,
  });

  @override
  State<VoiceTrimSheet> createState() => _VoiceTrimSheetState();
}

enum _DragHandle { start, end }

class _VoiceTrimSheetState extends State<VoiceTrimSheet> {
  static const _minTrimSec = 0.05;
  static const _handleSize = 32.0;
  static const _trackHeight = 12.0;

  late WavInfo _info;
  List<double> _bars = List.filled(100, 4.0);
  double _startSec = 0;
  double _endSec = 0;
  bool _isApplying = false;
  bool _isPlaying = false;
  _DragHandle? _dragging;
  double _playheadFraction = 0.0;

  AudioPlayer? _player;
  Timer? _playTimer;
  Timer? _playheadTimer;
  DateTime? _playStartTime;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _playheadTimer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _info = WavCodec.readHeader(widget.audioPath);
    _endSec = _info.duration.inSeconds.toDouble();
    if (_endSec < _minTrimSec) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('التسجيل قصير جداً للقص'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    _bars = await _computeBars();
    if (mounted) setState(() {});
  }

  Future<List<double>> _computeBars() async {
    final all = File(widget.audioPath).readAsBytesSync();
    final dataStart = _info.dataOffset;
    final dataEnd = dataStart + _info.dataSize;
    final frameSize = _info.frameSize;
    final samples = (dataEnd - dataStart) ~/ frameSize;
    final perBar = (samples / _bars.length).ceil();
    final bars = <double>[];
    for (var b = 0; b < _bars.length; b++) {
      double maxAmp = 0;
      final from = b * perBar;
      final to = (b + 1) * perBar;
      for (var s = from; s < to && s < samples; s++) {
        final offset = dataStart + s * frameSize;
        final sample = _readInt16(all, offset);
        final amp = sample.abs() / 32768.0;
        if (amp > maxAmp) maxAmp = amp;
      }
      bars.add((4.0 + maxAmp * 8.0).clamp(4.0, 12.0));
    }
    return bars;
  }

  static int _readInt16(List<int> bytes, int offset) {
    final v = bytes[offset] | (bytes[offset + 1] << 8);
    return v > 32767 ? v - 65536 : v;
  }

  String _formatSec(double s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toInt().toString().padLeft(2, '0');
    return '$m:$sec';
  }

  double _fraction(double sec) {
    final d = _info.duration.inSeconds.toDouble();
    if (d <= 0) return 0.0;
    return (sec / d).clamp(0.0, 1.0);
  }

  double _secondsFromFraction(double f) {
    final d = _info.duration.inSeconds.toDouble();
    if (d <= 0) return 0.0;
    return f.clamp(0.0, 1.0) * d;
  }

  void _updateFromDx(double dx, double width) {
    if (width <= 0) return;
    final f = (dx / width).clamp(0.0, 1.0);
    final sec = _secondsFromFraction(f);
    if (_dragging == _DragHandle.start) {
      setState(() => _startSec = sec.clamp(0, _endSec - _minTrimSec));
    } else {
      setState(
        () => _endSec = sec.clamp(
          _startSec + _minTrimSec,
          _info.duration.inSeconds.toDouble(),
        ),
      );
    }
  }

  Future<void> _playSelected() async {
    if (_isPlaying) return;
    _player ??= AudioPlayer();
    try {
      await _player!.play(DeviceFileSource(widget.audioPath));
      await _player!.seek(Duration(milliseconds: (_startSec * 1000).round()));
      setState(() {
        _isPlaying = true;
        _playheadFraction = _fraction(_startSec);
        _playStartTime = DateTime.now();
      });
      final playDuration = Duration(
        milliseconds: ((_endSec - _startSec) * 1000).round(),
      );
      _playTimer = Timer(playDuration, () {
        if (mounted) {
          setState(() => _isPlaying = false);
          _player?.pause();
          _playheadTimer?.cancel();
        }
      });
      _playheadTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted || !_isPlaying) {
          _playheadTimer?.cancel();
          return;
        }
        final elapsedMs = DateTime.now()
            .difference(_playStartTime ?? DateTime.now())
            .inMilliseconds
            .toDouble();
        final startMs = _startSec * 1000;
        final endMs = _endSec * 1000;
        final totalMs = endMs - startMs;
        if (totalMs <= 0) return;
        final progress = (elapsedMs / totalMs).clamp(0.0, 1.0);
        if (mounted) {
          setState(
            () => _playheadFraction = _fraction(
              _startSec + progress * (_endSec - _startSec),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Trim preview play failed: $e');
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _applyTrim() async {
    if (_isApplying) return;
    setState(() => _isApplying = true);
    try {
      final dir = await _recordingsDir();
      final out =
          '${dir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.wav';
      final result = await VoiceAudioEditor.trim(
        inputPath: widget.audioPath,
        outputPath: out,
        startSec: _startSec,
        endSec: _endSec,
      );
      if (mounted) widget.onTrimmed(result.outputPath, result.duration);
    } catch (e) {
      debugPrint('Apply trim failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تطبيق القص: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<Directory> _recordingsDir() async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/recordings',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Widget _buildTrack(double width) {
    final startF = _fraction(_startSec);
    final endF = _fraction(_endSec);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final chat = context.chatColors;

    // Positionen من اليسار (للرسم)، ثم نعكس في RTL لللمس
    final cxStartLtr = startF * width;
    final cxEndLtr = endF * width;
    final cxStart = isRTL ? width - cxStartLtr : cxStartLtr;
    final cxEnd = isRTL ? width - cxEndLtr : cxEndLtr;

    final left = cxStart < cxEnd ? cxStart : cxEnd;
    final right = cxStart < cxEnd ? cxEnd : cxStart;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        final localDx = details.localPosition.dx;
        final f = (localDx / width).clamp(0.0, 1.0);
        final distStart = (f - startF).abs();
        final distEnd = (f - endF).abs();
        _dragging = distStart <= distEnd ? _DragHandle.start : _DragHandle.end;
        _updateFromDx(localDx, width);
      },
      onHorizontalDragUpdate: (details) =>
          _updateFromDx(details.localPosition.dx, width),
      onHorizontalDragEnd: (_) => setState(() => _dragging = null),
      child: SizedBox(
        height: _trackHeight + _handleSize + 12,
        child: Stack(
          children: [
            // شريط الموجة الخلفي (غير محدد)
            Positioned(
              left: 0,
              right: 0,
              top: (_handleSize - _trackHeight) / 2,
              child: Container(
                height: _trackHeight,
                decoration: BoxDecoration(
                  color: chat.recordingWaveUnplayed.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                ),
                child: CustomPaint(
                  size: Size(width, _trackHeight),
                  painter: _WaveBarsPainter(
                    bars: _bars,
                    inactiveColor: chat.recordingWaveUnplayed.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
              ),
            ),

            // شريط النطاق المحدد (الوسط)
            if (right > left)
              Positioned(
                left: left,
                right: width - right,
                top: (_handleSize - _trackHeight) / 2,
                child: Container(
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: chat.sendButton.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(_trackHeight / 2),
                  ),
                  child: CustomPaint(
                    size: Size(right - left, _trackHeight),
                    painter: _WaveBarsPainter(
                      bars: _bars,
                      inactiveColor: chat.sendButton,
                      startOffset: left / width,
                      endOffset: right / width,
                    ),
                  ),
                ),
              ),

            // مؤشر التشغيل (playhead)
            if (_isPlaying)
              Positioned(
                left: _playheadFraction * width - 1,
                right: width - _playheadFraction * width - 1,
                top: (_handleSize - _trackHeight) / 2 - 2,
                child: Container(
                  width: 2,
                  height: _trackHeight + 4,
                  decoration: BoxDecoration(
                    color: chat.sendButton,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

            // مقبض البداية
            Positioned(
              left: cxStart - _handleSize / 2,
              top: 0,
              child: _TrimHandle(
                size: _handleSize,
                color: chat.sendButton,
                isActive: _dragging == _DragHandle.start,
              ),
            ),

            // مقبض النهاية
            Positioned(
              left: cxEnd - _handleSize / 2,
              top: 0,
              child: _TrimHandle(
                size: _handleSize,
                color: chat.sendButton,
                isActive: _dragging == _DragHandle.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final dur = _endSec - _startSec;
    final chat = context.chatColors;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatSec(_startSec)} − ${_formatSec(_endSec)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: chat.inputText,
                ),
              ),
              Text(
                'المدة: ${_formatSec(dur)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: chat.inputText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? LucideIcons.pause : LucideIcons.play,
                  size: 20,
                  color: chat.sendButton,
                ),
                onPressed: _isPlaying ? null : _playSelected,
                tooltip: 'استماع للمقطع المحدد',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              if (_isApplying)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ElevatedButton.icon(
                  onPressed: _applyTrim,
                  icon: Icon(LucideIcons.check, size: 18),
                  label: const Text('تطبيق القص'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: chat.sendButton,
                    foregroundColor: context.textColors.onAccent,
                    minimumSize: const Size(150, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _isApplying ? null : widget.onCancel,
                icon: Icon(LucideIcons.x, size: 18),
                label: const Text('إلغاء'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: chat.inputText,
                  minimumSize: const Size(110, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.50,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: context.textColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'قص التسجيل الصوتي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.textColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اسحب المقبضين من الطرفين لتحديد الجزء الذي تريد إبقاءه',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textColors.disabled,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  return _buildTrack(constraints.maxWidth);
                },
              ),
              const SizedBox(height: 26),
              _buildControls(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/// رسام أشرطة الموجة داخل نطاق معين
class _WaveBarsPainter extends CustomPainter {
  final List<double> bars;
  final Color inactiveColor;
  final double startOffset;
  final double endOffset;

  const _WaveBarsPainter({
    required this.bars,
    required this.inactiveColor,
    this.startOffset = 0.0,
    this.endOffset = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = bars.length.clamp(1, 1000);
    final barW = size.width / barCount;
    final midY = size.height / 2;
    for (var i = 0; i < barCount; i++) {
      final frac = i / barCount;
      if (frac < startOffset || frac > endOffset) continue;
      final x = i * barW;
      final h = bars[i].clamp(1.0, size.height);
      canvas.drawRRect(
        RRect.fromLTRBR(
          x + 0.5,
          midY - h / 2,
          x + barW - 0.5,
          midY + h / 2,
          const Radius.circular(1),
        ),
        Paint()
          ..color = inactiveColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveBarsPainter old) =>
      old.bars != bars ||
      old.inactiveColor != inactiveColor ||
      old.startOffset != startOffset ||
      old.endOffset != endOffset;
}

/// مقبض القص الدائري (أبيض مع حدود ملونة)
class _TrimHandle extends StatelessWidget {
  final double size;
  final Color color;
  final bool isActive;

  const _TrimHandle({
    required this.size,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.backgroundColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: isActive ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: context.backgroundColors.scrim.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
