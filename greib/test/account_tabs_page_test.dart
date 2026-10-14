import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/shared_widgets/account_tabs_page.dart';

void main() {
  testWidgets('صفحة الحساب تعرض تبويبي الملف الشخصي والمحفظة', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Directionality(
        textDirection: TextDirection.rtl,
        child: AccountTabsPage(),
      )),
    );
    await tester.pumpAndSettle();

    // التبويبان ظاهران.
    expect(find.text('الملف الشخصي'), findsWidgets);
    expect(find.text('المحفظة'), findsWidgets);

    // محتوى الملف الشخصي ظاهر افتراضياً (زر تعديل البيانات).
    expect(find.text('تعديل البيانات'), findsOneWidget);

    // الضغط على تبويب المحفظة يعرض صفحة المحفظة الأصلية.
    await tester.tap(find.text('المحفظة').last);
    await tester.pumpAndSettle();
    expect(find.text('محفظتي'), findsOneWidget);
    expect(find.text('إدارة رصيدك ونقاطك'), findsOneWidget);
  });

  testWidgets('فتح الصفحة على تبويب المحفظة مباشرة (initialTab)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Directionality(
        textDirection: TextDirection.rtl,
        child: AccountTabsPage(initialTab: 1),
      )),
    );
    await tester.pumpAndSettle();

    // المحفظة ظاهرة مباشرة دون الحاجة للضغط على التبويب.
    expect(find.text('محفظتي'), findsOneWidget);
  });
}
