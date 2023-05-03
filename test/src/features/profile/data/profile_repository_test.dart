import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../helper.dart';

void main() {
  late ProfileRepository profileRepo;
  late FirebaseFirestore fakeFirestore;

  group('validateDisplayName', () {
    fakeFirestore = FakeFirebaseFirestore();
    profileRepo = ProfileRepository(firestore: fakeFirestore);
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore.collection('UserProfile').add(initialUserProfile);
    });

    test(
      """
      Given a display name that is under 3 characters in length,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'ab';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name that is over 20 characters in length,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'abcdefghijklmnopqrstu';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name that contains special characters,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'test-user-123!';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name with spaces,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'test user';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name with leading underscores,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = '_test_user';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name with trailing underscores,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'test_user_';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name with double underscores,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'test__user';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name with letters, numbers, and single underscores,
      When it is passed into validateDisplayName,
      Then null is returned indicating success.
      """,
      () async {
        const displayName = 'Test_User_234';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNull);
      },
    );

    test(
      """
      Given a display name that is already taken by another user,
      When it is passed into validateDisplayName,
      Then it returns an error string.
      """,
      () async {
        const displayName = 'Test_User_123';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNotNull);
      },
    );

    test(
      """
      Given a display name that is available,
      When it is passed into validateDisplayName,
      Then null is returned indicating success.
      """,
      () async {
        const displayName = 'Test_User_456';
        final result = await profileRepo.validateDisplayName(displayName);
        expect(result, isNull);
      },
    );
  });

  group('Get veripoints', () {
    late String testUserId;
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      final docRef = await fakeFirestore
          .collection('UserProfile')
          .add(userProfileWithUsageData);
      testUserId = docRef.id;
    });

    test(
      """
      Given a valid user ID,
      When it is passed to getVeriPoints,
      Then the user's VeriPoints is returned.
      """,
      () async {
        final result = await profileRepo.getVeriPoints(testUserId);
        expect(result, 20);
      },
    );

    test(
      """
      Given an invalid user ID,
      When it is passed to getVeriPoints,
      Then an Exception is thrown.
      """,
      () async {
        expect(
          () async => await profileRepo.getVeriPoints('invalid'),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('currentUser', () {
    fakeFirestore = FakeFirebaseFirestore();
    profileRepo = ProfileRepository(firestore: fakeFirestore);
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore
          .collection('UserProfile')
          .doc(mockUserNoTwitter.uid)
          .set(initialUserProfile);
      await fakeFirestore
          .collection('UserProfile')
          .doc(mockUserWithTwitter.uid)
          .set(initialUserProfile);
    });

    test(
      """
      Given a null User,
      When it is passed to currentUser,
      Then null is returned.
      """,
      () async {
        final result = await profileRepo.currentUser(null).first;
        expect(result, isNull);
      },
    );

    test(
      """
      Given a valid User with no Twitter account linked,
      When it is passed to currentUser,
      Then a valid CurrentUser is returned and the twitterAccount is null.
      """,
      () async {
        final currentUser =
            await profileRepo.currentUser(mockUserNoTwitter).first;
        expect(currentUser, isNotNull);
        expect(currentUser?.twitterAccount, isNull);
      },
    );

    test(
      """
      Given a valid User with a linked Twitter account,
      When it is passed to currentUser,
      Then a valid CurrentUser is returned and the twitterAccount is not null.
      """,
      () async {
        final currentUser =
            await profileRepo.currentUser(mockUserWithTwitter).first;
        expect(currentUser, isNotNull);
        expect(currentUser?.twitterAccount, isNotNull);
      },
    );

    test(
      """
      Given the currentUser stream has been called,
      When getCurrentUser is called,
      Then a valid CurrentUser is returned.
      """,
      () async {
        await profileRepo.currentUser(mockUserWithTwitter).first;
        expect(profileRepo.getCurrentUser, isNotNull);
      },
    );
  });

  group('updateHideOnMap', () {
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore
          .collection('UserProfile')
          .doc(mockUserNoTwitter.uid)
          .set(initialUserProfile);
      await profileRepo.currentUser(mockUserNoTwitter).first;
    });

    test(
      """
      Given a valid user ID and hide on map setting,
      When they are passed to updateHideOnMap,
      Then the user's hide on map setting is updated.
      """,
      () async {
        await profileRepo.updateHideOnMap(true);
        await fakeFirestore
            .collection('UserProfile')
            .doc(mockUserNoTwitter.uid)
            .get()
            .then((value) {
          expect(value.get('HideOnMap'), true);
        });
      },
    );
  });

  group('updateUserLocation', () {
    late String testUserId;
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore
          .collection('UserProfile')
          .doc(mockUserNoTwitter.uid)
          .set(initialUserProfile);
      await profileRepo.currentUser(mockUserNoTwitter).first;
    });

    test(
      """
      Given a valid user ID and a LatLng location,
      When they are passed to updateUserLocation,
      Then LastLocation is not null 
      and LastLocation.geopoint contains that location
      """,
      () async {
        await profileRepo.updateUserLocation(LatLng(1.0, 1.0));
        fakeFirestore
            .collection('UserProfile')
            .doc(mockUserNoTwitter.uid)
            .get()
            .then((value) {
          expect(value.get('LastLocation'), isNotNull);
          expect(
            value.get('LastLocation')['geopoint'],
            const GeoPoint(1.0, 1.0),
          );
        });
      },
    );
  });

  group('userWithUid', () {
    fakeFirestore = FakeFirebaseFirestore();
    profileRepo = ProfileRepository(firestore: fakeFirestore);
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore
          .collection('UserProfile')
          .doc(mockUserNoTwitter.uid)
          .set(initialUserProfile);
    });

    test(
      """
      Given a valid user id,
      When userWithUid is called with that user id, 
      Then the corresponding UserProfile is returned.
      """,
      () async {
        final userProfile =
            await profileRepo.userWithUid(mockUserNoTwitter.uid).first;
        expect(userProfile, isNotNull);
      },
    );

    test(
      """
      Given an invalid user id,
      When userWithUid is called with that user id, 
      Then null is returned.
      """,
      () async {
        final userProfile = await profileRepo.userWithUid('invalid-id').first;
        expect(userProfile, isNull);
      },
    );
  });

  group('createUserProfile', () {
    fakeFirestore = FakeFirebaseFirestore();
    profileRepo = ProfileRepository(firestore: fakeFirestore);
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
    });

    test(
      """
      Given a userId and display name, 
      When createUserProfile is called, 
      A new UserProfile is created with the given userId and display name.
      """,
      () async {
        await profileRepo.createUserProfile(
          userId: mockUserNoTwitter.uid,
          displayName: 'Test User',
        );
        await fakeFirestore
            .collection('UserProfile')
            .doc(mockUserNoTwitter.uid)
            .get()
            .then((value) {
          expect(value.get('DisplayName'), 'Test User');
        });
      },
    );
  });

  group('userProfileRankings', () {
    fakeFirestore = FakeFirebaseFirestore();
    profileRepo = ProfileRepository(firestore: fakeFirestore);
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore.collection('UserProfile').add(userProfile50Points);
      await fakeFirestore.collection('UserProfile').add(userProfile100Points);
      await fakeFirestore.collection('UserProfile').add(userProfile101Points);
    });

    test(
      """
      Given three user profiles with 50, 100, and 101 VeriPoints,
      When userProfileRankings is called, 
      Then three user profiles are returned in descending order [101, 100, 50].
      """,
      () async {
        final rankings = await profileRepo.userProfileRankings().first;
        expect(rankings[0].veriPoints, 101);
        expect(rankings[1].veriPoints, 100);
        expect(rankings[2].veriPoints, 50);
      },
    );
  });

  group('profileExists', () {
    fakeFirestore = FakeFirebaseFirestore();
    profileRepo = ProfileRepository(firestore: fakeFirestore);
    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      profileRepo = ProfileRepository(firestore: fakeFirestore);
      await fakeFirestore
          .collection('UserProfile')
          .doc(mockUserNoTwitter.uid)
          .set(initialUserProfile);
    });

    test(
      """
      Given a valid user id that exists in the UserProfile collection,
      When it is passed to profileExists,
      Then it returns true.
      """,
      () async {
        await profileRepo.profileExists(mockUserNoTwitter.uid).then((value) {
          expect(value, true);
        });
      },
    );

    test(
      """
      Given a user id that does not exists in the UserProfile collection,
      When it is passed to profileExists,
      Then it returns false.
      """,
      () async {
        await profileRepo.profileExists('invalid-id').then((value) {
          expect(value, false);
        });
      },
    );
  });
}
