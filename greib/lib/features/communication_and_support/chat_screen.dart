import 'dart:async';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/chat_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/loading_states.dart';
import 'widgets/call_log_tile.dart';
import 'widgets/chat_whatsapp_ui.dart';
import 'widgets/conversation_search_filter.dart';
import 'widgets/conversation_tile.dart';
import 'widgets/locked_archived_rows.dart';
import 'widgets/document_preview_sheet.dart';
import 'widgets/whatsapp_attachment.dart';
import 'widgets/whatsapp_bubble.dart';
import 'widgets/whatsapp_input_bar.dart';
import '../../features/auth/mock_auth.dart';
import 'contacts_chat_store.dart';
import 'contacts_screen.dart';
import 'story_message_store.dart';

// ---------------------------------------------------------------------------
//  أدوات مساعدة متجاوبة (Responsive helpers)
//  نقطة الكسر (breakpoint) تعتمد على أصغر بُعد في الشاشة لكي تعمل بشكل
//  صحيح سواء في الوضع الرأسي أو الأفقي (Landscape).
// ---------------------------------------------------------------------------
const double _kTabletBreakpoint = 600.0;
const double _kMaxChatAreaWidth =
    700.0; // يُقيّد عرض المحادثة على الشاشات العريضة
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
/// ★ مقاس واتساب الحقيقي: الصوت 75% بحد 300px — مدمجة وليست منفوخة.
double _bubbleMaxWidth(BuildContext context, {required bool isVoice}) => min(
  MediaQuery.of(context).size.width * (isVoice ? 0.75 : 0.78),
  isVoice ? 300.0 : _kMaxBubbleWidth,
);

