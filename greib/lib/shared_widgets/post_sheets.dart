import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show Drag;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/mock_data/mock_data.dart';
import '../core/models/service_model.dart';
import '../core/theme/app_colors.dart';
import '../../features/communication_and_support/chat_screen.dart';
import '../core/widgets/app_sheet.dart';
import 'post_reaction.dart';

/// ============================================================================
///  PostSheets — أوراق (Bottom Sheets) المشتركة لكل منشور في التطبيق.
///
///  ★ نواة واحدة: منشور الصفحة الرئيسية ومنشورات صفحة تفاصيل الخدمة
///    يستخدمان نفس الأوراق ونفس منطق العرض (تعليقات / تفاعل / خيارات /
///    صور / معاينة). أي تعديل هنا يسري على الشاشتين معاً.
///

/// ============================================================================
///  PostSheetsController — النواة المشتركة لكل منشور في التطبيق.
///
///  ★ يجعل "منطق الأوراق" واحداً لا نسختين:
///    - الحالة (المفضلة / التفاعل / التعليقات) محفوظة هنا، لا في كل شاشة.
///    - كل دالة تفتح ورقة واحدة فقط (تعليقات / تفاعل / خيارات / صور /
///      معاينة) بنفس السلوك في أي مكان.
///
///  الاستخدام: أنشئه في `initState`، واربطه بالبطاقة عبر `onSaveChanged`
///  و`onReaction`...، وتصرّف في `dispose`.
///
///  يطلب `notifyListeners` عند أي تغيير ⇒ أي شاشة تستمع (`ListenableBuilder`)
///  تعيد بناء البطاقات تلقائياً.
class PostSheetsController extends ChangeNotifier {
  PostSheetsController({required this.isDark});

  final bool isDark;

  /// الخدمات المحفوظة (الضغط على علامة الحفظ في رأس المنشور).
  final Set<String> _favorites = {};

  /// تفاعل كل منشور: 0 = بلا، 1 = إعجاب، -1 = عدم إعجاب.
  final Map<String, int> _reactions = {};

  /// تعليقات كل منشور (بيانات وهمية + ما يكتبه المستخدم داخل الورقة).
  final Map<String, List<PostComment>> _comments = {};

  /// أسماء مستخدمين وهميين (كما يعرض فيسبوك من تفاعلوا مع المنشور)،
  /// موزّعين على تفاعلات مختلفة ليراها المستخدم داخل ورقة التفاعل.
  static const Map<int, List<String>> kMockReactedUsers = {
    1: ['سارة', 'محمد', 'ريم', 'خالد', 'نور', 'يوسف'],
    2: ['آية', 'سليم', 'مريم'],
    4: ['هند', 'رامي', 'باسمة'],
    7: ['ليان', 'عمر'],
  };

  /// قائمة قديمة للإعجاب (مستخدمة في الواجهات القديمة).
  static const List<String> kMockLikedUsers = [
    'سارة',
    'محمد',
    'ريم',
    'خالد',
    'نور',
    'يوسف',
  ];

  static const List<String> kMockDislikedUsers = ['ليان', 'عمر', 'هدى', 'فهد'];

  // ================= الحالة (للقراءة من البطاقة) =================

  bool isFavorite(String postId) => _favorites.contains(postId);

  /// تفاعل المنشور مطبّعاً على النظام الجديد (0 = بلا، 1..7 = تفاعل).
  int reactionOf(String postId) =>
      PostReaction.normalize(_reactions[postId] ?? 0);

  /// عدد ثابت مشتق من معرّف المنشور ⇒ رقم إنجليزي ثابت بين عمليات البناء.
  static String countFor(String id, int span, int min) =>
      (min + id.hashCode.abs() % span).toString();

  // ================= تغييرات الحالة =================

  void setFavorite(String postId, bool value) {
    if (value) {
      _favorites.add(postId);
    } else {
      _favorites.remove(postId);
    }
    notifyListeners();
  }

  void setReaction(String postId, int value) {
    _reactions[postId] = PostReaction.normalize(value);
    notifyListeners();
  }

