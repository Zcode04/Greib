import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/main.dart';

void main() {
  testWidgets('تطبيق گريب منك يفتح بشكل صحيح', (WidgetTester tester) async {
    await tester.pumpWidget(const GreibMenkApp());
    expect(find.text('گريب منك'), findsOneWidget);
  });
}