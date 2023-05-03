import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../auth_robot.dart';
import '../../mocks.dart';

void main() {
  late ProfileRepository profileRepository;
  late AuthenticationRepository authRepository;
  late TextEditingController displayNameTextController;
  group(DisplayNameScreen, () {
    setUp(() {
      profileRepository = MockProfileRepository();
      authRepository = MockAuthRepository();
      displayNameTextController = TextEditingController();
    });

    testWidgets(
      '''
      Given a DisplayNameScreen,
      When it first displays,
      Then a TextField should be displayed along with a submit button.
      ''',
      (tester) async {
        final r = AuthRobot(tester);
        await r.pumpDisplayNameScreen(
          profileRepository,
          authRepository,
          displayNameTextController,
        );
        r.expectDisplayNameTextField();
        r.expectDisplayNameSubmitButton();
      },
    );

    testWidgets(
      '''
      Given a DisplayNameScreen,
      When text is entered into the TextField 
      and the submit button is tapped
      and ProfileRepository.validateDisplayName returns an error
      Then the error is displayed.
      ''',
      (tester) async {
        final r = AuthRobot(tester);
        const error = 'Invalid display name error';
        await r.pumpDisplayNameScreen(
          profileRepository,
          authRepository,
          displayNameTextController,
        );
        when(
          () => profileRepository.validateDisplayName(any()),
        ).thenAnswer((_) async => error);
        await r.enterDisplayName('test_user');
        await r.tapDisplayNameSubmitButton();
        r.expectDisplayNameErrorText(error);
      },
    );
  });
}
