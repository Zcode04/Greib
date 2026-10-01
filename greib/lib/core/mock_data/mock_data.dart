import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/design_tokens.dart';

import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/chat_model.dart';
import '../models/hotel_model.dart';
import '../models/travel_model.dart';
import '../models/doctor_model.dart';
import '../models/product_model.dart';

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

  /// لون موحّد لكل التخصصات — لا ألوان إضافية.
  static Color getSpecialtyColor(String specialty) => AppColors.accentPrimary;

  // تبويبات المتجر (الأول "الكل" مفعّل افتراضياً — البقية تُطوَّر لاحقاً)
  static const List<Map<String, String>> productCategories = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'electronics', 'label': 'الإلكترونيات'},
    {'id': 'beauty', 'label': 'الجمال والعطور'},
    {'id': 'home', 'label': 'المنزل'},
    {'id': 'grocery', 'label': 'البقالة'},
    {'id': 'men_fashion', 'label': 'أزياء الرجال'},
    {'id': 'women_fashion', 'label': 'أزياء النساء'},
    {'id': 'baby', 'label': 'مستلزمات الأم والبيبي'},
    {'id': 'toys', 'label': 'الألعاب'},
    {'id': 'boys_fashion', 'label': 'أزياء الأولاد'},
    {'id': 'sports', 'label': 'الرياضة'},
    {'id': 'health', 'label': 'الصحة والتغذية'},
    {'id': 'cars', 'label': 'السيارات'},
    {'id': 'best', 'label': 'أحسن المنتجات'},
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'حذاء رياضي خفيف',
      category: 'shoes',
      price: 199.0,
      oldPrice: 259.0,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80',
      rating: 4.7,
    ),
    Product(
      id: 'p2',
      name: 'فستان صيفي أنيق',
      category: 'women',
      price: 149.0,
      imageUrl:
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&q=80',
      rating: 4.5,
    ),
    Product(
      id: 'p3',
      name: 'قميص قطني مريح',
      category: 'men',
      price: 89.0,
      oldPrice: 120.0,
      imageUrl:
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500&q=80',
      rating: 4.3,
    ),
    Product(
      id: 'p4',
      name: 'حذاء جلدي كلاسيكي',
      category: 'shoes',
      price: 279.0,
      imageUrl:
          'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=500&q=80',
      rating: 4.8,
    ),
    Product(
      id: 'p5',
      name: 'عباية مطرزة فاخرة',
      category: 'women',
      price: 320.0,
      oldPrice: 390.0,
      imageUrl:
          'https://images.unsplash.com/photo-1554412933-514a83d2f3c8?w=500&q=80',
      rating: 4.9,
    ),
    Product(
      id: 'p6',
      name: 'بدلة رجالية رسمية',
      category: 'men',
      price: 450.0,
      imageUrl:
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=500&q=80',
      rating: 4.6,
    ),
    Product(
      id: 'p7',
      name: 'حذاء أطفال ملوّن',
      category: 'kids',
      price: 75.0,
      oldPrice: 95.0,
      imageUrl:
          'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=500&q=80',
      rating: 4.4,
    ),
    Product(
      id: 'p8',
      name: 'تي شيرت أطفال قطني',
      category: 'kids',
      price: 45.0,
      imageUrl:
          'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=500&q=80',
      rating: 4.2,
    ),
    Product(
      id: 'p9',
      name: 'نعال رياضية نسائية',
      category: 'women',
      price: 130.0,
      imageUrl:
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500&q=80',
      rating: 4.5,
    ),
    Product(
      id: 'p10',
      name: 'جاكيت شتوي رجالي',
      category: 'men',
      price: 240.0,
      oldPrice: 300.0,
      imageUrl:
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&q=80',
      rating: 4.7,
    ),
    Product(
      id: 'p11',
      name: 'صندل أطفال صيفي',
      category: 'kids',
      price: 60.0,
      imageUrl:
          'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=500&q=80',
      rating: 4.1,
    ),
    Product(
      id: 'p12',
      name: 'حقيبة يد نسائية',
      category: 'women',
      price: 210.0,
      oldPrice: 260.0,
      imageUrl:
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&q=80',
      rating: 4.8,
    ),
  ];

  static const List<Hotel> mockHotels = [
    Hotel(
      id: 'h1',
      name: 'فندق برج العرب',
      location: 'دبي، الإمارات',
      imageUrl:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=500&q=80',
      rating: 5.0,
      pricePerNight: 4500.0,
      amenities: ['مسبح', 'سبا', 'واي فاي', 'إطلالة بحرية'],
      description:
          'غرفتنا العلوية بإطلالة بانورامية على الخليج، وإفطار شامل في مطعم الطابق 32. احجز الآن واحصل على خصم 20% على الإقامة 3 ليالٍ.',
      gallery: [
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&q=80',
      ],
    ),
    Hotel(
      id: 'h2',
      name: 'منتجع جزيرة السعديات',
      location: 'أبوظبي، الإمارات',
      imageUrl:
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=500&q=80',
      rating: 4.9,
      pricePerNight: 1200.0,
      amenities: ['شاطئ خاص', 'جيم', 'مطاعم فاخرة'],
      description:
          'منتجع على شاطئ خاص: مطبخ مفتوح طوال اليوم، وخدمة غرف حتى المساء. مناسب للعائلات وعلى خطوات من المارينا.',
      gallery: [
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80',
      ],
    ),
    Hotel(
      id: 'h3',
      name: 'فندق قصر الإمارات',
      location: 'أبوظبي، الإمارات',
      imageUrl:
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=500&q=80',
      rating: 5.0,
      pricePerNight: 2800.0,
      amenities: ['خدمة غرف', 'مواقف مجانية', 'حدائق'],
      description:
          'قصر على طراز معماري كلاسيكي يطل على الحديقة الخلفية، مع قاعة اجتماعات مثالية للمناسبات. موقف مجاني وسيارة كهربائية للنزلاء.',
      gallery: [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&q=80',
      ],
    ),
    Hotel(
      id: 'h4',
      name: 'منتجع واحة الصحراء',
      location: 'الرياض، السعودية',
      imageUrl:
          'https://images.unsplash.com/photo-1584132915807-fd1f5fbc078f?w=500&q=80',
      rating: 4.7,
      pricePerNight: 900.0,
      amenities: ['safari صحراوي', 'مطعم بدوي', 'تأجير خيول'],
      description:
          'خيمة فاخرة وسط الكثبان مع عشاء بدوي أصيل ورحلات صحراوية عند الغروب. تجربة هادئة بعيداً عن ضجيج المدينة.',
      gallery: [
        'https://images.unsplash.com/photo-1584132915807-fd1f5fbc078f?w=800&q=80',
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80',
        'https://images.unsplash.com/photo-1517821362941-f7f7536a4a0b?w=800&q=80',
      ],
    ),
  ];

  static const List<TravelDestination> mockTravelDestinations = [
    TravelDestination(
      id: 't1',
      title: 'رحلة سفاري صحراوية',
      country: 'الإمارات',
      imageUrl:
          'https://images.unsplash.com/photo-1542314831-c6a4d14d8376?w=500&q=80',
      description: 'تجربة القيادة على الكثبان الرملية وعشاء تقليدي تحت النجوم.',
      price: 250.0,
      duration: 'يوم كامل',
      tripType: 'جولة صحراوية',
      rating: 4.9,
      highlights: ['عشاء بدوي', 'جولات مراكب', 'تصوير احترافي'],
      gallery: [
        'https://images.unsplash.com/photo-1542314831-c6a4d14d8376?w=800&q=80',
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80',
        'https://images.unsplash.com/photo-1517821362941-f7f7536a4a0b?w=800&q=80',
      ],
    ),
    TravelDestination(
      id: 't2',
      title: 'جولة في جبال حتا',
      country: 'دبي',
      imageUrl:
          'https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=500&q=80',
      description: 'استكشف الجبال الخلابة والبحيرات الزرقاء.',
      price: 150.0,
      duration: '5 ساعات',
      tripType: 'جولة يومية',
      rating: 4.6,
      highlights: ['مرشد محلي', 'نقل شامل', 'تأمين مشمول'],
      gallery: [
        'https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=800&q=80',
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&q=80',
        'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&q=80',
      ],
    ),
    TravelDestination(
      id: 't3',
      title: 'جولة جزيرة النخلة بالهليكوبتر',
      country: 'دبي',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=500&q=80',
      description: 'شاهد معالم دبي المذهلة من السماء.',
      price: 850.0,
      duration: '30 دقيقة',
      tripType: 'جولة جوية',
      rating: 4.9,
      highlights: ['تذكرة هليكوبتر', 'مرشد عربي', 'تصوير بانورامي'],
      gallery: [
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',
        'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&q=80',
        'https://images.unsplash.com/photo-1512100356356-de1b84283e18?w=800&q=80',
      ],
    ),
    TravelDestination(
      id: 't4',
      title: 'رحلة إلى وادي رم',
      country: 'عمّان، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=500&q=80',
      description:
          'ثلاثة أيام بين وادي رم وبيترا والجبل الأحمر، مع إقامة في خيم مميزة ومرشد بدوي طوال الرحلة.',
      price: 620.0,
      duration: '3 أيام',
      tripType: 'رحلة منظمة',
      rating: 4.8,
      highlights: ['إقامة شاملة', 'مرشد بدوي', 'جولة دفع رباعي'],
      gallery: [
        'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=800&q=80',
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80',
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&q=80',
      ],
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
      case 'film':
        return LucideIcons.film;
      case 'wallet':
        return LucideIcons.wallet;
      case 'map':
        return LucideIcons.map;
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
