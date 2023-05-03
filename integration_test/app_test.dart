import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/src/robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end tests', () {
    testWidgets('complete auth', (widgetTester) async {
      final r = Robot(widgetTester);
      await r.pumpApp(isSignedIn: false);
      r.auth.expectPhoneScreen();
      await r.auth.enterPhoneNumber('+16505553434');
      await r.auth.tapPhoneSubmitButton();
      await widgetTester.pump();
      r.auth.expectSmsScreen();
      await r.auth.enterSmsCode('123456');
      r.auth.expectDisplayNameScreen();
      await r.auth.enterDisplayName('test_user');
      await r.auth.tapDisplayNameSubmitButton();
      await Future.delayed(const Duration(seconds: 3));
    });
  });
}