  // ================= الأوراق (نفس المنطق في كل مكان) =================

  /// ورقة التعليقات: قائمة تعليقات المنشور + حقل إضافة (يكتب المستخدم داخلها).
  void showComments(
    BuildContext context, {
    required String postId,
    required ServiceCategory service,
  }) {
    // قائمة قابلة للتوسيع (ليست const) حتى يضيف المستخدم تعليقاته.
    final list = _comments.putIfAbsent(
      postId,
      () => [
        const PostComment('سارة', 'الخدمة ممتازة وسرعة التنفيذ رهيبة.'),
        const PostComment('محمد', 'جرّبتها أمس وأنصح فيها بشدة.'),
        const PostComment('ريم', 'هل يوجد خصم للمتابعة الشهرية؟'),
      ],
    );

    showAppSheet<void>(
      context,
      builder: (_) =>
          PostCommentsSheet(service: service, isDark: isDark, comments: list),
    );
  }

  /// ورقة التفاعل (إعجاب / عدم إعجاب) مع قائمة المتفاعلين.
  void showReaction(
    BuildContext context, {
    required String postId,
    required ServiceCategory service,
  }) {
    showAppSheet<void>(
      context,
      builder: (sheetContext) => PostReactionSheet(
        service: service,
        isDark: isDark,
        reactedUsers: kMockReactedUsers,
        current: reactionOf(postId),
        onReact: (value) {
          setReaction(postId, value);
          // ★ الاختيار يُغلق الورقة مباشرة (كما في فيسبوك) ليعود المستخدم
          //   للبطاقة ويرى الإيموجي بجوار الأيقونات.
          Navigator.of(sheetContext).maybePop();
        },
      ),
    );
  }

  /// ★ معاينة كاملة للصور: شاشة سوداء + PageView (سحب بين الصور) + عدّاد

  /// ★ ورقة سفلية موحّدة تظهر عند ضغط أيقونة من أزرار إجراءات المنشور.
  /// `draggable: true` ⇒ ورقة ديناميكية: سحب للأعلى للتكبير، وللأسفل للإغلاق.
  void showAction(
    BuildContext context, {
    IconData? icon,
    required String title,
    String? hint,
    List<Widget> Function(BuildContext sheetContext)? options,
    bool draggable = false,
  }) {
    final secondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.textPrimary : AppColors.lightText;

    showAppSheet<void>(
      context,
      scrollControlled: draggable,
      builder: (sheetContext) {
        // رأس الورقة (أيقونة اختيارية + جملة + تلميح) — مشترك بين النمطين.
        final header = <Widget>[
          if (icon != null) ...[
            Icon(icon, size: 18, color: secondary),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(hint, style: TextStyle(color: secondary, fontSize: 13)),
          ],
        ];

        // نمط ديناميكي: الورقة تتبع إصبع السحب وتتمدد/تنكمش.
        if (draggable) {
          return DraggableSheetBody(
            initialExtent: 0.5,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                ...header,
                if (options != null) ...[
                  const SizedBox(height: 8),
                  ...options(sheetContext),
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...header,
              if (options != null) ...[
                const SizedBox(height: 8),
                ...options(sheetContext),
              ],
            ],
          ),
        );
      },
    );
  }

  /// وزر إغلاق + تكبير/تصغير بالمزدوج.
  void openImagePreview(
    BuildContext context, {
    required List<String> images,
    required ServiceCategory service,
  }) {
    if (images.isEmpty) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'معاينة الصور',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (_, _, _) =>
          ImagePreviewDialog(images: images, service: service),
      transitionBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  /// ★ «طلب الآن» ⇒ محادثة مباشرة مع مقدّم الخدمة (لا الصفحة التعريفية)،
  /// ومعها معاينة المنشور كمرفق بانتظار إرسال المستخدم.
  ///
  /// متفق عليها في النواة ⇒ الزر يتصرف بنفسه في أي شاشة.
  void openServiceChat(
    BuildContext context, {
    required ServiceCategory service,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          conversationTitle: service.title,
          conversationId: 'service_${service.id}',
          avatar: service.iconName,
          phone: '',
          online: true,
          activity: 'متصل الآن',
          isGroup: false,
          postPreview: ChatPostPreview(
            title: service.title,
            subtitle: service.subtitle,
            imageUrl: service.coverImage,
            color: service.color,
          ),
        ),
      ),
    );
  }
}

