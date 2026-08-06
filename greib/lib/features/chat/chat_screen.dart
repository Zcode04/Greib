import 'package:flutter/material.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../features/auth/mock_auth.dart';
import '../../shared_widgets/app_button.dart';

// شاشة قائمة المحادثات
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

    // محادثات افتراضية
    _conversations = [
      {
        'id': 'chat1',
        'name': 'دعم گريب منك',
        'lastMessage': 'أهلاً بك، طلبك في الطريق الآن 🚀',
        'time': 'منذ 5 دقائق',
        'unread': 2,
        'icon': '🤝',
        'type': 'support',
        'participants': ['u1', 'adm1'],
      },
      {
        'id': 'chat2',
        'name': 'فريق التوصيل - دبي',
        'lastMessage': 'تم تسليم طلب الممزر بنجاح ✅',
        'time': 'منذ 10 دقائق',
        'unread': 0,
        'icon': '🚚',
        'type': 'group',
        'participants': ['a1', 'adm1', 'a2'],
      },
      {
        'id': 'chat3',
        'name': 'تنبيهات الطلبات',
        'lastMessage': 'طلب جديد من أحمد محمد - توصيل طعام',
        'time': 'منذ 30 دقيقة',
        'unread': 1,
        'icon': '📋',
        'type': 'system',
        'participants': [],
      },
    ];

    // تصفية حسب الدور
    if (role == UserRole.admin) {
      _conversations.addAll([
        {
          'id': 'chat4',
          'name': 'الوكلاء (المجموعة العامة)',
          'lastMessage': 'سلام عليكم، التقرير اليومي جاهز',
          'time': 'منذ ساعة',
          'unread': 3,
          'icon': '👥',
          'type': 'group',
          'participants': ['adm1', 'a1', 'a2', 'a3'],
        },
        {
          'id': 'chat5',
          'name': 'شكاوى العملاء',
          'lastMessage': 'العميل أحمد يطلب تحديث حالة الطلب',
          'time': 'منذ 45 دقيقة',
          'unread': 1,
          'icon': '📢',
          'type': 'support',
          'participants': ['adm1', 'u1', 'u2'],
        },
      ]);
    }

    if (role == UserRole.admin) {
      _conversations.add({
        'id': 'chat6',
        'name': 'مجموعة جديدة (مثال)',
        'lastMessage': 'تم إنشاء المجموعة بنجاح',
        'time': 'الآن',
        'unread': 0,
        'icon': '✨',
        'type': 'group',
        'participants': ['adm1'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = AuthService.instance.currentRole;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        actions: [
          if (role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () => _showCreateGroupDialog(context),
              tooltip: 'إنشاء مجموعة',
            ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث في المحادثات...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // فلترة المحادثات
                setState(() {});
              },
            ),
          ),

          // قائمة المحادثات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                return _buildConversationTile(context, theme, conv);
              },
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة محادثة
  Widget _buildConversationTile(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> conv,
  ) {
    final unread = conv['unread'] as int;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              conv['icon'] as String,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                conv['name'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              conv['time'] as String,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Row(
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
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                conversationTitle: conv['name'] as String,
                conversationId: conv['id'] as String,
              ),
            ),
          );
        },
      ),
    );
  }

  // نافذة إنشاء مجموعة
  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final role = AuthService.instance.currentRole;
    final canCreate = role == UserRole.admin &&
        PermissionService.canPerform(role, 'create_dynamic_group');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إنشاء مجموعة جديدة',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة',
                hintText: 'مثال: فريق الشارقة',
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'اختر الأعضاء',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // قائمة الأعضاء المتاحة
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                children: MockData.demoAccounts.map((user) {
                  return CheckboxListTile(
                    title: Text(user.name),
                    subtitle: Text(user.role),
                    value: false,
                    onChanged: (value) {},
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'إنشاء المجموعة',
              icon: Icons.check,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      canCreate
                          ? 'تم إنشاء المجموعة "${nameController.text}" بنجاح ✅'
                          : 'ليس لديك صلاحية إنشاء مجموعات',
                    ),
                    backgroundColor: canCreate ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// شاشة تفاصيل المحادثة
class ChatDetailScreen extends StatefulWidget {
  final String conversationTitle;
  final String conversationId;

  const ChatDetailScreen({
    super.key,
    required this.conversationTitle,
    required this.conversationId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
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
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    // محاكاة رد آلي
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
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.conversationTitle),
          ],
        ),
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(theme, msg);
              },
            ),
          ),

          // حقل الإدخال
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                // زر إرفاق
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('خاصية إرفاق الملفات قريباً 📎'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // حقل النص
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),

                // زر الإرسال
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // فقاعة رسالة
  Widget _buildMessageBubble(ThemeData theme, Map<String, dynamic> msg) {
    final isMine = msg['isMine'] as bool;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Text(
                  msg['sender'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMine
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMine
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg['content'] as String,
                    style: TextStyle(
                      color: isMine ? Colors.white : theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['time'] as String,
                    style: TextStyle(
                      color: isMine
                          ? Colors.white70
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
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