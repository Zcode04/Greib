import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/features/communication_and_support/alhadheq_chat_screen.dart';
import 'package:greib_menk/core/theme/theme_controller.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('شاشة الحاذق تفتح وتعرض رسالة الترحيب وزر الإرسال', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const MaterialApp(
          home: AlhadheqChatScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // نتحقق من عنوان الحاذق ورسالة الترحيب
    expect(find.text('الحاذق'), findsOneWidget);
    expect(find.textContaining('المساعد الذكي'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);

    // إرسال رسالة تجريبية
    await tester.enterText(find.byType(TextField), 'أريد مطعم قريب');
    await tester.tap(find.byTooltip('إرسال'));
    await tester.pump();

    // التحقق من ظهور رسالة المستخدم
    expect(find.text('أريد مطعم قريب'), findsOneWidget);

    // انتظار رد الذكاء الاصطناعي (تأخير 1100 ملي ثانية)
    await tester.pump(const Duration(milliseconds: 1200));

    // التحقق من وصول الرد الذكي
    expect(find.textContaining('شاورما الريف الأصيل'), findsOneWidget);
  });
}
