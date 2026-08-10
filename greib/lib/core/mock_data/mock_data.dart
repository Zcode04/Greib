import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/design_tokens.dart';

// ==================== نماذج البيانات (Models) ====================

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String avatar;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatar,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'avatar': avatar,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'],
        avatar: json['avatar'],
      );
}

class ServiceCategory {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final Color color;
  final String route;
  final String? imageUrl; // صورة مميّزة للخدمة (اختيارية)

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.color,
    required this.route,
    this.imageUrl,
  });
}

class Order {
  final String id;
  final String userId;
  final String serviceType;
  final String status;
  final String description;
  final double price;
  final String? agentId;
  final DateTime? createdAt;
  final String pickupLocation;
  final String deliveryLocation;

  const Order({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.status,
    required this.description,
    required this.price,
    this.agentId,
    this.createdAt,
    required this.pickupLocation,
    required this.deliveryLocation,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime? timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.timestamp,
    this.isRead = false,
  });
}

class ChatConversation {
  final String id;
  final String title;
  final List<String> participantIds;
  final List<ChatMessage> messages;
  final String type;
  final String? createdBy;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.messages,
    required this.type,
    this.createdBy,
  });
}

class AppUserProfile {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;
  final String? address;
  final String? avatarUrl;
  final String membershipTier;
  final int loyaltyPoints;

  const AppUserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.address,
    this.avatarUrl,
    this.membershipTier = 'regular',
    this.loyaltyPoints = 1250,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
        'email': email,
        'address': address,
        'avatarUrl': avatarUrl,
        'membershipTier': membershipTier,
        'loyaltyPoints': loyaltyPoints,
      };

  factory AppUserProfile.fromJson(Map<String, dynamic> json) => AppUserProfile(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
        avatarUrl: json['avatarUrl'],
        membershipTier: json['membershipTier'] ?? 'regular',
        loyaltyPoints: json['loyaltyPoints'] ?? 0,
      );
}

class DoctorProfile {
  final String id;
  final String name;
  final String specialty;
  final String avatar;
  final double rating;
  final int yearsOfExperience;
  final String hospitalName;
  final bool isAvailableNow;
  final double consultationFee;

  const DoctorProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.rating,
    required this.yearsOfExperience,
    required this.hospitalName,
    required this.isAvailableNow,
    required this.consultationFee,
  });
}

// ==================== البيانات الوهمية (Mock Data) ====================

class MockData {
  static const List<UserAccount> demoAccounts = [
    UserAccount(
      id: 'u1',
      name: 'أحمد محمد',
      email: 'user@greib.com',
      phone: '+971501234567',
      role: 'user',
      avatar: 'https://i.pravatar.cc/150?img=1',
    ),
    UserAccount(
      id: 'a1',
      name: 'خالد العمري',
      email: 'agent@greib.com',
      phone: '+971502345678',
      role: 'agent',
      avatar: 'https://i.pravatar.cc/150?img=2',
    ),
    UserAccount(
      id: 'adm1',
      name: 'سالم راشد',
      email: 'admin@greib.com',
      phone: '+971503456789',
      role: 'admin',
      avatar: 'https://i.pravatar.cc/150?img=3',
    ),
  ];

  static const List<AppUserProfile> demoProfiles = [
    AppUserProfile(
      id: 'u1',
      name: 'أحمد محمد',
      role: 'user',
      phone: '+971501234567',
      email: 'user@greib.com',
      address: 'دبي، الممزر، شارع 14',
      membershipTier: 'gold',
      loyaltyPoints: 1250,
    ),
    AppUserProfile(
      id: 'a1',
      name: 'خالد العمري',
      role: 'agent',
      phone: '+971502345678',
      email: 'agent@greib.com',
      address: 'دبي، القصيص',
      membershipTier: 'regular',
      loyaltyPoints: 850,
    ),
    AppUserProfile(
      id: 'adm1',
      name: 'سالم راشد',
      role: 'admin',
      phone: '+971503456789',
      email: 'admin@greib.com',
      address: 'أبوظبي، مدينة خليفة',
      membershipTier: 'gold',
      loyaltyPoints: 2100,
    ),
  ];

