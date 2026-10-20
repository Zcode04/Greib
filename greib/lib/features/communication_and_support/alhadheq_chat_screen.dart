// features/communication_and_support/alhadheq_chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/design_tokens.dart';

/// نموذج رسالة دردشة الحاذق (AI)
class AlhadheqMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<AlhadheqAction>? actions;
  bool? isLiked;

  AlhadheqMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actions,
    this.isLiked,
  });
}

/// زر إجراء تفاعلي داخل رسالة الذكاء الاصطناعي
class AlhadheqAction {
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;

  AlhadheqAction({
    required this.label,
    required this.icon,
    this.route,
    this.onTap,
  });
}

/// شاشة المساعد الذكي «الحاذق» (دردشة مع الـ AI ببيانات تفاعلية ومحاكاة ذكية)
class AlhadheqChatScreen extends StatefulWidget {
  const AlhadheqChatScreen({super.key});

  @override
  State<AlhadheqChatScreen> createState() => _AlhadheqChatScreenState();
}

class _AlhadheqChatScreenState extends State<AlhadheqChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<AlhadheqMessage> _messages = [];
  bool _isTyping = false;
  late final AnimationController _pulseController;

  static const List<String> _quickSuggestions = [
    '🔍 اقترح لي أفضل المطاعم القريبة',
    '📦 كيف أتتبع طلبي الحالي؟',
    '💳 كيف أشحن محفظتي الرقمية؟',
    '💡 ما هي أقوى العروض والتخفيضات اليوم؟',
    '🛠️ كيف أحجز خدمة صيانة منزلية؟',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _initWelcomeMessages();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initWelcomeMessages() {
    _messages.add(
      AlhadheqMessage(
        id: 'welcome_1',
        text:
            'أهلاً بك! أنا «الحاذق» 🤖✨، المساعد الذكي في منصة گريب منك.\n'
            'أستطيع مساعدتك في العثور على أفضل المتاجر والخدمات، تتبع طلباتك، إدارة محفظتك، واقتراح أفضل الخيارات بالقرب منك.\n\n'
            'كيف يمكنني مساعدتك الآن؟',
        isUser: false,
        timestamp: DateTime.now(),
        actions: [
          AlhadheqAction(
            label: 'استكشاف الأقرب إليك',
            icon: LucideIcons.mapPin,
            route: '/my_location',
          ),
          AlhadheqAction(
            label: 'فتح المحفظة',
            icon: LucideIcons.wallet,
            route: '/profile?tab=wallet',
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = (customText ?? _textController.text).trim();
    if (text.isEmpty) return;

    if (customText == null) {
      _textController.clear();
    }

    final userMsg = AlhadheqMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    // محاكاة استجابة الذكاء الاصطناعي مع تأخير واقعي
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      final response = _generateMockAiResponse(text);
      setState(() {
        _isTyping = false;
        _messages.add(response);
      });
      _scrollToBottom();
    });
  }

  AlhadheqMessage _generateMockAiResponse(String query) {
    final lower = query.toLowerCase();
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();

    if (lower.contains('مطعم') ||
        lower.contains('مطاعم') ||
        lower.contains('أكل') ||
        lower.contains('طعام') ||
        lower.contains('كافيه')) {
      return AlhadheqMessage(
        id: id,
        text:
            'بناءً على موقعك الحالي، إليك أبرز الترشيحات الأكثر طلباً وتقييماً 🌟:\n\n'
            '1. **شاورما الريف الأصيل** - تقييم 4.9 ★ (على بُعد 800 متر)\n'
            '2. **برجر هاوس جورميه** - توصيل سريع خلال 20 دقيقة 🛵\n'
            '3. **كافيه أرابيكا الفاخر** - جلسات هادئة وقهوة مختصة ☕️\n\n'
            'هل تود تصفح القائمة الكاملة أو اختيار تصنيف آخر؟',
        isUser: false,
        timestamp: now,
        actions: [
          AlhadheqAction(
            label: 'استعراض الأماكن القريبة',
            icon: LucideIcons.compass,
            route: '/my_location',
          ),
          AlhadheqAction(
            label: 'البحث عن مطاعم',
            icon: LucideIcons.search,
            route: '/search',
          ),
        ],
      );
    }

    if (lower.contains('طلب') ||
        lower.contains('تتبع') ||
        lower.contains('أوردر')) {
      return AlhadheqMessage(
        id: id,
        text:
            'قمت بالتحقق من نظام الشحنات والطلبات 📦:\n\n'
            '• لديك طلب قيد التوصيل الآن رقم **#GM-8921**.\n'
            '• المندوب في طريقه إليك ويبعد حوالي **12 دقيقة**.\n\n'
            'يمكنك متابعة خط سير المندوب مباشرة على الخريطة.',
        isUser: false,
        timestamp: now,
        actions: [
          AlhadheqAction(
            label: 'تتبع المندوب على الخريطة',
            icon: LucideIcons.navigation,
            route: '/tracking',
          ),
        ],
      );
    }

    if (lower.contains('محفظ') ||
        lower.contains('رصيد') ||
        lower.contains('شحن') ||
        lower.contains('فلوس') ||
        lower.contains('دفع')) {
      return AlhadheqMessage(
        id: id,
        text:
            'بإمكانك إدارة كل معاملاتك المالية عبر «المحفظة الرقمية» بسهولة 💳:\n\n'
            '• شحن الرصيد ببطاقات مدى، فيزا، أو Apple Pay.\n'
            '• تحويل رصيد فوري لأي مستخدم برقم الجوال.\n'
            '• الاطلاع على كشف الحساب واسترداد النقود (الكاش باك).',
        isUser: false,
        timestamp: now,
        actions: [
          AlhadheqAction(
            label: 'الانتقال للمحفظة الرقمية',
            icon: LucideIcons.wallet,
            route: '/profile?tab=wallet',
          ),
        ],
      );
    }

    if (lower.contains('عرض') ||
        lower.contains('عروض') ||
        lower.contains('خصم') ||
        lower.contains('كوبون')) {
      return AlhadheqMessage(
        id: id,
        text:
            'إليك العروض الحصرية النشطة في منطقتك اليوم 🎉:\n\n'
            '• كود **GREIB25**: خصم 25% على أول طلبين توصيل طعام.\n'
            '• توصيل مجاني لمشتريات السوبرماركت فوق 100 ر.س.\n'
            '• كاش باك 10% عند الدفع عبر المحفظة الرقمية.',
        isUser: false,
        timestamp: now,
        actions: [
          AlhadheqAction(
            label: 'مشاهدة الريلز والعروض',
            icon: LucideIcons.clapperboard,
            route: '/reels',
          ),
        ],
      );
    }

    if (lower.contains('صيانة') ||
        lower.contains('سباك') ||
        lower.contains('كهربا') ||
        lower.contains('خدمة') ||
        lower.contains('فني')) {
      return AlhadheqMessage(
        id: id,
        text:
            'خدمات الصيانة والمهن المنزلية متاحة عبر مزودين موثوقين ومعتمدين 🛠️:\n\n'
            '• سباكة وتمديدات صحية.\n'
            '• صيانة أجهزة تكييف وتبريد.\n'
            '• أعمال الكهرباء والإنارة.\n'
            'كل الخدمات تأتي مع ضمان الجودة ومعاينة مسبقة.',
        isUser: false,
        timestamp: now,
        actions: [
          AlhadheqAction(
            label: 'تصفح خدمات الصيانة',
            icon: LucideIcons.wrench,
            route: '/home',
          ),
        ],
      );
    }

    if (lower.contains('مرحبا') ||
        lower.contains('سلام') ||
        lower.contains('أهلا') ||
        lower.contains('هلا')) {
      return AlhadheqMessage(
        id: id,
        text:
            'يا هلا وغلا! أسعد دائماً بمساعدتك 😊\n'
            'أنا جاهز لأي استفسار حول خدمات تطبيق گريب منك، أو إذا كنت تبحث عن شيء محدد بالقرب منك.',
        isUser: false,
        timestamp: now,
      );
    }

    // الرد الذكي العام
    return AlhadheqMessage(
      id: id,
      text:
          'فهمت طلبك بخصوص "$query" 💡.\n\n'
          'نظام «الحاذق» يحلل آلاف الخدمات والعروض المتجددة لتقديم أفضل الاقتراحات المناسبة لك في منطقة تواجدك.\n\n'
          'يمكنني مساعدتك بالتفصيل في:\n'
          '1. البحث عن الخدمات والمتاجر القريبة.\n'
          '2. مقارنة الأسعار والعروض المتاحة.\n'
          '3. تتبع طلباتك والتواصل مع الدعم الفني.',
      isUser: false,
      timestamp: now,
      actions: [
        AlhadheqAction(
          label: 'تصفح الصفحة الرئيسية',
          icon: LucideIcons.house,
          route: '/home',
        ),
      ],
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بدء محادثة جديدة'),
        content: const Text(
          'هل ترغب في مسح سجل المحادثة الحالي وبدء جلسة جديدة مع الحاذق؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _initWelcomeMessages();
              });
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.sparkles,
                      color: context.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'عن المساعد الذكي «الحاذق»',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '«الحاذق» هو رفيقك الذكي المعتمد على خوارزميات الذكاء الاصطناعي لمساعدتك في تصفح عروض وخدمات گريب منك بدقة وسرعة فائقة.\n\n'
                '• توصيات مخصصة حسب موقعك الجغرافي.\n'
                '• استجابة فورية لاستفسارات الحجوزات والطلبات.\n'
                '• اقتراحات وتنبيهات لأقوى التخفيضات اليومية.',
                style: TextStyle(height: 1.6, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً، فهمت'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.palette.isDark;
    final surface = context.backgroundColors.surface;
    final accent = context.accentColor;
    final outline = context.backgroundColors.outline;

    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: AppBar(
        backgroundColor: surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight),
          tooltip: 'رجوع',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            // أيقونة الحاذق الذكية مع نبض خفيف
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.08);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent,
                          accent.withValues(alpha: 0.75),
                          context.accentLightColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(
                            alpha: 0.3 + (_pulseController.value * 0.2),
                          ),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      LucideIcons.sparkles,
                      color: context.textColors.onAccent,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'الحاذق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'AI ذكي',
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _isTyping ? 'يكتب الآن...' : 'متصل ومستعد للمساعدة ⚡️',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isTyping ? accent : context.textColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw, size: 20),
            tooltip: 'محادثة جديدة',
            onPressed: _clearChat,
          ),
          IconButton(
            icon: const Icon(LucideIcons.info, size: 20),
            tooltip: 'معلومات عن الحاذق',
            onPressed: _showInfoSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الاقتراحات السريعة القابل للتمرير
          _buildSuggestionsBar(accent, surface, isDark),

          // قائمة الرسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(accent, surface);
                }
                final message = _messages[index];
                return _buildMessageBubble(message, accent, isDark);
              },
            ),
          ),

          // شريط الإدخال السفلي
          _buildInputBar(surface, outline, accent, isDark),
        ],
      ),
    );
  }

  Widget _buildSuggestionsBar(Color accent, Color surface, bool isDark) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: context.backgroundColors.outline.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _quickSuggestions[index];
          return ActionChip(
            label: Text(
              suggestion,
              style: TextStyle(fontSize: 11, color: context.textColors.primary),
            ),
            backgroundColor: surface,
            side: BorderSide(color: accent.withValues(alpha: 0.25), width: 0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _sendMessage(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(
    AlhadheqMessage message,
    Color accent,
    bool isDark,
  ) {
    final isUser = message.isUser;
    final bubbleColor = isUser
        ? accent
        : context.backgroundColors.surfaceElevated;
    final textColor = isUser
        ? context.textColors.onAccent
        : context.textColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 2, left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.sparkles, size: 14, color: accent),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.backgroundColors.scrim.withValues(
                          alpha: 0.04,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: isUser
                                  ? context.textColors.onAccent.withValues(
                                      alpha: 0.75,
                                    )
                                  : context.textColors.secondary,
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.checkCheck,
                              size: 13,
                              color: context.textColors.onAccent,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // أزرار الإجراءات داخل رد الذكاء الاصطناعي
                if (!isUser &&
                    message.actions != null &&
                    message.actions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: message.actions!.map((action) {
                      return OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: accent.withValues(
                            alpha: isDark ? 0.12 : 0.06,
                          ),
                          side: BorderSide(
                            color: accent.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(action.icon, size: 14, color: accent),
                        label: Text(
                          action.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        onPressed: () {
                          if (action.route != null) {
                            context.push(action.route!);
                          } else if (action.onTap != null) {
                            action.onTap!();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],

                // أدوات التفاعل (نسخ / إعجاب)
                if (!isUser) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.copy, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        tooltip: 'نسخ الرد',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ نص الرد بنجاح 📋'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          message.isLiked == true
                              ? LucideIcons.thumbsUp
                              : LucideIcons.thumbsUp,
                          size: 14,
                          color: message.isLiked == true ? accent : null,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        tooltip: 'مفيد',
                        onPressed: () {
                          setState(() => message.isLiked = true);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          message.isLiked == false
                              ? LucideIcons.thumbsDown
                              : LucideIcons.thumbsDown,
                          size: 14,
                          color: message.isLiked == false
                              ? context.iconColors.error
                              : null,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        tooltip: 'غير دقيق',
                        onPressed: () {
                          setState(() => message.isLiked = false);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color accent, Color surface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.sparkles, size: 14, color: accent),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, accent),
                const SizedBox(width: 4),
                _buildDot(1, accent),
                const SizedBox(width: 4),
                _buildDot(2, accent),
                const SizedBox(width: 8),
                Text(
                  'الحاذق يفكّر ويكتب...',
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4 + (0.6 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar(
    Color surface,
    Color outline,
    Color accent,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: context.backgroundColors.scrim.withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.backgroundColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: outline.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'اسأل الحاذق أي شيء...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.mic, size: 18),
                      tooltip: 'تسجيل صوتي',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'التعرف الصوتي الذكي سيتوفر قريباً 🎙️',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  LucideIcons.sendHorizontal,
                  color: context.textColors.onAccent,
                  size: 18,
                ),
                tooltip: 'إرسال',
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'م' : 'ص';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
