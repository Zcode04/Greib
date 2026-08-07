import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'گريب منك',
      'tagline': 'كل خدماتك في مكان واحد',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'home': 'الرئيسية',
      'profile': 'البروفايل',
      'notifications': 'الإشعارات',
      'chat': 'المحادثات',
      'orders': 'الطلبات',
      'favorites': 'المفضلة',
      'order_history': 'طلباتي السابقة',
      'wallet': 'المحفظة',
      'loyalty_points': 'نقاط الولاء',
      'promo_code': 'كود الخصم',
      'reviews': 'التقييمات',
      'membership': 'العضوية',
      'support': 'الدعم',
      'tracking': 'التتبع',
      'apply': 'تطبيق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'search': 'بحث',
      'no_results': 'لا توجد نتائج',
      'loading': 'جارٍ التحميل...',
      'error': 'خطأ',
      'success': 'نجاح',
      'admin': 'مشرف',
      'agent': 'وكيل',
      'user': 'مستخدم',
      'welcome': 'أهلاً',
      'services': 'خدماتنا',
      'current_orders': 'طلباتك الحالية',
      'no_orders': 'لا توجد طلبات حالية',
      'quick_actions': 'صفحات سريعة',
      'food_delivery': 'توصيل طعام',
      'pharmacy': 'الصيدلية',
      'courier': 'نقل طرود',
      'ride': 'المواصلات',
      'shopping': 'تسوق ومقاضي',
      'tourism': 'سياحة وفعاليات',
      'track_order': 'تتبع الطلب',
      'add_review': 'إضافة تقييم',
      'your_rating': 'تقييمك',
      'write_comment': 'اكتب تعليقك...',
      'submit': 'إرسال',
      'promo_placeholder': 'أدخل كود الخصم',
      'invalid_code': 'كود خصم غير صالح',
      'points_earned': 'نقاط مكتسبة',
      'redeem': 'استبدال',
      'gold_member': 'عضوية ذهبية',
      'regular_member': 'عضوية عادية',
      'upgrade': 'ترقية',
      'support_ticket': 'تذكرة دعم',
      'open_tickets': 'تذاكر مفتوحة',
      'closed_tickets': 'تذاكر مغلقة',
      'create_ticket': 'إنشاء تذكرة',
      'ticket_subject': 'موضوع التذكرة',
      'ticket_description': 'وصف المشكلة',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
    },
    'en': {
      'app_name': 'Greib Menk',
      'tagline': 'All your services in one place',
      'login': 'Login',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'home': 'Home',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'chat': 'Chat',
      'orders': 'Orders',
      'favorites': 'Favorites',
      'order_history': 'Order History',
      'wallet': 'Wallet',
      'loyalty_points': 'Loyalty Points',
      'promo_code': 'Promo Code',
      'reviews': 'Reviews',
      'membership': 'Membership',
      'support': 'Support',
      'tracking': 'Tracking',
      'apply': 'Apply',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'search': 'Search',
      'no_results': 'No results',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'admin': 'Admin',
      'agent': 'Agent',
      'user': 'User',
      'welcome': 'Welcome',
      'services': 'Our Services',
      'current_orders': 'Your Current Orders',
      'no_orders': 'No current orders',
      'quick_actions': 'Quick Actions',
      'food_delivery': 'Food Delivery',
      'pharmacy': 'Pharmacy',
      'courier': 'Courier',
      'ride': 'Ride',
      'shopping': 'Shopping',
      'tourism': 'Tourism & Events',
      'track_order': 'Track Order',
      'add_review': 'Add Review',
      'your_rating': 'Your Rating',
      'write_comment': 'Write your comment...',
      'submit': 'Submit',
      'promo_placeholder': 'Enter promo code',
      'invalid_code': 'Invalid promo code',
      'points_earned': 'Points Earned',
      'redeem': 'Redeem',
      'gold_member': 'Gold Member',
      'regular_member': 'Regular Member',
      'upgrade': 'Upgrade',
      'support_ticket': 'Support Ticket',
      'open_tickets': 'Open Tickets',
      'closed_tickets': 'Closed Tickets',
      'create_ticket': 'Create Ticket',
      'ticket_subject': 'Ticket Subject',
      'ticket_description': 'Problem Description',
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language');
    if (lang != null) {
      _locale = Locale(lang);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLang = _locale.languageCode == 'ar' ? 'en' : 'ar';
    await setLanguage(newLang);
  }
}
