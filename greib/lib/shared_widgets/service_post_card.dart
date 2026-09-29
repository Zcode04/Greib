import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/mock_data/mock_data.dart';
import '../core/models/service_model.dart';
import '../core/theme/app_colors.dart';
import 'smart_image.dart';

/// ============================================================================
///  ServicePostCard — بطاقة المنشور الموحّدة.
///
///  ★ تصميم واحد لكل المنشورات في التطبيق (منشورات الصفحة الرئيسية)،
///    يُعاد استخدامه في تبويبات صفحة تفاصيل الخدمة ⇒ نفس الشكل تماماً
///    بلا تكرار في الكود.
///
///  البنية: رأس (أيقونة + اسم + وقت + زر حفظ) ← نص ← صور ← تفاعلات ← فاصل ← أزرار.
///
///  حالات الحفظ/التفاعل محلية داخل البطاقة ⇒ تعمل في أي قائمة بلا ربط خارجي،
///  و`countSeed` يولّد أرقاماً ثابتة مشتقة من النص (بلا عشوائية كل إطار).
/// ============================================================================
class ServicePostCard extends StatefulWidget {
  final ServiceCategory service;

  /// نص المنشور — إن كان null يُستخدم `service.subtitle`.
  final String? text;

  /// وقت النشر («منذ ساعتين») — الافتراضي «الآن».
  final String? timeAgo;

  /// صور المنشور — الافتراضي صورة الغلاف بنسبة ثابتة.
  final List<String> imageUrls;

  final bool isDark;

  /// لون خلفية البطاقة — الافتراضي خلفية التطبيق (تمتد للحواف مثل فيسبوك).
  final Color? backgroundColor;

  /// بذرة الأرقام الثابتة (مثلاً `post.text` أو `service.id`).
  final String countSeed;

  /// أعداد الأزرار — إن كانت null تُحسب من `countSeed`.
  final String? likeCount;
  final String? commentCount;
  final String? shareCount;

  // ---------- حالة مُدارة من الخارج (اختياري) ----------
  // عند تمريرها تتحول البطاقة إلى "متحكَّم بها" (Controlled): تعرض القيمة
  // القادمة وتبلّغ عن التغيير بدل الاحتفاظ بحالة داخلية.
  // هذا يتيح للصفحة الرئيسية (Spotlight) أن يبقي التفاعل/المفضلة في
  // الـ State الخاص بها (ورقتي التعليقات وقائمة المتفاعلين) بينما تستخدم
  // نفس البطاقة.
  final int? reaction;
  final bool? isSaved;
  final ValueChanged<int>? onReactionChanged;
  final ValueChanged<bool>? onSaveChanged;

  /// ★ إذا كان true: النقر على زر التفاعل لا يبدّل الحالة المحلية، بل يستدعي
  /// `onReaction` فقط (ليفتح ورقة الاختيار). هذا وضع الصفحة الرئيسية حيث
  /// الاختيار يتم داخل الورقة، بينما عرض الأيقونة يعتمد على `reaction` الخارجي.
  final bool delegateReactionToCallback;

  final VoidCallback? onSave;
  final VoidCallback? onRequest;
  final VoidCallback? onReaction;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onImageTap;

  const ServicePostCard({
    super.key,
    required this.service,
    required this.isDark,
    this.text,
    this.timeAgo,
    this.imageUrls = const [],
    this.backgroundColor,
    this.countSeed = '',
    this.likeCount,
    this.commentCount,
    this.shareCount,
    this.reaction,
    this.isSaved,
    this.onReactionChanged,
    this.onSaveChanged,
    this.delegateReactionToCallback = false,
    this.onSave,
    this.onRequest,
    this.onReaction,
    this.onComment,
    this.onShare,
    this.onImageTap,
  });

  @override
  State<ServicePostCard> createState() => _ServicePostCardState();
}

class _ServicePostCardState extends State<ServicePostCard> {
  /// 0 = بلا تفاعل، 1 = إعجاب، -1 = عدم إعجاب (يُستخدم فقط في الوضع الذاتي).
  int _reaction = 0;
  bool _isSaved = false;

  /// التفاعل المعروض: الخارجي إن وُجد، وإلا الداخلي.
  int get _effectiveReaction => widget.reaction ?? _reaction;

