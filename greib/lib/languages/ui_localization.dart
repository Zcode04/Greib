// Central UI Localization File — نصوص الواجهة الثابتة.
// للتوسعة: أضف خريطة لغة جديدة بنفس المفاتيح وسجلها في _values.
class AppSupportedLocales {
  static const String arabic = 'ar';
  static const String english = 'en';
  static const List<String> values = [arabic, english];
  static const String fallback = arabic;
}

abstract class UiKeys {
  static const String tabHome = 'tabHome';
  static const String tabWallet = 'tabWallet';
  static const String tabChat = 'tabChat';
  static const String tabLocation = 'tabLocation';
  static const String tabReels = 'tabReels';
  static const String titleHome = 'titleHome';
  static const String titleWallet = 'titleWallet';
  static const String titleChat = 'titleChat';
  static const String titleLocation = 'titleLocation';
  static const String titleReels = 'titleReels';
  static const String sectionTrending = 'sectionTrending';
  static const String sectionFeatured = 'sectionFeatured';
  static const String sectionServices = 'sectionServices';
  static const String sectionLatest = 'sectionLatest';
  static const String sectionNearby = 'sectionNearby';
  static const String appName = 'appName';
  static const String searchHint = 'searchHint';
  static const String seeAll = 'seeAll';
  static const String retry = 'retry';
  static const String cancel = 'cancel';
  static const String confirm = 'confirm';
  static const String save = 'save';
  static const String back = 'back';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String logout = 'logout';
  static const String email = 'email';
  static const String password = 'password';
  static const String phone = 'phone';
  static const String fullName = 'fullName';
  static const String forgotPassword = 'forgotPassword';
  static const String createAccount = 'createAccount';
  static const String haveAccount = 'haveAccount';
  static const String noAccount = 'noAccount';
  static const String continueAsGuest = 'continueAsGuest';
  static const String welcomeBack = 'welcomeBack';
}

class AppUiStrings {
  static const List<String> supportedLocales = AppSupportedLocales.values;

  static const Map<String, String> ar = {
    UiKeys.tabHome: 'الرئيسية',
    UiKeys.tabWallet: 'المحفظة',
    UiKeys.tabChat: 'الدردشة',
    UiKeys.tabLocation: 'موقعي',
    UiKeys.tabReels: 'الريلز',
    UiKeys.titleHome: 'الرئيسية',
    UiKeys.titleWallet: 'المحفظة الرقمية',
    UiKeys.titleChat: 'الدردشة والرسائل',
    UiKeys.titleLocation: 'موقعي',
    UiKeys.titleReels: 'الريلز',
    UiKeys.sectionTrending: 'الرائج',
    UiKeys.sectionFeatured: 'المميز',
    UiKeys.sectionServices: 'الخدمات',
    UiKeys.sectionLatest: 'الأحدث',
    UiKeys.sectionNearby: 'الأقرب إليك',
    UiKeys.appName: 'گريب منك',
    UiKeys.searchHint: 'ابحث عن خدمة، متجر، منتج...',
    UiKeys.seeAll: 'عرض الكل',
    UiKeys.retry: 'إعادة المحاولة',
    UiKeys.cancel: 'إلغاء',
    UiKeys.confirm: 'تأكيد',
    UiKeys.save: 'حفظ',
    UiKeys.back: 'رجوع',
    UiKeys.login: 'تسجيل الدخول',
    UiKeys.signup: 'إنشاء حساب',
    UiKeys.logout: 'تسجيل الخروج',
    UiKeys.email: 'البريد الإلكتروني',
    UiKeys.password: 'كلمة المرور',
    UiKeys.phone: 'رقم الهاتف',
    UiKeys.fullName: 'الاسم الكامل',
    UiKeys.forgotPassword: 'نسيت كلمة المرور؟',
    UiKeys.createAccount: 'إنشاء حساب جديد',
    UiKeys.haveAccount: 'لديك حساب بالفعل؟',
    UiKeys.noAccount: 'ليس لديك حساب؟',
    UiKeys.continueAsGuest: 'المتابعة كضيف',
    UiKeys.welcomeBack: 'مرحباً بعودتك',
  };

  static const Map<String, String> en = {
    UiKeys.tabHome: 'Home',
    UiKeys.tabWallet: 'Wallet',
    UiKeys.tabChat: 'Chat',
    UiKeys.tabLocation: 'My Location',
    UiKeys.tabReels: 'Reels',
    UiKeys.titleHome: 'Home',
    UiKeys.titleWallet: 'Digital Wallet',
    UiKeys.titleChat: 'Chat & Messages',
    UiKeys.titleLocation: 'My Location',
    UiKeys.titleReels: 'Reels',
    UiKeys.sectionTrending: 'Trending',
    UiKeys.sectionFeatured: 'Featured',
    UiKeys.sectionServices: 'Services',
    UiKeys.sectionLatest: 'Latest',
    UiKeys.sectionNearby: 'Near You',
    UiKeys.appName: 'Greib Menk',
    UiKeys.searchHint: 'Search services, stores, products...',
    UiKeys.seeAll: 'See all',
    UiKeys.retry: 'Retry',
    UiKeys.cancel: 'Cancel',
    UiKeys.confirm: 'Confirm',
    UiKeys.save: 'Save',
    UiKeys.back: 'Back',
    UiKeys.login: 'Login',
    UiKeys.signup: 'Sign Up',
    UiKeys.logout: 'Logout',
    UiKeys.email: 'Email',
    UiKeys.password: 'Password',
    UiKeys.phone: 'Phone Number',
    UiKeys.fullName: 'Full Name',
    UiKeys.forgotPassword: 'Forgot password?',
    UiKeys.createAccount: 'Create New Account',
    UiKeys.haveAccount: 'Already have an account?',
    UiKeys.noAccount: "Don't have an account?",
    UiKeys.continueAsGuest: 'Continue as Guest',
    UiKeys.welcomeBack: 'Welcome back',
  };

  static const Map<String, Map<String, String>> _values = {
    AppSupportedLocales.arabic: ar,
    AppSupportedLocales.english: en,
  };

  static String get(String key, [String locale = AppSupportedLocales.fallback]) {
    final table = _values[locale] ?? _values[AppSupportedLocales.fallback]!;
    return table[key] ?? _values[AppSupportedLocales.fallback]![key] ?? key;
  }

  static bool isSupported(String locale) => _values.containsKey(locale);
}
