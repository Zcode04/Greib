import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/core/theme/app_theme.dart';
import 'package:greib_menk/features/home_and_services/widgets/hotels_section.dart';

void main() {
  Widget wrap({
    required double width,
    Brightness brightness = Brightness.dark,
  }) {
    return MaterialApp(
      theme: brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      home: Scaffold(
        // ★ في Home القسم داخل SingleChildScrollView ⇒ لا حدّ للارتفاع.
        // هنا نحاكي ذلك حتى نبني كل المنشورات دون فيض.
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: width,
              // حشو الصفحة كما في Home (20) حتى نختبر تمدد الـ OverflowBox.
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: HotelsSection(isDark: brightness == Brightness.dark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('يبدأ بوضع المنشورات: بوست واحد + زر عرض المزيد', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 390));
    await tester.pump(const Duration(milliseconds: 400));

    // أول منشور ظاهر.
    expect(find.text('فندق برج العرب'), findsOneWidget);
    // غير ظاهر بعد (يظهر بعد الضغط).
    expect(find.text('منتجع جزيرة السعديات'), findsNothing);
    // الزرّان موجودان.
    expect(find.text('عرض المزيد'), findsOneWidget);
    expect(find.text('عرض الشرائح'), findsOneWidget);
  });

  testWidgets('عرض المزيد يجلب منشوراً جديداً في كل ضغطة', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 390));
    await tester.pump(const Duration(milliseconds: 400));

    // ★ نبحث في الشجرة كلها (skipOffstage: false) ⇒ لا ندخل في الفهرسة
    // (lazy) للعناصر التي خرجت عن الشاشة.
    final postTitle = (String t) => find.text(t, skipOffstage: false);

    // ⚠ الزر ينزل مع نمو المنشورات ⇒ نمرّر له قبل كل ضغطة.
    Future<void> tapShowMore() async {
      final more = find.text('عرض المزيد');
      await tester.ensureVisible(more);
      await tester.pumpAndSettle();
      await tester.tap(more);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await tapShowMore();
    expect(postTitle('منتجع جزيرة السعديات'), findsOneWidget);

    await tapShowMore();
    expect(postTitle('فندق قصر الإمارات'), findsOneWidget);

    // آخر منشور ⇒ يختفي زر «عرض المزيد».
    await tapShowMore();
    expect(postTitle('منتجع واحة الصحراء'), findsOneWidget);
    expect(find.text('عرض المزيد'), findsNothing);
  });

  testWidgets('زر التبديل ينقل بين المنشورات والشرائح', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 390));
    await tester.pump(const Duration(milliseconds: 400));

    // إلى الشرائح: يظهر PageView + نقاط + تغيّر نص الزر.
    await tester.tap(find.text('عرض الشرائح'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('عرض كمنشورات'), findsOneWidget);

    // العودة للمنشورات.
    await tester.tap(find.text('عرض كمنشورات'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PageView), findsNothing);
    expect(find.text('عرض الشرائح'), findsOneWidget);
  });

  testWidgets('الوضع النهاري يبني بلا أخطاء', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 390, brightness: Brightness.light));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.text('عرض المزيد'), findsOneWidget);
  });
}
