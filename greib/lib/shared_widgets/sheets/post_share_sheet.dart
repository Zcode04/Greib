import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/service_model.dart';
import '../../core/theme/design_tokens.dart';
import '../smart_image.dart';
import '../share_arrow_icon.dart';

/// ============================================================================
///  PostShareSheet — ورقة مشاركة المنشور التفاعلية (على طريقة فيسبوك/ميتا).
///
///  ★ زر علوي لنسخ الرابط مع معاينة الرابط وتأكيد بصري فوري.
///  ★ صف تطبيقات الهاتف وميتا (واتساب، فيسبوك، إنستغرام، ماسنجر، تيليجرام، X، تطبيقات الهاتف).
///  ★ خيارات سريعة داخل التطبيق (إعادة النشر، إرسال في رسالة خاصة، حفظ المنشور).
/// ============================================================================
class PostShareSheet extends StatefulWidget {
  const PostShareSheet({
    super.key,
    required this.service,
    required this.postId,
    required this.isDark,
    this.isSaved = false,
    this.onSaveToggle,
    this.onChatTap,
    this.onRepost,
    this.customUrl,
  });

  final ServiceCategory service;
  final String postId;
  final bool isDark;
  final bool isSaved;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onChatTap;
  final VoidCallback? onRepost;
  final String? customUrl;

  @override
  State<PostShareSheet> createState() => _PostShareSheetState();
}

class _PostShareSheetState extends State<PostShareSheet> {
  bool _copied = false;
  Timer? _copyTimer;
  late bool _isSaved = widget.isSaved;

  String get _postUrl =>
      widget.customUrl ?? 'https://greib.app/post/${widget.postId}';

  String get _shareText =>
      'شاهد «${widget.service.title}» على تطبيق گريب منك:\n$_postUrl';

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopyLink() async {
    await Clipboard.setData(ClipboardData(text: _postUrl));
    HapticFeedback.lightImpact();

    if (!mounted) return;
    setState(() => _copied = true);

    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.check, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'تم نسخ رابط المنشور إلى الحافظة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  Future<void> _shareWithSystem({String? appName}) async {
    HapticFeedback.selectionClick();
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      await Share.share(
        _shareText,
        subject: widget.service.title,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      // تجاهل إذا ألغى المستخدم المشاركة
    }
  }

