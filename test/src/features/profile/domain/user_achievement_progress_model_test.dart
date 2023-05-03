import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/profile/domain/user_achievement_progress_model.dart';

import '../helper.dart';

void main() {
  group(UserAchievementProgress, () {
    test(
      """
      Given an empty map,
      When it is passed into UserAchievementProgress.fromFirestoreDocumentData,
      Then an Exception is thrown.
      """,
      () {
        expect(
          () => UserAchievementProgress.fromFirestoreDocumentData({}),
          throwsException,
        );
      },
    );

    test(
      """
      Given data representing user achievement progress 
      with CurrentTier set to an invalid Tier ID,
      When it is passed to UserAchievementProgress.fromFirestoreDocumentData,
      Then an Exception is thrown.
      """,
      () {
        const invalidCurrentTier = 'invalid';
        final tiersProgress = {
          'Bronze': 0,
          'Silver': 0,
          'Gold': 0,
        };
        final input = {
          'CurrentTier': invalidCurrentTier,
          'TiersProgress': tiersProgress,
        };
        expect(
          () => UserAchievementProgress.fromFirestoreDocumentData(input),
          throwsException,
        );
      },
    );

    test(
      """
      Given data representing user achievement progress 
      with a key in Tiers set to an invalid Tier ID, 
      When it is passed to UserAchievementProgress.fromFirestoreDocumentData, 
      Then an Exception is thrown.
      """,
      () {
        const invalidTierId = 'invalid';
        final invalidTiersProgress = {
          'Bronze': 1,
          invalidTierId: 0,
        };
        final input = {
          'CurrentTier': 'Bronze',
          'TiersProgress': invalidTiersProgress,
        };
        expect(
          () => UserAchievementProgress.fromFirestoreDocumentData(input),
          throwsException,
        );
      },
    );

    test(
      """
      Given data representing user achievement progress that is valid,
      When it is passed to UserAchievementProgress.fromFirestoreDocumentData,
      Then a UserAchievementProgress object is returned 
      and it contains all of the correct data.
      """,
      () {
        final validTiers = {
          'Bronze': 0,
          'Silver': 0,
          'Gold': 0,
        };
        final input = {
          'NextTier': 'Bronze',
          'TiersProgress': validTiers,
        };

        expect(
          () => UserAchievementProgress.fromFirestoreDocumentData(input),
          isNotNull,
        );
        expect(
          UserAchievementProgress.fromFirestoreDocumentData(input),
          equals(validUserAchievementProgress),
        );
      },
    );
  });
}
