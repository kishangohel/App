import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/achievement/presentation/achievement_progress_list_tile.dart';

void main() {
  group(AchievementProgressListTile, () {
    const goldenLabelHeight = 45.0;

    AchievementProgressListTile noProgress() => AchievementProgressListTile(
          progress: AchievementProgress(
            completedTier: null,
            isComplete: false,
            title: "No Progress Achievement",
            description: "Test Achievement Description",
            progress: 0,
            total: 10,
          ),
        );

    AchievementProgressListTile bronze() => AchievementProgressListTile(
          progress: AchievementProgress(
            completedTier: TierIdentifier.bronze,
            isComplete: false,
            title: "Bronze Achievement",
            description: "Test Achievement Description",
            progress: 3,
            total: 10,
          ),
        );

    AchievementProgressListTile silver() => AchievementProgressListTile(
          progress: AchievementProgress(
            completedTier: TierIdentifier.silver,
            isComplete: false,
            title: "Silver Achievement",
            description: "Test Achievement Description",
            progress: 8,
            total: 10,
          ),
        );

    AchievementProgressListTile gold() => AchievementProgressListTile(
          progress: AchievementProgress(
            completedTier: TierIdentifier.gold,
            isComplete: true,
            title: "Gold Achievement",
            description: "Test Achievement Description",
            progress: 10,
            total: 10,
          ),
        );

    testGoldens('AchievementProgressListTiles should look correct',
        (tester) async {
      await loadAppFonts();
      final builder = GoldenBuilder.column()
        ..addScenario('No Progress', noProgress())
        ..addScenario('Bronze', bronze())
        ..addScenario('Silver', silver())
        ..addScenario('Gold', gold());
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(
          400,
          (AchievementProgressListTile.height + goldenLabelHeight) * 4,
        ),
      );
      await screenMatchesGolden(
        tester,
        'achievement_progresses_list_tiles',
      );
    });
  });
}