  void _handleRepost() {
    Navigator.of(context).maybePop();
    widget.onRepost?.call();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ShareArrowIcon(size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'تمت إعادة نشر «${widget.service.title}» على صفحتك',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final cardBg = widget.isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── ترويسة الورقة ───
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: textSecondary,
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'إغلاق',
                ),
                Expanded(
                  child: Text(
                    'مشاركة المنشور',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // لموازنة زر الإغلاق
              ],
            ),
            const SizedBox(height: 12),

            // ─── بطاقة معاينة المنشور المصغرة ───
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: widget.service.coverImage != null
                          ? SmartImage(
                              src: widget.service.coverImage,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: widget.service.color.withValues(alpha: 0.2),
                              child: Icon(
                                LucideIcons.image,
                                color: widget.service.color,
                                size: 22,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.service.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── زر نسخ الرابط ورابط المنشور (القسم العلوي المطلوب) ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(
                  color: _copied
                      ? const Color(0xFF10B981).withValues(alpha: 0.5)
                      : borderColor,
                  width: _copied ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.link,
                    size: 18,
                    color: _copied ? const Color(0xFF10B981) : textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _postUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: ElevatedButton.icon(
                      onPressed: _handleCopyLink,
                      icon: Icon(
                        _copied ? LucideIcons.check : LucideIcons.copy,
                        size: 15,
                        color: Colors.white,
                      ),
                      label: Text(
                        _copied ? 'تم النسخ!' : 'نسخ الرابط',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _copied
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── عنوان قسم تطبيقات المشاركة ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'المشاركة عبر التطبيقات',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ─── أيقونات تطبيقات الهاتف (تطبيقات ميتا وتطبيقات الهاتف) ───
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // واتساب (WhatsApp)
                  _AppShareItem(
                    name: 'واتساب',
                    bgColor: const Color(0xFF25D366),
                    icon: _BrandWhatsAppIcon(),
                    onTap: () => _shareWithSystem(appName: 'واتساب'),
                  ),
                  const SizedBox(width: 14),

                  // فيسبوك (Facebook)
                  _AppShareItem(
                    name: 'فيسبوك',
                    bgColor: const Color(0xFF1877F2),
                    icon: const Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'sans-serif',
                      ),
                    ),
                    onTap: () => _shareWithSystem(appName: 'فيسبوك'),
                  ),
                  const SizedBox(width: 14),

                  // إنستغرام (Instagram)
                  _AppShareItem(
                    name: 'إنستغرام',
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF833AB4),
                        Color(0xFFFD1D1D),
                        Color(0xFFFCB045),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    icon: const Icon(
                      LucideIcons.camera,
                      color: Colors.white,
                      size: 24,
                    ),
                    onTap: () => _shareWithSystem(appName: 'إنستغرام'),
                  ),
                  const SizedBox(width: 14),

                  // ماسنجر (Messenger)
                  _AppShareItem(
                    name: 'ماسنجر',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B2FF), Color(0xFF006AFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    icon: const Icon(
                      LucideIcons.messageCircle,
                      color: Colors.white,
                      size: 24,
                    ),
                    onTap: () => _shareWithSystem(appName: 'ماسنجر'),
                  ),
                  const SizedBox(width: 14),

                  // تيليجرام (Telegram)
                  _AppShareItem(
                    name: 'تيليجرام',
                    bgColor: const Color(0xFF24A1DE),
                    icon: const Icon(
                      LucideIcons.send,
                      color: Colors.white,
                      size: 22,
                    ),
                    onTap: () => _shareWithSystem(appName: 'تيليجرام'),
                  ),
                  const SizedBox(width: 14),

                  // منصة X
                  _AppShareItem(
                    name: 'منصة X',
                    bgColor: widget.isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFF0F1419),
                    icon: const Text(
                      '𝕏',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onTap: () => _shareWithSystem(appName: 'منصة X'),
                  ),
                  const SizedBox(width: 14),

                  // تطبيقات الهاتف / المزيد
                  _AppShareItem(
                    name: 'المزيد',
                    bgColor: widget.isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    icon: Icon(
                      LucideIcons.share2,
                      color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      size: 22,
                    ),
                    onTap: () => _shareWithSystem(appName: 'تطبيقات الهاتف'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── فاصل أنيق ───
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 12),

            // ─── إجراءات داخلية (نمط فيسبوك) ───
            // 1. إعادة النشر
            _actionTile(
              iconWidget: const ShareArrowIcon(size: 20),
              title: 'إعادة النشر على صفحتك',
              subtitle: 'نشر فوري لمتابعيك في گريب منك',
              onTap: _handleRepost,
              textColor: textPrimary,
              subColor: textSecondary,
            ),

            // 2. إرسال في رسالة
            _actionTile(
              iconWidget: Icon(
                LucideIcons.messageSquare,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              title: 'إرسال في رسالة خاصة',
              subtitle: 'محادثة مباشرة مع مقدّم الخدمة',
              onTap: () {
                Navigator.of(context).maybePop();
                widget.onChatTap?.call();
              },
              textColor: textPrimary,
              subColor: textSecondary,
            ),

            // 3. حفظ المنشور
            _actionTile(
              iconWidget: Icon(
                _isSaved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                size: 20,
                color: _isSaved ? const Color(0xFFF59E0B) : textSecondary,
              ),
              title: _isSaved ? 'إزالة من المحفوظات' : 'حفظ في المفضلة',
              subtitle: _isSaved
                  ? 'تم حفظ هذا المنشور في حسابك'
                  : 'حفظ للرجوع إليه في أي وقت',
              onTap: () {
                setState(() => _isSaved = !_isSaved);
                widget.onSaveToggle?.call();
                HapticFeedback.selectionClick();
              },
              textColor: textPrimary,
              subColor: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color subColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronLeft, size: 18, color: subColor),
          ],
        ),
      ),
    );
  }
}

/// عنصر أيقونة التطبيق في شريط المشاركة
class _AppShareItem extends StatelessWidget {
  const _AppShareItem({
    required this.name,
    required this.icon,
    required this.onTap,
    this.bgColor,
    this.gradient,
  });

  final String name;
  final Widget icon;
  final VoidCallback onTap;
  final Color? bgColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// أيقونة واتساب مبسطة وجذابة
class _BrandWhatsAppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      LucideIcons.phoneCall,
      color: Colors.white,
      size: 24,
    );
  }
}