/// أقصى عرض لفقاعة الصورة (نسبة من الشاشة + حد أقصى).
double _imageMaxWidth(BuildContext context) =>
    min(MediaQuery.of(context).size.width * 0.55, _kMaxImageWidth);

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
  int _selectedFilter = 0;
  String _query = '';

  static const List<String> _filterLabels = [
    'الكل',
    'غير مقروءة',
    'المكالمات',
    'المجموعات',
  ];

  /// ★ سجل المكالمات — بيانات تجريبية بستايل واتساب
  /// (صادرة/واردة/فائتة + صوتية/مرئية + المدة).
  final List<Map<String, dynamic>> _callLogs = [
    {
      'id': 'call1',
      'name': 'دعم گريب منك',
      'avatar': '🤝',
      'direction': 'incoming', // incoming | outgoing | missed
      'callType': 'voice', // voice | video
      'time': 'اليوم 10:20 ص',
      'duration': '05:32',
    },
    {
      'id': 'call2',
      'name': 'فريق التوصيل - دبي',
      'avatar': '🚚',
      'direction': 'missed',
      'callType': 'video',
      'time': 'أمس 6:45 م',
      'duration': null,
    },
    {
      'id': 'call3',
      'name': 'تنبيهات الطلبات',
      'avatar': '📋',
      'direction': 'outgoing',
      'callType': 'voice',
      'time': 'أمس 11:00 ص',
      'duration': '02:15',
    },
  ];

  /// هل تبويب المكالمات نشط؟ (index 2 بعد إضافة التبويب).
  bool get _isCallsTab => _selectedFilter == 2;

  /// سجل المكالمات بعد البحث النصي.
  List<Map<String, dynamic>> get _visibleCalls {
    if (_query.isEmpty) return _callLogs;
    final q = _query.trim();
    return _callLogs.where((c) => (c['name'] as String).contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★ تحديث عند كل عودة للصفحة (مثلاً بعد إرسال من ستوري):
    // تُدمج محادثات الخدمات الجديدة في الأعلى تلقائياً.
    final before = _conversations.length;
    _loadConversations();
    if (_conversations.length != before && mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ★ قائمة مرئية بعد البحث + الفلتر — منطق خفيف محلي (Local Filtering).
  /// الفهارس: 0 الكل | 1 غير مقروءة | 2 المكالمات (قائمة مستقلة) | 3 المجموعات.
  List<Map<String, dynamic>> get _visibleConversations {
    var list = _conversations;
    if (_selectedFilter == 1) {
      list = list.where((c) => (c['unread'] as int) > 0).toList();
    } else if (_selectedFilter == 3) {
      list = list.where((c) => c['type'] == 'group').toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.trim();
      list = list.where((c) {
        return (c['name'] as String).contains(q) ||
            (c['lastMessage'] as String).contains(q);
      }).toList();
    }
    return list;
  }

  /// عدد غير المقروءة لشارة فلتر «غير مقروءة» — مثل واتساب (غير مقروءة ١٥).
  int get _unreadCount =>
      _conversations.where((c) => (c['unread'] as int) > 0).length;

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

    // ★ محادثات الستوري المرسلة (حسابات خدمات جديدة بأسلوب فيسبوك):
    // تُدمج في الأعلى — كل خدمة أُرسل لها تظهر كحساب جديد بانتظار الرد.
    final storyConvs = StoryMessageStore.instance.storyConversations();
    final existingIds = _conversations.map((c) => c['id']).toSet();
    for (final sc in storyConvs) {
      if (existingIds.contains(sc['id'])) continue;
      existingIds.add(sc['id']);
      _conversations.insert(0, {
        ...sc,
        'participants': <String>[],
      });
    }

    // ★ «جهات اتصلي»: محادثات بدأها المستخدم من صفحة جهات الاتصال —
    // تُدمج في الأعلى (الحسابات الرسمية chat1-3 موجودة أصلاً فلا تتكرر).
    final contactConvs = ContactsChatStore.instance.contactConversations();
    for (final cc in contactConvs) {
      if (existingIds.contains(cc['id'])) continue;
      existingIds.add(cc['id']);
      _conversations.insert(0, cc);
    }

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
    // ★ الحل الصحيح للتحكم بالأبعاد دون تداخل أو فراغ مضاعف:
    // الـ Shell الخارجي فيه extendBodyBehindAppBar:true فيمرر Scaffold
    // (انظر _BodyBuilder في scaffold.dart) MediaQuery.padding.top جاهزة
    // = max(شريط الحالة، ارتفاع الهيدر) أي أنها تتضمن الهيدر أصلاً
    // وتتبع انكماشه (64 ↔ 48) تلقائياً. لذلك لا نجمع 64 يدوياً أبداً —
    // أي +64 يضاعف الهيدر ويخلق الفراغ الكبير، وحذف كل شيء يسبب
    // التداخل. الصحيح: padding.top الجاهزة + 8 تنفس فقط (مثل واتساب).
    final topInset = MediaQuery.paddingOf(context).top + 8;
    final chat = context.chatColors;
    final visible = _visibleConversations;
    return Scaffold(
      // ★ لون الخلفية من اللوحة المركزية (Color Palette).
      backgroundColor: chat.conversationBackground,
      // ★ بلا floatingActionButton هنا: الزر داخل الـ Stack فوق الشريط السفلي
      //   (مثل واتساب: زر أخضر عائم فوق BottomNavigationBar وليس خلفه).
      body: Stack(
        children: [
          Column(
            children: [
              // ★ إيقاع عمودي موحد على شبكة 8px مثل واتساب:
              //   هيدر → 8 → بحث (48) → 8 → شيبس (36) → 4
              //   → مقفلة/مؤرشفة → 4 → قائمة. كل فجوة مضبوطة رقمياً.
              SizedBox(height: topInset),
              // ── ① Persistent Search Bar — شريط بحث ثابت مثل واتساب ──
              Padding(
                // ★ 12 أفقي (مثل واتساب) بدل 8 الضيقة.
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ConversationSearchBar(
                  controller: _searchController,
                  query: _query,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              // ★ 8 بين البحث والفلاتر — وحدة الشبكة الكاملة.
              const SizedBox(height: 8),
              // ── ② Filter Chips Row — فلاتر أفقية ──
              // ★ 4 فلاتر: الكل | غير مقروءة | المكالمات | المجموعات.
              ConversationFilterChips(
                labels: _filterLabels,
                selectedIndex: _selectedFilter,
                unreadCount: _unreadCount,
                onSelected: (i) => setState(() => _selectedFilter = i),
              ),
              // ★ 4 قبل المقفلة/القائمة — فاصل تنفس صغير.
              // ── ③ Locked + Archived — مثل واتساب 100% ──
              // ★ فوق القائمة مباشرة (بعد الفلاتر)، تُخفى في المكالمات
              //   وأثناء البحث/الفلترة.
              if (_query.isEmpty && _selectedFilter == 0) ...[
                const SizedBox(height: 4),
                const LockedAndArchivedRows(lockedCount: 0, archivedCount: 19),
                const SizedBox(height: 4),
              ] else
                const SizedBox(height: 4),
              Expanded(
                // ★ تبويب المكالمات يعرض سجلاً مستقلاً بستايل واتساب،
                //   وبقية التبويبات تعرض قائمة المحادثات.
                child: _isCallsTab
                    ? _buildCallsList(context, chat)
                    : visible.isEmpty
                    ? EmptyState(
                        icon: _query.isNotEmpty
                            ? LucideIcons.searchX
                            : LucideIcons.messagesSquare,
                        title: _query.isNotEmpty
                            ? 'لا توجد نتائج لـ "$_query"'
                            : 'لا توجد محادثات هنا',
                        description: _query.isNotEmpty
                            ? 'جرّب كلمة أخرى أو امسح البحث'
                            : 'ستظهر محادثاتك هنا عند وصولها',
                      )
                    : ListView.builder(
                        // ★ حشوة سفلية كبيرة: الشريط السفلي العائم (68+20)
                        //   + الزر العائم فوقه ⇒ آخر محادثة لا تختبئ خلفهما.
                        padding: const EdgeInsets.only(bottom: 190),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final conv = visible[index];
                          final online = conv['online'] as bool;
                          final isGroup = conv['type'] == 'group';
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConversationTile(
                                name: conv['name'] as String,
                                lastMessage: conv['lastMessage'] as String,
                                time: conv['time'] as String,
                                avatar: conv['avatar'] as String,
                                unread: conv['unread'] as int,
                                online: online,
                                onTap: () =>
                                    _openConversation(conv, online, isGroup),
                              ),
                              // ★ فاصل واتساب: رفيع + يبدأ بعد الأفاتار (12+52+12=76).
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                indent: 76,
                                endIndent: 12,
                                color: chat.composerBorder,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          // ── ④ FAB عائم فوق الشريط السفلي — مثل زر واتساب الأخضر ──
          // ★ في RTL (العربية) الـ end = اليسار تلقائياً مثل واتساب.
          // ★ الأيقونة تتبع التبويب: هاتف في المكالمات، محادثة في البقية.
          PositionedDirectional(
            end: AppSpacing.lg,
            // ★ 108 = ارتفاع الشريط العائم (68) + هامشه السفلي (20)
            //   + مسافة تنفس (20) ⇒ الزر يطفو فوقه ولا يتداخل معه.
            bottom: 108,
            child: FloatingActionButton(
              heroTag: 'chat_list_fab',
              backgroundColor: chat.sendButton,
              foregroundColor: chat.sendIcon,
              elevation: 4,
              // ★ زر القلم (محادثة جديدة) يفتح صفحة «جهات الاتصال»:
              //   [جهات اتصال گريب منك | جهات اتصلي] — والضغط على أي حساب
              //   يفتح دردشة جديدة تُحفظ في قائمة الدردشة تلقائياً.
              //   في تبويب المكالمات يبقى سلوك «مكالمة جديدة» كما كان.
              onPressed: () {
                if (_isCallsTab) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('مكالمة جديدة 📞'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }
                Navigator.of(context, rootNavigator: true)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => ContactsScreen(
                          existingConversations: _conversations,
                        ),
                      ),
                    )
                    .then((_) {
                  // ★ العودة من الصفحة: دمج أي محادثات جديدة انطلقت منها.
                  if (!mounted) return;
                  setState(_loadConversations);
                });
              },
              child: Icon(
                _isCallsTab ? LucideIcons.phoneCall : LucideIcons.squarePen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ★ قائمة سجل المكالمات بستايل واتساب — نفس الشبكة والفواصل.
  Widget _buildCallsList(BuildContext context, dynamic chat) {
    final calls = _visibleCalls;
    if (calls.isEmpty) {
      return EmptyState(
        icon: _query.isNotEmpty ? LucideIcons.searchX : LucideIcons.phoneMissed,
        title: _query.isNotEmpty
            ? 'لا توجد نتائج لـ "$_query"'
            : 'لا توجد مكالمات',
        description: _query.isNotEmpty
            ? 'جرّب كلمة أخرى أو امسح البحث'
            : 'ستظهر مكالماتك هنا عند وصولها',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 190),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CallLogTile(
              name: call['name'] as String,
              avatar: call['avatar'] as String,
              direction: call['direction'] as String,
              callType: call['callType'] as String,
              time: call['time'] as String,
              duration: call['duration'] as String?,
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              indent: 76,
              endIndent: 12,
              color: chat.composerBorder,
            ),
          ],
        );
      },
    );
  }

  void _openConversation(Map<String, dynamic> conv, bool online, bool isGroup) {
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
          // ★ محادثة جديدة من جهات الاتصال تفتح فارغة (واتساب) —
          // والقديمة تفتح بمحادثتها القائمة كالمعتاد.
          startEmpty: (conv['isEmpty'] as bool?) ?? false,
        ),
      ),
    );
  }
}

/// معاينة منشور خدمة تُعرض كمرفق في صندوق الكتابة عند فتح المحادثة من
/// زر «طلب الآن»، وتبقى هناك حتى يرسلها المستخدم بنفسه (نصاً أو تسجيلاً صوتياً).
class ChatPostPreview {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Color color;

  const ChatPostPreview({
    required this.title,
    required this.subtitle,
    required this.color,
    this.imageUrl,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final String conversationTitle;
  final String conversationId;
  final String avatar;
  final String phone;
  final bool online;
  final String activity;
  final bool isGroup;

  /// مرفق «طلب الآن»: يُعرض في صندوق الكتابة ولا يُرسل إلا بضغط المستخدم.
  final ChatPostPreview? postPreview;

  /// ★ تركيز تلقائي على حقل الكتابة + فتح الكيبورد عند الفتح.
  /// يُستخدم عند القدوم من ستوري: المستخدم لمس «اكتب…»
  /// فيُوجَّه للدردشة ليكمل الكتابة فعلياً (هجين احترافي).
  final bool autofocusMessage;

  /// ★ محادثة جديدة فارغة تماماً (بلا الرسائل التجريبية المدمجة):
  /// تُستخدم عند بدء محادثة من صفحة «جهات الاتصال» — مثل واتساب.
  final bool startEmpty;

  const ChatDetailScreen({
    super.key,
    required this.conversationTitle,
    required this.conversationId,
    required this.avatar,
    required this.phone,
    required this.online,
    required this.activity,
    required this.isGroup,
    this.postPreview,
    this.autofocusMessage = false,
    this.startEmpty = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with WidgetsBindingObserver {
  /// ★ رسائل مرسلة من الستوري (إرسال خلفي بأسلوب فيسبوك): دمجها في
  /// قائمة المحادثة عند فتح الدردشة — بلا تكرار (نفس المعرف يُتجاهل).
  void _mergeStoryMessages() {
    final pending =
        StoryMessageStore.instance.forConversation(widget.conversationId);
    if (pending.isEmpty) return;
    final existingIds = _messages.map((m) => m['id']).toSet();
    var added = false;
    for (final p in pending) {
      if (existingIds.contains(p.id)) continue;
      _messages.add(p.toChatMap());
      added = true;
    }
    if (added) _scrollToBottom();
  }
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  // يتتبّع ظهور لوحة المفاتيح لإعادة التمرير لأسفل الرسائل عند فتحها.
  double _lastKeyboardInset = 0;

  // Focus node for the message input field.
  final FocusNode _messageFocusNode = FocusNode();

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

  // معاينة المنشور القادمة من زر «طلب الآن»: تظهر كمرفق في صندوق الكتابة،
  // وتبقى حتى يضغط المستخدم الإرسال (نصاً أو تسجيلاً صوتياً) أو يحذفها.
  ChatPostPreview? _pendingPost;

  // ★ الرد المقتبس بأسلوب WhatsApp (بصري فقط).
  Map<String, dynamic>? _replyingTo;

  // Tracks which voice bubble is currently playing, so starting one
  // pauses any other that's playing — same behaviour as WhatsApp.
  final ValueNotifier<String?> _currentlyPlayingId = ValueNotifier(null);

  final List<Map<String, dynamic>> _messages = [
    // ★ تسلسل يحاكي نفس فكرة الصورة: فويسات متبادلة + سجل مكالمة + رد + فاصل يوم.
    {
      'id': 'm1',
      'sender': 'أنت',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 6,
      'time': '2:20 م',
      'isMine': true,
      'isListened': true,
      'avatarText': '🌙',
    },
    {
      'id': 'm2',
      'sender': 'Di',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 3,
      'time': '7:31 م',
      'isMine': false,
      'isListened': false,
      'avatarText': '👤',
    },
    {
      'id': 'call1',
      'isCallLog': true,
      'callTitle': 'مكالمة صوتية',
      'callDuration': '23 ث',
      'time': '7:31 م',
      'isMine': false,
    },
    {
      'id': 'm3',
      'sender': 'أنت',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 44,
      'time': '7:59 م',
      'isMine': true,
      'isListened': true,
      'avatarText': '🌙',
    },
    {
      'id': 'm4',
      'sender': 'Di',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 3,
      'time': '8:02 م',
      'isMine': false,
      'isListened': false,
      'avatarText': '👤',
    },
    {
      'id': 'm5',
      'sender': 'أنت',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 15,
      'time': '8:03 م',
      'isMine': true,
      'isListened': true,
      'avatarText': '🌙',
      'quoted': {
        'sender': 'Di',
        'content': '',
        'isVoice': true,
        'duration': 3,
        'time': '8:02 م',
      },
    },
    {
      'id': 'm6',
      'sender': 'أنت',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 15,
      'time': '8:23 م',
      'isMine': true,
      'isListened': true,
      'avatarText': '🌙',
    },
    {
      'id': 'm7',
      'sender': 'أنت',
      'content': '',
      'isVoice': true,
      'audioPath': null,
      'duration': 16,
      'time': '8:23 م',
      'isMine': true,
      'isListened': false,
      'avatarText': '🌙',
    },
    {'id': 'day1', 'isDateDivider': true, 'label': 'السبت'},
    {
      'id': 'm8',
      'sender': 'أنت',
      'content': '26129374',
      'time': '8:08 م',
      'isMine': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // ★ محادثة جديدة من صفحة جهات الاتصال: تبدأ فارغة تماماً (واتساب).
    if (widget.startEmpty) _messages.clear();
    // ★ «طلب الآن» يفتح المحادثة ومعه معاينة المنشور ⇒ نضعها كمرفق «بانتظار
    // الإرسال» حتى لا تُرسل تلقائياً؛ المستخدم يختار الإرسال (نصاً/صوتاً).
    _pendingPost = widget.postPreview;
    // ★ رسائل مرسلة من الستوري (إرسال خلفي بأسلوب فيسبوك): دمجها هنا
    //   عند فتح الدردشة لاحقاً فيراها المستخدم مع المرفق — بلا توجيه تلقائي.
    _mergeStoryMessages();
    // لاحظ ظهور/اختفاء لوحة المفاتيح لإعادة التمرير لأسفل تلقائياً.
    WidgetsBinding.instance.addObserver(this);
    // ★ قدوم من حقل الستوري: ركّز حقل الكتابة وافتح الكيبورد تلقائياً.
    if (widget.autofocusMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _messageFocusNode.requestFocus();
      });
    }
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
    _messageFocusNode.dispose();
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
  Future<bool> _requestPermission(
    Permission permission,
    String deniedMessage,
  ) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(deniedMessage)));
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
        backgroundColor: context.chatColors.recordingTrash,
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
      _showErrorMessage(
        'تعذر الحصول على إذن الميكروفون لتسجيل الرسالة الصوتية',
      );
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
    _currentRecordingPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Print the full path so we can verify it's writable on the target OS.
    debugPrint('Recording path: $_currentRecordingPath');
    assert(
      await dir.exists(),
      'Temporary directory must exist before recording',
    );

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
            _liveWaveController.jumpTo(
              _liveWaveController.position.maxScrollExtent,
            );
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
        final idx = (i * raw.length / targetCount).floor().clamp(
          0,
          raw.length - 1,
        );
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
    final post = _pendingPost;
    final quoted = _replyingTo;
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
        'isListened': true,
        'avatarText': '🌙',
        // ★ إن بقي مرفق المنشور ⇒ يُرسَلان معاً (صورة + تفاصيل + تسجيل صوتي).
        if (post != null) ...{
          'isPost': true,
          'postTitle': post.title,
          'postSubtitle': post.subtitle,
          'postImageUrl': post.imageUrl,
          'postColor': post.color.toARGB32(),
        },
        if (quoted != null) 'quoted': Map<String, dynamic>.from(quoted),
      });
    });
    _pendingPost = null;
    _replyingTo = null;
    _scrollToBottom();
    _simulateReply();
  }

  /// Shows a WhatsApp-style attachment sheet with real Camera / Gallery
  /// options, each backed by the OS picker and its own permission prompt.
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => WhatsAppAttachmentPanel(
        onCamera: () {
          Navigator.pop(sheetContext);
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(sheetContext);
          _pickImage(ImageSource.gallery);
        },
        onVideo: () {
          Navigator.pop(sheetContext);
          _pickVideo();
        },
        onDocument: () {
          Navigator.pop(sheetContext);
          _pickDocument();
        },
        onAudio: () {
          Navigator.pop(sheetContext);
          _pickAudio();
        },
        onContact: () {
          Navigator.pop(sheetContext);
          _pickContact();
        },
        onLocation: () {
          Navigator.pop(sheetContext);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ميزة مشاركة الموقع قيد التطوير 📍')),
          );
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;
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
        if (_replyingTo != null)
          'quoted': Map<String, dynamic>.from(_replyingTo!),
      });
    });
    _replyingTo = null;
    _scrollToBottom();
    _simulateReply();
  }

  Future<void> _pickVideo() async {
    final granted = await _requestPermission(
      Permission.photos,
      'يجب السماح بالوصول إلى الصور من إعدادات التطبيق لاختيار فيديو',
    );
    if (!granted) return;
    try {
      final XFile? picked = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (picked == null) return;
      if (mounted) _showImagePreviewSheet(picked.path);
    } catch (e, st) {
      debugPrint('Video pick failed: $e\n$st');
      if (!mounted) return;
      _showErrorMessage('تعذر اختيار الفيديو: ${e.toString()}');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) {
        if (mounted) _showErrorMessage('تعذر قراءة الملف المختار');
        return;
      }
      if (mounted) _showDocumentPreviewSheet(path, result.files.first.name);
    } catch (e, st) {
      debugPrint('Document pick failed: $e\n$st');
      if (!mounted) return;
      _showErrorMessage('تعذر اختيار الملف: ${e.toString()}');
    }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) {
        if (mounted) _showErrorMessage('تعذر قراءة الملف الصوتي');
        return;
      }
      _sendVoiceMessage(path, 0);
    } catch (e, st) {
      debugPrint('Audio pick failed: $e\n$st');
      if (!mounted) return;
      _showErrorMessage('تعذر اختيار الملف الصوتي: ${e.toString()}');
    }
  }

  void _pickContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة مشاركة جهة الاتصال قيد التطوير')),
    );
  }

  void _showDocumentPreviewSheet(String filePath, String fileName) {
    final captionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DocumentPreviewSheet(
          filePath: filePath,
          fileName: fileName,
          captionController: captionController,
          onCancel: () => Navigator.pop(sheetContext),
          onSend: (caption) {
            Navigator.pop(sheetContext);
            _sendDocumentMessage(filePath, fileName, caption);
          },
        );
      },
    );
  }

  void _sendDocumentMessage(String filePath, String fileName, String caption) {
    setState(() {
      _messages.add({
        'id': 'm${DateTime.now().millisecondsSinceEpoch}',
        'sender': 'أنت',
        'content': caption,
        'filePath': filePath,
        'fileName': fileName,
        'isDocument': true,
        'time': 'الآن',
        'isMine': true,
        if (_replyingTo != null)
          'quoted': Map<String, dynamic>.from(_replyingTo!),
      });
    });
    _replyingTo = null;
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
        builder: (ctx) =>
            _FullScreenImageViewer(imagePath: imagePath, heroTag: tag),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    final post = _pendingPost;
    final quoted = _replyingTo;
    // ★ المرفق/الرد يعمل كرسالة صالحة بذاته ⇒ الإرسال متاح حتى بلا كتابة نص.
    if (text.isEmpty && post == null && quoted == null) return;

    setState(() {
      if (post != null) {
        _messages.add({
          'id': 'm${DateTime.now().millisecondsSinceEpoch}',
          'sender': 'أنت',
          'content': text,
          'time': 'الآن',
          'isMine': true,
          'isPost': true,
          'postTitle': post.title,
          'postSubtitle': post.subtitle,
          'postImageUrl': post.imageUrl,
          'postColor': post.color.toARGB32(),
          if (quoted != null) 'quoted': Map<String, dynamic>.from(quoted),
        });
      } else {
        _messages.add({
          'id': 'm${DateTime.now().millisecondsSinceEpoch}',
          'sender': 'أنت',
          'content': text,
          'time': 'الآن',
          'isMine': true,
          if (quoted != null) 'quoted': Map<String, dynamic>.from(quoted),
        });
      }
    });

    _pendingPost = null;
    _replyingTo = null;
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
            'sender': 'Di',
            'content': '',
            'isVoice': true,
            'audioPath': null,
            'duration': 3,
            'time': 'الآن',
            'isMine': false,
            'isListened': false,
            'avatarText': '👤',
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
    final chat = context.chatColors;
    final isLandscape = _isLandscape(context);
    // شاشات أفقية ضيقة الارتفاع: نقلّص الحشوات الرأسية للـ AppBar.
    final avatarSize = _isTablet(context) ? 48.0 : 40.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: chat.conversationBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: chat.conversationBackground,
        leadingWidth: 40,
        toolbarHeight: isLandscape ? 52 : kToolbarHeight,
        leading: Container(
          margin: const EdgeInsets.all(AppSpacing.xs),
          child: IconButton(
            icon: Icon(
              LucideIcons.chevronLeft,
              size: 22,
              color: chat.inputText,
            ),
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.phone),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: context.chatColors.sendButton.withValues(alpha: 0.12),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: chat.inputText,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        if (!widget.isGroup && widget.online)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: chat.onlineDot,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.isGroup
                                ? widget.activity
                                : (widget.online
                                      ? 'متصل الآن'
                                      : widget.activity),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: (!widget.isGroup && widget.online)
                                  ? chat.onlineDot
                                  : chat.recordingWaveUnplayed,
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
          IconButton(
            icon: Icon(LucideIcons.video, color: chat.composerIcon),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.phone, color: chat.composerIcon),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.moreVertical, color: chat.composerIcon),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // يُقيّد عرض المحادثة ويوسّطها أفقياً على الشاشات العريضة (تابلت/سطح مكتب).
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _chatAreaMaxWidth(context),
                ),
                child: ChatDoodleBackground(
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
          SafeArea(top: false, child: _buildComposer(theme)),
        ],
      ),
    );
  }

  Widget _buildComposer(ThemeData theme) {
    final pendingPost = _pendingPost;
    final chat = context.chatColors;
    final hasText =
        _messageController.text.isNotEmpty ||
        pendingPost != null ||
        _replyingTo != null;
    // شاشات أفقية ضيقة الارتفاع: نقلّص الحشوة الرأسية لتفادي طفح شريط التسجيل.
    final vPad = _isLandscape(context) ? AppSpacing.xs : AppSpacing.sm;
    final vPadMd = _isLandscape(context) ? AppSpacing.sm : AppSpacing.md;

    if (_composerMode == _ComposerMode.recording) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: vPadMd,
        ),
        decoration: BoxDecoration(
          color: chat.recordingBackground,
          border: Border(top: BorderSide(color: chat.composerBorder)),
        ),
        child: Row(
          children: [
            // زر سلة المهملات لإلغاء وحذف التسجيل فوراً
            Container(
              decoration: BoxDecoration(
                color: chat.recordingTrash.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  LucideIcons.trash2,
                  color: chat.recordingTrash,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _cancelRecording();
                },
                tooltip: 'إلغاء وحذف التسجيل',
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // النقطة الحمراء النابضة
            const _RecordingPulseDot(),
            const SizedBox(width: AppSpacing.xs + 2),

            // عداد الوقت
            Text(
              _formatDuration(_recordSeconds),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: chat.recordingTimer,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // مؤشر اسحب للإلغاء المتحرك
            const _SlideToCancel(),
            const SizedBox(width: AppSpacing.xs),

            // موجات الصوت الحية المتفاعلة مع الميكروفون
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: chat.inputField,
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
                      child: Center(
                        child: Container(
                          width: 2.6,
                          height: h,
                          decoration: BoxDecoration(
                            color: chat.recordingWavePlayed,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // زر التوقف والانتقال للمعاينة بأسلوب واتساب
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: chat.sendButton,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: chat.sendButton.withValues(alpha: 0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(LucideIcons.check, color: chat.sendIcon, size: 21),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _finishRecordingToPreview();
                },
                tooltip: 'إيقاف ومعاينة',
              ),
            ),
          ],
        ),
      );
    }

    if (_composerMode == _ComposerMode.preview && _pendingAudioPath != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: vPad,
        ),
        decoration: BoxDecoration(
          color: chat.recordingBackground,
          border: Border(top: BorderSide(color: chat.composerBorder)),
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
        color: chat.composerBackground,
        border: Border(top: BorderSide(color: chat.composerBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null) ...[
            ComposerReplyPreview(
              quoted: _replyingTo!,
              onCancel: () => setState(() => _replyingTo = null),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (pendingPost != null) ...[
            _PostAttachmentBar(
              preview: pendingPost,
              onRemove: () => setState(() => _pendingPost = null),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          WhatsAppInputBar(
            controller: _messageController,
            hasText: hasText,
            onSend: _sendMessage,
            onVoice: _startRecording,
            onAttach: _showAttachmentOptions,
            onCamera: () => _pickImage(ImageSource.camera),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, Map<String, dynamic> msg) {
    // ★ فواصل الأيام وسجلات المكالمات تُرسم بدون فقاعة واتساب المعتادة.
    if (msg['isDateDivider'] as bool? ?? false) {
      return _DateDividerPill(label: (msg['label'] as String?) ?? '');
    }
    if (msg['isCallLog'] as bool? ?? false) {
      return _InlineCallLogTile(
        title: (msg['callTitle'] as String?) ?? 'مكالمة صوتية',
        duration: msg['callDuration'] as String?,
        time: (msg['time'] as String?) ?? '',
        isMine: msg['isMine'] as bool? ?? false,
      );
    }
    final isMine = msg['isMine'] as bool;
    final isVoice = msg['isVoice'] as bool? ?? false;
    final isImage = msg['isImage'] as bool? ?? false;
    final isPost = msg['isPost'] as bool? ?? false;
    final chat = context.chatColors;

    return WhatsAppBubbleShell(
      key: ValueKey(msg['id']),
      isMine: isMine,
      maxWidth: _bubbleMaxWidth(context, isVoice: isVoice),
      onSwipeReply: () {
        HapticFeedback.lightImpact();
        _startReply(msg);
      },
      onLongPress: () => _showMessageOptions(msg),
      child: _bubbleInner(theme, msg, isMine, isVoice, isImage, isPost, chat),
    );
  }

  void _startReply(Map<String, dynamic> msg) {
    if (msg['isDateDivider'] as bool? ?? false) return;
    if (msg['isCallLog'] as bool? ?? false) return;
    setState(() => _replyingTo = Map<String, dynamic>.from(msg));
  }

  Widget _bubbleInner(
    ThemeData theme,
    Map<String, dynamic> msg,
    bool isMine,
    bool isVoice,
    bool isImage,
    bool isPost,
    AppChatColors chat,
  ) {
    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _quotedOrSender(theme, msg, isMine, isImage, chat),
        _bubbleBody(theme, msg, isMine, isVoice, isImage, isPost, chat),
      ],
    );
  }

  Widget _quotedOrSender(
    ThemeData theme,
    Map<String, dynamic> msg,
    bool isMine,
    bool isImage,
    AppChatColors chat,
  ) {
    final quoted = msg['quoted'] as Map<String, dynamic>?;
    if (quoted != null) return _BubbleQuoted(quoted: quoted, isMine: isMine);
    if (!isMine && !isImage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Text(
          msg['sender'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: chat.senderName,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _bubbleBody(
    ThemeData theme,
    Map<String, dynamic> msg,
    bool isMine,
    bool isVoice,
    bool isImage,
    bool isPost,
    AppChatColors chat,
  ) {
    final isDocument = msg['isDocument'] as bool? ?? false;

    if (isPost) {
      return _buildPostContent(context, msg, isMine, chat, isVoice);
    } else if (isImage) {
      return _buildImageContent(context, msg, isMine, chat);
    } else if (isDocument) {
      return _buildDocumentContent(context, msg, isMine, chat);
    } else if (isVoice) {
      return _VoiceMessageBubble(
        id: msg['id'] as String,
        audioPath: msg['audioPath'] as String?,
        durationSeconds: msg['duration'] as int? ?? 0,
        isMine: isMine,
        time: msg['time'] as String,
        isListened: msg['isListened'] as bool? ?? true,
        avatarText: msg['avatarText'] as String?,
        currentlyPlayingId: _currentlyPlayingId,
      );
    } else {
      return _buildTextContent(context, msg, isMine, chat);
    }
  }

  Widget _buildTextContent(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isMine,
    AppChatColors chat,
  ) {
    final content = msg['content'] as String? ?? '';
    final time = msg['time'] as String? ?? '';
    final isRead = msg['isRead'] as bool? ?? true;

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: AppSpacing.sm,
      runSpacing: 2,
      children: [
        Text(
          content,
          style: TextStyle(
            color: isMine ? chat.bubbleMineText : chat.bubbleTheirsText,
            fontSize: 15,
            height: 1.38,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: isMine ? chat.bubbleMineTime : chat.bubbleTheirsTime,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 3),
                WhatsAppTicks(isRead: isRead, size: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isMine,
    AppChatColors chat,
    bool isVoice,
  ) {
    final time = msg['time'] as String? ?? '';
    final isRead = msg['isRead'] as bool? ?? true;

    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg['postImageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(
                    msg['postImageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _postFallback(msg, isMine),
                  ),
                ),
              ),
            if (msg['postImageUrl'] != null)
              const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg['postTitle'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMine
                          ? chat.bubbleMineText
                          : chat.bubbleTheirsText,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    msg['postSubtitle'] as String,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMine
                          ? chat.bubbleMineTime
                          : chat.bubbleTheirsTime,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isVoice)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _VoiceMessageBubble(
              id: msg['id'] as String,
              audioPath: msg['audioPath'] as String?,
              durationSeconds: msg['duration'] as int? ?? 0,
              isMine: isMine,
              time: msg['time'] as String,
              isListened: msg['isListened'] as bool? ?? true,
              avatarText: msg['avatarText'] as String?,
              currentlyPlayingId: _currentlyPlayingId,
            ),
          )
        else if ((msg['content'] as String? ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              msg['content'] as String,
              style: TextStyle(
                color: isMine ? chat.bubbleMineText : chat.bubbleTheirsText,
                fontSize: 14,
              ),
            ),
          ),
        if (!isVoice)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMine ? chat.bubbleMineTime : chat.bubbleTheirsTime,
                    fontSize: 11,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 3),
                  WhatsAppTicks(isRead: isRead, size: 14),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isMine,
    AppChatColors chat,
  ) {
    final path = msg['imagePath'] as String?;
    final caption = (msg['content'] as String? ?? '').trim();
    final hasCaption = caption.isNotEmpty;
    final time = msg['time'] as String? ?? '';
    final isRead = msg['isRead'] as bool? ?? true;

    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (path != null) _openImageViewer(path, 'img_${msg['id']}');
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _imageMaxWidth(context),
                  ),
                  child: Builder(
                    builder: (context) {
                      final imageChild = path != null && File(path).existsSync()
                          ? Hero(
                              tag: 'img_${msg['id']}',
                              child: Image.file(File(path), fit: BoxFit.cover),
                            )
                          : Container(
                              color: isMine
                                  ? chat.bubbleMine
                                  : chat.bubbleTheirs,
                              child: const Center(
                                child: Text(
                                  '📷',
                                  style: TextStyle(fontSize: 56),
                                ),
                              ),
                            );
                      return AspectRatio(aspectRatio: 1.0, child: imageChild);
                    },
                  ),
                ),
              ),
              if (!hasCaption)
                Positioned(
                  bottom: 6,
                  right: isMine ? 6 : null,
                  left: isMine ? null : 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 3),
                          WhatsAppTicks(isRead: isRead, size: 12),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasCaption) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.sm,
            runSpacing: 2,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  caption,
                  style: TextStyle(
                    color: isMine ? chat.bubbleMineText : chat.bubbleTheirsText,
                    fontSize: 14.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: isMine
                            ? chat.bubbleMineTime
                            : chat.bubbleTheirsTime,
                        fontSize: 11,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 3),
                      WhatsAppTicks(isRead: isRead, size: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDocumentContent(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isMine,
    AppChatColors chat,
  ) {
    final fileName = msg['fileName'] as String? ?? '';
    final time = msg['time'] as String? ?? '';
    final isRead = msg['isRead'] as bool? ?? true;
    final extension = fileName.split('.').length > 1
        ? fileName.split('.').last.toLowerCase()
        : 'file';
    final fileColor = _getDocumentColor(extension);
    final fileIcon = _getDocumentIcon(extension);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: fileColor.withValues(alpha: isMine ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(fileIcon, color: fileColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMine
                          ? chat.bubbleMineText
                          : chat.bubbleTheirsText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    extension.toUpperCase(),
                    style: TextStyle(
                      color: isMine
                          ? chat.bubbleMineTime
                          : chat.bubbleTheirsTime,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                color: isMine ? chat.bubbleMineTime : chat.bubbleTheirsTime,
                fontSize: 11,
              ),
            ),
            if (isMine) ...[
              const SizedBox(width: 3),
              WhatsAppTicks(isRead: isRead, size: 14),
            ],
          ],
        ),
      ],
    );
  }

  Color _getDocumentColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
        return Colors.purple;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return LucideIcons.fileText;
      case 'doc':
      case 'docx':
        return LucideIcons.fileText;
      case 'xls':
      case 'xlsx':
        return LucideIcons.fileSpreadsheet;
      case 'ppt':
      case 'pptx':
        return LucideIcons.presentation;
      case 'zip':
      case 'rar':
        return LucideIcons.archive;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return LucideIcons.headphones;
      default:
        return LucideIcons.file;
    }
  }

  /// بديل صورة المنشور داخل الفقاعة عند فشل التحميل (أيقونة بلون الخدمة).
  Widget _postFallback(Map<String, dynamic> msg, bool isMine) {
    final color = Color(msg['postColor'] as int? ?? 0xFF888888);
    return Container(
      color: color.withValues(alpha: isMine ? 0.25 : 0.15),
      child: Center(
        child: Icon(
          LucideIcons.package,
          color: isMine ? context.chatColors.sendIcon : color,
          size: 28,
        ),
      ),
    );
  }

  /// خيارات الرسالة بالضغط المطوّل — رد/تمييز/حذف بأسلوب WhatsApp.
  void _showMessageOptions(Map<String, dynamic> msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.chatColors.attachmentSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (sheetContext) {
        final chat = sheetContext.chatColors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.md),
                decoration: BoxDecoration(
                  color: chat.attachmentSheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _optTile(chat, LucideIcons.reply, 'رد', () {
                Navigator.pop(sheetContext);
                _startReply(msg);
              }),
              _optTile(chat, LucideIcons.star, 'تمييز', () {
                Navigator.pop(sheetContext);
              }),
              _optTile(chat, LucideIcons.trash2, 'حذف', () {
                Navigator.pop(sheetContext);
                setState(() => _messages.remove(msg));
              }, danger: true),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _optTile(
    AppChatColors chat,
    IconData icon,
    String label,
    VoidCallback tap, {
    bool danger = false,
  }) {
    final color = danger ? chat.recordingTrash : chat.inputText;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: tap,
    );
  }
}

/// الرد المقتبس داخل فقاعة الرسالة بأسلوب WhatsApp الأصيل
class _BubbleQuoted extends StatelessWidget {
  final Map<String, dynamic> quoted;
  final bool isMine;

  const _BubbleQuoted({required this.quoted, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final content = (quoted['content'] as String? ?? '').trim();
    final sender = (quoted['sender'] as String? ?? 'رسالة').trim();
    final isVoice = quoted['isVoice'] as bool? ?? false;
    final isImage = quoted['isImage'] as bool? ?? false;
    final isDocument = quoted['isDocument'] as bool? ?? false;
    final imagePath = quoted['imagePath'] as String?;

    IconData? typeIcon;
    String label = content;
    if (isVoice) {
      typeIcon = LucideIcons.mic;
      final duration = quoted['duration'] as int?;
      label = duration != null ? 'رسالة صوتية (0:${duration.toString().padLeft(2, '0')})' : 'رسالة صوتية';
    } else if (isImage) {
      typeIcon = LucideIcons.image;
      label = content.isEmpty ? 'صورة' : content;
    } else if (isDocument) {
      typeIcon = LucideIcons.fileText;
      label = quoted['fileName'] as String? ?? 'مستند';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: isMine ? chat.quotedBackgroundMine : chat.quotedBackgroundTheirs,
        borderRadius: BorderRadius.circular(AppRadii.sm + 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الشريط الرأسي الملوّن
            Container(width: 4.0, color: chat.quotedBar),
            const SizedBox(width: AppSpacing.xs + 2),

            // العنوان ومقتطف الرسالة
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (typeIcon != null) ...[
                          Icon(
                            typeIcon,
                            size: 13,
                            color: isMine
                                ? chat.quotedBodyMine
                                : chat.quotedBodyTheirs,
                          ),
                          const SizedBox(width: 3),
                        ],
                        Flexible(
                          child: Text(
                            label.isEmpty ? '...' : label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isMine
                                  ? chat.quotedBodyMine
                                  : chat.quotedBodyTheirs,
                              fontSize: 12,
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
                padding: const EdgeInsets.all(3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                  child: Image.file(
                    File(imagePath),
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// معاينة منشور (مع صورته وتفاصيله) في صندوق الكتابة: تبقى بانتظار إرسال
/// المستخدم، ويمكن حذفها قبل الإرسال.
class _PostAttachmentBar extends StatelessWidget {
  const _PostAttachmentBar({required this.preview, required this.onRemove});

  final ChatPostPreview preview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: chat.quotedBackgroundTheirs,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          // صورة المنشور (مربّعة) مع بديل أيقونة عند فشل التحميل/غيابها.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 56,
              height: 56,
              child: preview.imageUrl != null
                  ? Image.network(
                      preview.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _postIcon(preview.color),
                    )
                  : _postIcon(preview.color),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  preview.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: chat.quotedBodyTheirs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18),
            onPressed: onRemove,
            tooltip: 'إزالة المرفق',
            color: chat.composerIcon,
          ),
        ],
      ),
    );
  }

  Widget _postIcon(Color color) => Container(
    color: color.withValues(alpha: 0.15),
    child: Center(child: Icon(LucideIcons.package, color: color, size: 24)),
  );
}

class _RecordingPulseDot extends StatefulWidget {
  const _RecordingPulseDot();

  @override
  State<_RecordingPulseDot> createState() => _RecordingPulseDotState();
}

class _RecordingPulseDotState extends State<_RecordingPulseDot>
    with SingleTickerProviderStateMixin {
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
        decoration: BoxDecoration(
          color: context.chatColors.recordingTrash,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// مؤشر حركة «اسحب للإلغاء» المطابق لتطبيق واتساب مع سهم نابض
class _SlideToCancel extends StatefulWidget {
  const _SlideToCancel();

  @override
  State<_SlideToCancel> createState() => _SlideToCancelState();
}

class _SlideToCancelState extends State<_SlideToCancel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: 0.35 + (0.65 * _ctrl.value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: chat.recordingWaveUnplayed,
              ),
              const SizedBox(width: 2),
              Text(
                'اسحب للإلغاء',
                style: TextStyle(
                  color: chat.recordingWaveUnplayed,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A WhatsApp-style voice message bubble with **real** audio playback:
/// play/pause, live progress against the actual audio position, tap on
/// the waveform to seek, and automatic pause when another bubble starts
/// playing.
///
/// ★ يطابق فكرة الصورة المرسلة: أفاتار دائري بطرف الفقاعة مع شارة مايك،
/// نقطة زرقاء للرسائل غير المستمعة، وموجات صوتية رفيعة بأسلوب واتساب.
class _VoiceMessageBubble extends StatefulWidget {
  final String id;
  final String? audioPath;
  final int durationSeconds;
  final bool isMine;
  final String time;
  final bool isListened;
  final String? avatarText;
  final ValueNotifier<String?> currentlyPlayingId;

  const _VoiceMessageBubble({
    required this.id,
    required this.audioPath,
    required this.durationSeconds,
    required this.isMine,
    required this.time,
    this.isListened = true,
    this.avatarText,
    required this.currentlyPlayingId,
  });

  @override
  State<_VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<_VoiceMessageBubble> {
  // ★ واتساب الحقيقي: ~55 خط كثيف رفيع — وليس 40 متباعدة.
  static const int _barCount = 55;

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
        const SnackBar(
          content: Text(
            'رسالة تجريبية بدون ملف صوتي حقيقي، سجّل رسالة جديدة لتجربة التشغيل',
          ),
        ),
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
    final isMine = widget.isMine;

    final totalMs = _totalDuration.inMilliseconds;
    final playedFraction = totalMs == 0
        ? 0.0
        : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final playedBars = (playedFraction * _barCount).floor();

    final remaining = _totalDuration - _position;
    final remainingSeconds = remaining.isNegative ? 0 : remaining.inSeconds;

    final chat = context.chatColors;
    final onBubble = isMine ? chat.bubbleMineText : chat.bubbleTheirsText;
    // ★ ألوان موجات واتساب: المقروء أبيض، غير المقروء #8696A0.
    final playedColor = Colors.white;
    final unplayedColor = isMine
        ? Colors.white.withValues(alpha: 0.38)
        : const Color(0xFF8696A0);

    // ★ سطر واحد مدمج مثل واتساب (ارتفاع ~68px) — بدون تكرار.
    // ★ الترتيب البصري من اليمين لليسار (واتساب عربي):
    //  رسائلي: [أفاتاري | موجة | تشغيل] — مثل صورتك.
    //  رسائلهم: [تشغيل | موجة | أفاتارهم].
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMine) ...[
            _VoiceAvatarBadge(
              avatarText: widget.avatarText,
              isMine: true,
            ),
            const SizedBox(width: 6),
          ],
          GestureDetector(
            onTap: _togglePlay,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 30,
              height: 34,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onBubble,
                      ),
                    )
                  else
                    Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFFD1D7DB),
                      size: 30,
                    ),
                  if (!widget.isListened && !_isPlaying && !isMine)
                    const Positioned(
                      left: -3,
                      top: 4,
                      child: _UnreadDot(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200, minWidth: 120),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final width = constraints.maxWidth;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          _seekToFraction(
                            _fractionFromOffset(
                              details.localPosition.dx,
                              width,
                            ),
                          );
                        },
                        onHorizontalDragUpdate: (details) {
                          _seekToFraction(
                            _fractionFromOffset(
                              details.localPosition.dx,
                              width,
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 26,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(_barCount, (i) {
                              final played = i < playedBars;
                              final h = _bars[i].clamp(3.0, 22.0);
                              return Container(
                                width: 2,
                                height: h,
                                decoration: BoxDecoration(
                                  color: played ? playedColor : unplayedColor,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatSeconds(
                              _isPlaying || _position > Duration.zero
                                  ? remainingSeconds
                                  : widget.durationSeconds,
                            ),
                            maxLines: 1,
                            style: const TextStyle(
                              color: Color(0xFF8696A0),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.time,
                            style: const TextStyle(
                              color: Color(0xFF8696A0),
                              fontSize: 11,
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 3),
                            WhatsAppTicks(
                              isRead: widget.isListened,
                              size: 15,
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (!isMine) ...[
            const SizedBox(width: 6),
            _VoiceAvatarBadge(
              avatarText: widget.avatarText,
              isMine: false,
            ),
          ],
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

/// ★ نقطة زرقاء صغيرة لغير المستمع مثل واتساب في الصورة.
class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF38BDF8),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// ★ أفاتار دائري بطرف الفقاعة الصوتية — مقاس واتساب 32px + شارة مايك 14px.
class _VoiceAvatarBadge extends StatelessWidget {
  final String? avatarText;
  final bool isMine;

  const _VoiceAvatarBadge({this.avatarText, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return SizedBox(
      width: 32,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMine
                  ? chat.bubbleMineText.withValues(alpha: 0.16)
                  : chat.bubbleTheirsText.withValues(alpha: 0.14),
              image: null,
            ),
            alignment: Alignment.center,
            child: Text(
              avatarText ?? (isMine ? '🌙' : '👤'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chat.tickRead,
                border: Border.all(
                  color: isMine ? chat.bubbleMine : chat.bubbleTheirs,
                  width: 2,
                ),
              ),
              child: const Icon(
                LucideIcons.mic,
                size: 9,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ★ فاصل يوم دائري صغير مثل "السبت" في الصورة.
class _DateDividerPill extends StatelessWidget {
  final String label;

  const _DateDividerPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: chat.bubbleTheirs.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: chat.bubbleTheirsText.withValues(alpha: 0.75),
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}

/// ★ سجل مكالمة داخل المحادثة مثل "مكالمة صوتية 23 ث" في الصورة.
class _InlineCallLogTile extends StatelessWidget {
  final String title;
  final String? duration;
  final String time;
  final bool isMine;

  const _InlineCallLogTile({
    required this.title,
    this.duration,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    final onBubble = isMine ? chat.bubbleMineText : chat.bubbleTheirsText;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMine ? chat.bubbleMine : chat.bubbleTheirs,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: Radius.circular(isMine ? 3 : 16),
              bottomLeft: Radius.circular(isMine ? 16 : 3),
              bottomRight: const Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onBubble.withValues(alpha: 0.14),
                ),
                child: Icon(
                  LucideIcons.phone,
                  size: 16,
                  color: onBubble.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: onBubble,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration != null ? '$duration · $time' : time,
                      style: TextStyle(
                        color: onBubble.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final playedFraction = totalMs == 0
        ? 0.0
        : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final playedBars = (playedFraction * barCount).floor();

    final remaining = _totalDuration - _position;
    final remainingSeconds = remaining.isNegative ? 0 : remaining.inSeconds;

    return Row(
      children: [
        IconButton(
          icon: _isDeleting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.chatColors.recordingTrash,
                  ),
                )
              : Icon(
                  LucideIcons.trash2,
                  color: context.chatColors.recordingTrash,
                ),
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
              color: context.chatColors.sendButton.withValues(alpha: 0.15),
            ),
            child: _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(9),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.chatColors.sendButton,
                    ),
                  )
                : Icon(
                    _isPlaying ? LucideIcons.pause : LucideIcons.play,
                    color: context.chatColors.sendButton,
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
                      final fraction = (details.localPosition.dx / width).clamp(
                        0.0,
                        1.0,
                      );
                      _seekToFraction(fraction);
                    },
                    onHorizontalDragUpdate: (details) {
                      final fraction = (details.localPosition.dx / width).clamp(
                        0.0,
                        1.0,
                      );
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
                                      ? context.chatColors.sendButton
                                      : context.chatColors.recordingWaveUnplayed
                                            .withValues(alpha: 0.35),
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
                                color: context.chatColors.sendButton,
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
                  _isPlaying || _position > Duration.zero
                      ? remainingSeconds
                      : widget.durationSeconds,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.chatColors.recordingWaveUnplayed,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        CircleAvatar(
          backgroundColor: context.chatColors.sendButton,
          child: IconButton(
            icon: Icon(
              LucideIcons.send,
              color: context.chatColors.sendIcon,
              size: 18,
            ),
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
        color: context.chatColors.attachmentSheet,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.x,
                  color: context.chatColors.recordingTrash,
                ),
                onPressed: widget.onCancel,
                tooltip: 'إلغاء',
              ),
              const Spacer(),
              Text(
                'معاينة الصورة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
              fillColor: context.chatColors.inputField,
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
                backgroundColor: context.chatColors.sendButton,
                foregroundColor: context.chatColors.sendIcon,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
              icon: const Icon(LucideIcons.send),
              label: const Text('إرسال'),
              onPressed: () =>
                  widget.onSend(widget.captionController.text.trim()),
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
      await Share.shareXFiles([
        XFile(widget.imagePath),
      ], text: 'صورة من گريب منك');
    } catch (e, st) {
      debugPrint('Share failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر مشاركة الصورة')));
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Route through the system share sheet — on both iOS and Android it
      // surfaces a "Save Image" target, so no extra plugin is required.
      await Share.shareXFiles([
        XFile(widget.imagePath),
      ], text: 'حفظ صورة من گريب منك');
    } catch (e, st) {
      debugPrint('Save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حفظ الصورة')));
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
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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
