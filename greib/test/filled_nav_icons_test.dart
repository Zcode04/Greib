import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/shared_widgets/floating_bottom_nav.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  /// يبني الشريط مع عنصرين: الأول له نسخة SVG ممتلئة، والثاني بلا (زر إجراء).
  Future<void> pumpNav(WidgetTester tester) {
    int current = 0;
    late StateSetter setOuter;
    return tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return Scaffold(
              bottomNavigationBar: FloatingBottomNav(
                currentIndex: current,
                onTap: (i) => setOuter(() => current = i),
                items: const [
                  FloatingNavItem(
                    icon: LucideIcons.house,
                    filledAsset: 'house',
                    label: 'الرئيسية',
                  ),
                  FloatingNavItem(
                    icon: LucideIcons.messageSquare,
                    filledAsset: 'message-square',
                    label: 'الدردشة',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('التبويب المحدد يعرض النسخة الممتلئة SVG (بأسلوب فيسبوك)', (
    tester,
  ) async {
    await pumpNav(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // الأول محدد ⇒ SVG ممتلئ يظهر، وأيقونة Lucide المفرّغة مخفية.
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(LucideIcons.house), findsNothing);
    // الثاني غير محدد ⇒ مفرّغ ظاهر.
    expect(find.byIcon(LucideIcons.messageSquare), findsOneWidget);
  });

  testWidgets('النقر ينقل النسخة الممتلئة للتبويب الجديد', (tester) async {
    await pumpNav(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(LucideIcons.house), findsNothing);

    await tester.tap(find.byIcon(LucideIcons.messageSquare));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // الممتلئة انتقلت: الأول عاد مفرّغاً والثاني صار SVG.
    expect(find.byIcon(LucideIcons.house), findsOneWidget);
    expect(find.byIcon(LucideIcons.messageSquare), findsNothing);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
