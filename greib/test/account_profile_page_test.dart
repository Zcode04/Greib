import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:greib_menk/features/services/data/account_repository.dart';
import 'package:greib_menk/features/services/data/services_repository.dart';
import 'package:greib_menk/features/services/presentation/account_profile_page.dart';

/// ============================================================================
///  اختبارات صفحة الحساب (AccountProfilePage).
///
///  ★ الفكرة المُختبَرة: صفحة الحساب يجب أن تعرض بيانات الحساب (اسم/وصف/
///  زرّي مراسلة ومتابعة) وأن تبويباتها تجلب **منشورات هذا الحساب وحده**،
///  لا منشورات مشتركة بين متاجر مختلفة (مشكلة كانت في صفحة مقدم الخدمة).
/// ============================================================================
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ServicesRepository.instance.load();
    await AccountRepository.instance.load();
  });

  /// يبني الصفحة داخل MaterialApp مع ثيم داكن (نفس ألوان التطبيق).
  /// ★ شاشة بعرض 400 وطول 900 (محاكاة هاتف) ⇒ نرى الترويسة كاملة + التبويبات.
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: Directionality(textDirection: TextDirection.rtl, child: child),
  );

  /// يضبط مقاس شاشة هاتف قبل الاختبار.
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('صفحة الحساب تعرض الاسم والوصف وزرّي (مراسلة / متابعة)', (
    tester,
  ) async {
    usePhoneScreen(tester);
    final account = AccountRepository.instance.forService('food').first;
    expect(account, isNotNull);

    await tester.pumpWidget(wrap(AccountProfilePage(accountId: account.id)));
    await tester.pump(const Duration(milliseconds: 300));

    // اسم الحساب (قالب «{service} إكسبريس» تخصّص باسم الخدمة).
    expect(find.textContaining('إكسبريس'), findsWidgets);
    // الوصف موجود أسفل الاسم.
    expect(find.textContaining('نوصل طلبك'), findsOneWidget);
    // الزرّان موجودان مباشرة بعد الوصف.
    expect(find.text('مراسلة'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);

    // التبويبات الثلاثة نفسها في صفحة الخدمة (شريط مثبّت أسفل الترويسة).
    // نمرّر لأعلى قليلاً لإظهاره على الشاشة ثم نتحقق.
    await tester.drag(find.byType(AccountProfilePage), const Offset(0, -250));
    await tester.pump();

    expect(find.text('الأحدث'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('الأكثر تفاعلاً'), findsOneWidget);
  });

  testWidgets('زر المتابعة يبدّل حالته إلى «متابَع»', (tester) async {
    usePhoneScreen(tester);
    final account = AccountRepository.instance.forService('pharmacy').first;

    await tester.pumpWidget(wrap(AccountProfilePage(accountId: account.id)));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('متابعة'), findsOneWidget);
    await tester.tap(find.text('متابعة'));
    await tester.pump();

    expect(find.text('متابَع'), findsOneWidget);
  });

  // ================= طبقة البيانات: الأساس الصلب =================

  test('كل منشور ينتمي للحساب المحدد وحده (لا خلط بين المتاجر)', () {
    final accounts = AccountRepository.instance.forService('food');

    for (final account in accounts) {
      final posts = AccountRepository.instance.postsFor(account.id);
      expect(posts, isNotEmpty, reason: 'كل حساب يجب أن يكون له منشورات');
      // ★ كل منشور يحمل معرّف حسابه ⇒ لا يمكن أن يُرجَع منشور حساب آخر.
      expect(
        posts.every((p) => p.accountId == account.id),
        isTrue,
        reason: 'منشور لا ينتمي للحساب المطلوب',
      );
    }

    // ومعرّفات المنشورات لا تتكرر بين حسابين.
    final ids = accounts
        .map((a) => AccountRepository.instance.postsFor(a.id).map((p) => p.id).toSet())
        .toList();
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        expect(
          ids[i].intersection(ids[j]),
          isEmpty,
          reason: 'تعارض منشورات بين حسابين $i و $j',
        );
      }
    }
  });

  test('حسابا الخدمة نفسها لهما منشورات مختلفة تماماً', () {
    final accounts = AccountRepository.instance.forService('food');
    final a = AccountRepository.instance.postsFor(accounts[0].id);
    final b = AccountRepository.instance.postsFor(accounts[1].id);

    // لا نص منشور مشترك (⇒ ليسا نفس المنشورات من متاجر مختلفة).
    final shared = a.map((p) => p.text).toSet().intersection(b.map((p) => p.text).toSet());
    expect(shared, isEmpty, reason: 'تكرار نصوص ⇒ المنشورات مشتركة، وهذا خطأ');
  });

  test('منشورات الحساب مستقلة عن منشورات الخدمة المشتركة', () {
    final account = AccountRepository.instance.forService('tourism').first;
    final accountTexts = AccountRepository.instance
        .postsFor(account.id)
        .map((p) => p.text)
        .toSet();
    final shared = ServicesRepository.instance
        .postsFor('tourism')
        .map((p) => p.text)
        .where(accountTexts.contains);

    expect(shared, isEmpty, reason: 'منشورات الحساب تخصّه وحده');
  });

  test('الاسم والوصف يتخصّصان باسم الخدمة (لا يبقى {service})', () {
    final account = AccountRepository.instance.forService('food').first;
    expect(account.name, isNot(contains('{service}')));
    expect(account.bio, isNot(contains('{service}')));
    expect(account.name, contains('توصيل طعام'));
    expect(account.avatarUrl, isNotNull);
    expect(account.coverUrl, isNotNull);
  });

  test('معرّف غير صالح يعيد null بدل الكراش', () {
    expect(AccountRepository.instance.byId('no-separator'), isNull);
    expect(AccountRepository.instance.postsFor('no-separator'), isEmpty);
  });
}
