import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../helper.dart';

void main() {
  late FirebaseFirestore firestore;
  group(UserProfile, () {
    setUpAll(() async {
      firestore = FakeFirebaseFirestore();
    });

    test('Invalid doc id throws exception', () async {
      final snap =
          await firestore.collection('UserProfile').doc('invalid-id').get();
      expect(() => UserProfile.fromDocumentSnapshot(snap), throwsException);
    });

    test('can be created from Firestore with minimum data', () async {
      final docRef =
          await firestore.collection('UserProfile').add(initialUserProfile);
      final snap =
          await firestore.collection('UserProfile').doc(docRef.id).get();
      final userProfile = UserProfile.fromDocumentSnapshot(snap);
      expect(userProfile, isNotNull);
      expect(userProfile.displayName, initialUserProfile['DisplayName']);
      expect(userProfile.veriPoints, initialUserProfile['VeriPoints']);
    });

    test(
      'can be created from Firestore with achievement and statistic data',
      () async {
        final docRef = await firestore
            .collection('UserProfile')
            .add(userProfileWithUsageData);
        final snap =
            await firestore.collection('UserProfile').doc(docRef.id).get();
        final userProfile = UserProfile.fromDocumentSnapshot(snap);
        expect(userProfile, isNotNull);
        expect(
          userProfile.displayName,
          userProfileWithUsageData['DisplayName'],
        );
        expect(
          userProfile.veriPoints,
          userProfileWithUsageData['VeriPoints'],
        );
        expect(
          userProfile.achievementsProgress,
          isNotNull,
        );
        expect(
          userProfile.achievementsProgress['AccessPointContributor'],
          isNotNull,
        );
      },
    );

    test('fromJson / toJson', () async {
      expect(
        userProfileWithUsage,
        equals(UserProfile.fromJson(userProfileWithUsage.toJson())),
      );
    });

    test('get user achievement progress by valid id succeeds', () {
      expect(
        userProfileWithUsage.getAchievementProgress("AccessPointContributor"),
        isNotNull,
      );
    });

    test('get user achievement progress by invalid id returns null', () {
      expect(
        userProfileWithUsage.getAchievementProgress("invalid-id"),
        isNull,
      );
    });
  });
}
