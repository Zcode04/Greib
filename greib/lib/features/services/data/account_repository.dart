import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/models/account_model.dart';
import '../../../core/models/service_model.dart';
import 'services_repository.dart';

/// ============================================================================
///  AccountRepository — طبقة البيانات لحسابات المستخدمين (SSOT).
///
///  نفس نمط `ServicesRepository` تماماً:
///  - مصدر واحد للحقيقة: assets/data/accounts.json
///  - الواجهة لا تعرف من أين تأتي البيانات (استبدال لاحق بـ API = صفر تغيير).
///  - تحمّل مرة واحدة قبل runApp (main.dart) ⇒ لا شاشة تحميل ولا وميض.
///
///  ★ التوليد: الملف يحتوي «بذور» (AccountSeed) عامة، ولكل خدمة نولّد منها
///  خمسة حسابات ثابتة (نفس الترتيب ونفس الصور في كل مرة ⇒ نفس العرض دائماً).
///
///  ★ المنشورات: كل حساب يبني قائمته من منشورات **بذرته هو** مع استبدال
///  {service} باسم الخدمة ⇒ منشورات تخصّ هذا الحساب وحده، لا منشورات
///  مشتركة بين متاجر مختلفة (وهو المطلوب بالضبط في صفحة الحساب).
/// ============================================================================
class AccountRepository {
  AccountRepository._();

  static const _assetPath = 'assets/data/accounts.json';

  /// نسخة واحدة فقط (Singleton) — التحميل يحدث مرة واحدة في عمر التطبيق.
  static final AccountRepository instance = AccountRepository._();

  /// كم حساباً لكل خدمة (الترتيب ثابت ⇒ نفس العرض في كل مرة).
  static const int accountsPerService = 5;

  List<AccountSeed>? _seeds;

  /// هل البيانات جاهزة؟ تستخدمه الواجهة لتفادي الوميض قبل التحميل.
  bool get isLoaded => _seeds != null;

  // ================= التحميل =================

