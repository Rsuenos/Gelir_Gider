// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gelir_gider/app.dart';
import 'package:gelir_gider/features/auth/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const {});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Drawer lists credit and debt entries', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('tr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => SessionNotifier.test(isAuthenticated: true),
            ),
          ],
          child: const FinanceXApp(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Banking'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Credit Cards'), findsOneWidget);
    expect(find.text('Add Credit Card'), findsOneWidget);
    expect(find.text('Add Credit'), findsOneWidget);
    expect(find.text('Add Debt'), findsOneWidget);
  });
}