  /// حالة الحفظ المعروضة: الخارجية إن وُجدت، وإلا الداخلية.
  bool get _effectiveSaved => widget.isSaved ?? _isSaved;

  ServiceCategory get _service => widget.service;

  Color get _primary =>
      widget.isDark ? AppColors.textPrimary : AppColors.lightText;
  Color get _secondary =>
      widget.isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get _line => widget.isDark ? AppColors.outline : AppColors.lightOutline;
  Color get _accent => _service.color;

  static const double _kPillRadius = 999;

  /// عدد ثابت مشتق من countSeed (بلا عشوائية تتغير كل إطار).
  String _countFor(int span, int min) {
    final seed = widget.countSeed.isEmpty
        ? widget.service.id
        : widget.countSeed;
    return (min + seed.hashCode.abs() % span).toString();
  }

  /// دورة الضغط: بلا <- إعجاب <- عدم إعجاب <- بلا.
  void _cycleReaction() {
    // ★ وضع "الورقة": النقر يستدعي callback فقط (يفتح ورقة الاختيار) ولا
    // يغيّر الحالة هنا، لأن الاختيار الفعلي يتم داخل الورقة.
    if (widget.delegateReactionToCallback) {
      (widget.onReaction ?? _showLater)();
      return;
    }

    final next = _effectiveReaction >= 1
        ? -1
        : (_effectiveReaction == 0 ? 1 : 0);
    // وضع مُتحكَّم به ⇒ نُبلغ الأب ولا نلمس الحالة الداخلية.
    if (widget.onReactionChanged != null) {
      widget.onReactionChanged!(next);
    } else {
      setState(() => _reaction = next);
    }
    (widget.onReaction ?? _showLater)();
  }

  void _toggleSaved() {
    final next = !_effectiveSaved;
    if (widget.onSaveChanged != null) {
      widget.onSaveChanged!(next);
    } else {
      setState(() => _isSaved = next);
    }
    (widget.onSave ?? _showLater)();
  }

  void _showLater() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة ستتوفر قريباً بإذن الله'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls.isNotEmpty
        ? widget.imageUrls
        : <String>[?_service.coverImage];

