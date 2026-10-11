import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import 'auth_service.dart';

// ==========================================
// 1. ثيمات الألوان العالمية للبدائل البصرية
// ==========================================
enum AppThemeStyle { iceBlueGray, careemEmerald, midnightObsidian, royalIndigo }

class AppPalette {
  final Color primary;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color cardLight;
  final Color cardDark;
  final Color textPrimary;

  const AppPalette({
    required this.primary,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.cardLight,
    required this.cardDark,
    required this.textPrimary,
  });

  /// ★ الهوية الرسمية للتطبيق: خلفية Slate 900 + لون رسمي Sapphire #3B82F6
  /// ★ القيم مأخوذة من النظام المركزي (AppColors ← AppColorPalette) — بلا ألوان صلبة.
  static const iceBlueGray = AppPalette(
    primary: AppColors.accentPrimary, // ★ Sapphire — اللون الرسمي
    backgroundLight: AppColors.lightBackground, // slate-100
    backgroundDark: AppColors.backgroundPrimary, // ★ slate-900 — خلفية التطبيق الرسمية
    cardLight: AppColors.lightSurface,
    cardDark: AppColors.surfaceCard, // slate-800
    textPrimary: AppColors.lightText, // slate-900
  );

  // ★ كل الخيارات تستخدم نفس الهوية: خلفية Slate 900 + لون واحد Sapphire
  static const careemEmerald = AppPalette(
    primary: AppColors.accentPrimary,
    backgroundLight: AppColors.lightBackground,
    backgroundDark: AppColors.backgroundPrimary,
    cardLight: AppColors.lightSurface,
    cardDark: AppColors.surfaceCard,
    textPrimary: AppColors.lightText,
  );

  static const midnightObsidian = AppPalette(
    primary: AppColors.accentPrimary,
    backgroundLight: AppColors.lightBackground,
    backgroundDark: AppColors.backgroundPrimary,
    cardLight: AppColors.lightSurface,
    cardDark: AppColors.surfaceCard,
    textPrimary: AppColors.lightText,
  );

  static const royalIndigo = AppPalette(
    primary: AppColors.accentPrimary,
    backgroundLight: AppColors.lightBackground,
    backgroundDark: AppColors.backgroundPrimary,
    cardLight: AppColors.lightSurface,
    cardDark: AppColors.surfaceCard,
    textPrimary: AppColors.lightText,
  );

  /// المحتوى (نص/أيقونة) فوق اللون الأساسي — داكن إذا كان اللون فاتحاً.
  Color get onPrimary => primary.computeLuminance() > 0.5
      ? AppColors.lightText
      : AppColors.onAccentPrimary;

  /// اللون الأساسي بدرجة تُقرأ على الخلفية الفاتحة (للنصوص والأيقونات).
  Color get primaryOnLight => primary.computeLuminance() > 0.5
      ? HSLColor.fromColor(primary).withLightness(0.36).toColor()
      : primary;

  /// اللون الأساسي للنص/الأيقونة حسب الوضع الحالي (داكن في الوضع النهاري).
  Color primaryForeground(bool isDark) => isDark ? primary : primaryOnLight;
}

// ==========================================
// 2. الشاشة الرئيسية لتسجيل الدخول
// ==========================================
enum AuthTab { login, signup }

class LoginScreen extends StatefulWidget {
  final AppThemeStyle currentThemeStyle;

