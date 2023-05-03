import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_screen.dart';

import '../../../../mocks.dart';
import '../../auth_robot.dart';

void main() {
  late TextEditingController pinputTextEditingController;
  late AuthenticationRepository authRepository;
  setUp(() {
    pinputTextEditingController = TextEditingController();
    authRepository = MockAuthRepository();
  });

  group(SmsScreen, () {
    testWidgets(
      """
      Given user on SmsScreen page,
      When they enter the SMS code,
      Then it is shown in the Pinput field.
      """,
      (tester) async {
        await tester.runAsync(
          () async {
            final r = AuthRobot(tester);
            await r.pumpSmsScreen(
              authRepository,
              pinputTextEditingController,
            );
            r.expectPinput();
            when(
              () => authRepository.submitSmsCode(any()),
            ).thenAnswer((_) async => Future.value());
            await r.enterSmsCode('123456');
            expect(pinputTextEditingController.value.text, '123456');
            verify(
              () => authRepository.submitSmsCode(any()),
            ).called(1);
          },
        );
      },
    );
  });
}
