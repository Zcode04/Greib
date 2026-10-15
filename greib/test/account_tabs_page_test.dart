import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/shared_widgets/account_tabs_page.dart';

void main() {
  // ★ AccountTabsPage يُعرض كـ body داخل Scaffold (كما في الراوتر).
  testWidgets('صفحة الحساب تعرض تبويبي الملف الشخصي والمحفظة', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: AccountTabsPage()),
      )),
    );
    await tester.pumpAndSettle();

    // التبويبان ظاهران داخل شريط التبويبات.
    expect(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('الملف الشخصي'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('المحفظة'),
      ),
      findsOneWidget,
    );

    // محتوى الملف الشخصي ظاهر افتراضياً (الاسم + معلومات التواصل).
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('+971501234567'), findsWidgets);

    // الضغط على تبويب المحفظة يعرض صفحة المحفظة الأصلية.
    await tester.tap(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('المحفظة'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('محفظتي'), findsOneWidget);
  });

  testWidgets('فتح الصفحة على تبويب المحفظة مباشرة (initialTab)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: AccountTabsPage(initialTab: 1)),
      )),
    );
    await tester.pumpAndSettle();

    // المحفظة ظاهرة مباشرة دون الحاجة للضغط على التبويب.
    expect(find.text('محفظتي'), findsOneWidget);
  });
}

