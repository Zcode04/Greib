// ============================================================================
//  UserData — ملف بيانات المستخدم المركزي (المصدر الوحيد للحقيقة).
//
//  يحفظ صورة البروفايل محلياً (SharedPreferences) فتبقى بعد الخروج والعودة،
//  ويُشعِر كل الواجهات فور التغيير (ChangeNotifier):
//    • صفحة الحساب (AccountTabsPage) تعرض وتحدّث.
//    • هيدر أي صفحة رئيسية (SuperHeader) يعرض المصغّرة.
//
//  ★ تطوير لاحق: استبدال الحفظ المحلي برفع Backend + تحديث نموذج المستخدم.
// ============================================================================
import 'package:flutter/material.dart';

import '../storage/app_prefs.dart';

class UserData extends ChangeNotifier {
  static final UserData instance = UserData._();
  UserData._();

  String? _avatarPath;

  /// هل اختار المستخدم صورة بروفايل مخصصة؟
  bool get hasCustomAvatar => _avatarPath != null && _avatarPath!.isNotEmpty;

  /// مسار صورة البروفايل المحلية (null = لا توجد مخصصة ⇒ الأفاتار الافتراضي).
  String? get avatarPath => _avatarPath;

  /// تحميل الصورة المحفوظة عند بدء التطبيق (يُستدعى من main بعد AppPrefs.init).
  void load() {
    _avatarPath = AppPrefs.avatarPath;
    notifyListeners();
  }

  /// حفظ صورة جديدة (من الكاميرا/المعرض) + إشعار كل الواجهات فوراً.
  Future<void> setAvatarPath(String path) async {
    _avatarPath = path;
    notifyListeners();
    await AppPrefs.setAvatarPath(path);
  }

  /// مسح الصورة المخصصة (العودة للأفاتار الافتراضي).
  Future<void> clearAvatar() async {
    _avatarPath = null;
    notifyListeners();
    await AppPrefs.clearAvatarPath();
  }
}
