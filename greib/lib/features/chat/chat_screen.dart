import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/header.dart';

// ---------------------------------------------------------------------------
//  أدوات مساعدة متجاوبة (Responsive helpers)
//  نقطة الكسر (breakpoint) تعتمد على أصغر بُعد في الشاشة لكي تعمل بشكل
//  صحيح سواء في الوضع الرأسي أو الأفقي (Landscape).
// ---------------------------------------------------------------------------
const double _kTabletBreakpoint = 600.0;
const double _kMaxChatAreaWidth = 700.0; // يُقيّد عرض المحادثة على الشاشات العريضة
const double _kMaxBubbleWidth = 480.0; // حد أقصى مريح لقراءة فقاعة الرسالة
const double _kMaxImageWidth = 280.0; // حد أقصى لفقاعة الصورة

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= _kTabletBreakpoint;

bool _isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

/// عرض منطقة المحادثة الكلي، مُقيّد بحد أقصى ومُوسّط على الشاشات العريضة.
double _chatAreaMaxWidth(BuildContext context) =>
    min(MediaQuery.of(context).size.width, _kMaxChatAreaWidth);

/// أقصى عرض لفقاعة رسالة واحدة (نسبة من الشاشة + حد أقصى مطلق بالبكسل).
double _bubbleMaxWidth(BuildContext context, {required bool isVoice}) =>
    min(MediaQuery.of(context).size.width * (isVoice ? 0.82 : 0.78), _kMaxBubbleWidth);

/// أقصى عرض لفقاعة الصورة (نسبة من الشاشة + حد أقصى).
double _imageMaxWidth(BuildContext context) =>
    min(MediaQuery.of(context).size.width * 0.55, _kMaxImageWidth);

/// ثوابت أحجام دائرية متجاوبة (صغير/متوسط/كبير) لتفادي الأرقام السحرية المتكررة.
double _responsiveAvatar(BuildContext context, {double phone = 56, double tablet = 72}) =>
    _isTablet(context) ? tablet : phone;

// NOTE ON DEPENDENCIES
// This screen records/plays *real* audio and attaches *real* photos,
// like WhatsApp. The following are required in pubspec.yaml:
//   record: ^7.1.1
//   audioplayers: ^6.1.0
//   path_provider: ^2.1.0
//   image_picker: ^1.1.0
//   permission_handler: ^11.3.0 (opens OS settings when a permission is denied)
//
// iOS: NSCameraUsageDescription, NSMicrophoneUsageDescription and
// NSPhotoLibraryUsageDescription in ios/Runner/Info.plist.
// Android: RECORD_AUDIO, CAMERA and READ_MEDIA_IMAGES in AndroidManifest.xml.

