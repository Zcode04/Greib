import 'package:flutter/material.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/models/user_model.dart';
import '../../core/permissions/permissions.dart';

/// كلمة المرور الموحّدة للحسابات التجريبية (Mock) — تُعرض كتلميح في شاشة الدخول.
const String demoPassword = '123456';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  UserAccount? _currentUser;
  UserRole? _currentRole;

  UserAccount? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;
  bool get isLoggedIn => _currentUser != null;

  /// تسجيل دخول تجريبي مُتحقَّق منه:
  /// يقبل البريد أو رقم الهاتف لحساب من الحسابات التجريبية + كلمة المرور الثابتة.
  Future<bool> login(String emailOrPhone, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final id = emailOrPhone.trim().toLowerCase();
    final matches = MockData.demoAccounts.where(
      (acc) =>
          acc.email.toLowerCase() == id ||
          acc.phone == id ||
          acc.phone.replaceFirst('+971', '0') == id,
    );
    if (matches.isEmpty || password != demoPassword) return false;

    _currentUser = matches.first;
    _currentRole = PermissionService.roleFromString(matches.first.role);
    notifyListeners();
    return true;
  }

  Future<UserAccount> quickLogin(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final roleStr = PermissionService.roleToString(role);
    final account = MockData.demoAccounts.firstWhere(
      (acc) => acc.role == roleStr,
    );
    _currentUser = account;
    _currentRole = role;
    notifyListeners();
    return account;
  }

  /// دخول كضيف: تصفّح التطبيق بصلاحيات مستخدم عادي دون إنشاء حساب.
  Future<void> continueAsGuest() => quickLogin(UserRole.user);

  void logout() {
    _currentUser = null;
    _currentRole = null;
    notifyListeners();
  }
}
