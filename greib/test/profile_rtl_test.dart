import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/shared_widgets/profile_widget.dart';
import 'package:greib_menk/core/models/user_model.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  const profile = AppUserProfile(
    id: 'u1',
    name: 'أحمد محمد',
    role: 'user',
    phone: '+971501234567',
    email: 'user@greib.com',
    address: 'دبي، الممزر، شارع 14',
    membershipTier: 'gold',
    loyaltyPoints: 1250,
  );

  testWidgets('رقم الهاتف يُعرض باتجاه LTR (لا تنقلب العلامة +)', (tester) async {
    await tester.pumpWidget(_wrap(ProfileWidget(profile: profile)));
    await tester.pumpAndSettle();

    final phoneFinder = find.text('+971501234567');
    expect(phoneFinder, findsWidgets);

    // ★ يظهر مرتين: صفّ الهاتف وصفّ الواتساب — كلاهما LTR.
    final textWidget = tester.widget<Text>(phoneFinder.first);
    expect(textWidget.textDirection, TextDirection.ltr);

    // الأحرف الأولى «أ م» تظهر كبديل الأفاتار (لا أيقونة عامة).
    expect(find.text('أم'), findsOneWidget);
  });
}
