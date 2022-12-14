import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/account_phone_form_field.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/onboarding_outline_button.dart';

class AuthRobot {
  final WidgetTester tester;
  const AuthRobot(this.tester);

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
    await tester.pumpAndSettle();
  }

  Future<void> enterSmsCode(String smsCode) async {
    final smsCodeInputField = find.byType(Pinput);
    expect(smsCodeInputField, findsOneWidget);
    await tester.enterText(smsCodeInputField, smsCode);
  }

  Future<void> pumpPhoneInputScreen() async {
    return tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PhoneScreen(),
        ),
      ),
    );
  }
}
