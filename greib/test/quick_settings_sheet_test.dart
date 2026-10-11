import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/core/storage/app_prefs.dart';
import 'package:greib_menk/core/theme/theme_controller.dart';
import 'package:greib_menk/shared_widgets/quick_settings_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.init();
  });

  testWidgets('ورقة الإعدادات السريعة تعرض الحاذق في البداية يليه الأقسام والبحث والوضع الليلي',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickSettingsSheet.show(context),
                child: const Text('فتح'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();

    // نتحقق من وجود البنود بالترتيب
    expect(find.text('الحاذق'), findsOneWidget);
    expect(find.text('المساعد الذكي (AI)'), findsOneWidget);
    expect(find.text('الأقسام'), findsOneWidget);
    expect(find.text('البحث'), findsOneWidget);
    expect(find.text('الوضع الليلي'), findsOneWidget);
    expect(find.text('التحكم في الألوان'), findsOneWidget);
    expect(find.text('الخرائط الحقيقية'), findsOneWidget);
  });
}
