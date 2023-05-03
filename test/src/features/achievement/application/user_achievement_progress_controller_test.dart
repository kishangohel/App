import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/achievement/data/achievement_repository.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/achievement/presentation/user_achievements_progress_controller.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../profile/helper.dart';
import '../helper.dart';

void main() {
  group(UserAchievementsProgressController, () {
    ProviderContainer makeProviderContainer({
      required Stream<List<Achievement>> achievements,
      required Stream<CurrentUser> currentUser,
    }) {
      final container = ProviderContainer(
        overrides: [
          achievementsProvider.overrideWith((ref) => achievements),
          currentUserProvider.overrideWith((ref) => currentUser),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      '''
      When achievementsProvider doesn't emit a value,
      Then userAchievementsProgressControllerProvider should return null.
      ''',
      () async {
        final container = makeProviderContainer(
          achievements: const Stream.empty(),
          currentUser: Stream.value(CurrentUser(profile: userProfileWithUsage)),
        );
        final result =
            container.read(userAchievementsProgressControllerProvider);
        expect(result, null);
      },
    );

    test(
      '''
      When currentUserProvider doesn't emit a value,
      Then userAchievementsProgressControllerProvider should return null.
      ''',
      () async {
        final container = makeProviderContainer(
          achievements: Stream.value([achievement]),
          currentUser: const Stream.empty(),
        );
        final result =
            container.read(userAchievementsProgressControllerProvider);
        expect(result, null);
      },
    );

    test(
      ''' 
      When currentUserProvider and achievementsProvider both emit a value,
      Then userAchievementsProgressControllerProvider should return achievement 
        progress for the user.
      ''',
      () async {
        final container = makeProviderContainer(
          achievements: Stream.value([accessPointContributorAchievement]),
          currentUser: Stream.value(CurrentUser(profile: userProfileWithUsage)),
        );
        await container.read(currentUserProvider.future);
        await container.read(achievementsProvider.future);
        final result =
            container.read(userAchievementsProgressControllerProvider);
        expect(result, isNotNull);
        expect(result?.length, 1);
        expect(result![0].item1, accessPointContributorAchievement);
        expect(result[0].item2, isNotNull);
        expect(
          result[0].item2!.nextTier,
          userProfileWithUsage
              .achievementsProgress["AccessPointContributor"]!.nextTier,
        );
      },
    );
  });
}
