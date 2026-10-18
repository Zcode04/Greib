// ============================================================================
//  ContactsChatStore — دليل جهات الاتصال + مخزن محادثات المستخدم
// ============================================================================
//
//  ◆ «جهات اتصال گريب منك»: الحسابات الرسمية (دعم/التوصيل/التنبيهات)
//    + حسابات خدمات واحدة لكل تصنيف من تبويبات الرئيسية
//    (`MockData.productCategories`).
//  ◆ «جهات اتصلي»: أي حساب بدأ المستخدم معه محادثة من صفحة جهات الاتصال
//    يُحفظ هنا ⇒ يظهر في قائمة الدردشة (بنفس آلية StoryMessageStore).
//  ◆ خفيف: Map في الذاكرة — بلا أي Streams (مستوى باقي التطبيق).

/// جهة اتصال واحدة (حساب رسمي أو خدمة).
class ServiceContact {
  final String id;

  /// نفس معرّف المحادثة في الدردشة (chat1..3 للرسمية، svc_.. للخدمات)
  /// حتى يفتح الضغط نفس المحادثة بلا تكرار.
  final String name;
  final String avatar;
  final String phone;

  /// معرّف التصنيف في `MockData.productCategories` أو 'official'.
  final String category;
  final String activity;
  final bool online;

  const ServiceContact({
    required this.id,
    required this.name,
    required this.avatar,
    required this.phone,
    required this.category,
    required this.activity,
    this.online = false,
  });
}

class ContactsChatStore {
  ContactsChatStore._();
  static final ContactsChatStore instance = ContactsChatStore._();

  /// ★ الحسابات الرسمية «من گريب منك» — معرّفاتها نفس المحادثات الثابتة
  ///   في قائمة الدردشة (chat1/chat2/chat3) ⇒ تفتح نفس المحادثة القائمة.
  static const List<ServiceContact> officialAccounts = [
    ServiceContact(
      id: 'chat1',
      name: 'دعم گريب منك',
      avatar: '🤝',
      phone: '+971 50 123 4567',
      category: 'official',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'chat2',
      name: 'فريق التوصيل - دبي',
      avatar: '🚚',
      phone: '+971 52 987 6543',
      category: 'official',
      activity: 'آخر ظهور اليوم 9:15 ص',
    ),
    ServiceContact(
      id: 'chat3',
      name: 'تنبيهات الطلبات',
      avatar: '📋',
      phone: '+971 4 000 0000',
      category: 'official',
      activity: 'حساب آلي',
    ),
  ];

  /// ★ حسابات الخدمات — واحد لكل تصنيف من تبويبات الرئيسية
  ///   (نفس معرّفات `MockData.productCategories`).
  static const List<ServiceContact> serviceAccounts = [
    ServiceContact(
      id: 'svc_men_fashion',
      name: 'خياط الأناقة',
      avatar: '🧵',
      phone: 'خدمة · أزياء الرجال',
      category: 'men_fashion',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'svc_boys_fashion',
      name: 'أزياء الأولاد',
      avatar: '👦',
      phone: 'خدمة · أزياء الأولاد',
      category: 'boys_fashion',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'svc_electronics',
      name: 'عالم الإلكترونيات',
      avatar: '📱',
      phone: 'خدمة · الإلكترونيات والسماعات',
      category: 'electronics',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'svc_watches',
      name: 'دار الساعات',
      avatar: '⌚',
      phone: 'خدمة · الساعات والإكسسوارات',
      category: 'watches',
      activity: 'آخر ظهور اليوم',
    ),
    ServiceContact(
      id: 'svc_health',
      name: 'صحة وتغذية',
      avatar: '🥗',
      phone: 'خدمة · الصحة والتغذية',
      category: 'health_nutrition',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'svc_sports',
      name: 'مستلزمات الرياضة',
      avatar: '🏆',
      phone: 'خدمة · الرياضة',
      category: 'sports',
      activity: 'آخر ظهور أمس',
    ),
    ServiceContact(
      id: 'svc_cars',
      name: 'عناية السيارات',
      avatar: '🚗',
      phone: 'خدمة · السيارات',
      category: 'cars',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'svc_toys',
      name: 'عالم الألعاب',
      avatar: '🧸',
      phone: 'خدمة · الألعاب',
      category: 'toys',
      activity: 'آخر ظهور اليوم',
    ),
    ServiceContact(
      id: 'svc_perfumes',
      name: 'عطور وعناية',
      avatar: '🌸',
      phone: 'خدمة · العطور والعناية',
      category: 'perfumes_care',
      activity: 'متصل الآن',
      online: true,
    ),
    ServiceContact(
      id: 'svc_hotels',
      name: 'حجوزات الفنادق',
      avatar: '🏨',
      phone: 'خدمة · الفنادق والإقامات',
      category: 'hotels',
      activity: 'آخر ظهور اليوم',
    ),
  ];

  /// المحادثات التي بدأها المستخدم من صفحة جهات الاتصال (معرّف ⇒ بيانات).
  final Map<String, Map<String, dynamic>> _started = {};

  /// بدء محادثة جديدة مع حساب خدمة — تحفظ ضمن «جهات اتصلي» وقائمة الدردشة.
  /// الحسابات الرسمية (chat1..3) متجاهَلة: موجودة أصلاً في القائمة.
  void startChat(ServiceContact contact) {
    if (officialAccounts.any((a) => a.id == contact.id)) return;
    _started.putIfAbsent(contact.id, () => _contactToConversation(contact));
  }

  /// ★ محادثات تُدمج في قائمة الدردشة (بنفس شكل `storyConversations`).
  List<Map<String, dynamic>> contactConversations() =>
      _started.values.map((m) => Map<String, dynamic>.from(m)).toList();

  static Map<String, dynamic> _contactToConversation(ServiceContact c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'lastMessage': 'محادثة جديدة — قل مرحباً 👋',
        'time': 'الآن',
        'unread': 0,
        'avatar': c.avatar,
        'type': 'service',
        'online': c.online,
        'activity': c.activity,
        // ★ محادثة بلا رسائل تجريبية (تفتح فارغة تماماً مثل واتساب).
        'isEmpty': true,
      };
}