/// تعليق واحد داخل ورقة التعليقات (وهمية أو يكتبها المستخدم).
class PostComment {
  const PostComment(this.author, this.text, {this.mine = false});

  final String author;
  final String text;

  /// تعليق المستخدم الحالي ⇒ يُعرض بلون مختلف (فقاعة بلون أنعم).
  final bool mine;
}

/// ============================================================================
///  ورقة التعليقات (Bottom Sheet): قائمة تعليقات + حقل إضافة.
///  Widget حالة مستقل: يملك الـ controller ويحرّره في dispose، وارتفاعه
///  maxHeight (لا ثابت) ⇒ يتقلّص مع لوحة المفاتيح بدل الفيض، ويختفي نظيفاً
///  عند الإغلاق (بلا «استخدام بعد التحرير» ولا شريط تحذير في Debug).
/// ============================================================================
class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({
    super.key,
    required this.service,
    required this.isDark,
    required this.comments,
  });

  final ServiceCategory service;
  final bool isDark;
  final List<PostComment> comments;

  @override
  State<PostCommentsSheet> createState() => PostCommentsSheetState();
}

class PostCommentsSheetState extends State<PostCommentsSheet> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => widget.comments.add(PostComment('أنت', text, mine: true)));
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.service.color;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;
    final secondary = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final line = widget.isDark ? AppColors.outline : AppColors.lightOutline;

    // ★ ورقة ديناميكية: السحب للأعلى يكشف المزيد، وللأسفل يغلقها، مع Snap.
    return DraggableSheetBody(
      initialExtent: 0.6,
      snapSizes: const [0.35, 0.45, 0.55, 0.6, 0.7, 0.8, 0.92],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        // ★ stretch ⇒ الرأس والفواصل تأخذ عرض الورقة كله (منطقة سحب كاملة).
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ★ الرأس منطقة سحب أيضاً: للأعلى توسّع الورقة، ولأسفل تصغيرها.
          SheetDragArea(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Icon(LucideIcons.messagesSquare, size: 18, color: secondary),
                  const SizedBox(width: 8),
                  Text(
                    'التعليقات (${widget.comments.length})',
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: line),
          // ★ القائمة مرتبطة بـ ScrollController الخاص بالورقة ⇒ السحب داخلها
          // يمرّرها أولاً، وبعد نهايتها يوسّع/يصغّر الورقة.
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _commentRow(widget.comments[i]),
            ),
          ),
          Divider(height: 1, color: line),
          // حقل التعليق + زر الإرسال (ثابت أسفل الورقة لا يمرّر).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: primary, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'اكتب تعليقاً…',
                      hintStyle: TextStyle(color: secondary, fontSize: 13),
                      filled: true,
                      fillColor: widget.isDark
                          ? AppColors.surface
                          : AppColors.lightBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _submit,
                  icon: Icon(LucideIcons.send, size: 20, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// صف تعليق واحد (صورة رمزية + فقاعة نص).
  Widget _commentRow(PostComment c) {
    final accent = widget.service.color;
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.15),
          ),
          child: Icon(LucideIcons.user, size: 16, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.mine
                  ? accent.withValues(alpha: 0.12)
                  : (widget.isDark ? AppColors.surfaceCard : Colors.white),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.author,
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(c.text, style: TextStyle(color: primary, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
///  جسم ورقة سفلية ديناميكي (Draggable): ارتفاعه نسبة من الشاشة ويتغيّر مع
///  السحب — للأعلى تكبير (حتى 92%) مع Snap عند مواضع محددة، وللأسفل تصغير
///  حتى الإغلاق. `builder` يستلم `ScrollController` الخاص بالورقة لربطه
///  بالقائمة الداخلية فتمرّر قائمة التعليقات نفسها.
/// ============================================================================
class DraggableSheetBody extends StatelessWidget {
  const DraggableSheetBody({
    super.key,
    required this.builder,
    this.initialExtent = 0.5,
    this.snapSizes = const [0.32, 0.42, 0.5, 0.6, 0.7, 0.8, 0.92],
  });

  final Widget Function(BuildContext context, ScrollController controller)
  builder;
  final double initialExtent;
  final List<double> snapSizes;

  static const double _kMinExtent = 0.32;
  static const double _kMaxExtent = 0.92;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialExtent,
      minChildSize: _kMinExtent,
      maxChildSize: _kMaxExtent,
      // ★ Snap: يتوقف عند المواضع المحددة (تجربة احترافية) بدل التوقف العشوائي.
      snap: true,
      snapSizes: snapSizes,
      builder: (context, controller) => builder(context, controller),
    );
  }
}

/// ============================================================================
///  منطقة سحب داخل الورقة (مثل رأسها): تنشئ نشاط سحب حقيقي
///  (`ScrollPosition.drag`) على نفس `ScrollController` الخاص بـ
///  `DraggableScrollableSheet`، فيصبح السحب للأعلى توسّعاً ولأسفل
///  تصغيراً/إغلاقاً — تماماً كالسحب على القوائم نفسها.
/// ============================================================================
class SheetDragArea extends StatefulWidget {
  const SheetDragArea({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<SheetDragArea> createState() => SheetDragAreaState();
}

class SheetDragAreaState extends State<SheetDragArea> {
  Drag? _drag;

  @override
  void dispose() {
    _drag?.cancel();
    _drag = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ★ عرض كامل ⇒ منطقة السحب تغطي كل عرض الرأس (وليس النص في المنتصف فقط).
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onVerticalDragStart: (details) {
          // ★ نشاط سحب رسمي للإطار ⇒ لا تحذيرات عند إعادة توجيه السحب،
          // والـ Snap/animation يعملان كما لو سحبت القائمة نفسها.
          _drag = widget.controller.position.drag(details, () => _drag = null);
        },
        onVerticalDragUpdate: (details) {
          _drag?.update(
            DragUpdateDetails(
              delta: Offset(0, details.delta.dy),
              primaryDelta: details.delta.dy,
              globalPosition: details.globalPosition,
              sourceTimeStamp: details.sourceTimeStamp,
            ),
          );
        },
        onVerticalDragEnd: (details) {
          // إنهاء السحب ⇒ إطلاق الـ Snap على أقرب موضع.
          _drag?.end(details);
          _drag = null;
        },
        onVerticalDragCancel: () {
          _drag?.cancel();
          _drag = null;
        },
        child: widget.child,
      ),
    );
  }
}

/// ============================================================================
///  معاينة صور البطاقة: شاشة كاملة سوداء مع PageView للتنقل بين الصور،
///  عدّاد «2/3»، زر إغلاق، وتكبير/تصغير بالمزدوج (InteractiveViewer).
///  تدعم روابط الشبكة ومسارات الأصول المحلية معاً (مع بديل أيقونة).
/// ============================================================================
class ImagePreviewDialog extends StatefulWidget {
  const ImagePreviewDialog({
    super.key,
    required this.images,
    required this.service,
  });

  final List<String> images;
  final ServiceCategory service;

  @override
  State<ImagePreviewDialog> createState() => ImagePreviewDialogState();
}

class ImagePreviewDialogState extends State<ImagePreviewDialog>
    with SingleTickerProviderStateMixin {
  late final PageController _page = PageController(initialPage: 0);
  late int _index = 0;

  // ★ التكبير/التصغير: قرص الإصبعين (pinch) + زر تكبير/تصغير، بتكبير
  // *متحرّك* حول مركز الشاشة (لا قفز من الزاوية) وبانتقال أنيميشن ناعم.
  final TransformationController _zoom = TransformationController();
  late final AnimationController _zoomAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  Animation<Matrix4>? _zoomTween;
  bool _zoomed = false;
  Size _viewport = Size.zero;

  // ★ نقرة واحدة على الصورة = تكبير/تصغير (Listener خام ⇒ تعمل في الحالتين،
  // ويبقى السحب الأفقي للتنقل بين الصور بلا تعارض).
  Offset? _pressAt;
  DateTime? _pressedAt;

  static const double _kTapSlop = 12;
  static const Duration _kTapWindow = Duration(milliseconds: 350);

  void _onPointerDown(PointerDownEvent event) {
    _pressAt = event.position;
    _pressedAt = DateTime.now();
  }

  void _onPointerUp(PointerUpEvent event) {
    final start = _pressAt;
    final at = _pressedAt;
    _pressAt = null;
    _pressedAt = null;
    if (start == null || at == null) return;
    final moved = (event.position - start).distance;
    final held = DateTime.now().difference(at);
    if (moved < _kTapSlop && held < _kTapWindow) _toggleZoom();
  }

  @override
  void initState() {
    super.initState();
    _zoomAnim.addListener(() {
      final tween = _zoomTween;
      if (tween != null) _zoom.value = tween.value;
    });
  }

  /// تكبير/تصغير ناعم حول مركز العرض ⇒ لا قفز إلى الزوايا.
  void _animateZoomTo(bool zoomIn) {
    final target = zoomIn ? 2.5 : 1.0;
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    final end = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(target, target, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);

    _zoomTween = Matrix4Tween(
      begin: _zoom.value.clone(),
      end: end,
    ).animate(CurvedAnimation(parent: _zoomAnim, curve: Curves.easeOutCubic));

    setState(() => _zoomed = zoomIn);
    _zoomAnim
      ..reset()
      ..forward();
  }

  void _toggleZoom() => _animateZoomTo(!_zoomed);

  @override
  void dispose() {
    _zoomAnim.dispose();
    _page.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// بديل أيقونة عند فشل تحميل الصورة.
  Widget _fallback() => Center(
    child: Icon(
      MockData.getIconByName(widget.service.iconName),
      size: 72,
      color: widget.service.color,
    ),
  );

  Widget _image(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // ★ LayoutBuilder ⇒ مركز التكبير = مركز العرض الفعلي.
      body: LayoutBuilder(
        builder: (context, constraints) {
          _viewport = Size(constraints.maxWidth, constraints.maxHeight);
          return _buildStack(context);
        },
      ),
    );
  }

  Widget _buildStack(BuildContext context) {
    final many = widget.images.length > 1;
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          child: PageView.builder(
            controller: _page,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              // ★ عودة ناعمة للوضع الطبيعي عند الانتقال لصورة أخرى.
              if (_zoomed) _animateZoomTo(false);
              setState(() => _index = i);
            },
            itemBuilder: (context, i) => InteractiveViewer(
              transformationController: _zoom,
              minScale: 1,
              maxScale: 4,
              // ★ pan مُفعّل فقط بعد التكبير ⇒ السحب الأفقي ينقل بين الصور
              // ما دامت الصورة غير مكبّرة.
              panEnabled: _zoomed,
              onInteractionEnd: (_) => setState(
                () => _zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01,
              ),
              // ★ قرص الإصبعين للتكبير/التصغير (pinch) + زر أعلى الشاشة.
              child: Center(child: _image(widget.images[i])),
            ),
          ),
        ),
        // عدّاد الصور.
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 8,
          start: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        // ★ شعار التطبيق بجوار زر الإغلاق.
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 4,
          end: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'گريب منك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              // ★ زر التكبير/التصغير (يعمل دائماً، بخلاف النقر المزدوج الذي
              // يبتلعه الـ InteractiveViewer بعد التكبير).
              IconButton(
                onPressed: _toggleZoom,
                icon: Icon(
                  _zoomed ? LucideIcons.zoomOut : LucideIcons.zoomIn,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
        if (many)
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: i == _index ? 1 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ============================================================================
///  PostReactionSheet — ورقة تفاعل المنشور: صفّ إيموجي تفاعل + قائمة المتفاعلين.
///
///  ★ الضغط على زر التفاعل في البطاقة يفتح هذه الورقة، ومن داخلها يختار
///    المستخدم واحداً من تفاعلات فيسبوك السبعة (إيموجي الجهاز)، فيُحفظ التفاعل
///    ويظهر إيموجيه فوراً بجوار أيقونات البطاقة، ثم تُغلق الورقة.
///
///  ★ بدون أصول صور ⇒ يعتمد على إيموجي النظام فقط.
/// ============================================================================
class PostReactionSheet extends StatefulWidget {
  const PostReactionSheet({
    super.key,
    required this.service,
    required this.isDark,
    required this.reactedUsers,
    required this.current,
    required this.onReact,
  });

  final ServiceCategory service;
  final bool isDark;

  /// أسماء مستخدمين وهميين لكل تفاعل (لعرض «من تفاعل مع المنشور»).
  final Map<int, List<String>> reactedUsers;

  /// التفاعل الحالي (0 = بلا).
  final int current;

  /// يُستدعى عند اختيار إيموجي (مع 0 لإلغاء التفاعل).
  final ValueChanged<int> onReact;

  @override
  State<PostReactionSheet> createState() => PostReactionSheetState();
}

class PostReactionSheetState extends State<PostReactionSheet> {
  /// تفاعل محلي ⇒ صفّ الإيموجي يتحدّث فوراً داخل الورقة.
  late int _current = PostReaction.normalize(widget.current);

  /// الإيموجي الذي يمرّ عليه الإصبع ⇒ تكبير + تسمية (كما في فيسبوك).
  int? _hovered;

  /// تفاعل واحد في صفّ الإيموجي: تكبير عند المرور/الاختيار + إظهار الاسم.
  Widget _emojiButton(PostReaction reaction) {
    final active = _current == reaction.value;
    final hovered = _hovered == reaction.value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() => _current = active ? 0 : reaction.value);
          widget.onReact(_current);
        },
        onHover: (event) =>
            setState(() => _hovered = event ? reaction.value : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.35 : (hovered ? 1.25 : 1),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: Text(
                  reaction.emoji,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.1,
                    shadows: [
                      if (active || hovered)
                        Shadow(
                          color: reaction.color.withValues(alpha: 0.55),
                          blurRadius: 12,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                opacity: active || hovered ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: Text(
                  reaction.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: reaction.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// المتفاعلون: تفاعل المستخدم أولاً ثم الوهميين، مع إيموجي التفاعل
  /// بلون التفاعل لكل شخص (كما يعرض فيسبوك).
  Widget _reactedList() {
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;

    final entries = <(String, int)>[
      if (_current != 0) ('أنت', _current),
      for (final reaction in PostReaction.all)
        for (final name
            in widget.reactedUsers[reaction.value] ?? const <String>[])
          (name, reaction.value),
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final (name, value) = entries[i];
        final reaction = PostReaction.byValue(value)!;
        final mine = name == 'أنت';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reaction.color.withValues(alpha: 0.15),
                ),
                child: Text(
                  name.characters.first,
                  style: TextStyle(
                    color: reaction.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: mine ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              ReactionEmoji(value, size: 18),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.isDark ? AppColors.textPrimary : AppColors.lightText;
    final line = widget.isDark ? AppColors.outline : AppColors.lightOutline;

    final selected = PostReaction.byValue(_current);

    return DraggableSheetBody(
      initialExtent: 0.55,
      snapSizes: const [0.35, 0.45, 0.55, 0.65, 0.8],
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetDragArea(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Text(
                    'تفاعل المنشور',
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (selected != null)
                    Text(
                      selected.label,
                      style: TextStyle(
                        color: selected.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: line),
          // ★ صفّ الإيموجي: العرض والتحييد بسحبة (onHover) على الحاسوب.
          MouseRegion(
            onHover: (event) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final dx = event.localPosition.dx;
              final width = box.size.width / PostReaction.all.length;
              final index = (dx / width).floor().clamp(
                0,
                PostReaction.all.length - 1,
              );
              final value = PostReaction.all[index].value;
              if (_hovered != value) setState(() => _hovered = value);
            },
            onExit: (_) => setState(() => _hovered = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final reaction in PostReaction.all)
                    _emojiButton(reaction),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: line),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _reactedList(),
            ),
          ),
        ],
      ),
    );
  }
}
