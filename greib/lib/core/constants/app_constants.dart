class AppConstants {
  // URLs and Endpoints (Mock for now)
  static const String apiBaseUrl = 'https://api.greibmenk.ae/v1';
  static const String supportEmail = 'support@greibmenk.ae';
  static const String supportPhone = '+971800123456';

  // Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderAvatar = 'assets/images/placeholder_avatar.png';
  static const String placeholderImage = 'assets/images/placeholder_image.png';

  // Shared Preferences Keys
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyUserToken = 'user_token';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyLastTab = 'last_tab_index';
}
