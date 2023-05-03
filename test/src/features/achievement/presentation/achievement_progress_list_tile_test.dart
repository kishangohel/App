import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/achievement/presentation/achievement_progress_list_tile.dart';
import 'package:verifi/src/features/profile/domain/user_achievement_progress_model.dart';

import '../helper.dart';

void main() {
  group(AchievementProgressListTile, () {
    const goldenLabelHeight = 45.0;

    AchievementProgressListTile noProgressToBronze() =>
        const AchievementProgressListTile(
          progress: null,
          achievement: achievement,
        );

    AchievementProgressListTile progressToBronze() =>
        const AchievementProgressListTile(
          progress: UserAchievementProgress(
            nextTier: TierIdentifier.bronze,
            tiersProgress: {
              TierIdentifier.bronze: 2,
              TierIdentifier.silver: 0,
              TierIdentifier.gold: 0,
            },
          ),
          achievement: achievement,
        );

    AchievementProgressListTile bronzeToSilver() =>
        const AchievementProgressListTile(
          progress: UserAchievementProgress(
            currentTier: TierIdentifier.bronze,
            nextTier: TierIdentifier.silver,
            tiersProgress: {
              TierIdentifier.bronze: 3,
              TierIdentifier.silver: 6,
              TierIdentifier.gold: 0,
            },
          ),
          achievement: achievement,
        );

    AchievementProgressListTile silverToGold() =>
        const AchievementProgressListTile(
          progress: UserAchievementProgress(
            currentTier: TierIdentifier.silver,
            nextTier: TierIdentifier.gold,
            tiersProgress: {
              TierIdentifier.bronze: 3,
              TierIdentifier.silver: 7,
              TierIdentifier.gold: 1,
            },
          ),
          achievement: achievement,
        );

    AchievementProgressListTile goldComplete() =>
        const AchievementProgressListTile(
          progress: UserAchievementProgress(
            nextTier: TierIdentifier.gold,
            currentTier: TierIdentifier.gold,
            tiersProgress: {
              TierIdentifier.bronze: 3,
              TierIdentifier.silver: 7,
              TierIdentifier.gold: 15,
            },
          ),
          achievement: achievement,
        );

    testGoldens(
      'AchievementProgressListTiles should look correct',
      (tester) async {
        await loadAppFonts();
        final builder = GoldenBuilder.column()
          ..addScenario('Bronze No Progress', noProgressToBronze())
          ..addScenario('Bronze', progressToBronze())
          ..addScenario('Silver', bronzeToSilver())
          ..addScenario('Gold', silverToGold())
          ..addScenario('Gold Complete', goldComplete());
        await tester.pumpWidgetBuilder(
          builder.build(),
          surfaceSize: const Size(
            400,
            (AchievementProgressListTile.height + goldenLabelHeight) * 5,
          ),
        );
        await screenMatchesGolden(
          tester,
          'achievements_progress_list_tiles',
        );
      },
    );
  });
}
