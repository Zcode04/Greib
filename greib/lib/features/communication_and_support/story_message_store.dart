// ============================================================================
//  StoryMessageStore — مخزن رسائل الستوري (إرسال خلفي بأسلوب فيسبوك)
// ============================================================================
//
//  ◆ الفكرة: المستخدم يرسل من الستوري ويبقى فيها (لا توجيه).
//    الرسالة تُحفظ هنا، وعندما يفتح الدردشة لاحقاً يجدها مع المرفق.
//  ◆ المفتاح: نفس `conversationId` (story_{title}_{page}) يربط الطرفين.
//  ◆ خفيف: Map في الذاكرة — بلا أي Streams.

class StoryPendingMessage {
  final String id;
  final String conversationId;
  final String content;
  final String time;

  /// ★ بيانات حساب الخدمة — لظهور محادثة جديدة في قائمة الدردشة
  /// (اسم + أيقونة + هاتف + حالة) بأسلوب الحسابات الثابتة.
  final String serviceName;
  final String serviceAvatar;
  final String servicePhone;
  final String serviceCategory;

  final String? postTitle;
  final String? postSubtitle;
  final String? postImageUrl;
  final int? postColor;

  const StoryPendingMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.time,
    required this.serviceName,
    this.serviceAvatar = '🏪',
    this.servicePhone = '',
    this.serviceCategory = 'عام',
    this.postTitle,
    this.postSubtitle,
    this.postImageUrl,
    this.postColor,
  });

  Map<String, dynamic> toChatMap() => {
        'id': id,
        'sender': 'أنت',
        'content': content,
        'time': time,
        'isMine': true,
        if (postTitle != null) 'isPost': true,
        if (postTitle != null) 'postTitle': postTitle,
        if (postSubtitle != null) 'postSubtitle': postSubtitle,
        if (postImageUrl != null) 'postImageUrl': postImageUrl,
        if (postColor != null) 'postColor': postColor,
      };
}

class StoryMessageStore {
  StoryMessageStore._();
  static final StoryMessageStore instance = StoryMessageStore._();

  final Map<String, List<StoryPendingMessage>> _byConversation = {};

  /// حفظ رسالة مرسلة من الستوري (تظهر لاحقاً في الدردشة).
  void save(StoryPendingMessage message) {
    final list = _byConversation.putIfAbsent(
      message.conversationId,
      () => [],
    );
    // ★ منع التكرار (نفس المعرف لا يُحفظ مرتين).
    if (list.any((m) => m.id == message.id)) return;
    list.add(message);
  }

  /// رسائل محادثة معيّنة (للدمج عند فتح الدردشة).
  List<StoryPendingMessage> forConversation(String conversationId) =>
      List.unmodifiable(_byConversation[conversationId] ?? const []);

  /// ★ كل المحادثات الجديدة (واحدة لكل خدمة أُرسل لها) — تُدمج في
  /// قائمة الدردشة فتظهر كحسابات جديدة بأسماء الخدمات وبروفايلاتها.
  List<Map<String, dynamic>> storyConversations() {
    final result = <Map<String, dynamic>>[];
    _byConversation.forEach((convId, messages) {
      if (messages.isEmpty) return;
      final first = messages.first;
      final last = messages.last;
      result.add({
        'id': convId,
        'name': first.serviceName,
        'phone': first.servicePhone.isEmpty
            ? 'خدمة · ${first.serviceCategory}'
            : first.servicePhone,
        'lastMessage': last.content,
        'time': last.time,
        'unread': messages.length,
        'avatar': first.serviceAvatar,
        'type': 'service',
        'online': true,
        'activity': 'بانتظار الرد',
        'isStory': true,
      });
    });
    return result;
  }
}
