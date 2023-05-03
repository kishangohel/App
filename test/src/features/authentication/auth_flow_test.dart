import 'package:flutter_test/flutter_test.dart';

import '../../robot.dart';

void main() {
  testWidgets('Authentication flow', (tester) async {
    await tester.runAsync(() async {
      final r = Robot(tester);
      await r.pumpApp(isSignedIn: false);
      r.auth.expectPhoneScreen();
      await r.auth.enterPhoneNumber('6505553434');
      await r.auth.tapPhoneSubmitButton();
      r.auth.expectSmsScreen();
      await r.auth.enterSmsCode('941555');
      r.auth.expectDisplayNameScreen();
      await r.auth.enterDisplayName('test_user');
      await r.auth.tapDisplayNameSubmitButton();
      // final finder = find.byType(HomeScreen);
      // expect(finder, findsOneWidget);
    });
  });
}