  static const List<Order> demoOrders = [
    Order(
      id: 'ord1',
      userId: 'u1',
      serviceType: 'food',
      status: 'assigned',
      description: 'طلب برياني دجاج من مطعم المندي الملكي',
      price: 45.0,
      agentId: 'a1',
      pickupLocation: 'مطعم المندي الملكي، ديرة',
      deliveryLocation: 'الممزر، دبي',
    ),
    Order(
      id: 'ord2',
      userId: 'u1',
      serviceType: 'pharmacy',
      status: 'in_transit',
      description: 'أدوية: بانادول، فيتامين سي',
      price: 32.5,
      agentId: 'a1',
      pickupLocation: 'صيدلية أستر، الرقة',
      deliveryLocation: 'الكرامة، دبي',
    ),
    Order(
      id: 'ord3',
      userId: 'u2',
      serviceType: 'courier',
      status: 'pending',
      description: 'توصيل طرد - مستندات رسمية',
      price: 25.0,
      pickupLocation: 'مكتب الشركة، شارع الشيخ زايد',
      deliveryLocation: 'الشارقة، المجاز',
    ),
  ];

  static const List<ChatConversation> demoConversations = [
    ChatConversation(
      id: 'chat1',
      title: 'دعم المستخدم',
      participantIds: ['u1', 'adm1'],
      messages: [
        ChatMessage(
          id: 'm1',
          senderId: 'u1',
          senderName: 'أحمد محمد',
          content: 'مرحباً، متى يوصل طلب الطعام؟',
          isRead: true,
        ),
        ChatMessage(
          id: 'm2',
          senderId: 'adm1',
          senderName: 'سالم راشد',
          content: 'أهلاً بك، طلبك في الطريق الآن 🚀',
        ),
      ],
      type: 'direct',
      createdBy: 'adm1',
    ),
    ChatConversation(
      id: 'chat2',
      title: 'فريق التوصيل - دبي',
      participantIds: ['a1', 'adm1', 'a2'],
      messages: [
        ChatMessage(
          id: 'm3',
          senderId: 'a1',
          senderName: 'خالد العمري',
          content: 'تم تسليم طلب الممزر بنجاح ✅',
        ),
        ChatMessage(
          id: 'm4',
          senderId: 'adm1',
          senderName: 'سالم راشد',
          content: 'ممتاز، تفضل بالطلب التالي',
        ),
      ],
      type: 'group',
      createdBy: 'adm1',
    ),
  ];

  static const List<Map<String, String>> demoNotifications = [
    {
      'id': 'n1',
      'title': 'طلب جديد',
      'body': 'لديك طلب جديد من أحمد محمد - توصيل طعام',
      'type': 'order',
      'timestamp': 'منذ ٥ دقائق',
    },
    {
      'id': 'n2',
      'title': 'رسالة جديدة',
      'body': 'رسالة جديدة من سالم راشد في مجموعة فريق التوصيل',
      'type': 'chat',
      'timestamp': 'منذ ١٠ دقائق',
    },
    {
      'id': 'n3',
      'title': 'تحديث الطلب',
      'body': 'تم تعيين وكيل لطلبك رقم ord1',
      'type': 'order_update',
      'timestamp': 'منذ ٣٠ دقيقة',
    },
  ];

