import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

void main() {
  group(AchievementProgress, () {
    UserProfile createProfile({
      required Map<String, int> statistics,
      required Map<String, int> achievementProgresses,
    }) =>
        UserProfile(
          id: 'testUserId',
          displayName: 'testUserDisplayName',
          hideOnMap: false,
          statistics: statistics,
          achievementProgresses: achievementProgresses,
        );

    test('No relevant statistics or progress', () {
      final profile = createProfile(statistics: {}, achievementProgresses: {});
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        tiers: [
          AchievementTier(identifier: TierIdentifier.gold, goalTotal: 10),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.completedTier, isNull);
      expect(progress.isComplete, isFalse);
      expect(progress.anyTierAchieved, isFalse);
      expect(progress.title, achievement.name);
      expect(progress.description.isEmpty, isTrue);
      expect(progress.progress, 0);
      expect(progress.total, 10);
    });

    test('description comes from achievement if tier has none', () {
      final profile = createProfile(statistics: {}, achievementProgresses: {});
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        description: "Test Achievement description",
        tiers: [
          AchievementTier(identifier: TierIdentifier.gold, goalTotal: 10),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.description, achievement.description);
    });

    test('description comes from tier if provided', () {
      final profile = createProfile(statistics: {}, achievementProgresses: {});
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        description: "Test Achievement description",
        tiers: [
          AchievementTier(
            identifier: TierIdentifier.gold,
            goalTotal: 10,
            description: "Achievement tier description",
          ),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.description, achievement.tiers.single.description);
    });

    test('matching statistic, no tier achieved', () {
      final profile = createProfile(
        statistics: {'TestAchievementProgress': 5},
        achievementProgresses: {},
      );
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        description: "Test Achievement description",
        tiers: [
          AchievementTier(identifier: TierIdentifier.gold, goalTotal: 10),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.progress, 5);
    });

    test('matching statistic, tier achieved', () {
      final profile = createProfile(
        statistics: {'TestAchievementProgress': 12},
        achievementProgresses: {'TestAchievement': 0},
      );
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        description: "Test Achievement description",
        tiers: [
          AchievementTier(identifier: TierIdentifier.gold, goalTotal: 10),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.completedTier, TierIdentifier.gold);
      expect(progress.isComplete, isTrue);
      expect(progress.anyTierAchieved, isTrue);
      expect(progress.progress, 12);
      expect(progress.total, 10);
    });

    test('matching statistic, no matching progress', () {
      final profile = createProfile(
        statistics: {'TestAchievementProgress': 12},
        achievementProgresses: {'DifferentTestAchievement': 1},
      );
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        description: "Test Achievement description",
        tiers: [
          AchievementTier(identifier: TierIdentifier.gold, goalTotal: 10),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.completedTier, isNull);
      expect(progress.isComplete, isFalse);
      expect(progress.anyTierAchieved, isFalse);
      expect(progress.progress, 12);
      expect(progress.total, 10);
    });
    test('completed tier index is out of range, falls back to highest tier',
        () {
      final profile = createProfile(
        statistics: {'TestAchievementProgress': 12},
        achievementProgresses: {'TestAchievement': 1},
      );
      const achievement = Achievement(
        identifier: "TestAchievement",
        name: "Test Achievement",
        statisticsKey: "TestAchievementProgress",
        description: "Test Achievement description",
        tiers: [
          AchievementTier(identifier: TierIdentifier.gold, goalTotal: 10),
        ],
      );

      final progress = AchievementProgress.evaluate(profile, achievement);
      expect(progress.completedTier, TierIdentifier.gold);
      expect(progress.isComplete, isTrue);
      expect(progress.anyTierAchieved, isTrue);
      expect(progress.progress, 12);
      expect(progress.total, 10);
    });
  });
}
