import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';

const achievement = Achievement(
  id: 'test-achievement',
  name: 'Test Achievement',
  description: 'A test achievement',
  priority: 1,
  cumulative: true,
  initialTier: TierIdentifier.bronze,
  tiers: {
    TierIdentifier.bronze: AchievementTier(
      requirement: 3,
      reward: 20,
      description: 'Do a thing',
    ),
    TierIdentifier.silver: AchievementTier(
      requirement: 10,
      reward: 50,
      description: 'Do another thing',
    ),
    TierIdentifier.gold: AchievementTier(
      requirement: 25,
      reward: 100,
      description: 'Do one final thing',
    ),
  },
);

const accessPointContributorAchievement = Achievement(
    id: 'AccessPointContributor',
    name: 'Access Point Contributor',
    description: 'Contribute access points',
    priority: 100,
    tiers: {
      TierIdentifier.bronze: AchievementTier(
        requirement: 3,
        reward: 20,
        description: 'Contribute 3 access points',
      ),
      TierIdentifier.silver: AchievementTier(
        requirement: 10,
        reward: 50,
        description: 'Contribute 10 access points',
      ),
      TierIdentifier.gold: AchievementTier(
        requirement: 25,
        reward: 100,
        description: 'Contribute 25 access points',
      ),
    },
    initialTier: TierIdentifier.bronze,
    cumulative: true);

// const achievementData = {
//   "Name": "Test Achievement",
//   "Description": "A test achievement",
//   "Priority": 1,
//   "Cumulative": true,
//   "Tiers": {
//     "Bronze": {
//       "Requirement": 1,
//       "Reward": 10,
//       "Description": "Do a thing",
//     }
//   },
// };
