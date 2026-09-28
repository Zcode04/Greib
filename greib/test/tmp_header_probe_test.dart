import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:greib_menk/core/location/location_controller.dart';
import 'package:greib_menk/core/permissions/permissions.dart';
import 'package:greib_menk/core/notifications/notification_manager.dart';
import 'package:greib_menk/core/router/app_router.dart';
import 'package:greib_menk/core/storage/app_prefs.dart';
import 'package:greib_menk/core/theme/theme_controller.dart';
import 'package:greib_menk/core/widgets/super_header.dart';
import 'package:greib_menk/features/auth/auth_service.dart';
import 'package:greib_menk/features/auth/mock_auth.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.init();
    AuthService.instance.logout();
  });

  testWidgets('probe', (tester) async {
    await tester.runAsync(() => AuthService.instance.quickLogin(UserRole.user));
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final router = AppRouter.createRouter(initialLocation: '/home');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),
          ChangeNotifierProvider<AuthService>.value(
            value: AuthService.instance,
          ),
          ChangeNotifierProvider<NotificationManager>.value(
            value: NotificationManager.instance,
          ),
          ChangeNotifierProvider<LocationController>.value(
            value: LocationController(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    debugPrint('LOC=${router.state.matchedLocation}');
    debugPrint('STATUS_TOP=${tester.view.padding.top}');
    final header = tester.renderObject<RenderBox>(
      find.byType(SuperHeader).first,
    );
    debugPrint('HEADER=${header.size} top=${header.localToGlobal(Offset.zero)}');

    await tester.tap(find.text('الدردشة').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final text = find.text('دعم گريب منك').first;
    final rb = tester.renderObject<RenderBox>(text);
    debugPrint('FIRST_ROW top=${rb.localToGlobal(Offset.zero)} size=${rb.size}');
    final listRb = tester.renderObject<RenderBox>(
      find.byType(ListView).last,
    );
    debugPrint('LISTVIEW top=${listRb.localToGlobal(Offset.zero)}');

    expect(true, isTrue);
  });
}
