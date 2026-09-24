import 'package:flutter/material.dart';

import '../storage/app_prefs.dart';

// متحكم الوضع الليلي والنهاري - الداكن هو الافتراضي (Dark as Default)
// ويُحفظ اختيار المستخدم محلياً عبر AppPrefs فلا يُفقد بعد إعادة التشغيل.
class ThemeController extends ChangeNotifier {
  bool _isDarkMode = AppPrefs.isDarkMode;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() => setDarkMode(!_isDarkMode);

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    // حفظ التفضيل محلياً (لا ننتظر الكتابة حتى لا نُبطئ الواجهة).
    AppPrefs.setDarkMode(value);
  }
}