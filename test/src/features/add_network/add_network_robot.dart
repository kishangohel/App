import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/add_network/presentation/add_access_point_dialog.dart';

import '../../../test_helper/go_router_mock.dart';

class AddNetworkRobot {
  final WidgetTester tester;
  AddNetworkRobot(this.tester);

  Future<void> pumpAddAccessPointDialog(
    ProviderContainer container,
    GoRouterMock goRouterMock,
    String ssid,
    TextEditingController ssidController,
    TextEditingController passwordController,
    TextEditingController placeController,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: mockGoRouter(
          goRouterMock,
          child: MaterialApp(
            home: Scaffold(
              body: AddAccessPointDialog(
                ssid: ssid,
                ssidController: ssidController,
                passwordController: passwordController,
                placeController: placeController,
                debounce: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectSsidText(String ssid) {
    final ssidFinder = find.text(ssid);
    expect(ssidFinder, findsOneWidget);
  }

  TextField getSsidTextFieldWidget() {
    final ssidTextFieldFinder = find.byKey(const Key('ssidTextField'));
    final ssidTextField =
        ssidTextFieldFinder.evaluate().single.widget as TextField;
    return ssidTextField;
  }

  void expectPasswordRequiredSwitch() {
    final passwordRequiredSwitchFinder = find.byKey(
      const Key('passwordRequiredSwitch'),
    );
    expect(passwordRequiredSwitchFinder, findsOneWidget);
  }

  void expectPasswordRequiredSwitchIsOff(WidgetTester tester) {
    final passwordRequiredSwitchFinder = find.byKey(
      const Key('passwordRequiredSwitch'),
    );
    expect(tester.widget<Switch>(passwordRequiredSwitchFinder).value, false);
  }

  void expectPasswordRequiredSwitchIsOn(WidgetTester tester) {
    final passwordRequiredSwitchFinder = find.byKey(
      const Key('passwordRequiredSwitch'),
    );
    expect(tester.widget<Switch>(passwordRequiredSwitchFinder).value, true);
  }

  Future<void> togglePasswordRequiredSwitch(WidgetTester tester) async {
    final passwordRequiredSwitchFinder = find.byKey(
      const Key('passwordRequiredSwitch'),
    );
    await tester.tap(passwordRequiredSwitchFinder);
    await tester.pumpAndSettle();
  }

  void expectPasswordTextFieldHasFocus(WidgetTester tester) {
    final passwordRequiredSwitchFinder = find.byKey(
      const Key('passwordTextField'),
    );
    expect(
      tester
          .widget<TextField>(passwordRequiredSwitchFinder)
          .focusNode
          ?.hasFocus,
      true,
    );
  }

  void expectPasswordTextFieldIsEnabled(WidgetTester tester) {
    final passwordRequiredSwitchFinder = find.byKey(
      const Key('passwordTextField'),
    );
    expect(
      tester.widget<TextField>(passwordRequiredSwitchFinder).enabled,
      true,
    );
  }

  Future<void> enterTextPlaceSearch(WidgetTester tester, String text) async {
    final placeSearchFieldFinder = find.byKey(
      const Key('placeSearchFormField'),
    );
    await tester.enterText(placeSearchFieldFinder, text);
    await tester.pumpAndSettle();
  }

  void expectPlaceSearchResultListTile(WidgetTester tester, String placeName) {
    final placeSearchResultListTileFinder = find.byKey(
      Key('placeSearchListTile-$placeName'),
    );
    expect(placeSearchResultListTileFinder, findsOneWidget);
  }

  Future<void> tapPlaceSearchResultListTile(
    WidgetTester tester,
    String placeName,
  ) async {
    final placeSearchResultListTileFinder = find.byKey(
      Key('placeSearchListTile-$placeName'),
    );
    await tester.tap(placeSearchResultListTileFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmitButton(
    WidgetTester tester,
  ) async {
    final submitButtonFinder = find.byKey(
      const Key('submitButton'),
    );
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();
  }
}
