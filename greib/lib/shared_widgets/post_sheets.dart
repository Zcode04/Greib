import 'package:flutter/material.dart';

import '../core/models/service_model.dart';
import '../core/widgets/app_sheet.dart';
import '../core/widgets/draggable_sheet_body.dart';
import '../core/widgets/image_preview_dialog.dart';
import '../../features/communication_and_support/chat_screen.dart';
import 'sheets/post_comments_sheet.dart';
import 'sheets/post_reaction_sheet.dart';
import 'sheets/post_share_sheet.dart';
import 'post_reaction.dart';

export 'sheets/post_comments_sheet.dart' show PostComment, PostCommentsSheet;
export 'sheets/post_reaction_sheet.dart' show PostReactionSheet;
export 'sheets/post_share_sheet.dart' show PostShareSheet;

/// ============================================================================
///  PostSheetsController — النواة المشتركة لكل منشور في التطبيق.
///
///  ★ يحتفظ بالحالة (مفضلة / تفاعل / تعليقات) ويتيح فتح الأوراق
///    بنفس السلوك في أي شاشة (الرئيسية، تفاصيل الخدمة، الحساب…).
///
///  ★ يطلب `notifyListeners` عند أي تغيير ⇒ أي شاشة تستمع
///    (`ListenableBuilder`) تعيد بناء البطاقات تلقائياً.
///
///  الاستخدام:
///    final ctrl = PostSheetsController(isDark: isDark);
///    // في زر التعليق:
///    ctrl.showComments(context, postId: post.id, service: service);
/// ============================================================================
class PostSheetsController extends ChangeNotifier {
  PostSheetsController({required this.isDark});

  final bool isDark;

  /// الخدمات المحفوظة.
  final Set<String> _favorites = {};

  /// تفاعل كل منشور: 0 = بلا، 1..6 = تفاعلات.
  final Map<String, int> _reactions = {};

  /// تعليقات كل منشور.
  final Map<String, List<PostComment>> _comments = {};

  /// أسماء مستخدمين وهميين لكل تفاعل.
  static const Map<int, List<String>> kMockReactedUsers = {
    1: ['سارة', 'محمد', 'ريم', 'خالد', 'نور', 'يوسف'],
    2: ['آية', 'سليم', 'مريم'],
    3: ['هند', 'رامي', 'باسمة'],
    5: ['ليان', 'عمر', 'هدى'],
  };

  static const List<String> kMockLikedUsers = [
    'سارة',
    'محمد',
    'ريم',
    'خالد',
    'نور',
    'يوسف',
  ];

  static const List<String> kMockDislikedUsers = ['ليان', 'عمر', 'هدى', 'فهد'];

  // ═══════════════════════════════ القراءة ═══════════════════════════════════

  bool isFavorite(String postId) => _favorites.contains(postId);

  int reactionOf(String postId) =>
      PostReaction.normalize(_reactions[postId] ?? 0);

  static String countFor(String id, int span, int min) =>
      (min + id.hashCode.abs() % span).toString();

  // ═══════════════════════════════ التعديل ══════════════════════════════════

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

  // ═══════════════════════════════ الأوراق ══════════════════════════════════

  /// ورقة التعليقات.
  void showComments(
    BuildContext context, {
    required String postId,
    required ServiceCategory service,
  }) {
    final list = _comments.putIfAbsent(
      postId,
      () => [
        const PostComment('سارة', 'الخدمة ممتازة وسرعة التنفيذ رهيبة.'),
        const PostComment(
          'محمد',
          'جرّبتها أمس وأنصح فيها بشدة.',
          replies: [
            PostComment('سارة', 'نعم خدمة ممتازة والأسعار مناسبة.', seq: 1),
            PostComment('ريم', 'هل تعمل في جميع المناطق؟', seq: 2),
          ],
        ),
        const PostComment(
          'ريم',
          'توفر Apple Intelligence في إصدار تجريبي. قد لا تتوفر بعض الميزات في '
          'كل المناطق أو بكل اللغات لمعرفة المزيد عن توفر الميزات واللغات '
          'ومتطلبات النظام تفضل بزيارة support.apple.com/ar-ae/121115\n'
          'يكون دعم كاربلاي ميزة أساسية أو خياراً متاحاً في العديد من السيارات '
          'الجديدة موديل 2016 وأحدث، ويوفر بعض المصنعين تحديثات للبرامج في '
          'الموديلات الأقدم، ولا تتوفر جميع الموديلات في جميع المناطق. يخضع دعم '
          'كاربلاي للتغيير ولمزيد من التفاصيل راجع وكيل السيارات.\n'
          'إن Apple Pay هي خدمة تقدمها بعض الشركات التابعة لشركة Apple كما هو '
          'محدد في إشعار خصوصية Apple Pay.',
        ),
      ],
    );

    showAppSheet<void>(
      context,
      builder: (_) =>
          PostCommentsSheet(service: service, isDark: isDark, comments: list),
    );
  }

  /// ورقة التفاعل.
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
          Navigator.of(sheetContext).maybePop();
        },
      ),
    );
  }

  /// ورقة مشاركة المنشور التفاعلية (على طريقة فيسبوك/ميتا).
  void showShare(
    BuildContext context, {
    required String postId,
    required ServiceCategory service,
    VoidCallback? onRepost,
  }) {
    showAppSheet<void>(
      context,
      builder: (_) => PostShareSheet(
        service: service,
        postId: postId,
        isDark: isDark,
        isSaved: isFavorite(postId),
        onSaveToggle: () => setFavorite(postId, !isFavorite(postId)),
        onChatTap: () => openServiceChat(context, service: service),
        onRepost: onRepost,
      ),
    );
  }

  /// معاينة كاملة للصور.
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

  /// فتح محادثة مباشرة مع مقدّم الخدمة («طلب الآن»).
  ///
  /// ★ القيم الاختيارية تتيح إعادة استخدام نفس المحادثة بمرفق طلب مختلف
  ///   (مثل البث المباشر: المتجر الباثّ + المنتج المطلوب) بلا تكرار منطق.
  ///   تركها فارغة ⇒ نفس السلوك الأصلي في المنشورات تماماً.
  void openServiceChat(
    BuildContext context, {
    required ServiceCategory service,
    String? conversationTitle,
    String? avatar,
    ChatPostPreview? preview,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          conversationTitle: conversationTitle ?? service.title,
          conversationId: 'service_${service.id}',
          avatar: avatar ?? service.iconName,
          phone: '',
          online: true,
          activity: 'متصل الآن',
          isGroup: false,
          postPreview:
              preview ??
              ChatPostPreview(
                title: service.title,
                subtitle: service.subtitle,
                imageUrl: service.coverImage,
                color: service.color,
              ),
        ),
      ),
    );
  }

  /// ورقة إجراء عام (مثل إعادة النشر): أيقونة + عنوان + تلميح + خيارات.
  /// `draggable: true` ⇒ ورقة ديناميكية قابلة للسحب.
  void showAction(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String title,
    String? hint,
    List<Widget> Function(BuildContext sheetContext)? options,
    bool draggable = false,
  }) {
    showAppSheet<void>(
      context,
      scrollControlled: draggable,
      builder: (sheetContext) {
        final primary =
            Theme.of(sheetContext).colorScheme.onSurface;
        final secondary = Theme.of(sheetContext)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.6);

        final header = <Widget>[
          if (iconWidget != null) ...[
            iconWidget,
            const SizedBox(height: 8),
          ] else if (icon != null) ...[
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
}
