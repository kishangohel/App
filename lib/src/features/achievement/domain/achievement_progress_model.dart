import 'dart:math';

import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class AchievementProgress {
  final TierIdentifier? completedTier;
  final bool isComplete;
  final String title;
  final String description;
  final int progress;
  final int total;

  AchievementProgress({
    required this.completedTier,
    required this.isComplete,
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
  });

  static AchievementProgress evaluate(
    UserProfile profile,
    Achievement achievement,
  ) {
    final int progress = profile.statistics[achievement.statisticsKey] ?? 0;
    final int completedTierIndex = min(
      profile.achievementProgresses[achievement.identifier] ?? -1,
      achievement.tiers.length - 1,
    );
    AchievementTier? completedTier =
        completedTierIndex == -1 ? null : achievement.tiers[completedTierIndex];
    final targetTierIndex =
        min(completedTierIndex + 1, achievement.tiers.length - 1);

    AchievementTier targetTier = achievement.tiers[targetTierIndex];
    final isComplete = completedTierIndex == achievement.tiers.length - 1;

    return AchievementProgress(
      completedTier: completedTier?.identifier,
      isComplete: isComplete,
      title: achievement.name,
      description: targetTier.description ?? achievement.description ?? "",
      progress: progress,
      total: targetTier.goalTotal,
    );
  }

  bool get anyTierAchieved => completedTier != null;
}