  static const List<DoctorProfile> mockDoctors = [
    DoctorProfile(
      id: 'd1',
      name: 'د. محمد أحمد',
      specialty: 'باطنة',
      avatar: 'https://i.pravatar.cc/150?img=10',
      rating: 4.8,
      yearsOfExperience: 12,
      hospitalName: 'مستشفى الشيخ خليفة بن زايد الجامعي',
      isAvailableNow: true,
      consultationFee: 150.0,
    ),
    DoctorProfile(
      id: 'd2',
      name: 'د. فاطنة حسن',
      specialty: 'أطفال',
      avatar: 'https://i.pravatar.cc/150?img=11',
      rating: 4.9,
      yearsOfExperience: 8,
      hospitalName: 'مستشفى توام',
      isAvailableNow: true,
      consultationFee: 180.0,
    ),
    DoctorProfile(
      id: 'd3',
      name: 'د. عمر البكري',
      specialty: 'أسنان',
      avatar: 'https://i.pravatar.cc/150?img=12',
      rating: 4.7,
      yearsOfExperience: 10,
      hospitalName: 'مستشفى راشد',
      isAvailableNow: false,
      consultationFee: 120.0,
    ),
    DoctorProfile(
      id: 'd4',
      name: 'د. سارة محمود',
      specialty: 'جلدية',
      avatar: 'https://i.pravatar.cc/150?img=13',
      rating: 4.6,
      yearsOfExperience: 6,
      hospitalName: 'مستشفى برجيل',
      isAvailableNow: true,
      consultationFee: 200.0,
    ),
    DoctorProfile(
      id: 'd5',
      name: 'د. ليلى عبدالله',
      specialty: 'نساء وولادة',
      avatar: 'https://i.pravatar.cc/150?img=14',
      rating: 4.9,
      yearsOfExperience: 15,
      hospitalName: 'مستشفى الفاطمة',
      isAvailableNow: true,
      consultationFee: 220.0,
    ),
    DoctorProfile(
      id: 'd6',
      name: 'د. خالد رمضان',
      specialty: 'عظام',
      avatar: 'https://i.pravatar.cc/150?img=15',
      rating: 4.5,
      yearsOfExperience: 14,
      hospitalName: 'مستشفى العين الدولي',
      isAvailableNow: false,
      consultationFee: 250.0,
    ),
    DoctorProfile(
      id: 'd7',
      name: 'د. أمير صالح',
      specialty: 'قلب',
      avatar: 'https://i.pravatar.cc/150?img=16',
      rating: 4.8,
      yearsOfExperience: 11,
      hospitalName: 'مستشفى دبي الدولي',
      isAvailableNow: true,
      consultationFee: 300.0,
    ),
    DoctorProfile(
      id: 'd8',
      name: 'د. نورا الزهراء',
      specialty: 'طب الأسرة',
      avatar: 'https://i.pravatar.cc/150?img=17',
      rating: 4.4,
      yearsOfExperience: 7,
      hospitalName: 'مركز الراشد للرعاية الصحية',
      isAvailableNow: true,
      consultationFee: 130.0,
    ),
  ];

  static Color getSpecialtyColor(String specialty) {
    switch (specialty) {
      case 'باطنة':
        return const Color(0xFF0F5132); // أخضر غامق
      case 'أطفال':
        return AppColors.info; // أزرق
      case 'أسنان':
        return const Color(0xFFD4A853); // ذهبي
      case 'جلدية':
        return AppColors.serviceShopping; // وردي
      case 'نساء وولادة':
        return AppColors.accentPrimary; // بنفسجي
      case 'عظام':
        return AppColors.warning; // برتقالي
      case 'قلب':
        return AppColors.error; // أحمر
      case 'طب الأسرة':
        return AppColors.serviceTourism; // تركواز
      default:
        return AppColors.accentPrimary;
    }
  }

