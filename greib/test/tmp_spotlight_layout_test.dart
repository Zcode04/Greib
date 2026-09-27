import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/features/home_and_services/widgets/spotlight_carousel.dart';
import 'package:greib_menk/shared_widgets/glass_container.dart';

Widget host() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: const SpotlightSection(isDark: true),
        ),
      ),
    ),
  );
}

Future<void> showPosts(WidgetTester tester) async {
  await tester.tap(find.text('عرض كمنشورات'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('phone narrow: card fills the full width', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    final rect = tester.getRect(find.byType(AspectRatio).first);
    expect(rect.left, 0);
    expect(rect.right, 320);
    expect(rect.height, closeTo(320 / 1.5, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone wide rtl: card spans both edges', (tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    final rect = tester.getRect(find.byType(AspectRatio).first);
    expect(rect.left, 0);
    expect(rect.right, 412);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet: centered column capped at 620', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    final rect = tester.getRect(find.byType(AspectRatio).first);
    expect(rect.width, 620);
    expect(rect.center.dx, closeTo(600, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('carousel phone: spans both screen edges, sized from width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();

    final viewport = tester.getRect(find.byKey(const ValueKey('carousel')));
    expect(viewport.left, 0);
    expect(viewport.right, 320);

    final card = tester.getRect(find.byType(GlassContainer).first);
    expect(card.width, closeTo(320 * 0.84, 0.5));
    expect(card.height, closeTo(320 * 0.84 * 0.86, 1.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('carousel tablet: card capped at 620 and centered',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();

    final viewport = tester.getRect(find.byKey(const ValueKey('carousel')));
    expect(viewport.left, 0);
    expect(viewport.right, 1200);

    final card = tester.getRect(find.byType(GlassContainer).first);
    expect(card.width, 620);
    expect(card.height, 280);
    expect(card.center.dx, closeTo(600, 1.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('carousel survives a screen width change (no controller crash)',
      (tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    final before = tester.getRect(find.byType(GlassContainer).first);

    tester.view.physicalSize = const Size(900, 900);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final after = tester.getRect(find.byType(GlassContainer).first);
    expect(after.width, greaterThan(before.width));
    expect(after.width, 620);
    expect(tester.takeException(), isNull);
  });
}
