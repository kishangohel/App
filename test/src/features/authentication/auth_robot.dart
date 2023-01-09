import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/account_phone_form_field.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen_controller.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/onboarding_outline_button.dart';
import 'package:verifi/src/routing/app_router.dart';

import '../../../test_helper/go_router_mock.dart';
import 'presentation/phone_number/phone_screen_controller_stub.dart';

class AuthRobot {
  final WidgetTester tester;
  final GoRouterMock _goRouterMock;
  final PhoneScreenControllerStub _phoneScreenControllerStub;

  AuthRobot(this.tester)
      : _goRouterMock = GoRouterMock(),
        _phoneScreenControllerStub = PhoneScreenControllerStub()
          ..setInitialValue(false);

  Future<void> enterPhoneNumber(String phoneNumber) async {
    final phoneInputField = find.byType(PhoneScreenPhoneFormField);
    expect(phoneInputField, findsOneWidget);
    await tester.enterText(phoneInputField, phoneNumber);
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmitButton() async {
    final submitButton = find.byType(OnboardingOutlineButton);
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> enterSmsCode(String smsCode) async {
    final smsCodeInputField = find.byType(Pinput);
    expect(smsCodeInputField, findsOneWidget);
    await tester.enterText(smsCodeInputField, smsCode);
  }

  Future<void> pumpPhoneInputScreen() async {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          phoneScreenControllerProvider
              .overrideWith(() => _phoneScreenControllerStub),
        ],
        child: MaterialApp(
          home: mockGoRouter(
            _goRouterMock,
            child: const PhoneScreen(),
          ),
        ),
      ),
    );
  }

  void mockRequestSmsCode({required FutureOr<bool> result}) {
    _phoneScreenControllerStub.stubSmsCodeResult(result);
  }

  void verifyNavigationToSmsPage() {
    verify(() => _goRouterMock.pushNamed(AppRoute.sms.name)).called(1);
  }
}
