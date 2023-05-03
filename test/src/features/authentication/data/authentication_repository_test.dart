import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';

import '../../../mocks.dart';

void main() {
  late FirebaseAuth firebaseAuth;
  late AuthenticationRepository authRepository;

  setUpAll(() {
    registerFallbackValue(MockTwitterAuthProvider());
    registerFallbackValue(MockUserCredential());
  });

  group(AuthenticationRepository, () {
    group('currentUser', () {
      setUpAll(() {
        firebaseAuth = MockFirebaseAuth();
        authRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );
      });
      test(
        """
        Given a default AuthenticationRepository instance,
        When currentUser is called,
        Then null is returned.
        """,
        () {
          expect(authRepository.currentUser, isNull);
        },
      );
    });
    group('signOut', () {
      setUpAll(() {
        firebaseAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: '1234'),
        );
        authRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );
      });
      test(
        """
        Given an AuthenticationRepository with a user logged in,
        When signOut is called,
        Then the user is signed out and currentUser returns null.
        """,
        () async {
          expect(authRepository.currentUser, isNotNull);
          await authRepository.signOut();
          expect(authRepository.currentUser, isNull);
        },
      );
    });

    group('updateDisplayName', () {
      setUp(() {
        firebaseAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: '1234'),
        );
        authRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );
      });

      test(
        """
        Given an AuthenticationRepository with a user logged in
        and a new display name,
        When updateDisplayName called,
        Then the currentUser is updated with the new display name.
        """,
        () async {
          expect(authRepository.currentUser, isNotNull);
          await authRepository.updateDisplayName('test-user');
          expect(authRepository.currentUser?.displayName, 'test-user');
        },
      );

      test(
        """
        Given an AuthenticationRepository with no user logged in
        and a new display name,
        When updateDisplayName called,
        Then an Exception is thrown.
        """,
        () async {
          await authRepository.signOut();
          expect(authRepository.currentUser, isNull);
          expect(
            () async => await authRepository.updateDisplayName('test-user'),
            throwsException,
          );
        },
      );
    });

    group('updateProfilePhoto', () {
      setUp(() {
        firebaseAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: '1234'),
        );

        authRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );
      });

      // Waiting for this PR to be merged:
      // https://github.com/atn832/firebase_auth_mocks/pull/91
      //
      test(
        """
        Given an AuthenticationRepository with a user logged in
        and a new profile photo,
        When updateProfilePhoto is called,
        Then the currentUser is updated with the new profile picture.
        """,
        () async {
          expect(authRepository.currentUser, isNotNull);
          await authRepository.updateProfilePhoto('photo-url');
          expect(authRepository.currentUser?.photoURL, 'photo-url');
        },
      );

      test(
        """
        Given an AuthenticationRepository with no user logged in
        and a new display name,
        When updateDisplayName called,
        Then an Exception is thrown.
        """,
        () async {
          await authRepository.signOut();
          expect(authRepository.currentUser, isNull);
          expect(
            () async => await authRepository.updateProfilePhoto('photo-url'),
            throwsException,
          );
        },
      );
    });

    group('linkTwitterAccount', () {
      setUp(() {
        firebaseAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: '1234'),
        );
        authRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );
      });

      test(
        """
        Given an AuthenticationRepository with a logged in user 
        When linkTwitterAccount is called,
        Then User.linkWithProvider is called with a TwitterAuthProvider
        """,
        () async {
          // when(() => firebaseAuth.currentUser!.linkWithProvider(any()))
          //     .thenAnswer((_) => any());
          await authRepository.linkTwitterAccount();
          expect(
            firebaseAuth.currentUser!.providerData.any(
              (info) => info.providerId == 'twitter.com',
            ),
            true,
          );
        },
      );

      test(
        """
        Given an AuthenticationRepository with a logged in user 
        and a Twitter account already linked
        When linkTwitterAccount is called,
        Then a FirebaseAuthException is thrown.
        """,
        () async {
          await authRepository.linkTwitterAccount();
          // second call should throw exception
          expect(
            await authRepository.linkTwitterAccount(),
            'Auth Error',
          );
        },
      );
    });
    group('unlinkTwitterAccount', () {
      setUp(() {
        firebaseAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: '1234'),
        );
        authRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );
      });

      test(
        """
        Given a user linked to a Twitter account,
        When unlinkTwitterAccount is called,
        It succeeds
        """,
        () async {
          await authRepository.linkTwitterAccount();
          expect(
            authRepository.unlinkTwitterAccount(),
            completes,
          );
        },
      );
    });
  });
}
