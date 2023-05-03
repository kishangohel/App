import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/onboarding_outline_button.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../../../mocks.dart';
import '../../auth_robot.dart';

void main() {
  const testPhoneNumber = '6505553434';
  late AuthenticationRepository authRepository;
  late ProfileRepository profileRepository;
  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
  });

  group(PhoneScreen, () {
    testWidgets(
      '''
      Given the PhoneScreen,
      When the PhoneScreenPhoneFormField is empty, 
      Then the submit button is not visible.
      ''',
      (tester) async {
        await tester.runAsync(() async {
          final r = AuthRobot(tester);
          await r.pumpPhoneScreen(authRepository, profileRepository);
          expect(
            find.byType(OnboardingOutlineButton),
            findsNothing,
          );
        });
      },
    );

    testWidgets(
      '''
      Given the PhoneScreen,
      When an invalid phone number is entered,
      Then the submit button is not visible.
      ''',
      (tester) async {
        await tester.runAsync(() async {
          final r = AuthRobot(tester);
          await r.pumpPhoneScreen(authRepository, profileRepository);
          await r.enterPhoneNumber('1234');
          expect(
            find.byType(OnboardingOutlineButton),
            findsNothing,
          );
        });
      },
    );

    testWidgets(
      '''
      Given the PhoneScreen,
      When a valid phone number is entered,
      Then the submit button is visible.
      ''',
      (tester) async {
        await tester.runAsync(() async {
          final r = AuthRobot(tester);
          await r.pumpPhoneScreen(authRepository, profileRepository);
          await r.enterPhoneNumber(testPhoneNumber);
          expect(
            find.byType(OnboardingOutlineButton),
            findsOneWidget,
          );
        });
      },
    );
  });
}
