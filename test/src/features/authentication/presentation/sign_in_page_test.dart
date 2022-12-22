import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/onboarding_outline_button.dart';

import '../auth_robot.dart';

void main() {
  const testPhoneNumber = '6505553434';

  group('Sign In', () {
    testWidgets('''
      Given user is on sign in page 
      When phone number input is empty
      Then submit button is not visible 
      ''', (tester) async {
      await tester.runAsync(() async {
        final r = AuthRobot(tester);
        await r.pumpPhoneInputScreen();
        expect(
          find.byType(OnboardingOutlineButton),
          findsNothing,
        );
      });
    });

    testWidgets('''
      Given user is on sign in page 
      When user enters phone number
      Then submit button is visible 
      ''', (tester) async {
      await tester.runAsync(() async {
        final r = AuthRobot(tester);
        await r.pumpPhoneInputScreen();
        await r.enterPhoneNumber(testPhoneNumber);
        expect(
          find.byType(OnboardingOutlineButton),
          findsOneWidget,
        );
      });
    });

    testWidgets('''
      Given user is on sign in page
      When user enters phone number
      And taps submit button
      Then bottom pinput sheet appears
      ''', (tester) async {
      await tester.runAsync(() async {
        final r = AuthRobot(tester);
        await r.pumpPhoneInputScreen();
        await r.enterPhoneNumber(testPhoneNumber);
        r.mockRequestSmsCode(result: true);
        await r.tapSubmitButton();
        r.verifyNavigationToSmsPage();
      });
    });
  });
}
