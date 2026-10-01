import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/mock_data/mock_data.dart';
import '../core/models/service_model.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_sheet.dart';
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

  // ---------- رأس المنشور: صاحب المنشور ----------
  // ★ عند تمريرها تتحول البطاقة إلى منشور **حساب** بدل منشور خدمة:
  //   يعرض اسم الحساب وصورته بدل اسم الخدمة وأيقونتها، مع إبقاء نفس التصميم.
  //   تُستخدم في صفحة الحساب فقط (AccountProfilePage).

  /// اسم صاحب المنشور — الافتراضي: `service.title`.
  final String? authorName;

  /// صورة البروفايل — الافتراضي: أيقونة الخدمة.
  final String? authorAvatarUrl;

  /// الفئة/التصنيف تحت الاسم (مثل «توصيل طعام») — الافتراضي: `service.title`.
  final String? authorSubtitle;

  /// حالة الاتصال لصاحب المنشور — الافتراضي: مشتقّة ثابتة من `countSeed`.
  /// true = متصل الآن، false = آخر ظهور.
  final bool? authorIsOnline;

  /// نص آخر ظهور (مثل «آخر ظهور منذ 12 دقيقة») — يُعرض عند عدم الاتصال.
  /// الافتراضي: مشتقّ ثابت من `countSeed`.
  final String? authorPresence;

  /// علامة التوثيق بجوار اسم صاحب المنشور — الافتراضي: true.
  final bool authorVerified;

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
    this.authorName,
    this.authorAvatarUrl,
    this.authorSubtitle,
    this.authorIsOnline,
    this.authorPresence,
    this.authorVerified = true,
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

  /// ★ حالة المتابعة لصاحب المنشور (وهمية محلية حتى ربط الـ backend).
  bool _isFollowing = true;

  /// التفاعل المعروض: الخارجي إن وُجد، وإلا الداخلي.
  int get _effectiveReaction => widget.reaction ?? _reaction;

  /// حالة الحفظ المعروضة: الخارجية إن وُجدت، وإلا الداخلية.
  bool get _effectiveSaved => widget.isSaved ?? _isSaved;

  ServiceCategory get _service => widget.service;

  Color get _primary =>
      widget.isDark ? AppColors.textPrimary : AppColors.lightText;
  Color get _secondary =>
      widget.isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get _accent => _service.color;

  static const double _kPillRadius = 999;

  // ---------- حالة الاتصال (Mock مشتقّة من البذرة ⇒ ثابتة لكل منشور) ----------
  int get _presenceSeed {
    final seed = (widget.countSeed.isEmpty
            ? widget.service.id
            : widget.countSeed)
        .hashCode
        .abs();
    return seed == 0 ? 1 : seed;
  }

  bool get _derivedIsOnline => _presenceSeed % 3 != 0;

  String get _derivedPresence {
    final minutes = _presenceSeed % 180 + 5;
    if (minutes < 60) return 'آخر ظهور منذ $minutes دقيقة';
    final hours = (minutes / 60).floor();
    return 'آخر ظهور منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
  }

  /// ★ متابعة صاحب المنشور — «متابع» مع أيقونة علامة صح، والنقر يتبدّل
  /// بين المتابعة وعدم المتابعة (حالة محلية وهمية حالياً).
  Widget _followLabel() {
    final following = _isFollowing;
    return InkWell(
      onTap: () => setState(() => _isFollowing = !following),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              following ? 'متابع' : 'غير متابع',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: following ? _accent : _secondary,
                fontSize: 12,
                fontWeight: following ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (following) ...[
              const SizedBox(width: 3),
              Icon(
                LucideIcons.badgeCheck,
                size: 12,
                color: _accent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// أسماء مستخدمين وهميين — مشتقّة ثابتة من البذرة (بلا عشوائية كل إطار).
  static const List<String> _peopleFirst = [
    'محمد',
    'سيدي',
    'عالي',
    'أحمد',
    'يوسف',
    'عبدالله',
    'خالد',
    'إبراهيم',
  ];

  static const List<String> _peopleLast = [
    'ولد لامين',
    'ال比上年',
    'المعز',
    'بن عمر',
    'عبد القادر',
    'المهدي',
  ];

  /// الاسم الوهمي الثابت للمنشور (عند عدم تمرير `authorName`).
  String get _derivedAuthorName {
    final seed = _presenceSeed;
    return '${_peopleFirst[seed % _peopleFirst.length]} '
        '${_peopleLast[(seed ~/ 7) % _peopleLast.length]}';
  }

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

  // ---------- ورقة خيارات المنشور (⋯) ----------
  /// تُغلق الورقة ثم ينفّذ الإجراء (رسالة "قريباً" مؤقتة للباقي).
  void _runFromSheet(VoidCallback action) {
    Navigator.of(context, rootNavigator: true).pop();
    action();
  }

  Future<void> _showPostOptions() async {
    final saved = _effectiveSaved;
    await showAppSheet(
      context,
      builder: (sheetContext) {
        final sheetText = Theme.of(sheetContext).colorScheme.onSurface;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Text(
                      'خيارات المنشور',
                      style: TextStyle(
                        color: sheetText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _sheetTile(
                sheetContext,
                icon: saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                label: saved ? 'إلغاء حفظ المنشور' : 'حفظ المنشور',
                iconColor: sheetText,
                onTap: () => _runFromSheet(_toggleSaved),
              ),
              _sheetTile(
                sheetContext,
                icon: LucideIcons.thumbsUp,
                label: 'مهتم',
                iconColor: AppColors.info,
                onTap: () => _runFromSheet(_showLater),
              ),
              _sheetTile(
                sheetContext,
                icon: LucideIcons.thumbsDown,
                label: 'غير مهتم',
                iconColor: AppColors.error,
                onTap: () => _runFromSheet(_showLater),
              ),
              _sheetTile(
                sheetContext,
                icon: LucideIcons.flag,
                label: 'الإبلاغ عن المنشور',
                iconColor: AppColors.error,
                onTap: () => _runFromSheet(_showLater),
                showDivider: false,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// ★ ورقة الضغط على زر الإغلاق (✕): إخفاء المنشور، إخفاء كل منشورات
  /// نشاط هذا التاجر، الإبلاغ عن المنشور (رسالة "قريباً" مؤقتة).
  Future<void> _showCloseOptions() async {
    await showAppSheet(
      context,
      builder: (sheetContext) {
        final sheetText = Theme.of(sheetContext).colorScheme.onSurface;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Text(
                      'خيارات المنشور',
                      style: TextStyle(
                        color: sheetText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _sheetTile(
                sheetContext,
                icon: LucideIcons.eyeOff,
                label: 'إخفاء المنشور',
                iconColor: sheetText,
                onTap: () => _runFromSheet(_showLater),
              ),
              _sheetTile(
                sheetContext,
                icon: LucideIcons.eyeOff,
                label: 'إخفاء جميع منشورات نشاط هذا التاجر',
                iconColor: sheetText,
                onTap: () => _runFromSheet(_showLater),
              ),
              _sheetTile(
                sheetContext,
                icon: LucideIcons.flag,
                label: 'الإبلاغ عن المنشور',
                iconColor: AppColors.error,
                onTap: () => _runFromSheet(_showLater),
                showDivider: false,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// عنصر قائمة داخل الورقة: أيقونة + نص، مع فاصل رفيع تحته.
  Widget _sheetTile(
    BuildContext sheetContext, {
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final sheetText = Theme.of(sheetContext).colorScheme.onSurface;
    final sheetLine = Theme.of(sheetContext).colorScheme.outlineVariant;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(color: sheetText, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: sheetLine),
      ],
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
      // ★ مسافة عمودية مريحة بين المنشورات المتتابعة (فقط، بلا تغيير في الهيكل).
      padding: const EdgeInsets.only(top: 12, bottom: 20),
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
          _actions(),
        ],
      ),
    );
  }

  // ---------- 1. رأس المنشور (Profile) ----------
  // ★ نفس التصميم في الحالتين: منشور خدمة (أيقونة) أو منشور حساب (صورة).
  //
  // ★ العنوان = اسم صاحب المنشور مع أيقونة توثيق بجواره، وتحته سطر
  //   المتابعة + الفئة + وقت النشر. حالة الاتصال ( globe ) سطر مستقل
  //   أسفل أيقونات التفاعل.
  Widget _header() {
    final authorAvatar = widget.authorAvatarUrl;
    final category = widget.authorSubtitle ?? _service.title;

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
              image: authorAvatar != null
                  ? DecorationImage(
                      image: NetworkImage(authorAvatar),
                      fit: BoxFit.cover,
                      onError: (_, _) {},
                    )
                  : null,
            ),
            // ★ صورة البروفايل تحل محل الأيقونة فقط عند وجودها.
            child: authorAvatar == null
                ? Icon(
                    MockData.getIconByName(_service.iconName),
                    color: _accent,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ★ العنوان: اسم صاحب المنشور + أيقونة التوثيق بجواره.
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.authorName ?? _derivedAuthorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (widget.authorVerified) ...[
                      const SizedBox(width: 3),
                      Icon(
                        LucideIcons.badgeCheck,
                        size: 15,
                        color: _accent,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                // ★ الفئة + وقت النشر (حالة الاتصال نُقلت لأسفل التفاعلات).
                Row(
                  children: [
                    _followLabel(),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$category · ${widget.timeAgo ?? 'الآن'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _secondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // إجراءات المنشور في طرف الهيدر: خيارات (⋯) ثم إغلاق (✕).
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _showPostOptions,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Icon(
                    LucideIcons.ellipsis,
                    color: _secondary,
                    size: 25,
                  ),
                ),
              ),
              InkWell(
                onTap: _showCloseOptions,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Icon(LucideIcons.x, color: _secondary, size: 25),
                ),
              ),
            ],
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

  // ---------- 4. أيقونات التفاعل + حالة الاتصال في الزاوية المقابلة ----------
  Widget _reactionChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
      child: Row(
        children: [
          _reactionChip(LucideIcons.thumbsUp, AppColors.info),
          const SizedBox(width: 2),
          _reactionChip(LucideIcons.thumbsDown, AppColors.error),
          const Spacer(),
          _presence(),
        ],
      ),
    );
  }

  /// ★ حالة الاتصال (أيقونة العالم + النص) — في الزاوية المقابلة تماماً.
  Widget _presence() {
    final online = widget.authorIsOnline ?? _derivedIsOnline;
    final presence = online
        ? 'متصل الآن'
        : (widget.authorPresence ?? _derivedPresence);
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              presence,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: online ? _accent : _secondary,
                fontSize: 12,
                fontWeight: online ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(LucideIcons.globe, size: 12, color: _secondary),
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
            grouped: true,
            icon: LucideIcons.shoppingBag,
            label: 'طلب الآن',
            color: _secondary,
            onTap: () => (widget.onRequest ?? _showLater)(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
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
                    trailingGap: 16,
                    trailing: InkWell(
                      onTap: () => (widget.onComment ?? _showLater)(),
                      borderRadius: BorderRadius.circular(_kPillRadius),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.messageCircle, size: 20, color: _secondary),
                          const SizedBox(width: 5),
                          Text(
                            widget.commentCount ?? _countFor(40, 2),
                            maxLines: 1,
                            style: TextStyle(
                              color: _secondary.withValues(alpha: 0.75),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    Widget? trailing,
    double trailingGap = 0,
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
                  if (trailing != null) ...[
                    SizedBox(width: trailingGap),
                    Container(
                      width: 1,
                      height: countSize + 2,
                      color: color.withValues(alpha: 0.25),
                    ),
                    SizedBox(width: trailingGap),
                    trailing,
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
