import 'package:flutter/material.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../shared_widgets/app_button.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  UserAccount? _currentUser;
  UserRole? _currentRole;

  UserAccount? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;
  bool get isLoggedIn => _currentUser != null;

  // تسجيل الدخول بالحسابات التجريبية
  Future<bool> login(String email, String password) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(seconds: 1));

    // حسابات تجريبية ثابتة
    final account = MockData.demoAccounts.firstWhere(
      (acc) => acc.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('حساب غير موجود'),
    );

    // في النموذج الأولي، كل كلمة مرور صحيحة (مثال: "123456")
    if (password != '123456') {
      throw Exception('كلمة المرور غير صحيحة');
    }

    _currentUser = account;
    _currentRole = PermissionService.roleFromString(account.role);
    notifyListeners();
    return true;
  }

  // تسجيل الدخول السريع بدور محدد (لأغراض العرض)
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

  // تسجيل الخروج
  void logout() {
    _currentUser = null;
    _currentRole = null;
    notifyListeners();
  }
}

// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _quickLogin(String role) async {
    final roleEnum = PermissionService.roleFromString(role);
    if (roleEnum == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.quickLogin(roleEnum);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // شعار التطبيق
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.rocket_launch,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'گريب منك',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'كل خدماتك في مكان واحد',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // حقل كلمة المرور
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 8),

              // رسالة خطأ
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // زر تسجيل الدخول
              AppButton(
                label: 'تسجيل الدخول',
                icon: Icons.login,
                onPressed: _isLoading ? null : _handleLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // قسم تسجيل الدخول السريع
              Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'تسجيل دخول سريع',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.outline)),
                ],
              ),
              const SizedBox(height: 16),

              // حسابات تجريبية
              AppButton(
                label: 'دخول كمستخدم',
                icon: Icons.person,
                color: Colors.green,
                onPressed: _isLoading ? null : () => _quickLogin('user'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'دخول كموظف',
                icon: Icons.delivery_dining,
                color: Colors.blue,
                onPressed: _isLoading ? null : () => _quickLogin('agent'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'دخول كمشرف',
                icon: Icons.shield,
                color: Colors.red,
                onPressed: _isLoading ? null : () => _quickLogin('admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}