  static List<ServiceCategory> get services => [
        ServiceCategory(
          id: 'food',
          title: 'توصيل طعام',
          subtitle: 'من مطعمك المفضل',
          iconName: 'utensils',
          color: AppColors.serviceFood,
          route: '/food',
        ),
        ServiceCategory(
          id: 'pharmacy',
          title: 'الصيدلية',
          subtitle: 'أدوية ووصفات',
          iconName: 'pills',
          color: AppColors.servicePharmacy,
          route: '/pharmacy',
        ),
        ServiceCategory(
          id: 'courier',
          title: 'نقل طرود',
          subtitle: 'توصيل سريع',
          iconName: 'package',
          color: AppColors.serviceCourier,
          route: '/courier',
        ),
        ServiceCategory(
          id: 'ride',
          title: 'المواصلات',
          subtitle: 'تنقل براحة',
          iconName: 'car',
          color: AppColors.serviceRide,
          route: '/ride',
        ),
        ServiceCategory(
          id: 'shopping',
          title: 'تسوق ومقاضي',
          subtitle: 'كل احتياجاتك',
          iconName: 'shopping-cart',
          color: AppColors.serviceShopping,
          route: '/shopping',
        ),
        ServiceCategory(
          id: 'tourism',
          title: 'سياحة وفعاليات',
          subtitle: 'استكشف المكان',
          iconName: 'palmtree',
          color: AppColors.serviceTourism,
          route: '/tourism',
        ),

        // ===== الخدمات الإضافية الجديدة =====
        ServiceCategory(
          id: 'moving',
          title: 'نقل',
          subtitle: 'نقل عفش وأثاث',
          iconName: 'truck-moving',
          color: AppColors.serviceMoving,
          route: '/moving',
          imageUrl: 'assets/images/moving.jpg',
        ),
        ServiceCategory(
          id: 'taxi',
          title: 'تكاسي',
          subtitle: 'توصيل ركاب',
          iconName: 'taxi',
          color: AppColors.serviceTaxi,
          route: '/taxi',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/a82074ee3f1142119c3ac58dfb1a6bde~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'electricity',
          title: 'الكهرباء',
          subtitle: 'صيانة وتركيب',
          iconName: 'zap',
          color: AppColors.serviceElectricity,
          route: '/electricity',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/6d0d08cad4e743cb89536f8195112515~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'water',
          title: 'الماء',
          subtitle: 'توصيل وصيانة',
          iconName: 'droplet',
          color: AppColors.serviceWater,
          route: '/water',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/e388099b7de04a72a0b429675c872037~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'laundry',
          title: 'الغسيل',
          subtitle: 'غسيل وكيّ',
          iconName: 'washing-machine',
          color: AppColors.serviceLaundry,
          route: '/laundry',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/ac00df1d838244c8880ab43eb2d6b2dc~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'clothes',
          title: 'الملابس',
          subtitle: 'تفصيل وتعديل',
          iconName: 'shirt',
          color: AppColors.serviceClothes,
          route: '/clothes',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/13c9992e6f294c4e81c58cf41135d815~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'phones',
          title: 'الهواتف',
          subtitle: 'صيانة وتركيب',
          iconName: 'smartphone',
          color: AppColors.servicePhones,
          route: '/phones',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/8741f9dc3c114e46a10be3e91397e179~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'devices',
          title: 'الأجهزة',
          subtitle: 'إصلاح وصيانة',
          iconName: 'laptop',
          color: AppColors.serviceDevices,
          route: '/devices',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/7a2cdc3bd79a4dbeb612b52f45710a14~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'appliances',
          title: 'الأجهزة المنزلية',
          subtitle: 'تركيب وصيانة',
          iconName: 'refrigerator',
          color: AppColors.serviceAppliances,
          route: '/appliances',
          imageUrl: 'https://p19-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/1b678879cbcd40f9a693f73683b697bd~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'office',
          title: 'المعدات المكتبية',
          subtitle: 'تأجير وبيع',
          iconName: 'printer',
          color: AppColors.serviceOffice,
          route: '/office',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/b2e5ed955a134cefabfcdf07de0e5ece~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'delivery',
          title: 'التوصيل',
          subtitle: 'توصيل طرود',
          iconName: 'package-delivery',
          color: AppColors.serviceDelivery,
          route: '/delivery',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/e039d726a70f41a49249d133250fd5fa~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'estore',
          title: 'المتاجر الإلكترونية',
          subtitle: 'تسوّق أونلاين',
          iconName: 'shopping-bag',
          color: AppColors.serviceEstore,
          route: '/estore',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/2ac5118f095a4ea8a6ba12c7b59e3049~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'travel',
          title: 'السفر',
          subtitle: 'حجوزات طيران',
          iconName: 'plane',
          color: AppColors.serviceTravel,
          route: '/travel',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/cb83a3e0449149b0a13e4e1e8ec72167~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'tourism_extra',
          title: 'السياحة',
          subtitle: 'رحلات واستكشاف',
          iconName: 'map-pin-tourism',
          color: AppColors.serviceTourismX,
          route: '/tourism_extra',
          imageUrl: 'https://p19-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/9c766be8b1514042950475b2215f5726~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'medicine',
          title: 'الأدوية',
          subtitle: 'أدوية ومستلزمات',
          iconName: 'pill-medicine',
          color: AppColors.serviceMedicine,
          route: '/medicine',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/0158ade305b04892bef39f7874876747~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'pharmacy_extra',
          title: 'صيدلة',
          subtitle: 'صيدليات قريبة',
          iconName: 'cross-pharmacy',
          color: AppColors.servicePharmacyX,
          route: '/pharmacy_extra',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/b5db28b6e22a4854bc5679803cd3e4ee~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'consult',
          title: 'حجز لاستشارات طبية',
          subtitle: 'استشارات عن بُعد',
          iconName: 'stethoscope',
          color: AppColors.serviceConsult,
          route: '/consult',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/d1e580ed76444e579cdc17370623a96b~tplv-h9hire4aei-image.jpeg',
        ),
        ServiceCategory(
          id: 'freight',
          title: 'نقل البضائعة',
          subtitle: 'شحن وتوصيل بضائع',
          iconName: 'container-freight',
          color: AppColors.serviceFreight,
          route: '/freight',
          imageUrl: 'https://p16-cc-image-search-sign-sg.ibyteimg.com/tos-alisg-i-h9hire4aei-sg/6aaac25d00964a7c822747dbe568e71f~tplv-h9hire4aei-image.jpeg',
        ),
      ];

