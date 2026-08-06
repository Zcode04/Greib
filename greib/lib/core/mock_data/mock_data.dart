import 'package:flutter/material.dart';

// ==================== نماذج البيانات (Models) ====================

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // admin / agent / user
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

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.color,
    required this.route,
  });
}

class Order {
  final String id;
  final String userId;
  final String serviceType;
  final String status; // pending / assigned / in_transit / delivered / cancelled
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
  final String type; // direct / group
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

// ==================== ملف تعريف المستخدم ====================

class AppUserProfile {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;
  final String? address;
  final String? avatarUrl;

  const AppUserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.address,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
        'email': email,
        'address': address,
        'avatarUrl': avatarUrl,
      };

  factory AppUserProfile.fromJson(Map<String, dynamic> json) => AppUserProfile(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
        avatarUrl: json['avatarUrl'],
      );
}

// ==================== البيانات الوهمية (Mock Data) ====================

class MockData {
  // حسابات تجريبية
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
    ),
    AppUserProfile(
      id: 'a1',
      name: 'خالد العمري',
      role: 'agent',
      phone: '+971502345678',
      email: 'agent@greib.com',
      address: 'دبي، القصيص',
    ),
    AppUserProfile(
      id: 'adm1',
      name: 'سالم راشد',
      role: 'admin',
      phone: '+971503456789',
      email: 'admin@greib.com',
      address: 'أبوظبي، مدينة خليفة',
    ),
  ];

  // الطلبات الوهمية
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

  // محادثات وهمية
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

  // الإشعارات الوهمية
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

  static List<ServiceCategory> get services => [
        ServiceCategory(
          id: 'food',
          title: 'توصيل طعام',
          subtitle: 'من مطعمك المفضل',
          iconName: 'utensils',
          color: const Color(0xFFFF9800),
          route: '/food',
        ),
        ServiceCategory(
          id: 'pharmacy',
          title: 'الصيدلية',
          subtitle: 'أدوية ووصفات',
          iconName: 'pills',
          color: const Color(0xFF4CAF50),
          route: '/pharmacy',
        ),
        ServiceCategory(
          id: 'courier',
          title: 'نقل طرود',
          subtitle: 'توصيل سريع',
          iconName: 'package',
          color: const Color(0xFF2196F3),
          route: '/courier',
        ),
        ServiceCategory(
          id: 'ride',
          title: 'المواصلات',
          subtitle: 'تنقل براحة',
          iconName: 'car',
          color: const Color(0xFF9C27B0),
          route: '/ride',
        ),
        ServiceCategory(
          id: 'shopping',
          title: 'تسوق ومقاضي',
          subtitle: 'كل احتياجاتك',
          iconName: 'shopping-cart',
          color: const Color(0xFFE91E63),
          route: '/shopping',
        ),
        ServiceCategory(
          id: 'tourism',
          title: 'سياحة وفعاليات',
          subtitle: 'استكشف المكان',
          iconName: 'palmtree',
          color: const Color(0xFF00BCD4),
          route: '/tourism',
        ),
      ];

  // دالة لإرجاع أيقونة من اسم
  static IconData getIconByName(String name) {
    switch (name) {
      case 'utensils':
        return Icons.restaurant;
      case 'pills':
        return Icons.medical_services;
      case 'package':
        return Icons.inventory_2;
      case 'car':
        return Icons.local_taxi;
      case 'shopping-cart':
        return Icons.shopping_cart;
      case 'palmtree':
        return Icons.park;
      case 'chat':
        return Icons.chat_bubble;
      case 'home':
        return Icons.home;
      case 'profile':
        return Icons.person;
      case 'shield':
        return Icons.shield;
      case 'users':
        return Icons.group;
      case 'bell':
        return Icons.notifications;
      case 'settings':
        return Icons.settings;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.circle;
    }
  }
}