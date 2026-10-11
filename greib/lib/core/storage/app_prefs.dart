import 'dart:convert';

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

  // ------------------------- الخرائط الحقيقية -------------------------
  /// ★ الافتراضي = الكرة الأرضية 3D الأصلية (useRealMaps = false).
  /// الخريطة الحقيقية لا تظهر إلا إذا اختارها المستخدم من «نمط الخريطة».
  static bool get useRealMaps =>
      _prefs?.getBool(AppConstants.keyUseRealMaps) ?? false;

  static Future<void> setUseRealMaps(bool value) async {
    await _prefs?.setBool(AppConstants.keyUseRealMaps, value);
  }

  // ----------------------- نمط الخريطة (0=عادي, 1=داكن, 2=أقمار) -----------------------
  /// يُحفظ كـ int حتى يعمل بشكل مستقل عن وضع التطبيق الداكن.
  static int get mapStyleIndex =>
      _prefs?.getInt(AppConstants.keyMapStyle) ?? 0;

  static Future<void> setMapStyleIndex(int value) async {
    await _prefs?.setInt(AppConstants.keyMapStyle, value);
  }

  // -------------------- لوحة الألوان المخصّصة (تحكم في الألوان) --------------------
  /// ★ تخصيصات المستخدم محفوظة كخريطة: مفتاح الحقل (مثل `background.primary`)
  ///   ← قيمة ARGB. فارغة = لا تخصيص (اللوحة الافتراضية).

  static String _paletteKeyFor(bool isDark) => isDark
      ? AppConstants.keyColorPaletteDark
      : AppConstants.keyColorPaletteLight;

  /// كل التخصيصات المحفوظة لوضع معيّن (فارغة = لا تخصيص).
  static Map<String, int> paletteOverrides({required bool isDark}) {
    final raw = _prefs?.getString(_paletteKeyFor(isDark));
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return const {};
    }
  }

  /// حفظ/تحديث لون حقل واحد (يُستعاد تلقائياً عند إعادة التشغيل).
  static Future<void> setPaletteOverride(
    String field,
    int argb, {
    required bool isDark,
  }) async {
    final map = Map<String, int>.from(paletteOverrides(isDark: isDark));
    map[field] = argb;
    await _prefs?.setString(_paletteKeyFor(isDark), jsonEncode(map));
  }

  /// حذف كل تخصيصات الوضع (العودة للوحة الافتراضية).
  static Future<void> clearPaletteOverrides({required bool isDark}) async {
    await _prefs?.remove(_paletteKeyFor(isDark));
  }
}
