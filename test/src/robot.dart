import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/app.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import 'features/authentication/auth_robot.dart';

class Robot {
  final WidgetTester tester;
  final AuthRobot auth;

  Robot(this.tester) : auth = AuthRobot(tester);

  Future<void> pumpApp({required bool isSignedIn}) async {
    final firebaseAuth = MockFirebaseAuth(signedIn: isSignedIn);
    final authRepository = AuthenticationRepository(firebaseAuth: firebaseAuth);
    final profileRepository = ProfileRepository(
      firestore: FakeFirebaseFirestore(),
    );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: VeriFi(),
      ),
    );
    await tester.pumpAndSettle();
  }
}