    return Container(
      // ★ خلفية المنشور = خلفية التطبيق ⇒ تندمج البطاقة مع الصفحة من طرف
      // لطرف كما في فيسبوك، والضوء البصري يأتي من الصور والفواصل فقط.
      color:
          widget.backgroundColor ??
          (widget.isDark ? AppColors.background : AppColors.lightBackground),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          const SizedBox(height: 12),
          _text(),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _imageGrid(images),
          ],
          const SizedBox(height: 12),
          _reactionChips(),
          Divider(height: 1, color: _line),
          _actions(),
        ],
      ),
    );
  }

  // ---------- 1. رأس المنشور (Profile) ----------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withValues(alpha: 0.15),
              border: Border.all(color: _accent.withValues(alpha: 0.3)),
            ),
            child: Icon(
              MockData.getIconByName(_service.iconName),
              color: _accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Greib · ${widget.timeAgo ?? 'الآن'} · ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _secondary, fontSize: 12),
                      ),
                    ),
                    Icon(LucideIcons.globe, size: 12, color: _secondary),
                  ],
                ),
              ],
            ),
          ),
          // زر الحفظ (Add to list) في طرف الهيدر.
          InkWell(
            onTap: _toggleSaved,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(
                _effectiveSaved
                    ? LucideIcons.bookmarkCheck
                    : LucideIcons.bookmarkPlus,
                color: _effectiveSaved ? _accent : _secondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 2. نص المنشور ----------
  Widget _text() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.text ?? _service.subtitle,
        style: TextStyle(color: _primary, fontSize: 15, height: 1.5),
      ),
    );
  }

  // ---------- 3. شبكة الصور: صورة واحدة بنسبة ثابتة، أو صورتان جنباً إلى جنب ----------
  Widget _imageGrid(List<String> images) {
    void open() => (widget.onImageTap ?? _showLater)();

    if (images.length == 1) {
      return InkWell(
        onTap: open,
        child: AspectRatio(aspectRatio: 1.5, child: _tile(images.first)),
      );
    }

    return InkWell(
      onTap: open,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Row(
          children: [
            Expanded(flex: 3, child: _tile(images[0])),
            const SizedBox(width: 2),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _tile(images[1])),
                  if (images.length > 2) ...[
                    const SizedBox(height: 2),
                    Expanded(child: _tile(images[2])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String src) => SmartImage(src: src, placeholder: _iconHero());

  /// بديل الصورة عند فشل التحميل — تدرج بلون الخدمة + أيقونتها.
  Widget _iconHero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // حجم الأيقونة نسبة لعرض البطاقة => لا يفيض على الشاشات الضيقة.
        final badge = (constraints.maxWidth * 0.3).clamp(64.0, 120.0);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accent.withValues(alpha: 0.22),
                _accent.withValues(alpha: 0.07),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: badge,
              height: badge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.18),
                border: Border.all(
                  color: _accent.withValues(alpha: 0.38),
                  width: 2,
                ),
              ),
              child: Icon(
                MockData.getIconByName(_service.iconName),
                color: _accent,
                size: badge * 0.48,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- 4. أيقونات التفاعل ----------
  Widget _reactionChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _reactionChip(LucideIcons.thumbsUp, AppColors.info),
          const SizedBox(width: 2),
          _reactionChip(LucideIcons.thumbsDown, AppColors.error),
        ],
      ),
    );
  }

  Widget _reactionChip(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          // حد بنفس لون خلفية المنشور (وإلا ظهرت حلقة فاتحة في الوضع الداكن).
          color: widget.isDark
              ? AppColors.background
              : AppColors.lightBackground,
          width: 1.5,
        ),
      ),
      child: Icon(icon, size: 11, color: Colors.white),
    );
  }

  // ---------- 5. أزرار الإجراءات ----------
  /// "طلب الآن" يأخذ ثلث العرض (ملتصق بالزاوية) والمجموعة ثلاث الباقي،
  /// مع خلفيات متماثلة الأبعاد تماماً كمنشور الصفحة الرئيسية.
  Widget _actions() {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _pillButton(
            icon: LucideIcons.shoppingBag,
            label: 'طلب الآن',
            color: _accent,
            onTap: () => (widget.onRequest ?? _showLater)(),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Row(
              children: [
                Expanded(
                  child: _pillButton(
                    grouped: true,
                    icon: _effectiveReaction >= 0
                        ? LucideIcons.thumbsUp
                        : LucideIcons.thumbsDown,
                    color: _effectiveReaction == 0
                        ? _secondary
                        : (_effectiveReaction > 0
                              ? AppColors.info
                              : AppColors.error),
                    count: widget.likeCount ?? _countFor(80, 10),
                    onTap: _cycleReaction,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillButton(
                    grouped: true,
                    icon: LucideIcons.messageCircle,
                    color: _secondary,
                    count: widget.commentCount ?? _countFor(40, 2),
                    onTap: () => (widget.onComment ?? _showLater)(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillButton(
                    grouped: true,
                    icon: LucideIcons.repeat2,
                    color: _secondary,
                    count: widget.shareCount ?? _countFor(20, 1),
                    onTap: () => (widget.onShare ?? _showLater)(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// زر "كبسولة" (Pill) يملأ الخلية بالتساوي، مع تصغير تلقائي عند ضيق الشاشة.
  Widget _pillButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? label,
    String? count,
    bool grouped = false,
  }) {
    // المجموعة ثلاث أكبر قليلاً => منطقة لمس مريحة.
    final iconSize = grouped ? 20.0 : 18.0;
    // توسيع أفقي للخلفية فقط (الأيقونة/الرقم بلا تغيير) => مظهر أنيق ومتوازن.
    final pillHPad = grouped ? 22.0 : 18.0;
    final pillVPad = grouped ? 8.0 : 7.0;
    final countSize = grouped ? 12.5 : 12.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_kPillRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: grouped ? 9 : 8),
        child: Align(
          alignment: grouped
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          child: Container(
            width: grouped ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: pillHPad,
              vertical: pillVPad,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(_kPillRadius),
            ),
            child: FittedBox(
              // تصغير المحتوى عند ضيق الشاشة بدل فيض الخلفية.
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: color),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (count != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      count,
                      maxLines: 1,
                      style: TextStyle(
                        // الرقم أخف من الكلمة => لا يزاحم الأيقونة.
                        color: color.withValues(alpha: 0.75),
                        fontSize: countSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
