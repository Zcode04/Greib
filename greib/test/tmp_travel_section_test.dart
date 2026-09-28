import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/core/theme/app_theme.dart';
import 'package:greib_menk/features/home_and_services/widgets/travel_section.dart';

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
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: width,
              // حشو الصفحة كما في Home (20) لاختبار تمدد الـ OverflowBox.
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TravelSection(isDark: brightness == Brightness.dark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('يبدأ بوضع المنشورات: بوست واحد + زرَّي التبديل', (tester) async {
    setPhone(tester);
    await tester.pumpWidget(wrap(width: 390));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('رحلة سفاري صحراوية'), findsOneWidget);
    expect(find.text('عرض المزيد'), findsOneWidget);
    expect(find.text('عرض الشرائح'), findsOneWidget);
  });

  testWidgets('عرض المزيد يجلب منشوراً جديداً في كل ضغطة', (tester) async {
    setPhone(tester);
    await tester.pumpWidget(wrap(width: 390));
    await tester.pump(const Duration(milliseconds: 400));

    final postTitle = (String t) => find.text(t, skipOffstage: false);

    Future<void> tapShowMore() async {
      final more = find.text('عرض المزيد');
      await tester.ensureVisible(more);
      await tester.pumpAndSettle();
      await tester.tap(more);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await tapShowMore();
    expect(postTitle('جولة في جبال حتا'), findsOneWidget);

    await tapShowMore();
    expect(postTitle('جولة جزيرة النخلة بالهليكوبتر'), findsOneWidget);

    // آخر منشور ⇒ يختفي زر «عرض المزيد».
    await tapShowMore();
    expect(postTitle('رحلة إلى وادي رم'), findsOneWidget);
    expect(find.text('عرض المزيد'), findsNothing);
  });

  testWidgets('زر التبديل ينقل بين المنشورات والشرائح', (tester) async {
    setPhone(tester);
    await tester.pumpWidget(wrap(width: 390));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('عرض الشرائح'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('عرض كمنشورات'), findsOneWidget);

    await tester.tap(find.text('عرض كمنشورات'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PageView), findsNothing);
    expect(find.text('عرض الشرائح'), findsOneWidget);
  });

  testWidgets('الوضع النهاري يبني بلا أخطاء', (tester) async {
    setPhone(tester);
    await tester.pumpWidget(wrap(width: 390, brightness: Brightness.light));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.text('عرض المزيد'), findsOneWidget);
  });
}
