import 'dart:async';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:math' as math;

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
import '../../core/extensions/context_extensions.dart';
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
import 'widgets/whatsapp_voice_button.dart';
import 'widgets/whatsapp_voice_recorder.dart';
import 'widgets/voice_edit/voice_trim_sheet.dart';
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
    math.min(MediaQuery.of(context).size.width, _kMaxChatAreaWidth);

/// أقصى عرض لفقاعة رسالة واحدة (نسبة من الشاشة + حد أقصى مطلق بالبكسل).
/// ★ مقاس واتساب الحقيقي: الصوت 75% بحد 300px — مدمجة وليست منفوخة.
double _bubbleMaxWidth(BuildContext context, {required bool isVoice}) =>
    math.min(
      MediaQuery.of(context).size.width * (isVoice ? 0.75 : 0.78),
      isVoice ? 300.0 : _kMaxBubbleWidth,
    );

/// أقصى عرض لفقاعة الصورة (نسبة من الشاشة + حد أقصى).
double _imageMaxWidth(BuildContext context) =>
    math.min(MediaQuery.of(context).size.width * 0.55, _kMaxImageWidth);

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

// ComposerVoiceState (defined in whatsapp_voice_recorder.dart) is used directly.

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
      _conversations.insert(0, {...sc, 'participants': <String>[]});
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
    // التداخل. الصحيح: padding.top الجاهزة + 12 تنفس (مثل واتساب).
    final topInset = MediaQuery.paddingOf(context).top + 12;
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
              // ★ إيقاع عمودي موحد مع تنفّس أوسع بين المكوّنات:
              //   هيدر → 12 → بحث (48) → 16 → شيبس (36) → 16
              //   → مقفلة/مميزة/مؤرشفة → 16 → قائمة. كل فجوة مضبوطة رقمياً.
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
              // ★ 16 بين البحث والفلاتر — تنفّس أوسع.
              const SizedBox(height: 16),
              // ── ② Filter Chips Row — فلاتر أفقية ──
              // ★ 4 فلاتر: الكل | غير مقروءة | المكالمات | المجموعات.
              ConversationFilterChips(
                labels: _filterLabels,
                selectedIndex: _selectedFilter,
                unreadCount: _unreadCount,
                onSelected: (i) => setState(() => _selectedFilter = i),
              ),
              // ★ 16 قبل المقفلة/القائمة — فاصل تنفّس واضح.
              // ── ③ Locked + Starred + Archived — مثل واتساب 100% ──
              // ★ فوق القائمة مباشرة (بعد الفلاتر)، تُخفى في المكالمات
              //   وأثناء البحث/الفلترة.
              if (_query.isEmpty && _selectedFilter == 0) ...[
                const SizedBox(height: 16),
                const LockedAndArchivedRows(lockedCount: 0, archivedCount:0),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),
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
                          // ★ بلا خط فاصل أفقي بين المحادثات — كان يشوّش
                          //   الرؤية البصرية بين عناصر القائمة (خاصة الحسابات).
                          return ConversationTile(
                            name: conv['name'] as String,
                            lastMessage: conv['lastMessage'] as String,
                            time: conv['time'] as String,
                            avatar: conv['avatar'] as String,
                            unread: conv['unread'] as int,
                            online: online,
                            onTap: () => _openConversation(conv, online, isGroup),
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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  /// ★ رسائل مرسلة من الستوري (إرسال خلفي بأسلوب فيسبوك): دمجها في
  /// قائمة المحادثة عند فتح الدردشة — بلا تكرار (نفس المعرف يُتجاهل).
  void _mergeStoryMessages() {
    final pending = StoryMessageStore.instance.forConversation(
      widget.conversationId,
    );
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

  // ---- Real audio recording (WhatsApp 6-state machine) ----
  final AudioRecorder _audioRecorder = AudioRecorder();
  ComposerVoiceState _voiceState = ComposerVoiceState.idle;
  double _lockDragProgress = 0.0;
  double _cancelProgress = 0.0;
  Offset _micTranslationOffset = Offset.zero;
  bool _axisLockVertical = false;
  bool _axisLockHorizontal = false;
  bool _cancelArmed = false;
  double _micScale = 1.0;
  bool _micPermissionGranted = false;
  AnimationController? _lockHintController;
  late final AnimationController _panelAnimController;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  String? _currentRecordingPath;

  // Live waveform bars driven by real microphone amplitude while recording.
  final List<double> _liveWaveform = [];
  final ScrollController _liveWaveController = ScrollController();

  // Recorded-but-not-sent-yet voice note (for preview when paused / preview bar)
  String? _pendingAudioPath;
  int _pendingDuration = 0;
  List<double> _pendingWaveformBars = const [];

  // Preview player for locked/paused panel
  AudioPlayer? _previewPlayer;
  Timer? _previewSimTimer;
  bool _isPreviewPlaying = false;
  double _previewProgress = 0.0;
  StreamSubscription<Duration>? _previewPosSub;
  StreamSubscription<void>? _previewCompleteSub;

  // ★ ميزة القص النهائي: بعد تطبيق القص يُعطَّل الاستئناف (استماع + إرسال فقط).
  bool _isTrimmed = false;

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
    // التحقق المسبق من إذن الميكروفون لتمكين التسجيل الفوري دون أي تأخير
    Permission.microphone.status.then((status) {
      if (status.isGranted && mounted) {
        _micPermissionGranted = true;
      }
    });
    // ★ حركة تلميح القفل الصاعد — تتكرر صعوداً ونزولاً أثناء الضغطة المطوّلة.
    _lockHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    // ★ كونترولر تحوّل اللوحة السفلية المقفلة (~200ms easeOut)
    _panelAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // ★ قدوم من حقل الستوري: ركّز حقل الكتابة وافتح الكيبورد تلقائياً.
    if (widget.autofocusMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _messageFocusNode.requestFocus();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // إلغاء وحذف التسجيل فوراً عند مقاطعة التطبيق أو الانتقال للخلفية
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_voiceState != ComposerVoiceState.idle &&
          _voiceState != ComposerVoiceState.sent &&
          _voiceState != ComposerVoiceState.cancelled) {
        _cancelRecording();
      }
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
    _previewSimTimer?.cancel();
    _audioRecorder.dispose();
    _currentlyPlayingId.dispose();
    _lockHintController?.dispose();
    _panelAnimController.dispose();
    _previewPosSub?.cancel();
    _previewCompleteSub?.cancel();
    _previewPlayer?.dispose();
    super.dispose();
  }

  // ignore: unused_element
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

  /// مجلد التسجيلات الدائم في مستندات التطبيق (ينجو من إعادة التشغيل،
  /// بخلاف المجلد المؤقت الذي قد تمسحه نظام التشغيل في أي وقت —
  /// وبالتالي تظل أيقونة التشغيل تعمل والاستماع للتسجيل ممكناً لاحقاً).
  Future<Directory> _recordingsDir() async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/recordings',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// إنهاء محاولة تسجيل فاشلة: إعادة الواجهة لحالة البداية ورسالة واضحة للمستخدم،
  /// بدل الاستمرار بواجهة تسجيل "وهمية" يفشل إرسالها لاحقاً بصمت.
  Future<void> _abortRecordingStart(String message) async {
    _recordTimer?.cancel();
    _recordTimer = null;
    await _amplitudeSub?.cancel();
    try {
      final p = await _audioRecorder.stop();
      if (p != null) {
        final f = File(p);
        if (await f.exists()) await f.delete();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _voiceState = ComposerVoiceState.idle;
      _recordSeconds = 0;
      _liveWaveform.clear();
    });
    _resetHoldState();
    _showErrorMessage(message);
  }

  Future<void> _startRecording() async {
    // التحقق المسبق من إذن الميكروفون — لا نكمل بدون إذن حقيقي.
    // (السماح السابق بالتجاهل مهما كان الرد كان يُنتج تسجيلاً "وهمياً" بلا ملف،
    // ثم تختفي الفقاعة عند الإرسال ولا صوت عند التشغيل.)
    if (!_micPermissionGranted) {
      try {
        final granted = await _requestPermission(
          Permission.microphone,
          'يجب السماح باستخدام الميكروفون من إعدادات الجهاز لتسجيل رسالة صوتية',
        );
        // المرجع النهائي: إذن المسجل نفسه (AVAudioSession) — يحمي من أعطال
        // واجهة الأذونات ويمنع الاستمرار بتسجيل وهمي بلا ملف.
        bool? recordOk;
        try {
          recordOk = await _audioRecorder.hasPermission();
        } catch (e) {
          debugPrint('Recorder hasPermission error: $e');
        }
        if (!granted && recordOk != true) return;
        if (recordOk == false) {
          _showErrorMessage(
            'تعذر الحصول على إذن الميكروفون لتسجيل الرسالة الصوتية',
          );
          return;
        }
        _micPermissionGranted = true;
      } catch (e) {
        debugPrint('Microphone permission check error: $e');
        // نتابع رغم خطأ واجهة الأذونات — والتحقق من نجاح المسجل أدناه يحمينا.
      }
    }

    final dir = await _recordingsDir();
    // ★ التسجيل WAV مباشرة ليتوافق مع ميزة القص (WavCodec يدعم PCM 16-bit فقط).
    _currentRecordingPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';

    debugPrint('Recording path: $_currentRecordingPath');

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
          androidConfig: AndroidRecordConfig(
            audioSource: AndroidAudioSource.mic,
          ),
          iosConfig: IosRecordConfig(),
        ),
        path: _currentRecordingPath!,
      );
    } catch (e, st) {
      debugPrint('Recording start failed: $e\n$st');
      await _abortRecordingStart('تعذر بدء التسجيل الصوتي: $e');
      return;
    }

    // ★ تحقق حقيقي من أن التسجيل بدأ فعلاً — إن فشل بصمت لا نكمل بواجهة وهمية.
    try {
      final recordingNow = await _audioRecorder.isRecording();
      if (!recordingNow) {
        throw Exception('المسجل لم يبدأ رغم عدم رمي خطأ');
      }
    } catch (e) {
      debugPrint('Recorder health check failed: $e');
      await _abortRecordingStart('تعذر بدء التسجيل الصوتي على هذا الجهاز: $e');
      return;
    }

    setState(() {
      _recordSeconds = 0;
      _liveWaveform.clear();
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _recordSeconds++;
          // إذا لم تصل عينات من المايك (مثل محاكي iOS)، نولد موجات حيوية طبيعية كواتساب
          if (_liveWaveform.length < _recordSeconds * 5) {
            final rand = math.Random();
            for (int i = 0; i < 4; i++) {
              final h = 4.0 + rand.nextDouble() * 16.0;
              _liveWaveform.add(h);
              if (_liveWaveform.length > 55) _liveWaveform.removeAt(0);
            }
          }
        });
      }
    });

    _amplitudeSub?.cancel();
    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen(
          (amp) {
            double normalized = ((amp.current + 45) / 45).clamp(0.0, 1.0);
            if (normalized <= 0.05) {
              final t = DateTime.now().millisecondsSinceEpoch / 150.0;
              normalized =
                  (0.2 +
                          0.5 * math.sin(t).abs() +
                          0.3 * math.cos(t * 1.7).abs())
                      .clamp(0.1, 1.0);
            }
            final height = 3.0 + normalized * 19.0;
            if (mounted) {
              setState(() {
                _liveWaveform.add(height);
                if (_liveWaveform.length > 55) {
                  _liveWaveform.removeAt(0);
                }
              });
            }
            if (_liveWaveController.hasClients) {
              _liveWaveController.jumpTo(
                _liveWaveController.position.maxScrollExtent,
              );
            }
          },
          onError: (e) {
            debugPrint('Amplitude stream error: $e');
          },
        );
  }

  /// يوقف التسجيل وينتقل لحالة المعاينة (تُستخدم للمعاينة اليدوية)
  // ignore: unused_element
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
        _voiceState = ComposerVoiceState.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    final duration = _recordSeconds;
    if (path == null) {
      setState(() {
        _voiceState = ComposerVoiceState.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    final file = File(path);
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    if (!exists || size == 0 || duration <= 0) {
      setState(() {
        _voiceState = ComposerVoiceState.idle;
        _liveWaveform.clear();
        _recordSeconds = 0;
      });
      return;
    }

    // ★ نفس عدد أشرطة موجة الفقاعة (55) لتوحيد التجربة.
    final capturedWaveform = _resampleWaveform(_liveWaveform, 55);

    setState(() {
      _voiceState = ComposerVoiceState.idle;
      _pendingAudioPath = path;
      _pendingDuration = duration;
      _pendingWaveformBars = capturedWaveform;
      _liveWaveform.clear();
      _recordSeconds = 0;
    });
  }

  /// إلغاء وحذف التسجيل فوراً
  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    _recordTimer = null;
    await _amplitudeSub?.cancel();
    await _previewPlayer?.stop();
    setState(() {
      _isPreviewPlaying = false;
      _previewProgress = 0.0;
    });

    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      // لو كان المسجل متوقفاً بالفعل (بعد إيقاف مؤقت) ننظّف الملف المعروف أيضاً.
      final known = _currentRecordingPath;
      if (known != null && known != path) {
        final file = File(known);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}

    await _panelAnimController.reverse();
    if (mounted) {
      setState(() {
        _voiceState = ComposerVoiceState.cancelled;
        _recordSeconds = 0;
        _liveWaveform.clear();
        _resetHoldState();
      });
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _voiceState = ComposerVoiceState.idle);
      });
    }
  }

  /// يصفّر حالة الضغطة المطوّلة والسحب
  void _resetHoldState() {
    _cancelArmed = false;
    _micScale = 1.0;
    _lockDragProgress = 0.0;
    _cancelProgress = 0.0;
    _micTranslationOffset = Offset.zero;
    _axisLockVertical = false;
    _axisLockHorizontal = false;
  }

  /// 2. الحالة: الضغط المطوّل (holding) — تكبير المايك وسكة القفل وبدء التسجيل
  Future<void> _onMicHoldStart() async {
    if (_voiceState != ComposerVoiceState.idle) return;
    setState(() {
      _voiceState = ComposerVoiceState.holding;
      _micScale = 1.5;
      _cancelArmed = false;
      _lockDragProgress = 0.0;
      _cancelProgress = 0.0;
      _micTranslationOffset = Offset.zero;
      _axisLockVertical = false;
      _axisLockHorizontal = false;
    });
    HapticFeedback.lightImpact();
    await _startRecording();
    if (mounted &&
        _voiceState == ComposerVoiceState.holding &&
        _recordTimer == null) {
      _resetHoldState();
      setState(() => _voiceState = ComposerVoiceState.idle);
    }
  }

  /// 3. الحالة: السحب (lockDragging) — للأعلى للقفل أو أفقياً للإلغاء مع تثبيت المحور
  void _onMicHoldMove(Offset delta) {
    if (_voiceState != ComposerVoiceState.holding &&
        _voiceState != ComposerVoiceState.lockDragging) {
      return;
    }

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final dx = delta.dx;
    final dy = delta.dy;
    final absDy = (-dy).clamp(0.0, double.infinity);
    final horizontalTowardsText = (isRTL ? dx : -dx).clamp(
      0.0,
      double.infinity,
    );

    // تثبيت المحور (Axis Lock): استجابة سريعة جداً لأي سحب للأعلى أو أفقياً
    if (!_axisLockVertical && !_axisLockHorizontal) {
      if (absDy > 6.0 && absDy >= horizontalTowardsText * 0.8) {
        _axisLockVertical = true;
      } else if (horizontalTowardsText > 6.0 &&
          horizontalTowardsText >= absDy * 0.8) {
        _axisLockHorizontal = true;
      }
    }

    // السحب للأعلى: قفل التسجيل Hands-free بسحب خفيف سريع (60px فقط)
    if (_axisLockVertical) {
      final progress = (absDy / 60.0).clamp(0.0, 1.0);
      setState(() {
        _lockDragProgress = progress;
        _voiceState = ComposerVoiceState.lockDragging;
        _micTranslationOffset = Offset.zero;
        _cancelProgress = 0.0;
        _cancelArmed = false;
      });

      if (progress >= 1.0) {
        _lockRecordingHandsFree();
      }
      return;
    }

    // السحب الأفقي: الإلغاء نحو النص مع تحرك المايك وخفوت النص
    if (_axisLockHorizontal) {
      final progress = (horizontalTowardsText / 100.0).clamp(0.0, 1.0);
      final micX = (isRTL ? 1.0 : -1.0) * math.min(horizontalTowardsText, 85.0);
      final armed = progress >= 1.0;

      if (armed != _cancelArmed) {
        HapticFeedback.lightImpact();
      }

      setState(() {
        _lockDragProgress = 0.0;
        _voiceState = ComposerVoiceState.lockDragging;
        _cancelProgress = progress;
        _cancelArmed = armed;
        _micTranslationOffset = Offset(micX, 0);
      });
      return;
    }
  }

  /// 4. إتمام القفل (locked): التحول للوحة Hands-free السفلية البيضاء
  Future<void> _lockRecordingHandsFree() async {
    setState(() {
      _voiceState = ComposerVoiceState.locked;
      _resetHoldState();
    });
    HapticFeedback.lightImpact();
    await _panelAnimController.forward();
  }

  /// إفلات الإصبع: إرسال التسجيل إذا تجاوز ثانية واحدة، أو إلغاء إذا مسلّح أو قصير جداً
  Future<void> _onMicHoldEnd() async {
    if (_voiceState == ComposerVoiceState.locked ||
        _voiceState == ComposerVoiceState.paused) {
      return; // وضع القفل يستمر وحده
    }

    if (_cancelArmed) {
      await _cancelRecording();
      return;
    }

    // إذا كان التسجيل أقل من ثانية: يُتجاهل (نقرة سريعة غير مقصودة)
    if (_recordSeconds < 1) {
      await _cancelRecording();
      return;
    }

    // إفلات عادي بعد تسجيل سليم: إرسال فوري!
    await _sendRecordedVoice();
  }

  /// 5. الحالة: الإيقاف المؤقت (paused) — يتم إيقاف المسجل لتجهيز الملف للمعاينة على iOS
  Future<void> _pauseRecording() async {
    _recordTimer?.cancel();
    _recordTimer = null;
    try {
      // نوقف التسجيل حتى يقوم النظام (iOS / AVFoundation) بإغلاق ترويسة ملف m4a وكتابته فعلياً
      final path = await _audioRecorder.stop();
      if (path != null) {
        _currentRecordingPath = path;
      }
    } catch (e) {
      debugPrint('Pause/stop failed: $e');
    }
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() => _voiceState = ComposerVoiceState.paused);
    }
  }

  /// استئناف التسجيل بعد الإيقاف المؤقت
  Future<void> _resumeRecording() async {
    // ★ القص النهائي يمنع الاستئناف — استماع + إرسال فقط.
    if (_isTrimmed) return;
    try {
      await _previewPlayer?.stop();
      setState(() {
        _isPreviewPlaying = false;
        _previewProgress = 0.0;
      });

      // إذا كان المسجل متوقفاً بالكامل، نبدأ تسجيلاً مكملاً أو نستأنف
      final isRecording = await _audioRecorder.isRecording();
      if (!isRecording) {
        final dir = await _recordingsDir();
        // ★ نفس صيغة WAV لضمان توافق القص المباشر.
        _currentRecordingPath =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            numChannels: 1,
            androidConfig: AndroidRecordConfig(
              audioSource: AndroidAudioSource.mic,
            ),
            iosConfig: IosRecordConfig(),
          ),
          path: _currentRecordingPath!,
        );
      } else {
        await _audioRecorder.resume();
      }
    } catch (e) {
      debugPrint('Resume failed: $e');
      // نبقى في وضع "إيقاف مؤقت" — يمكن للمستخدم إرسال ما سُجِّل أو حذفه،
      // بدل بقاء لوحة تسجيل "شغالة" والمسجل متوقف في الخلفية.
      if (mounted) setState(() => _voiceState = ComposerVoiceState.paused);
      _showErrorMessage('تعذر استئناف التسجيل — يمكنك إرسال ما سُجِّل أو حذفه');
      return;
    }
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _recordSeconds++);
    });
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() => _voiceState = ComposerVoiceState.locked);
    }
  }

  /// ★ ميزة القص: فتح شيت القص المكبّر من زر المقص عند الإيقاف المؤقت.
  /// يوقف المعاينة، يفتح [VoiceTrimSheet] بالملف WAV الحالي، وبعد التطبيق
  /// يستبدل المسار الحالي بالملف المقصوص ويُفعّل وضع القص النهائي.
  Future<void> _openTrimSheet() async {
    if (_voiceState != ComposerVoiceState.paused) return;
    final srcPath = _currentRecordingPath;
    if (srcPath == null) {
      _showErrorMessage('لا يوجد تسجيل لقصّه');
      return;
    }
    final srcFile = File(srcPath);
    if (!await srcFile.exists() || await srcFile.length() == 0) {
      _showErrorMessage('ملف التسجيل غير صالح للقص');
      return;
    }
    if (_recordSeconds < 1) {
      _showErrorMessage('التسجيل قصير جداً للقص');
      return;
    }

    // أوقف أي معاينة جارية قبل فتح الشيت.
    try {
      await _previewPlayer?.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isPreviewPlaying = false;
        _previewProgress = 0.0;
      });
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (sheetContext) => VoiceTrimSheet(
        audioPath: srcPath,
        onTrimmed: (trimmedPath, duration) {
          Navigator.of(sheetContext).pop();
          _applyTrimmedVoice(srcPath, trimmedPath, duration);
        },
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  /// ★ بعد تطبيق القص: استبدال الملف الحالي بالمقصوص + تعطيل الاستئناف.
  Future<void> _applyTrimmedVoice(
    String oldPath,
    String trimmedPath,
    Duration duration,
  ) async {
    final oldFile = File(oldPath);
    final newSeconds = duration.inSeconds > 0 ? duration.inSeconds : 1;
    // إعادة حساب أشرطة الموجة من الملف المقصوص مباشرة.
    List<double> newBars = const [];
    try {
      final bytes = await File(trimmedPath).readAsBytes();
      newBars = _waveformFromWavBytes(bytes);
    } catch (e) {
      debugPrint('Trim waveform rebuild failed: $e');
      newBars = List.filled(55, 12.0);
    }
    // حذف الملف الأصلي لتفادي الملفات الزائدة.
    try {
      if (await oldFile.exists() && oldPath != trimmedPath) {
        await oldFile.delete();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _currentRecordingPath = trimmedPath;
      _recordSeconds = newSeconds;
      _liveWaveform
        ..clear()
        ..addAll(newBars);
      _isTrimmed = true;
      _isPreviewPlaying = false;
      _previewProgress = 0.0;
    });
    HapticFeedback.mediumImpact();
  }

  /// ★ يحسب 55 شريط موجة من بايتات WAV (PCM 16-bit) للمعاينة بعد القص.
  List<double> _waveformFromWavBytes(List<int> bytes) {
    const targetCount = 55;
    if (bytes.length < 44) return List.filled(targetCount, 12.0);
    try {
      // تخطي الرأس للوصول لبيانات PCM — نبحث عن chunk "data".
      var dataOffset = 44;
      for (var i = 12; i + 8 <= bytes.length && i < 256; i++) {
        if (bytes[i] == 0x64 && // d
            bytes[i + 1] == 0x61 && // a
            bytes[i + 2] == 0x74 && // t
            bytes[i + 3] == 0x61) {
          // a
          dataOffset = i + 8;
          break;
        }
      }
      const frameSize = 2; // mono 16-bit
      final samples = (bytes.length - dataOffset) ~/ frameSize;
      if (samples <= 0) return List.filled(targetCount, 12.0);
      final perBar = (samples / targetCount).ceil().clamp(1, samples);
      return List.generate(targetCount, (b) {
        double maxAmp = 0;
        final from = b * perBar;
        final to = (b + 1) * perBar;
        for (var s = from; s < to && s < samples; s++) {
          final offset = dataOffset + s * frameSize;
          if (offset + 1 >= bytes.length) break;
          var v = bytes[offset] | (bytes[offset + 1] << 8);
          if (v > 32767) v -= 65536;
          final amp = v.abs() / 32768.0;
          if (amp > maxAmp) maxAmp = amp;
        }
        return (3.0 + maxAmp * 19.0).clamp(3.0, 22.0);
      });
    } catch (_) {
      return List.filled(targetCount, 12.0);
    }
  }

  /// تشغيل أو إيقاف معاينة التسجيل الصوتي أثناء الإيقاف المؤقت (paused)
  Future<void> _togglePreviewPlayback() async {
    final path = _currentRecordingPath;
    if (path == null) return;

    final file = File(path);
    if (!await file.exists() || await file.length() == 0) {
      debugPrint('Preview audio file does not exist at $path');
      _showErrorMessage(
        'لا يوجد تسجيل صوتي للاستماع — لم يتم حفظ الصوت على الجهاز',
      );
      return;
    }

    _previewPlayer ??= AudioPlayer();

    if (_isPreviewPlaying) {
      await _previewPlayer?.pause();
      if (mounted) setState(() => _isPreviewPlaying = false);
      return;
    }

    // إعداد AudioContext مناسب لمنصة iOS للسماح بتشغيل الصوت عبر السماعة.
    // مُغلف بـ try/catch حتى لا يفشل التشغيل إن رفض النظام ضبط الجلسة الصوتية.
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: const {
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.allowBluetooth,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.voiceCommunication,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (e) {
      debugPrint('setAudioContext failed (continuing playback): $e');
    }

    _previewPosSub?.cancel();
    _previewPosSub = _previewPlayer!.onPositionChanged.listen((pos) {
      final total = _recordSeconds > 0 ? _recordSeconds : 1;
      final frac = (pos.inMilliseconds / (total * 1000)).clamp(0.0, 1.0);
      if (mounted) setState(() => _previewProgress = frac);
    });

    _previewCompleteSub?.cancel();
    _previewCompleteSub = _previewPlayer!.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = false;
          _previewProgress = 0.0;
        });
      }
    });

    try {
      if (_previewProgress >= 1.0) {
        await _previewPlayer!.seek(Duration.zero);
      }
      await _previewPlayer!.play(DeviceFileSource(path));
      if (mounted) setState(() => _isPreviewPlaying = true);
    } catch (e) {
      debugPrint('Preview playback failed: $e');
      if (mounted) setState(() => _isPreviewPlaying = false);
    }
  }

  /// 6. الحالة: الإرسال (sent) — انطواء اللوحة وإرسال الرسالة
  Future<void> _sendRecordedVoice() async {
    _recordTimer?.cancel();
    _recordTimer = null;
    await _amplitudeSub?.cancel();
    await _previewPlayer?.stop();
    setState(() {
      _isPreviewPlaying = false;
      _previewProgress = 0.0;
    });

    String? path;
    try {
      path = await _audioRecorder.stop();
    } catch (e) {
      debugPrint('Recording stop failed: $e');
    }

    // ★ بعد "إيقاف مؤقت" يكون المسجل متوقفاً بالفعل (pause يستخدم stop()
    // لتجهيز الملف للاستماع) فيعيد stop() هنا null — نرجع لمسار الملف المعروف
    // حتى تُرسَل الرسالة بدل اختفاء الفقاعة دون إرسال.
    path ??= _currentRecordingPath;

    final duration = _recordSeconds;

    // ★ التحقق من وجود ملف صوتي حقيقي — ولا نفشل بصمت أبداً.
    int? safeDuration;
    if (path != null) {
      final file = File(path);
      final size = await file.exists() ? await file.length() : 0;
      if (size > 0) {
        safeDuration = duration > 0 ? duration : 1;
      } else if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    await _panelAnimController.reverse();

    if (!mounted) return;

    if (safeDuration == null) {
      // فشل حقيقي (لا ملف محفوظ): نعيد الحالة ونُخبر المستخدم بدل الاختفاء الصامت.
      setState(() {
        _voiceState = ComposerVoiceState.idle;
        _recordSeconds = 0;
        _liveWaveform.clear();
        _resetHoldState();
      });
      _showErrorMessage(
        'تعذر إرسال التسجيل الصوتي: لم يتم حفظ أي صوت — تحقق من إذن الميكروفون',
      );
      return;
    }

    setState(() {
      _voiceState = ComposerVoiceState.sent;
      _recordSeconds = 0;
      _liveWaveform.clear();
      _resetHoldState();
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _voiceState = ComposerVoiceState.idle);
    });

    _sendVoiceMessage(path!, safeDuration);
  }

  /// Discards the recorded-but-unsent note and deletes its temp file.
  Future<void> _discardPreview() async {
    final path = _pendingAudioPath;
    setState(() {
      _voiceState = ComposerVoiceState.idle;
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
      _voiceState = ComposerVoiceState.idle;
      _pendingAudioPath = null;
      _pendingDuration = 0;
      _pendingWaveformBars = const [];
    });

    _sendVoiceMessage(path, duration);
  }

  /// Collapses the raw ~150ms-interval amplitude samples down to a fixed
  /// number of bars so the preview/message waveform has a stable shape.
  List<double> _resampleWaveform(List<double> raw, int targetCount) {
    // ★ القيمة الافتراضية وسط نطاق الموجة الموحد (3..22) مثل الفقاعة.
    if (raw.isEmpty) return List.filled(targetCount, 12.0);
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
    final msgId = 'm${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add({
        'id': msgId,
        'sender': 'أنت',
        'content': '',
        'isVoice': true,
        'audioPath': audioPath,
        'duration': duration,
        'time': 'الآن',
        'isMine': true,
        'isListened': true,
        'status': 'sending',
        'isNew': true,
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

    // بعد مهلة قصيرة، يتحول من ساعة (قيد الإرسال) إلى صح (تم الإرسال)
    Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        final index = _messages.indexWhere((m) => m['id'] == msgId);
        if (index != -1) {
          _messages[index]['status'] = 'sent';
        }
      });
    });
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
                                  : chat.mutedText,
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // 4 & 5: وضع التسجيل المقفل (locked) والإيقاف المؤقت (paused) — لوحة سفلية بيضاء بموجة حية
    final bool isLockedOrPaused =
        _voiceState == ComposerVoiceState.locked ||
        _voiceState == ComposerVoiceState.paused;

    if (isLockedOrPaused || _panelAnimController.value > 0.01) {
      return AnimatedBuilder(
        animation: _panelAnimController,
        builder: (context, child) {
          final curveVal = CurvedAnimation(
            parent: _panelAnimController,
            curve: Curves.easeOutCubic,
          ).value;
          return ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: curveVal.clamp(0.0, 1.0),
              child: Opacity(opacity: curveVal.clamp(0.0, 1.0), child: child),
            ),
          );
        },
        child: WhatsAppLockedPanel(
          recordSeconds: _recordSeconds,
          liveWaveform: _liveWaveform,
          isPaused: _voiceState == ComposerVoiceState.paused,
          isPreviewPlaying: _isPreviewPlaying,
          previewProgress: _previewProgress,
          onPause: _pauseRecording,
          onResume: _resumeRecording,
          onTogglePreview: _togglePreviewPlayback,
          onDelete: _cancelRecording,
          onSend: _sendRecordedVoice,
          onTrim: _openTrimSheet,
          isTrimmed: _isTrimmed,
        ),
      );
    }

    if (_pendingAudioPath != null && _voiceState == ComposerVoiceState.idle) {
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
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: vPad),
      color: Colors.transparent,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              WhatsAppInputBar(
                controller: _messageController,
                hasText: hasText,
                onSend: _sendMessage,
                onVoice: _startRecording,
                onAttach: _showAttachmentOptions,
                onCamera: () => _pickImage(ImageSource.camera),
                onChanged: (_) => setState(() {}),
                // ★ تفاعل واتساب: ضغطة مطوّلة + سحب للقفل/الإلغاء.
                onHoldStart: _onMicHoldStart,
                onHoldMove: _onMicHoldMove,
                onHoldEnd: _onMicHoldEnd,
                micScale: _micScale,
                cancelArmed: _cancelArmed,
                isHolding:
                    _voiceState == ComposerVoiceState.holding ||
                    _voiceState == ComposerVoiceState.lockDragging,
                recordSeconds: _recordSeconds,
                micTranslationOffset: _micTranslationOffset,
                cancelProgress: _cancelProgress,
                liveWaveform: _liveWaveform,
              ),
              // ★ سكة القفل الصاعدة فوق زر المايك — تظهر أثناء الضغطة فقط.
              // في RTL الزر على اليسار ⇒ السكة على اليسار، وفي LTR على اليمين.
              Positioned(
                left: isRTL ? 8 : null,
                right: isRTL ? null : 8,
                bottom: 54,
                child: VoiceLockRail(
                  bounce: _lockHintController ?? kAlwaysCompleteAnimation,
                  lockProgress: _lockDragProgress,
                  isRTL: isRTL,
                  visible:
                      _voiceState == ComposerVoiceState.holding ||
                      _voiceState == ComposerVoiceState.lockDragging,
                ),
              ),
            ],
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
    final isNew = msg['isNew'] as bool? ?? false;
    final chat = context.chatColors;

    final bubble = WhatsAppBubbleShell(
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

    // ★ حركة دخول سلسة (fade + slide-in) للرسالة الصوتية الجديدة
    if (isNew && isVoice) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - value)),
              child: child,
            ),
          );
        },
        child: bubble,
      );
    }

    return bubble;
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
        status: msg['status'] as String?,
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
              status: msg['status'] as String?,
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
                      color: context.backgroundColors.mediaScrim.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: context.textColors.onMedia,
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
    final palette = context.attachmentPalette;
    switch (extension) {
      case 'pdf':
        return palette.documentPdf;
      case 'doc':
      case 'docx':
        return palette.documentWord;
      case 'xls':
      case 'xlsx':
        return palette.documentSheet;
      case 'ppt':
      case 'pptx':
        return palette.documentSlides;
      case 'zip':
      case 'rar':
        return palette.documentArchive;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return palette.documentAudio;
      default:
        return palette.documentFallback;
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
      label = duration != null
          ? 'رسالة صوتية (0:${duration.toString().padLeft(2, '0')})'
          : 'رسالة صوتية';
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
              Icon(LucideIcons.chevronRight, size: 16, color: chat.mutedText),
              const SizedBox(width: 2),
              Text(
                'اسحب للإلغاء',
                style: TextStyle(
                  color: chat.mutedText,
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
  final String? status;
  final String? avatarText;
  final ValueNotifier<String?> currentlyPlayingId;

  const _VoiceMessageBubble({
    required this.id,
    required this.audioPath,
    required this.durationSeconds,
    required this.isMine,
    required this.time,
    this.isListened = true,
    this.status,
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
  Timer? _simTimer;

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
        if (widget.audioPath != null) {
          _player.pause();
        } else {
          _simTimer?.cancel();
        }
        if (mounted) setState(() => _isPlaying = false);
      }
    };
    widget.currentlyPlayingId.addListener(_playingListener!);
  }

  @override
  void dispose() {
    _simTimer?.cancel();
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
    final rand = math.Random(seed.hashCode);
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
    if (_isPlaying) {
      if (widget.audioPath != null) {
        await _player.pause();
      } else {
        _simTimer?.cancel();
      }
      setState(() => _isPlaying = false);
      return;
    }

    widget.currentlyPlayingId.value = widget.id;

    if (widget.audioPath != null) {
      setState(() => _isLoading = true);

      // ★ تحقق من وجود ملف الصوت فعلاً — بدل الانتقال لوضع "تشغيل" بلا صوت.
      final audioFile = File(widget.audioPath!);
      if (!await audioFile.exists() || await audioFile.length() == 0) {
        debugPrint('Voice bubble audio missing: ${widget.audioPath}');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ملف التسجيل غير موجود على الجهاز'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (_totalDuration > Duration.zero && _position >= _totalDuration) {
        await _player.seek(Duration.zero);
      }
      try {
        await _player.play(DeviceFileSource(widget.audioPath!));
      } catch (e) {
        debugPrint('Playback error: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تعذر تشغيل التسجيل: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } else {
      // محاكاة حقيقية فائقة السلاسة لتشغيل الصوت وحركة الموجات
      _simTimer?.cancel();
      if (_totalDuration <= Duration.zero) {
        _totalDuration = Duration(
          seconds: widget.durationSeconds > 0 ? widget.durationSeconds : 15,
        );
      }
      if (_position >= _totalDuration) {
        _position = Duration.zero;
      }
      setState(() => _isPlaying = true);

      const stepMs = 100;
      _simTimer = Timer.periodic(const Duration(milliseconds: stepMs), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        final nextMs = _position.inMilliseconds + stepMs;
        if (nextMs >= _totalDuration.inMilliseconds) {
          t.cancel();
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        } else {
          setState(() {
            _position = Duration(milliseconds: nextMs);
          });
        }
      });
    }
  }

  /// Maps a local dx offset within the (dynamic) waveform width to a 0..1
  /// fraction of the clip. Works for both tap and horizontal drag.
  double _fractionFromOffset(double dx, double width, bool isRTL) {
    if (width <= 0) return 0.0;
    final normalizedDx = isRTL ? (width - dx) : dx;
    return (normalizedDx / width).clamp(0.0, 1.0);
  }

  Future<void> _seekToFraction(double fraction) async {
    if (_totalDuration <= Duration.zero) return;
    final target = _totalDuration * fraction.clamp(0.0, 1.0);
    if (widget.audioPath != null) {
      await _player.seek(target);
    }
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
    // ★ ألوان موجات واتساب: المشغّل أزرق سماوي #53BDEB، غير المشغّل أبيض خافت / رمادي.
    final playedColor = chat.recordingWavePlayed;
    final unplayedColor = isMine
        ? onBubble.withValues(alpha: 0.42)
        : chat.mutedText;

    // ★ سطر واحد مدمج مثل واتساب (ارتفاع ~68px) — بدون تكرار.
    // ★ الترتيب البصري من اليمين لليسار (واتساب عربي):
    //  رسائلي: [أفاتاري | موجة | تشغيل] — مثل صورتك.
    //  رسائلهم: [تشغيل | موجة | أفاتارهم].
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMine) ...[
            _VoiceAvatarBadge(avatarText: widget.avatarText, isMine: true),
            const SizedBox(width: 6),
          ],
          // ★ زر التشغيل/الإيقاف مكبّر وقريب جداً من الموجات
          GestureDetector(
            onTap: _togglePlay,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 38,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onBubble,
                      ),
                    )
                  else
                    Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: onBubble,
                      size: 36,
                    ),
                  if (!widget.isListened && !_isPlaying && !isMine)
                    const Positioned(left: -2, top: 4, child: _UnreadDot()),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
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
                              isRTL,
                            ),
                          );
                        },
                        onHorizontalDragUpdate: (details) {
                          _seekToFraction(
                            _fractionFromOffset(
                              details.localPosition.dx,
                              width,
                              isRTL,
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 26,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(_barCount, (i) {
                                  final isBarPlayed =
                                      i <= playedBars &&
                                      (_isPlaying || _position > Duration.zero);
                                  final h = _bars[i].clamp(3.5, 23.0);
                                  return Container(
                                    width: 2.2,
                                    height: h,
                                    decoration: BoxDecoration(
                                      color: isBarPlayed
                                          ? playedColor
                                          : unplayedColor,
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  );
                                }),
                              ),
                              // نقطة التقدم الحية في واتساب
                              if (width > 0 &&
                                  (_isPlaying || _position > Duration.zero))
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  start: (playedFraction * (width - 7)).clamp(
                                    0.0,
                                    width - 7,
                                  ),
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: playedColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.backgroundColors.scrim
                                              .withValues(alpha: 0.35),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
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
                            style: TextStyle(
                              color: isMine
                                  ? chat.bubbleMineTime
                                  : chat.bubbleTheirsTime,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.time,
                            style: TextStyle(
                              color: isMine
                                  ? chat.bubbleMineTime
                                  : chat.bubbleTheirsTime,
                              fontSize: 11,
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 3),
                            if (widget.status == 'sending')
                              Icon(
                                LucideIcons.clock,
                                size: 12,
                                color: isMine
                                    ? chat.bubbleMineTime
                                    : chat.bubbleTheirsTime,
                              )
                            else
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
            _VoiceAvatarBadge(avatarText: widget.avatarText, isMine: false),
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
      decoration: BoxDecoration(
        color: context.chatColors.tickRead,
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
    final onBubble = isMine ? chat.bubbleMineText : chat.bubbleTheirsText;
    return SizedBox(
      width: 40,
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onBubble.withValues(alpha: isMine ? 0.18 : 0.14),
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.user,
              size: 22,
              color: context.textColors.onMedia,
            ),
          ),
          Positioned(
            bottom: 0,
            right: -2,
            child: Icon(
              LucideIcons.mic,
              size: 15,
              color: chat.tickRead,
              shadows: [
                Shadow(
                  color: context.backgroundColors.scrim.withValues(alpha: 0.5),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
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
                  color: context.chatColors.mutedText,
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
    final onMedia = context.textColors.onMedia;
    return Scaffold(
      backgroundColor: context.backgroundColors.mediaScrim,
      appBar: AppBar(
        backgroundColor: context.backgroundColors.mediaScrim.withValues(
          alpha: 0.6,
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: onMedia),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onMedia,
                    ),
                  )
                : Icon(LucideIcons.download, color: onMedia),
            onPressed: _saving ? null : _save,
            tooltip: 'حفظ',
          ),
          IconButton(
            icon: Icon(LucideIcons.share2, color: onMedia),
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
