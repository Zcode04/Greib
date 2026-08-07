import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared_widgets/app_button.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  UserAccount? _currentUser;
  UserRole? _currentRole;

  UserAccount? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final account = MockData.demoAccounts.firstWhere(
      (acc) => acc.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('حساب غير موجود'),
    );

    if (password != '123456') {
      throw Exception('كلمة المرور غير صحيحة');
    }

    _currentUser = account;
    _currentRole = PermissionService.roleFromString(account.role);
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

  void logout() {
    _currentUser = null;
    _currentRole = null;
    notifyListeners();
  }
}

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
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [AppColors.lightBackground, AppColors.lightSurface],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language toggle
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton.icon(
                    onPressed: () => langProvider.toggleLanguage(),
                    icon: const Icon(LucideIcons.languages, size: 18),
                    label: Text(loc.get('language')),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // شعار التطبيق
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withValues(alpha: 0.3),
                        AppColors.accentPrimary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.xxl),
                    border: Border.all(
                      color: AppColors.accentPrimary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: AppShadows.glowGreen,
                  ),
                  child: const Icon(
                    LucideIcons.rocket,
                    size: 48,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  loc.get('app_name'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  loc.get('tagline'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: loc.get('email'),
                    prefixIcon: const Icon(LucideIcons.mail),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: loc.get('password'),
                    prefixIcon: const Icon(LucideIcons.lock),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                AppButton(
                  label: loc.get('login'),
                  icon: LucideIcons.logIn,
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'تسجيل دخول سريع',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                AppButton(
                  label: 'دخول كمستخدم',
                  icon: LucideIcons.user,
                  color: AppColors.success,
                  onPressed: _isLoading ? null : () => _quickLogin('user'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'دخول كموظف',
                  icon: LucideIcons.bike,
                  color: AppColors.info,
                  onPressed: _isLoading ? null : () => _quickLogin('agent'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'دخول كمشرف',
                  icon: LucideIcons.shield,
                  color: AppColors.error,
                  onPressed: _isLoading ? null : () => _quickLogin('admin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
