import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// ============================================================================
///  AppPrefs — التخزين المحلي للتفضيلات (الحالة الدائمة للتطبيق).
///
///  يُهيّأ مرة واحدة في main() قبل runApp:
///      WidgetsFlutterBinding.ensureInitialized();
///      await AppPrefs.init();
///
///  بعد التهيئة يصبح كل الوصول متزامناً (sync) فلا نحتاج شاشات انتظار إضافية.
/// ============================================================================
class AppPrefs {
  AppPrefs._();

  static SharedPreferences? _prefs;
  static bool _isReady = false;

  static bool get isReady => _isReady;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isReady = true;
  }

  static bool _getBool(String key, {required bool fallback}) =>
      _prefs?.getBool(key) ?? fallback;

  static Future<void> _setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // ------------------------------ الوضع الليلي ------------------------------
  /// الوضع الداكن هو الافتراضي (هوية Deep Space) حتى يغيّره المستخدم.
  static bool get isDarkMode =>
      _getBool(AppConstants.keyThemeMode, fallback: true);

  static Future<void> setDarkMode(bool value) =>
      _setBool(AppConstants.keyThemeMode, value);

  // --------------------------- شاشة التعريف (Onboarding) ---------------------------
  static bool get seenOnboarding =>
      _getBool(AppConstants.keyIsFirstTime, fallback: false);

  static Future<void> setSeenOnboarding(bool value) =>
      _setBool(AppConstants.keyIsFirstTime, value);

  // ------------------------- آخر تبويب كان مفتوحاً -------------------------
  /// 2 = تبويب «الرئيسية» في FloatingBottomNav.
  static int get lastTabIndex => _prefs?.getInt(AppConstants.keyLastTab) ?? 2;

  static Future<void> setLastTabIndex(int value) async {
    await _prefs?.setInt(AppConstants.keyLastTab, value);
  }
}