  /// يحمّل الملف ويبني الـ cache. يُستدعى مرة واحدة قبل runApp.
  Future<void> load() async {
    if (_seeds != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;

    _seeds = (decoded['accountSeeds'] as List<dynamic>? ?? const [])
        .map((e) => AccountSeed.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ================= القراءة =================

  /// حسابات خدمة معيّنة (خمسة دائماً) — مرتّبة ثابتاً.
  List<AccountProfile> forService(String serviceId) {
    final service = ServicesRepository.instance.byId(serviceId);
    if (service == null || _seeds == null || _seeds!.isEmpty) return const [];
    return List.generate(
      accountsPerService,
      (i) => _build(_seeds![i % _seeds!.length], service, i),
    );
  }

  /// حساب واحد بمعرّفه.
  ///
  /// المعرّف = serviceId + "::" + بذرته، مثل: `food::express`.
  AccountProfile? byId(String accountId) {
    final parts = accountId.split('::');
    if (parts.length != 2 || _seeds == null) return null;

    final service = ServicesRepository.instance.byId(parts.first);
    if (service == null) return null;

    final seed = _seedFor(parts.last);
    // ★ الفهرس جزء من الهوية ⇒ نفس الصور والأرقام في كل مرة.
    final index = _seeds!.indexOf(seed) % accountsPerService;
    return _build(seed, service, index);
  }

  /// منشورات حساب محدد — **قائمة خاصة به** (ليست منشورات الخدمة).
  List<AccountPost> postsFor(String accountId) {
    final parts = accountId.split('::');
    if (parts.length != 2 || _seeds == null) return const [];

    final seed = _seedFor(parts.last);
    final serviceTitle =
        ServicesRepository.instance.byId(parts.first)?.title ?? '';

    return List.generate(seed.posts.length, (i) {
      final post = seed.posts[i];
      return AccountPost(
        // ★ معرّف المنشور عام بين التبويبات الثلاثة ليبقى تفاعله واحداً
        //   بغضّ النظر عن التبويب المعروض.
        id: '${accountId}_p$i',
        accountId: accountId,
        text: post.text.replaceAll('{service}', serviceTitle),
        imageUrls: post.images,
        timeAgo: post.timeAgo,
        likes: post.likes,
        comments: post.comments,
        shares: post.shares,
      );
    });
  }

  /// كل الحسابات (مسطّحة) — مفيدة لصفحة «الكل» العامة لاحقاً.
  List<AccountProfile> get all {
    final services = ServicesRepository.instance.all;
    return [for (final service in services) ...forService(service.id)];
  }

  // ================= التوليد =================

  /// البذرة بالمفتاح، مع رجوع للأولى عند عدم وجوده (تفادي الأخطاء).
  AccountSeed _seedFor(String key) => _seeds!.firstWhere(
    (s) => s.key == key,
    orElse: () => _seeds!.first,
  );

  /// يبني حساباً كاملاً من بذرته + خدمته.
  AccountProfile _build(AccountSeed seed, ServiceCategory service, int index) {
    final id = '${service.id}::${seed.key}';
    return AccountProfile(
      id: id,
      serviceId: service.id,
      name: seed.nameTemplate.replaceAll('{service}', service.title),
      bio: seed.bioTemplate.replaceAll('{service}', service.title),
      location: seed.location,
      isVerified: seed.verified,
      avatarUrl: _pick(seed.avatars, index),
      coverUrl: _pick(seed.covers, index),
      // أرقام ثابتة مشتقّة من المعرّف ⇒ نفس العرض في كل مرة.
      followers: 1200 + (id.hashCode.abs() % 9000),
      following: 60 + (id.hashCode.abs() % 900),
      postsCount: seed.posts.length,
      rating: 4.2 + (index % 5) * 0.2,
    );
  }

  /// يختار عنصراً من قائمة دوارة ⇒ تتغيّر البذرة مع الفهرس (خصوصية لكل حساب).
  String? _pick(List<String> items, int index) {
    if (items.isEmpty) return null;
    return items[index % items.length];
  }
}

/// ============================================================================
///  AccountSeed — "بذرة" حساب من ملف JSON: قالب عام يُخصَّص لكل خدمة.
///  (قوالب بأسماء محايدة: «{service} إكسبريس» ⇒ «توصيل طعام إكسبريس»).
/// ============================================================================
class AccountSeed {
  final String key;
  final String nameTemplate;
  final String bioTemplate;
  final String location;
  final bool verified;
  final List<String> avatars;
  final List<String> covers;
  final List<AccountPostSeed> posts;

  const AccountSeed({
    required this.key,
    required this.nameTemplate,
    required this.bioTemplate,
    required this.location,
    required this.verified,
    required this.avatars,
    required this.covers,
    required this.posts,
  });

  factory AccountSeed.fromJson(Map<String, dynamic> json) => AccountSeed(
    key: json['key'] as String? ?? '',
    nameTemplate: json['nameTemplate'] as String? ?? '',
    bioTemplate: json['bioTemplate'] as String? ?? '',
    location: json['location'] as String? ?? '',
    verified: json['verified'] as bool? ?? false,
    avatars: (json['avatars'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    covers: (json['covers'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    posts: (json['posts'] as List<dynamic>? ?? const [])
        .map((e) => AccountPostSeed.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// ============================================================================
///  AccountPostSeed — منشور داخل البذرة (قالب يُخصَّص باسم الخدمة).
///  يحمل أرقام التفاعل الحقيقية لأن تبويب «الأكثر تفاعلاً» يرتّب بها.
/// ============================================================================
class AccountPostSeed {
  final String text;
  final List<String> images;
  final String timeAgo;
  final int likes;
  final int comments;
  final int shares;

  const AccountPostSeed({
    required this.text,
    required this.images,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  factory AccountPostSeed.fromJson(Map<String, dynamic> json) => AccountPostSeed(
    text: json['text'] as String? ?? '',
    images: (json['images'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    timeAgo: json['timeAgo'] as String? ?? 'الآن',
    likes: (json['likes'] as num?)?.toInt() ?? 0,
    comments: (json['comments'] as num?)?.toInt() ?? 0,
    shares: (json['shares'] as num?)?.toInt() ?? 0,
  );
}

