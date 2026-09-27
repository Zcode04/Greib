import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greib_menk/features/home_and_services/widgets/spotlight_carousel.dart';
import 'package:greib_menk/shared_widgets/glass_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:greib_menk/core/mock_data/mock_data.dart';

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

  testWidgets('carousel phone: spans both screen edges, sized from width', (
    tester,
  ) async {
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

  testWidgets('carousel tablet: card capped at 620 and centered', (
    tester,
  ) async {
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

  testWidgets('carousel survives a screen width change (no controller crash)', (
    tester,
  ) async {
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

  testWidgets('comments sheet: mock comments + adding a new one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // تعليقات وهمية جاهزة.
    expect(find.textContaining('التعليقات (3)'), findsOneWidget);
    expect(find.text('سارة'), findsOneWidget);

    // تعليق المستخدم.
    await tester.enterText(find.byType(TextField), 'تعليق تجريبي');
    await tester.tap(find.byIcon(LucideIcons.send));
    await tester.pump();

    expect(find.text('تعليق تجريبي'), findsOneWidget);
    expect(find.textContaining('التعليقات (4)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('comments sheet: dismissal leaves no error/overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('التعليقات (3)'), findsOneWidget);

    // إغلاق الورقة بالسحب للأسفل.
    await tester.drag(find.byType(TextField), const Offset(0, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('التعليقات'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('comments sheet: keyboard open then dismissed cleanly', (
    tester,
  ) async {
    // شاشة قصيرة + لوحة مفاتيح مفتوحة = أصعب حالة (فيض الارتفاع).
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // فتح لوحة المفاتيح فعلياً ⇒ تقليص المساحة المتاحة.
    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.takeException(), isNull);

    // الإغلاق عبر زر الرجوع.
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // محاكاة اختفاء لوحة المفاتيح بعد الإغلاق.
    tester.view.resetViewInsets();
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reaction sheet: two buttons + tabs with counts', (tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    // thumbsUp يظهر أيضاً كشارة إحصاء ⇒ نختار زر شريط الإجراءات.
    await tester.tap(find.byIcon(LucideIcons.thumbsUp).at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('تفاعل المنشور'), findsOneWidget);
    // زرّان في الأعلى + تبويب يحمل الأعداد.
    expect(find.text('إعجاب'), findsOneWidget);
    expect(find.text('عدم إعجاب'), findsOneWidget);
    expect(find.text('إعجاب (6)'), findsOneWidget);
    expect(find.text('عدم إعجاب (4)'), findsOneWidget);

    // الضغط على «إعجاب» يزيد العداد فوراً (6 ← 7).
    await tester.tap(find.text('إعجاب'));
    await tester.pump();
    expect(find.text('إعجاب (7)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // التبويب الثاني يعرض مستخدمي عدم الإعجاب.
    await tester.tap(find.text('عدم إعجاب (4)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ليان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('comments sheet: drag up expands, drag down collapses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('التعليقات'), findsOneWidget);
    final sheet = find.byType(DraggableScrollableSheet);
    final before = tester.getRect(sheet).height;

    await tester.drag(find.text('سارة'), const Offset(0, -220));
    await tester.pumpAndSettle();
    final after = tester.getRect(sheet).height;
    expect(after, greaterThan(before));
    expect(find.textContaining('التعليقات'), findsOneWidget);

    await tester.drag(find.text('سارة'), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(tester.getRect(sheet).height, lessThan(after));
    expect(tester.takeException(), isNull);
  });

  testWidgets('comments sheet: header is draggable too', (tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final sheet = find.byType(DraggableScrollableSheet);
    final before = tester.getRect(sheet).height;

    await tester.drag(find.textContaining('التعليقات'), const Offset(0, -200));
    await tester.pumpAndSettle();
    final afterUp = tester.getRect(sheet).height;
    expect(afterUp, greaterThan(before));

    await tester.drag(find.textContaining('التعليقات'), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(tester.getRect(sheet).height, lessThan(afterUp));
    expect(tester.takeException(), isNull);
  });

  testWidgets('comments sheet: header drag works from the edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await showPosts(tester);

    await tester.tap(find.byIcon(LucideIcons.messageCircle).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final sheet = find.byType(DraggableScrollableSheet);
    final before = tester.getRect(sheet).height;
    final headerBox = tester.getRect(
      find
          .ancestor(
            of: find.textContaining('التعليقات'),
            matching: find.byType(GestureDetector),
          )
          .first,
    );

    final gesture = await tester.startGesture(
      Offset(headerBox.left + 8, headerBox.center.dy),
    );
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, -15));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getRect(sheet).height, greaterThan(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('post images: preview opens and pages through images', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // منشور مرفق به أكثر من صورة (بيانات وهمية MockData).
    final multi = MockData.services.firstWhere((s) => s.imageUrls.length > 1);
    expect(multi.imageUrls.length, greaterThan(1));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Directionality(
              textDirection: TextDirection.rtl,
              child: SpotlightSection(isDark: true),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('عرض كمنشورات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // الضغط على صورة البطاقة يفتح المعاينة الكاملة مع العدّاد.
    // معرض الصور المتعدد = InkWell يلف AspectRatio بداخله أكثر من صورة.
    Finder? gallery;
    Finder? findMultiGallery() {
      final ratios = find.byWidgetPredicate(
        (w) => w is AspectRatio && w.aspectRatio == 1.5,
      );
      for (var i = 0; i < ratios.evaluate().length; i++) {
        final ar = ratios.at(i);
        if (find
                .descendant(of: ar, matching: find.byType(Image))
                .evaluate()
                .length >
            1) {
          return find.ancestor(of: ar, matching: find.byType(InkWell)).first;
        }
      }
      return null;
    }

    // تحميل منشورات إضافية حتى يظهر المنشور متعدد الصور.
    gallery = findMultiGallery();
    for (var i = 0; i < 6 && gallery == null; i++) {
      final more = find.text('عرض المزيد');
      if (more.evaluate().isEmpty) break;
      await tester.ensureVisible(more.first);
      await tester.pumpAndSettle();
      await tester.tap(more.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      gallery = findMultiGallery();
    }
    expect(gallery, isNotNull, reason: 'لم يُعرض منشور متعدد الصور');

    await tester.ensureVisible(gallery!);
    await tester.pumpAndSettle();
    await tester.tap(gallery);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1/${multi.imageUrls.length + 1}'), findsOneWidget);

    // السحب ينقل الصورة التالية.
    // في RTL: السحب لليسار ينقل للصورة التالية.
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('2/${multi.imageUrls.length + 1}'), findsOneWidget);

    // زر الإغلاق يغلق المعاينة.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('1/${multi.imageUrls.length + 1}'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('post images: zoom in and out from the toolbar', (tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await tester.tap(find.text('عرض كمنشورات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // الوصول لمنشور متعدد الصور.
    Finder? gallery;
    Finder? findMultiGallery() {
      final ratios = find.byWidgetPredicate(
        (w) => w is AspectRatio && w.aspectRatio == 1.5,
      );
      for (var i = 0; i < ratios.evaluate().length; i++) {
        final ar = ratios.at(i);
        if (find
                .descendant(of: ar, matching: find.byType(Image))
                .evaluate()
                .length >
            1) {
          return find.ancestor(of: ar, matching: find.byType(InkWell)).first;
        }
      }
      return null;
    }

    gallery = findMultiGallery();
    for (var i = 0; i < 6 && gallery == null; i++) {
      final more = find.text('عرض المزيد');
      if (more.evaluate().isEmpty) break;
      await tester.ensureVisible(more.first);
      await tester.pumpAndSettle();
      await tester.tap(more.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      gallery = findMultiGallery();
    }
    expect(gallery, isNotNull);

    await tester.ensureVisible(gallery!);
    await tester.pumpAndSettle();
    await tester.tap(gallery);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(InteractiveViewer).last;
    expect(tester.widget<InteractiveViewer>(viewer).panEnabled, isFalse);

    // زر التكبير ⇒ تكبير (وتفعيل السحب لتحريك الصورة).
    await tester.tap(find.byIcon(LucideIcons.zoomIn));
    await tester.pumpAndSettle();
    expect(tester.widget<InteractiveViewer>(viewer).panEnabled, isTrue);

    // زر التصغير ⇒ عودة للوضع العادي.
    await tester.tap(find.byIcon(LucideIcons.zoomOut));
    await tester.pumpAndSettle();
    expect(tester.widget<InteractiveViewer>(viewer).panEnabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('post images: tapping the image zooms in and out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await tester.tap(find.text('عرض كمنشورات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    Finder? findMultiGallery() {
      final ratios = find.byWidgetPredicate(
        (w) => w is AspectRatio && w.aspectRatio == 1.5,
      );
      for (var i = 0; i < ratios.evaluate().length; i++) {
        final ar = ratios.at(i);
        if (find
                .descendant(of: ar, matching: find.byType(Image))
                .evaluate()
                .length >
            1) {
          return find.ancestor(of: ar, matching: find.byType(InkWell)).first;
        }
      }
      return null;
    }

    var gallery = findMultiGallery();
    for (var i = 0; i < 6 && gallery == null; i++) {
      final more = find.text('عرض المزيد');
      if (more.evaluate().isEmpty) break;
      await tester.ensureVisible(more.first);
      await tester.pumpAndSettle();
      await tester.tap(more.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      gallery = findMultiGallery();
    }
    expect(gallery, isNotNull);
    await tester.ensureVisible(gallery!);
    await tester.pumpAndSettle();
    await tester.tap(gallery);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(InteractiveViewer).last;
    expect(tester.widget<InteractiveViewer>(viewer).panEnabled, isFalse);

    // نقرة على الصورة ⇒ تكبير.
    await tester.tap(find.byType(InteractiveViewer).last);
    await tester.pumpAndSettle();
    expect(tester.widget<InteractiveViewer>(viewer).panEnabled, isTrue);

    // نقرة أخرى ⇒ تصغير.
    await tester.tap(find.byType(InteractiveViewer).last);
    await tester.pumpAndSettle();
    expect(tester.widget<InteractiveViewer>(viewer).panEnabled, isFalse);
    expect(tester.takeException(), isNull);
  });
}