  const LoginScreen({
    super.key,
    this.currentThemeStyle =
        AppThemeStyle.iceBlueGray, // ★ الهوية الرسمية (slate-900 + #3B82F6)
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthTab _activeTab = AuthTab.login;
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _fail(String message) {
    setState(() => _errorMessage = message);
  }

  Future<void> _submit() async {
    final id = _emailPhoneController.text.trim();
    if (id.isEmpty) {
      _fail(
        _activeTab == AuthTab.login
            ? 'أدخل البريد أو رقم الهاتف'
            : 'أدخل رقم الهاتف',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1)); // محاكاة الاتصال
    if (!mounted) return;
    setState(() => _isLoading = false);

    // توجيه التطبيق حسب النجاح
    context.go('/home');
  }

  Future<void> _continueAsGuest() async {
    await AuthService.instance.continueAsGuest();
    if (!mounted) return;
    context.go('/home');
  }

  void _joinAsAgent() {
    context.push('/agent-register');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ★ كل الألوان من اللوحة المركزية (Color Palette) عبر السياق.
    final bgColor = context.backgroundColors.primary;
    final cardColor = context.backgroundColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. زر تخطي الفاخر في الأعلى (RTL Support)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // لموازنة الهيدر
                    // الشعار في المنتصف بأسلوب مينيمل
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.iconColors.primary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        LucideIcons.navigation,
                        color: context.iconColors.primary,
                        size: 24,
                      ),
                    ),
                    // زر التخطي
                    TextButton(
                      onPressed: _isLoading ? null : _continueAsGuest,
                      style: TextButton.styleFrom(
                        foregroundColor: context.textColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'تخطي',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(LucideIcons.arrowLeft, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // النصوص الرئيسية
                Text(
                  _activeTab == AuthTab.login
                      ? 'مرحباً بك مجدداً 👋'
                      : 'إنشاء حساب جديد 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: context.textColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'انطلق معنا واستمتع بأسهل تجربة تنقل وخدمات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textColors.secondary,
                  ),
                ),

                const SizedBox(height: 28),

                // 2. التبويبات المدمجة الذكية (Segmented Control Slider)
                _buildModernTabSegment(isDark, cardColor),

                const SizedBox(height: 24),

                // تنبيه الأخطاء
                if (_errorMessage != null) ...[
                  _buildErrorBanner(_errorMessage!),
                  const SizedBox(height: 16),
                ],

                // 3. حقول الإدخال المحسّنة
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(_activeTab),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_activeTab == AuthTab.signup) ...[
                        _buildInputField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          hint: 'أدخل اسمك كما في الهوية',
                          icon: LucideIcons.user,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                        const SizedBox(height: 14),
                      ],

                      _buildInputField(
                        controller: _emailPhoneController,
                        label: _activeTab == AuthTab.login
                            ? 'البريد أو رقم الهاتف'
                            : 'رقم الهاتف',
                        hint: _activeTab == AuthTab.login
                            ? 'name@example.com أو 05x...'
                            : '05xxxxxxxx',
                        icon: LucideIcons.phone,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        cardColor: cardColor,
                      ),

                      if (_activeTab == AuthTab.login) ...[
                        const SizedBox(height: 14),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          hint: '••••••••',
                          icon: LucideIcons.lock,
                          isPassword: true,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: context.iconColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // زر الإجراء الرئيسي (Main CTA Button)
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accentColor,
                      foregroundColor: context.textColors.onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: context.textColors.onAccent,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _activeTab == AuthTab.login
                                ? 'تسجيل الدخول'
                                : 'متابعة',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // خيارات تسجيل الدخول الاجتماعي عبر SVG
                _buildSocialLoginSection(isDark),

                const SizedBox(height: 28),

                // 4. كارت الانضمام كـ وكيل (شريك/كابتن) المميز
                _buildAgentJoinCard(isDark),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. الودجات الفرعية والتصميم المحسّن
  // ==========================================

  // تبويب محاكي لتصميم أبل وكريم مع حركة التبديل
  Widget _buildModernTabSegment(bool isDark, Color cardColor) {
    final isLogin = _activeTab == AuthTab.login;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.backgroundColors.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [
          // المؤشر المتحرك الأبيض/الداكن
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment: isLogin ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // نصوص التبويبات
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _activeTab = AuthTab.login),
                  child: Center(
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontWeight: isLogin ? FontWeight.bold : FontWeight.w500,
                        color: isLogin
                            ? context.textColors.primary
                            : context.textColors.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _activeTab = AuthTab.signup),
                  child: Center(
                    child: Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontWeight: !isLogin
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: !isLogin
                            ? context.textColors.primary
                            : context.textColors.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // حقل إدخال عصري
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    required bool isDark,
    required Color cardColor,
  }) {
    // ★ ألوان الحقول من اللوحة المركزية (Color Palette) — لا ألوان صلبة.
    final fillColor = context.backgroundColors.surfaceElevated;
    final borderIdle = context.backgroundColors.outline;
    final labelColor = context.textColors.secondary;
    final textColor = context.textColors.primary;
    final hintColor = context.textColors.tertiary;
    final iconColor = context.iconColors.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: labelColor,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 52),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                      color: iconColor,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 17,
            ),
            // حدود عادية (idle)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50), // pill كامل
              borderSide: BorderSide(color: borderIdle, width: 1.2),
            ),
            // حدود عند التركيز
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: context.iconColors.primary, width: 1.8),
            ),
            // حدود بدون تركيز (لا خط)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // خيارات التسجيل بـ Google و Apple بملفات SVG حقيقية
  Widget _buildSocialLoginSection(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: context.backgroundColors.outline),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'أو الدخول بواسطة',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textColors.tertiary,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: context.backgroundColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                label: 'Google',
                svgIcon: _googleSvg,
                isDark: isDark,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                label: 'Apple',
                svgIcon: _appleSvg,
                isDark: isDark,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String svgIcon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.backgroundColors.surface,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: context.backgroundColors.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(svgIcon, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.textColors.primary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. كارت الانضمام كـ وكيل (شريك / كابتن)
  Widget _buildAgentJoinCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.iconColors.primary.withValues(alpha: 0.12),
            context.iconColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: context.iconColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _joinAsAgent,
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.briefcase,
                    color: context.textColors.onAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'انضم إلينا كـ وكيل / كابتن 🚗',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.textColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'سجّل كشريك لتقديم الخدمات وزيادة دخلك',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronLeft,
                  color: context.iconColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. رموز SVG حقيقية للأيقونات (Google & Apple)
// ==========================================
const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8c-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C12.955 4 4 12.955 4 24s8.955 20 20 20s20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>
  <path fill="#FF3D00" d="m6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C16.318 4 9.656 8.337 6.306 14.691z"/>
  <path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238A11.91 11.91 0 0 1 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/>
  <path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303a12.04 12.04 0 0 1-4.087 5.571l.003-.002l6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"/>
</svg>
''';

const String _appleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 170 170">
  <path fill="currentColor" d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66c-4.58 6.53-8.33 11.05-11.22 13.56c-4.48 4.12-9.28 6.23-14.42 6.35c-3.69 0-8.14-1.05-13.32-3.18c-5.19-2.12-9.97-3.17-14.34-3.17c-4.58 0-9.49 1.05-14.75 3.17c-5.26 2.13-9.5 3.24-12.74 3.35c-4.33.13-9.13-1.9-14.4-6.08c-3.35-2.64-7.25-7.3-11.71-13.98c-6.8-10.19-12.12-21.78-15.96-34.78c-3.84-13-5.76-25.26-5.76-36.78c0-15.11 3.84-27.7 11.53-37.77c7.69-10.07 17.5-15.18 29.43-15.32c4.8 0 10.13 1.23 15.99 3.69c5.86 2.46 9.87 3.69 12.03 3.69c1.84 0 6.01-1.3 12.51-3.91c6.5-2.61 12.07-3.79 16.71-3.55c12.39.85 22.37 5.37 29.94 13.56c-10.83 6.56-16.14 15.75-15.93 27.57c.21 9.24 3.84 17.07 10.89 23.49c7.05 6.42 15.54 10.03 25.47 10.83c-2.47 7.28-5.71 14.88-9.73 22.82zm-30.82-108.41c0 6.94-2.58 13.78-7.74 20.52c-5.16 6.74-11.7 10.82-19.63 12.24c-.21-.99-.32-2.05-.32-3.18c0-6.8 2.68-13.67 8.04-20.61c5.36-6.94 12.04-11.08 20.04-12.42c.11.85.16 1.83.16 2.95z"/>
</svg>
''';