  static IconData getIconByName(String name) {
    switch (name) {
      case 'utensils':
        return LucideIcons.utensils;
      case 'pills':
        return LucideIcons.pill;
      case 'package':
        return LucideIcons.package;
      case 'car':
        return LucideIcons.car;
      case 'shopping-cart':
        return LucideIcons.shoppingCart;
      case 'palmtree':
        return LucideIcons.palmtree;
      // ---- أيقونات الخدمات الجديدة ----
      case 'truck-moving':
        return LucideIcons.truck;
      case 'taxi':
        return LucideIcons.car;
      case 'zap':
        return LucideIcons.zap;
      case 'droplet':
        return LucideIcons.droplet;
      case 'washing-machine':
        return LucideIcons.washingMachine;
      case 'shirt':
        return LucideIcons.shirt;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'laptop':
        return LucideIcons.laptop;
      case 'refrigerator':
        return LucideIcons.refrigerator;
      case 'printer':
        return LucideIcons.printer;
      case 'package-delivery':
        return LucideIcons.package;
      case 'shopping-bag':
        return LucideIcons.shoppingBag;
      case 'plane':
        return LucideIcons.plane;
      case 'map-pin-tourism':
        return LucideIcons.mapPin;
      case 'pill-medicine':
        return LucideIcons.pill;
      case 'cross-pharmacy':
        return LucideIcons.cross;
      case 'stethoscope':
        return LucideIcons.stethoscope;
      case 'container-freight':
        return LucideIcons.container;
      case 'chat':
        return LucideIcons.messageCircle;
      case 'home':
        return LucideIcons.home;
      case 'profile':
        return LucideIcons.user;
      case 'shield':
        return LucideIcons.shield;
      case 'users':
        return LucideIcons.users;
      case 'bell':
        return LucideIcons.bell;
      case 'settings':
        return LucideIcons.settings;
      case 'logout':
        return LucideIcons.logOut;
      default:
        return LucideIcons.circle;
    }
  }
}
