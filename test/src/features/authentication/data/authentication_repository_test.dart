import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';

void main() {
  late FirebaseAuth firebaseAuth;

  group(AuthenticationRepository, () {
    firebaseAuth = MockFirebaseAuth();
    final authRepository = AuthenticationRepository(
      firebaseAuth: firebaseAuth,
    );
    test('currentUser is null by default', () {
      expect(authRepository.currentUser, isNull);
    });
  });
}
