import 'service_model.dart';

/// ============================================================================
///  AccountProfile — حساب المستخدم/المتجر (Entity).
///
///  ★ لماذا هذا الموديل؟
///  صفحة الحساب تحتاج بيانات لا تخصّ خدمة بعينها: صورة بروفايل، صورة غلاف،
///  وصف (Bio)، ومنشورات **تخصّ هذا الحساب وحده** — بخلاف صفحة الخدمة التي
///  تعرض منشورات مشتركة بين عدة متاجر.
///
///  البيانات تأتي من assets/data/accounts.json وهو المصدر الوحيد للحقيقة،
///  فتستبدله لاحقاً بطبقة API دون تغيير الواجهة.
/// ============================================================================
class AccountProfile {
  final String id;

  /// معرّف الخدمة المرتبطة (لعرض اسمها ولونها في صفحة الحساب).
  final String serviceId;

  final String name;

  /// الوصف (Bio) — يظهر أسفل الاسم وقبل زرّي (مراسلة / متابعة).
  final String bio;

  final String location;
  final bool isVerified;

  /// صورة البروفايل (متداخلة فوق الغلاف).
  final String? avatarUrl;

  /// صورة الغلاف أعلى الصفحة.
  final String? coverUrl;

  /// ★ حالة الاتصال (Mock مشتق من المعرّف ⇒ ثابت لنفس الحساب في كل مرة).
  ///   يُستبدل لاحقاً بحقل `isOnline` قادم من الـ API.
  bool get isOnline => _presenceSeed % 3 != 0;

  /// ★ نص آخر ظهور: «متصل الآن» أو «آخر ظهور منذ …» (نفس مشتقّة المعرّف).
  String get presenceLabel {
    if (isOnline) return 'متصل الآن';
    final minutes = _presenceSeed % 180 + 5;
    if (minutes < 60) return 'آخر ظهور منذ $minutes دقيقة';
    final hours = (minutes / 60).floor();
    return 'آخر ظهور منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
  }

  int get _presenceSeed => id.hashCode.abs();

  /// أرقام ثابتة مشتقّة من المعرّف ⇒ نفس العرض في كل مرة (بلا عشوائية).
  final int followers;
  final int following;
  final int postsCount;
  final double rating;

  const AccountProfile({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.bio,
    required this.location,
    required this.isVerified,
    required this.avatarUrl,
    required this.coverUrl,
    required this.followers,
    required this.following,
    required this.postsCount,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'name': name,
    'bio': bio,
    'location': location,
    'isVerified': isVerified,
    'avatarUrl': avatarUrl,
    'coverUrl': coverUrl,
    'followers': followers,
    'following': following,
    'postsCount': postsCount,
    'rating': rating,
  };
}

/// ============================================================================
///  AccountPost — منشور خاص **بحساب واحد** (وليس منشور خدمة مشترك).
///
///  ★ يحمل تفاعلاته الحقيقية (likes/comments/shares) لأن تبويب
///  «الأكثر تفاعلاً» في صفحة الحساب يرتّب بها، بخلاف صفحة الخدمة التي
///  كانت ترتّب عشوائياً بنص المنشور.
/// ============================================================================
class AccountPost {
  final String id;
  final String accountId;
  final String text;
  final List<String> imageUrls;
  final String timeAgo;
  final int likes;
  final int comments;
  final int shares;

  const AccountPost({
    required this.id,
    required this.accountId,
    required this.text,
    required this.imageUrls,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  /// مجموع التفاعلات — يُستخدم لترتيب تبويب «الأكثر تفاعلاً».
  int get engagement => likes + comments * 2 + shares * 3;

  /// يحوّل منشور الحساب إلى `ServicePost` حتى نعيد استخدام
  /// `ServicePostCard` الموحّد (نفس تصميم المنشورات في التطبيق كله).
  ServicePost toServicePost() => ServicePost(
    text: text,
    imageUrls: imageUrls,
    timeAgo: timeAgo,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountId': accountId,
    'text': text,
    'imageUrls': imageUrls,
    'timeAgo': timeAgo,
    'likes': likes,
    'comments': comments,
    'shares': shares,
  };
}