/// Composer state machine: normal text entry, actively recording a voice
/// note, or previewing a just-recorded note before it's sent — mirrors
/// WhatsApp's record → preview → send flow.
enum _ComposerMode { idle, recording, preview }

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<Map<String, dynamic>> _conversations;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    final role = AuthService.instance.currentRole;

    _conversations = [
      {
        'id': 'chat1',
        'name': 'دعم گريب منك',
        'phone': '+971 50 123 4567',
        'lastMessage': 'أهلاً بك، طلبك في الطريق الآن 🚀',
        'time': '10:42 ص',
        'unread': 2,
        'avatar': '🤝',
        'type': 'support',
        'online': true,
        'activity': 'متصل الآن',
        'participants': ['u1', 'adm1'],
      },
      {
        'id': 'chat2',
        'name': 'فريق التوصيل - دبي',
        'phone': '+971 52 987 6543',
        'lastMessage': 'تم تسليم طلب الممزر بنجاح ✅',
        'time': '10:35 ص',
        'unread': 0,
        'avatar': '🚚',
        'type': 'group',
        'online': false,
        'activity': 'آخر ظهور اليوم 9:15 ص',
        'participants': ['a1', 'adm1', 'a2'],
      },
      {
        'id': 'chat3',
        'name': 'تنبيهات الطلبات',
        'phone': '+971 4 000 0000',
        'lastMessage': 'طلب جديد من أحمد محمد - توصيل طعام',
        'time': '10:00 ص',
        'unread': 1,
        'avatar': '📋',
        'type': 'system',
        'online': false,
        'activity': 'حساب آلي',
        'participants': [],
      },
    ];

    if (role == UserRole.admin) {
      _conversations.addAll([
        {
          'id': 'chat4',
          'name': 'الوكلاء (المجموعة العامة)',
          'phone': 'مجموعة · 4 أعضاء',
          'lastMessage': 'سلام عليكم، التقرير اليومي جاهز',
          'time': '9:30 ص',
          'unread': 3,
          'avatar': '👥',
          'type': 'group',
          'online': true,
          'activity': '3 أعضاء متصلين',
          'participants': ['adm1', 'a1', 'a2', 'a3'],
        },
        {
          'id': 'chat5',
          'name': 'شكاوى العملاء',
          'phone': 'مجموعة · 3 أعضاء',
          'lastMessage': 'العميل أحمد يطلب تحديث حالة الطلب',
          'time': '9:15 ص',
          'unread': 1,
          'avatar': '📢',
          'type': 'support',
          'online': false,
          'activity': 'آخر ظهور أمس 11:40 م',
          'participants': ['adm1', 'u1', 'u2'],
        },
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: Header(
        title: 'المحادثات',
        showNotifications: false,
        showDarkModeToggle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.full),
                border: Border.all(
                  color: isDark ? AppColors.outline : AppColors.lightOutline,
                ),
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث أو ابدأ محادثة جديدة',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(LucideIcons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                indent: 76,
                color: isDark ? AppColors.outline.withValues(alpha: 0.35) : AppColors.lightOutline,
              ),
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                return _buildConversationTile(context, theme, conv);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('محادثة جديدة ✏️'), duration: Duration(seconds: 1)),
          );
        },
        child: const Icon(LucideIcons.messageCircle),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> conv,
  ) {
    final unread = conv['unread'] as int;
    final online = conv['online'] as bool;
    final isGroup = conv['type'] == 'group';

    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationTitle: conv['name'] as String,
              conversationId: conv['id'] as String,
              avatar: conv['avatar'] as String,
              phone: conv['phone'] as String,
              online: online,
              activity: conv['activity'] as String,
              isGroup: isGroup,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: _responsiveAvatar(context),
                  height: _responsiveAvatar(context),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(conv['avatar'] as String, style: TextStyle(fontSize: (unread > 0 ? 26 : 22) * (_isTablet(context) ? 1.2 : 1.0))),
                  ),
                ),
                if (online)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: _isTablet(context) ? 16 : 14,
                      height: _isTablet(context) ? 16 : 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
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

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          conv['time'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: unread > 0 ? AppColors.accentPrimary : theme.colorScheme.onSurfaceVariant,
                            fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv['lastMessage'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: unread > 0
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Center(
                            // FittedBox يمنع قص/طفح رقم "غير مقروء" عند تكبير الخط.
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const Icon(LucideIcons.checkCheck, size: 16, color: AppColors.accentPrimary),
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

class ChatDetailScreen extends StatefulWidget {
  final String conversationTitle;
  final String conversationId;
  final String avatar;
  final String phone;
  final bool online;
  final String activity;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.conversationTitle,
    required this.conversationId,
    required this.avatar,
    required this.phone,
    required this.online,
    required this.activity,
    required this.isGroup,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  // يتتبّع ظهور لوحة المفاتيح لإعادة التمرير لأسفل الرسائل عند فتحها.
  double _lastKeyboardInset = 0;

  // ---- Real audio recording ----
  final AudioRecorder _audioRecorder = AudioRecorder();
  _ComposerMode _composerMode = _ComposerMode.idle;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  String? _currentRecordingPath;

  // Live waveform bars driven by real microphone amplitude while recording.
  final List<double> _liveWaveform = [];
  final ScrollController _liveWaveController = ScrollController();

  // Recorded-but-not-sent-yet voice note, shown as a preview the user can
  // listen to before deciding to send or discard — like WhatsApp.
  String? _pendingAudioPath;
  int _pendingDuration = 0;
  List<double> _pendingWaveformBars = const [];

  // ---- Real image attachment ----
  final ImagePicker _imagePicker = ImagePicker();

  // Tracks which voice bubble is currently playing, so starting one
  // pauses any other that's playing — same behaviour as WhatsApp.
  final ValueNotifier<String?> _currentlyPlayingId = ValueNotifier(null);

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'm1',
      'sender': 'أحمد محمد',
      'content': 'مرحباً، متى يوصل طلب الطعام؟',
      'time': '10:30 صباحاً',
      'isMine': false,
    },
    {
      'id': 'm2',
      'sender': 'دعم گريب منك',
      'content': 'أهلاً بك، طلبك في الطريق الآن 🚀',
      'time': '10:32 صباحاً',
      'isMine': true,
    },
    {
      'id': 'm3',
      'sender': 'أحمد محمد',
      'content': 'شكراً جزيلاً!',
      'time': '10:33 صباحاً',
      'isMine': false,
    },
    {
      'id': 'm4',
      'sender': 'دعم گريب منك',
      'content': 'العفو، نحن في الخدمة 🤝',
      'time': '10:35 صباحاً',
      'isMine': true,
    },
    {
      'id': 'm5',
      'sender': 'أحمد محمد',
      'content': 'كم باقي على التوصيل',
      'time': '10:40 صباحاً',
      'isMine': false,
    },
    {
      'id': 'm6',
      'sender': 'دعم گريب منك',
      'content': 'طلبك في الطريق، سيصل خلال ١٠ دقائق إن شاء الله ⏱️',
      'time': '10:42 صباحاً',
      'isMine': true,
    },
    // Demo voice message with no real audio file — tapping it explains
    // that only messages recorded in-app have real playback.
    {
      'id': 'm7',
      'sender': 'أحمد محمد',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 17,
      'time': '10:44 صباحاً',
      'isMine': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // لاحظ ظهور/اختفاء لوحة المفاتيح لإعادة التمرير لأسفل تلقائياً.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final inset = MediaQuery.of(context).viewInsets.bottom;
    // استدعِ التمرير لأسفل فقط عند فتح الكيبورد (لا عند إغلاقه لتفادي قفزات).
    if (inset > _lastKeyboardInset && inset > 0) {
      _scrollToBottom();
    }
    _lastKeyboardInset = inset;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _liveWaveController.dispose();
    _recordTimer?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    _currentlyPlayingId.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Requests the given permission. If the user permanently denied it,
  /// shows an alert that links directly to the OS app settings so they
  /// can re-enable it there.
  Future<bool> _requestPermission(Permission permission, String deniedMessage) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (mounted) _showSettingsAlert(deniedMessage);
      return false;
    }

    final result = await permission.request();
    if (result.isGranted) return true;

    if (result.isPermanentlyDenied || result.isRestricted) {
      if (mounted) _showSettingsAlert(deniedMessage);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(deniedMessage)));
      }
    }
    return false;
  }

  void _showSettingsAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الإذن مطلوب'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('فتح إعدادات التطبيق'),
          ),
        ],
      ),
    );
  }

  /// Shows a transient error message to the user for any recording /
  /// playback / permission failure — replaces silent failures.
  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _startRecording() async {
    // Real permission request — actually prompts the OS mic permission
    // dialog the first time, and reflects a prior denial afterwards.
    final granted = await _requestPermission(
      Permission.microphone,
      'يجب السماح باستخدام الميكروفون من إعدادات الجهاز لتسجيل رسالة صوتية',
    );
    if (!granted) return;

    if (!await _audioRecorder.hasPermission()) {
      _showErrorMessage('تعذر الحصول على إذن الميكروفون لتسجيل الرسالة الصوتية');
      return;
    }

    final dir = await getTemporaryDirectory();
    // Make sure the temp directory actually exists and is writable.
    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (e) {
        debugPrint('Failed to create temp dir: $e');
      }
    }
    _currentRecordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Print the full path so we can verify it's writable on the target OS.
    debugPrint('Recording path: $_currentRecordingPath');
    assert(await dir.exists(), 'Temporary directory must exist before recording');

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
          // Explicit platform configs avoid silent failures on some devices.
          androidConfig: AndroidRecordConfig(
            audioSource: AndroidAudioSource.mic,
          ),
          iosConfig: IosRecordConfig(),
        ),
        path: _currentRecordingPath!,
      );
    } catch (e, st) {
      debugPrint('Recording start failed: $e\n$st');
      if (mounted) {
        _showErrorMessage('فشل بدء التسجيل: ${e.toString()}');
      }
      return;
    }

    setState(() {
      _composerMode = _ComposerMode.recording;
      _recordSeconds = 0;
      _liveWaveform.clear();
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _recordSeconds++);
    });

    // Real microphone amplitude drives the waveform, instead of random bars.
    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 150))
        .listen((amp) {
      // amp.current is in dBFS, roughly -45 (silence) .. 0 (loud).
      final normalized = ((amp.current + 45) / 45).clamp(0.0, 1.0);
      final height = 4.0 + normalized * 22.0;
      if (mounted) setState(() => _liveWaveform.add(height));
      if (_liveWaveController.hasClients) {
        _liveWaveController.jumpTo(_liveWaveController.position.maxScrollExtent);
      }
    });
  }

  /// Stops recording and moves to the preview state — the note is NOT
  /// sent yet, exactly like tapping the checkmark in WhatsApp.
  Future<void> _finishRecordingToPreview() async {
    _recordTimer?.cancel();
    await _amplitudeSub?.cancel();

    String? path;
    try {
      path = await _audioRecorder.stop();
    } catch (e, st) {
      debugPrint('Recording stop failed: $e\n$st');
      if (mounted) _showErrorMessage('فشل إيقاف التسجيل: ${e.toString()}');
      setState(() {
        _composerMode = _ComposerMode.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    final duration = _recordSeconds;

    // Defensive check: make sure a real, non-empty audio file was produced
    // before we transition to the preview screen. Otherwise the preview
    // would silently show an empty/blank waveform.
    if (path == null) {
      debugPrint('Recording produced no path (path == null)');
      if (mounted) _showErrorMessage('لم يتم إنتاج ملف صوتي، حاول مرة أخرى');
      setState(() {
        _composerMode = _ComposerMode.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    final file = File(path);
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    debugPrint('recorded file exists=$exists size=$size path=$path');

    if (!exists || size == 0) {
      if (mounted) {
        _showErrorMessage('فشل التسجيل: لم يتم حفظ ملف صوت غير فارغ');
      }
      setState(() {
        _composerMode = _ComposerMode.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    if (duration <= 0) {
      setState(() {
        _composerMode = _ComposerMode.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    final capturedWaveform = _resampleWaveform(_liveWaveform, 40);

    setState(() {
      _composerMode = _ComposerMode.preview;
      _pendingAudioPath = path;
      _pendingDuration = duration;
      _pendingWaveformBars = capturedWaveform;
      _liveWaveform.clear();
      _recordSeconds = 0;
    });
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    await _amplitudeSub?.cancel();
    final path = await _audioRecorder.stop();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {
      _composerMode = _ComposerMode.idle;
      _recordSeconds = 0;
      _liveWaveform.clear();
    });
  }

  /// Discards the recorded-but-unsent note and deletes its temp file.
  Future<void> _discardPreview() async {
    final path = _pendingAudioPath;
    setState(() {
      _composerMode = _ComposerMode.idle;
      _pendingAudioPath = null;
      _pendingDuration = 0;
      _pendingWaveformBars = const [];
    });
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Actually sends the previewed voice note as a message.
  void _sendPendingVoice() {
    final path = _pendingAudioPath;
    final duration = _pendingDuration;
    if (path == null) return;

    setState(() {
      _composerMode = _ComposerMode.idle;
      _pendingAudioPath = null;
      _pendingDuration = 0;
      _pendingWaveformBars = const [];
    });

    _sendVoiceMessage(path, duration);
  }

  /// Collapses the raw ~150ms-interval amplitude samples down to a fixed
  /// number of bars so the preview/message waveform has a stable shape.
  List<double> _resampleWaveform(List<double> raw, int targetCount) {
    if (raw.isEmpty) return List.filled(targetCount, 6.0);
    if (raw.length <= targetCount) {
      return List.generate(targetCount, (i) {
        final idx = (i * raw.length / targetCount).floor().clamp(0, raw.length - 1);
        return raw[idx];
      });
    }
    final chunkSize = raw.length / targetCount;
    return List.generate(targetCount, (i) {
      final start = (i * chunkSize).floor();
      final end = ((i + 1) * chunkSize).floor().clamp(start + 1, raw.length);
      final chunk = raw.sublist(start, end);
      final avg = chunk.reduce((a, b) => a + b) / chunk.length;
      return avg;
    });
  }

  void _sendVoiceMessage(String audioPath, int duration) {
    setState(() {
      _messages.add({
        'id': 'm${DateTime.now().millisecondsSinceEpoch}',
        'sender': 'أنت',
        'content': '',
        'isVoice': true,
        'audioPath': audioPath,
        'duration': duration,
        'time': 'الآن',
        'isMine': true,
      });
    });
    _scrollToBottom();
    _simulateReply();
  }

  /// Shows a WhatsApp-style attachment sheet with real Camera / Gallery
  /// options, each backed by the OS picker and its own permission prompt.
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera, color: AppColors.accentPrimary),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: AppColors.accentPrimary),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final deniedMessage = source == ImageSource.camera
        ? 'يجب السماح باستخدام الكاميرا من إعدادات التطبيق لالتقاط صورة'
        : 'يجب السماح بالوصول إلى الصور من إعدادات التطبيق لاختيار صورة';

    final granted = await _requestPermission(permission, deniedMessage);
    if (!granted) return;

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked == null) return; // user cancelled

      // Open a WhatsApp-style preview sheet — the image is NOT added to the
      // conversation until the user actually presses "إرسال".
      if (mounted) _showImagePreviewSheet(picked.path);
    } catch (e, st) {
      debugPrint('Image pick failed: $e\n$st');
      if (!mounted) return;
      _showErrorMessage('تعذر اختيار الصورة: ${e.toString()}');
    }
  }

  /// Shows a full preview sheet before the image is committed to the chat.
  /// The user can cancel (discard) or add an optional caption and send.
  void _showImagePreviewSheet(String imagePath) {
    final captionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ImagePreviewSheet(
          imagePath: imagePath,
          captionController: captionController,
          onCancel: () => Navigator.pop(sheetContext),
          onSend: (caption) {
            Navigator.pop(sheetContext);
            _sendImageMessage(imagePath, caption);
          },
        );
      },
    );
  }

  void _sendImageMessage(String imagePath, String caption) {
    setState(() {
      _messages.add({
        'id': 'm${DateTime.now().millisecondsSinceEpoch}',
        'sender': 'أنت',
        'content': caption,
        'imagePath': imagePath,
        'isImage': true,
        'time': 'الآن',
        'isMine': true,
      });
    });
    _scrollToBottom();
    _simulateReply();
  }

  /// Opens a full-screen image viewer with zoom support and share/save.
  void _openImageViewer(String imagePath, String tag) {
    if (!File(imagePath).existsSync()) {
      _showErrorMessage('الصورة غير متوفرة على هذا الجهاز');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _FullScreenImageViewer(
          imagePath: imagePath,
          heroTag: tag,
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'id': 'm${DateTime.now().millisecondsSinceEpoch}',
        'sender': 'أنت',
        'content': text,
        'time': 'الآن',
        'isMine': true,
      });
    });

    _messageController.clear();
    _scrollToBottom();
    _simulateReply();
  }

  void _simulateReply() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': 'm${DateTime.now().millisecondsSinceEpoch}',
            'sender': 'دعم گريب منك',
            'content': 'شكراً لتواصلك، سيتم الرد عليك قريباً 🙏',
            'time': 'الآن',
            'isMine': false,
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = _isLandscape(context);
    // شاشات أفقية ضيقة الارتفاع: نقلّص الحشوات الرأسية للـ AppBar.
    final avatarSize = _isTablet(context) ? 48.0 : 40.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        leadingWidth: 40,
        toolbarHeight: isLandscape ? 52 : kToolbarHeight,
        leading: Container(
          margin: const EdgeInsets.all(AppSpacing.xs),
          child: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 22),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.phone), duration: const Duration(seconds: 1)),
            );
          },
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.avatar,
                    style: TextStyle(fontSize: avatarSize * 0.5),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.conversationTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        if (!widget.isGroup && widget.online)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.xs),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.isGroup ? widget.activity : (widget.online ? 'متصل الآن' : widget.activity),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: (!widget.isGroup && widget.online)
                                  ? AppColors.success
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.video), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.phone), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.moreVertical), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // يُقيّد عرض المحادثة ويوسّطها أفقياً على الشاشات العريضة (تابلت/سطح مكتب).
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _chatAreaMaxWidth(context)),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.backgroundPrimary
                        : const Color(0xFFECE5DD),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(theme, msg);
                    },
                  ),
                ),
              ),
            ),
          ),

          // SafeArea أسفل الشاشة: تتجنّب تداخل حقل الكتابة مع منطقة الإيماءات.
          SafeArea(
            top: false,
            child: _buildComposer(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(ThemeData theme) {
    final hasText = _messageController.text.isNotEmpty;
    // شاشات أفقية ضيقة الارتفاع: نقلّص الحشوة الرأسية لتفادي طفح شريط التسجيل.
    final vPad = _isLandscape(context) ? AppSpacing.xs : AppSpacing.sm;
    final vPadMd = _isLandscape(context) ? AppSpacing.sm : AppSpacing.md;

    if (_composerMode == _ComposerMode.recording) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: vPadMd),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: AppColors.error),
              onPressed: _cancelRecording,
              tooltip: 'إلغاء التسجيل',
            ),
            const SizedBox(width: AppSpacing.xs),
            const _RecordingPulseDot(),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatDuration(_recordSeconds),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: ListView.builder(
                  controller: _liveWaveController,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: _liveWaveform.length,
                  itemBuilder: (context, i) {
                    final h = _liveWaveform[_liveWaveform.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.2),
                      child: Container(
                        width: 2.5,
                        height: h,
                        decoration: BoxDecoration(
                          color: AppColors.accentPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Stops recording and moves to preview — NOT sent yet.
            CircleAvatar(
              backgroundColor: AppColors.accentPrimary,
              child: IconButton(
                icon: const Icon(LucideIcons.check, color: Colors.white, size: 20),
                onPressed: _finishRecordingToPreview,
                tooltip: 'إيقاف ومعاينة',
              ),
            ),
          ],
        ),
      );
    }

    if (_composerMode == _ComposerMode.preview && _pendingAudioPath != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: vPad),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
        ),
        child: _RecordingPreviewBar(
          audioPath: _pendingAudioPath!,
          durationSeconds: _pendingDuration,
          waveformBars: _pendingWaveformBars,
          onDelete: _discardPreview,
          onSend: _sendPendingVoice,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: vPad),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(LucideIcons.camera, color: Colors.white, size: 20),
              onPressed: _showAttachmentOptions,
              tooltip: 'إرفاق صورة',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasText ? AppColors.accentPrimary : AppColors.success,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                hasText ? LucideIcons.send : LucideIcons.mic,
                color: Colors.white,
                size: 22,
              ),
              onPressed: hasText ? _sendMessage : _startRecording,
              tooltip: hasText ? 'إرسال' : 'تسجيل صوتي',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, Map<String, dynamic> msg) {
    final isMine = msg['isMine'] as bool;
    final isVoice = msg['isVoice'] as bool? ?? false;
    final isImage = msg['isImage'] as bool? ?? false;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        // حد أقصى مطلق بالبكسل + نسبة من الشاشة، لتفادي الفقاعات العريضة على التابلت.
        constraints: BoxConstraints(maxWidth: _bubbleMaxWidth(context, isVoice: isVoice)),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine && !isImage)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.sm),
                child: Text(
                  msg['sender'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            if (isImage)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isMine ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final path = msg['imagePath'] as String?;
                        if (path != null) {
                          _openImageViewer(path, 'img_${msg['id']}');
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        // عرض يعتمد على نسبة الشاشة مع حد أقصى، وAspectRatio بدل ارتفاع ثابت.
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: _imageMaxWidth(context)),
                          child: Builder(builder: (context) {
                            final path = msg['imagePath'] as String?;
                            final imageChild = path != null && File(path).existsSync()
                                ? Hero(
                                    tag: 'img_${msg['id']}',
                                    child: Image.file(File(path), fit: BoxFit.cover),
                                  )
                                : Container(
                                    color: isMine
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceContainerHighest,
                                    child: const Center(child: Text('📷', style: TextStyle(fontSize: 56))),
                                  );
                            return AspectRatio(
                              aspectRatio: 1.0,
                              child: imageChild,
                            );
                          }),
                        ),
                      ),
                    ),
                    if ((msg['content'] as String? ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Text(
                          msg['content'] as String,
                          style: TextStyle(
                            color: isMine ? Colors.white : theme.colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      msg['time'] as String,
                      style: TextStyle(
                        color: isMine ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
            else if (isVoice)
              _VoiceMessageBubble(
                id: msg['id'] as String,
                audioPath: msg['audioPath'] as String?,
                durationSeconds: msg['duration'] as int? ?? 0,
                isMine: isMine,
                time: msg['time'] as String,
                currentlyPlayingId: _currentlyPlayingId,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isMine ? AppColors.accentPrimary : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadii.lg),
                    topRight: const Radius.circular(AppRadii.lg),
                    bottomLeft: isMine ? const Radius.circular(AppRadii.lg) : const Radius.circular(AppRadii.xs),
                    bottomRight: isMine ? const Radius.circular(AppRadii.xs) : const Radius.circular(AppRadii.lg),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        msg['content'] as String,
                        style: TextStyle(
                          color: isMine ? Colors.white : theme.colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // FittedBox يمنع طفح/قص وقت الرسالة عند تكبير خط النظام.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        msg['time'] as String,
                        style: TextStyle(
                          color: isMine ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
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

/// Small blinking red dot shown while recording, like WhatsApp's rec indicator.
class _RecordingPulseDot extends StatefulWidget {
  const _RecordingPulseDot();

  @override
  State<_RecordingPulseDot> createState() => _RecordingPulseDotState();
}

class _RecordingPulseDotState extends State<_RecordingPulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
      ),
    );
  }
}

/// A WhatsApp-style voice message bubble with **real** audio playback:
/// play/pause, live progress against the actual audio position, tap on
/// the waveform to seek, and automatic pause when another bubble starts
/// playing.
class _VoiceMessageBubble extends StatefulWidget {
  final String id;
  final String? audioPath;
  final int durationSeconds;
  final bool isMine;
  final String time;
  final ValueNotifier<String?> currentlyPlayingId;

  const _VoiceMessageBubble({
    required this.id,
    required this.audioPath,
    required this.durationSeconds,
    required this.isMine,
    required this.time,
    required this.currentlyPlayingId,
  });

  @override
  State<_VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<_VoiceMessageBubble> {
  static const int _barCount = 40;

  final AudioPlayer _player = AudioPlayer();
  late final List<double> _bars = _generateWaveform(widget.id, _barCount);

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<void>? _completeSub;
  VoidCallback? _playingListener;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.durationSeconds);

    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = _player.onDurationChanged.listen((d) {
      if (mounted && d > Duration.zero) setState(() => _totalDuration = d);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    // Auto-pause this bubble if another one starts playing.
    _playingListener = () {
      if (widget.currentlyPlayingId.value != widget.id && _isPlaying) {
        _player.pause();
        if (mounted) setState(() => _isPlaying = false);
      }
    };
    widget.currentlyPlayingId.addListener(_playingListener!);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _completeSub?.cancel();
    if (_playingListener != null) {
      widget.currentlyPlayingId.removeListener(_playingListener!);
    }
    _player.dispose();
    super.dispose();
  }

  List<double> _generateWaveform(String seed, int count) {
    final rand = Random(seed.hashCode);
    final bars = <double>[];
    double last = 10;
    for (var i = 0; i < count; i++) {
      final delta = (rand.nextDouble() - 0.5) * 14;
      last = (last + delta).clamp(3.0, 22.0);
      bars.add(last);
    }
    return bars;
  }

  Future<void> _togglePlay() async {
    if (widget.audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رسالة تجريبية بدون ملف صوتي حقيقي، سجّل رسالة جديدة لتجربة التشغيل')),
      );
      return;
    }

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);
    widget.currentlyPlayingId.value = widget.id;

    if (_totalDuration > Duration.zero && _position >= _totalDuration) {
      await _player.seek(Duration.zero);
    }

    await _player.play(DeviceFileSource(widget.audioPath!));

    if (mounted) {
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    }
  }

  /// Maps a local dx offset within the (dynamic) waveform width to a 0..1
  /// fraction of the clip. Works for both tap and horizontal drag.
  double _fractionFromOffset(double dx, double width) {
    if (width <= 0) return 0.0;
    return (dx / width).clamp(0.0, 1.0);
  }

  Future<void> _seekToFraction(double fraction) async {
    if (widget.audioPath == null || _totalDuration == Duration.zero) return;
    final target = _totalDuration * fraction.clamp(0.0, 1.0);
    // Seeking is allowed both while playing and while paused.
    await _player.seek(target);
    setState(() => _position = target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMine = widget.isMine;

    final totalMs = _totalDuration.inMilliseconds;
    final playedFraction = totalMs == 0 ? 0.0 : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final playedBars = (playedFraction * _barCount).floor();

    final remaining = _totalDuration - _position;
    final remainingSeconds = remaining.isNegative ? 0 : remaining.inSeconds;

    final bubbleColor = isMine ? AppColors.accentPrimary : theme.colorScheme.surfaceContainerHighest;
    final onBubble = isMine ? Colors.white : theme.colorScheme.onSurface;
    final playedColor = isMine ? Colors.white : theme.colorScheme.primary;
    final unplayedColor = (isMine ? Colors.white : theme.colorScheme.primary).withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadii.lg),
          topRight: const Radius.circular(AppRadii.lg),
          bottomLeft: isMine ? const Radius.circular(AppRadii.lg) : const Radius.circular(AppRadii.xs),
          bottomRight: isMine ? const Radius.circular(AppRadii.xs) : const Radius.circular(AppRadii.lg),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onBubble.withValues(alpha: 0.15),
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(9),
                      child: CircularProgressIndicator(strokeWidth: 2, color: onBubble),
                    )
                  : Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: onBubble,
                      size: 18,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // الموجة تتمدّد تلقائياً حسب المساحة المتاحة داخل الفقاعة، مع حد
          // أقصى معقول على الشاشات العريضة (تابلت) لتفادي التمدد المبالغ.
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final width = constraints.maxWidth;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final fraction = _fractionFromOffset(details.localPosition.dx, width);
                          _seekToFraction(fraction);
                        },
                        onHorizontalDragUpdate: (details) {
                          final fraction = _fractionFromOffset(details.localPosition.dx, width);
                          _seekToFraction(fraction);
                        },
                        child: SizedBox(
                          height: 26,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(_barCount, (i) {
                                  final played = i <= playedBars;
                                  return Container(
                                    width: 2.4,
                                    height: _bars[i],
                                    decoration: BoxDecoration(
                                      color: played ? playedColor : unplayedColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                              // Visible playhead that reflects the current position.
                              Positioned(
                                left: playedFraction * (width - 2.4),
                                top: -2,
                                bottom: -2,
                                child: Container(
                                  width: 2.4,
                                  decoration: BoxDecoration(
                                    color: playedColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _formatSeconds(
                                _isPlaying || _position > Duration.zero ? remainingSeconds : widget.durationSeconds,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: onBubble.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.time,
                                style: TextStyle(
                                  color: onBubble.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 3),
                            Icon(LucideIcons.checkCheck, size: 12, color: onBubble.withValues(alpha: 0.85)),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(LucideIcons.mic, color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }
}

/// Inline composer widget shown right after recording stops: lets the
/// user actually listen to what they just recorded, and only then
/// choose to send it or throw it away — the WhatsApp preview step.
class _RecordingPreviewBar extends StatefulWidget {
  final String audioPath;
  final int durationSeconds;
  final List<double> waveformBars;
  final VoidCallback onDelete;
  final VoidCallback onSend;

  const _RecordingPreviewBar({
    required this.audioPath,
    required this.durationSeconds,
    required this.waveformBars,
    required this.onDelete,
    required this.onSend,
  });

  @override
  State<_RecordingPreviewBar> createState() => _RecordingPreviewBarState();
}

class _RecordingPreviewBarState extends State<_RecordingPreviewBar> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isDeleting = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.durationSeconds);

    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = _player.onDurationChanged.listen((d) {
      if (mounted && d > Duration.zero) setState(() => _totalDuration = d);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);
    if (_totalDuration > Duration.zero && _position >= _totalDuration) {
      await _player.seek(Duration.zero);
    }
    await _player.play(DeviceFileSource(widget.audioPath));
    if (mounted) {
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    await _player.stop();
    widget.onDelete();
  }

  Future<void> _seekToFraction(double fraction) async {
    if (_totalDuration == Duration.zero) return;
    final target = _totalDuration * fraction.clamp(0.0, 1.0);
    await _player.seek(target);
    setState(() => _position = target);
  }

  String _formatSeconds(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barCount = widget.waveformBars.length;

    final totalMs = _totalDuration.inMilliseconds;
    final playedFraction = totalMs == 0 ? 0.0 : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final playedBars = (playedFraction * barCount).floor();

    final remaining = _totalDuration - _position;
    final remainingSeconds = remaining.isNegative ? 0 : remaining.inSeconds;

    return Row(
      children: [
        IconButton(
          icon: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                )
              : const Icon(LucideIcons.trash2, color: AppColors.error),
          onPressed: _isDeleting ? null : _handleDelete,
          tooltip: 'حذف',
        ),
        const SizedBox(width: AppSpacing.xs),

        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPrimary.withValues(alpha: 0.15),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPrimary),
                  )
                : Icon(
                    _isPlaying ? LucideIcons.pause : LucideIcons.play,
                    color: AppColors.accentPrimary,
                    size: 18,
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final width = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final fraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
                      _seekToFraction(fraction);
                    },
                    onHorizontalDragUpdate: (details) {
                      final fraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
                      _seekToFraction(fraction);
                    },
                    child: SizedBox(
                      height: 26,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(barCount, (i) {
                              final played = i <= playedBars;
                              return Container(
                                width: 2.4,
                                height: widget.waveformBars[i],
                                decoration: BoxDecoration(
                                  color: played
                                      ? AppColors.accentPrimary
                                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                          // Visible playhead reflecting the current position.
                          Positioned(
                            left: playedFraction * (width - 2.4),
                            top: -2,
                            bottom: -2,
                            child: Container(
                              width: 2.4,
                              decoration: BoxDecoration(
                                color: AppColors.accentPrimary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                _formatSeconds(
                  _isPlaying || _position > Duration.zero ? remainingSeconds : widget.durationSeconds,
                ),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        CircleAvatar(
          backgroundColor: AppColors.accentPrimary,
          child: IconButton(
            icon: const Icon(LucideIcons.send, color: Colors.white, size: 18),
            onPressed: widget.onSend,
            tooltip: 'إرسال',
          ),
        ),
      ],
    );
  }
}

/// WhatsApp-style image preview sheet shown right after picking a photo.
/// The image is NOT committed to the chat until the user presses "إرسال";
/// "X" discards it entirely. An optional caption can be added.
class _ImagePreviewSheet extends StatefulWidget {
  final String imagePath;
  final TextEditingController captionController;
  final VoidCallback onCancel;
  final ValueChanged<String> onSend;

  const _ImagePreviewSheet({
    required this.imagePath,
    required this.captionController,
    required this.onCancel,
    required this.onSend,
  });

  @override
  State<_ImagePreviewSheet> createState() => _ImagePreviewSheetState();
}

class _ImagePreviewSheetState extends State<_ImagePreviewSheet> {
  @override
  void dispose() {
    widget.captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.error),
                onPressed: widget.onCancel,
                tooltip: 'إلغاء',
              ),
              const Spacer(),
              Text(
                'معاينة الصورة',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: widget.captionController,
            textAlign: TextAlign.right,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'أضف تعليقاً (اختياري)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.full),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
              icon: const Icon(LucideIcons.send),
              label: const Text('إرسال'),
              onPressed: () => widget.onSend(widget.captionController.text.trim()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer with zoom (InteractiveViewer) and a smooth
/// Hero transition from the chat bubble. Supports share and save.
class _FullScreenImageViewer extends StatefulWidget {
  final String imagePath;
  final String heroTag;

  const _FullScreenImageViewer({
    required this.imagePath,
    required this.heroTag,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  bool _saving = false;

  Future<void> _share() async {
    try {
      await Share.shareXFiles([XFile(widget.imagePath)], text: 'صورة من گريب منك');
    } catch (e, st) {
      debugPrint('Share failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر مشاركة الصورة')),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Route through the system share sheet — on both iOS and Android it
      // surfaces a "Save Image" target, so no extra plugin is required.
      await Share.shareXFiles(
        [XFile(widget.imagePath)],
        text: 'حفظ صورة من گريب منك',
      );
    } catch (e, st) {
      debugPrint('Save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الصورة')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.download, color: Colors.white),
            onPressed: _saving ? null : _save,
            tooltip: 'حفظ',
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.white),
            onPressed: _share,
            tooltip: 'مشاركة',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: widget.heroTag,
            child: Image.file(File(widget.imagePath)),
          ),
        ),
      ),
    );
  }
}
