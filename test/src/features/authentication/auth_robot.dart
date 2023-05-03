import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/account_phone_form_field.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_screen.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/onboarding_outline_button.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  /////////////////////////////////////////////////////////////////////////////
  // Phone Screen
  /////////////////////////////////////////////////////////////////////////////

  Future<void> pumpPhoneScreen(
    AuthenticationRepository authRepository,
    ProfileRepository profileRepository,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profileRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PhoneScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectPhoneScreen() {
    final finder = find.byType(PhoneScreen);
    expect(finder, findsOneWidget);
  }

  Future<void> enterPhoneNumber(String phoneNumber) async {
    final phoneInputField = find.byType(PhoneScreenPhoneFormField);
    expect(phoneInputField, findsOneWidget);
    await tester.enterText(phoneInputField, phoneNumber);
    await tester.pumpAndSettle();
  }

  Future<void> tapPhoneSubmitButton() async {
    final submitButton = find.byType(OnboardingOutlineButton);
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  }

  /////////////////////////////////////////////////////////////////////////////
  // Sms Screen
  /////////////////////////////////////////////////////////////////////////////

  Future<void> pumpSmsScreen(
    AuthenticationRepository authRepository,
    TextEditingController smsTextEditingController,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SmsScreen(controller: smsTextEditingController),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectSmsScreen() {
    final finder = find.byType(SmsScreen);
    expect(finder, findsOneWidget);
  }

  void expectPinput() {
    final finder = find.byType(Pinput);
    expect(finder, findsOneWidget);
  }

  Future<void> enterSmsCode(
    String smsCode,
  ) async {
    final finder = find.byType(Pinput);
    expect(finder, findsOneWidget);
    final pinput = finder.evaluate().first.widget as Pinput;
    pinput.controller!.setText(smsCode);
    await tester.pumpAndSettle();
  }

  void expectErrorSnackbar() {
    final finder = find.byType(SnackBar);
    expect(finder, findsOneWidget);
  }

  /////////////////////////////////////////////////////////////////////////////
  // Display Name Screen
  /////////////////////////////////////////////////////////////////////////////

  Future<void> pumpDisplayNameScreen(
    ProfileRepository profileRepository,
    AuthenticationRepository authRepository,
    TextEditingController displayNameController,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profileRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: DisplayNameScreen(controller: displayNameController),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectDisplayNameScreen() {
    final finder = find.byType(DisplayNameScreen);
    expect(finder, findsOneWidget);
  }

  Future<void> enterDisplayName(String displayName) async {
    final finder = find.byType(TextField);
    expect(finder, findsOneWidget);
    await tester.enterText(finder, displayName);
    await tester.pumpAndSettle();
  }

  void expectDisplayNameTextField() {
    final finder = find.byType(TextField);
    expect(finder, findsOneWidget);
  }

  void expectDisplayNameSubmitButton() {
    final finder = find.byType(OnboardingOutlineButton);
    expect(finder, findsOneWidget);
  }

  void expectCircularProgressIndicator() {
    final finder = find.byType(CircularProgressIndicator);
    expect(finder, findsOneWidget);
  }

  void expectDisplayNameSubmitText() {
    final finder = find.text('Submit');
    expect(finder, findsOneWidget);
  }

  void expectDisplayNameErrorText(String errorText) {
    final finder = find.text(errorText);
    expect(finder, findsOneWidget);
  }

  Future<void> tapDisplayNameSubmitButton() async {
    final submitButton = find.byType(OnboardingOutlineButton);
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  }
}
