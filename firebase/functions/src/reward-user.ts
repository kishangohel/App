import { Achievement, AchievementProgresses } from "./achievement";
import { Statistics, UserProfile } from "./user-profile";

interface CalculateUserRewardProps {
  userProfile: UserProfile,
  veriPoints?: number,
  statistics?: Statistics,
}

type UserProfileChanges = {
  VeriPoints?: number,
  Statistics?: Statistics,
  AchievementProgresses?: AchievementProgresses,
}

export class UserRewardCalculator {
  _fetchAchievements: (statisticNames: (keyof Statistics)[]) => Promise<Array<Achievement>>;
  _log: (message: string) => any;

  constructor({
    fetchAchievements,
    log,
  }: {
    fetchAchievements: (statisticNames: (keyof Statistics)[]) => Promise<Array<Achievement>>,
    log: (message: string) => any,
  }) {
    this._fetchAchievements = fetchAchievements;
    this._log = log;
  }

  calculateUserReward = async (
    userRewardProps: CalculateUserRewardProps
  ): Promise<UserProfileChanges> => {
    const { userProfile, veriPoints } = userRewardProps;
    const statistics: Statistics = userRewardProps.statistics ?? {};
    let result: UserProfileChanges = {};

    // Calculate VeriPoints change
    result = {
      ...result,
      ...this.veriPointsChange(userProfile.VeriPoints ?? 0, veriPoints ?? 0),
    };

    // Calculate Statistics change
    for (const statisticName of (Object.keys(statistics) as Array<keyof Statistics>)) {
      const statisticValue = statistics[statisticName] ?? 0;
      result = {
        ...result,
        ...this.statisticsChange(userProfile.Statistics ?? {}, statisticName, statisticValue),
      };
    }

    // Calculate AchievementProgresses change as a result of Statistics change.
    result = {
      ...result,
      ...(await this.achievementsChange(
        this._fetchAchievements,
        userProfile.AchievementProgresses ?? {},
        result,
      )),
    };

    return result;
  }


  private veriPointsChange(
    veriPoints: number,
    veriPointsDelta: number,
  ): UserProfileChanges {
    if (veriPoints == 0 && veriPointsDelta == 0) return {};
    veriPoints += veriPointsDelta;

    return { VeriPoints: veriPoints };
  }

  private statisticsChange(
    statistics: Statistics,
    statisticsKey: keyof Statistics,
    valueDelta: number,
  ): UserProfileChanges {
    statistics[statisticsKey] ??= 0;
    statistics[statisticsKey]! += valueDelta;

    return { Statistics: statistics };
  }

  private async achievementsChange(
    fetchAchievements: (statisticNames: (keyof Statistics)[]) => Promise<Array<Achievement>>,
    achievementProgresses: AchievementProgresses,
    changes: UserProfileChanges,
  ): Promise<UserProfileChanges> {
    // No achievement changes if no statistics changed.
    if (!changes.Statistics) {
      this._log("No change to achievements: no statistics changed");
      return Promise.resolve({});
    }

    // Fetch achievements
    const matchingAchievements = await fetchAchievements(
      Object.keys(changes.Statistics) as Array<keyof Statistics>,
    );
    if (matchingAchievements.length == 0) {
      this._log("No change to achievements: no matching achievements exist");
      return Promise.resolve({});
    }

    let updatedAchievementProgresses: AchievementProgresses = { ...achievementProgresses }
    let veriPointsAward = 0;
    let tierChanged = false;

    for (const achievement of matchingAchievements) {
      // Find the relevant statistic value
      const statisticsKey: keyof Statistics = achievement.StatisticsKey;
      const statisticValue: number = changes.Statistics[statisticsKey]!;

      // Calculate the achievement tier with the new statistics
      const previousTierIndex: number = achievementProgresses[achievement.Identifier] ?? -1;
      let nextTierIndex = -1;
      for (let i = achievement.Tiers.length - 1; i >= 0; i--) {
        if (statisticValue >= achievement.Tiers[i].GoalTotal) {
          nextTierIndex = i;
          break;
        }
      }

      // If we are in a higher tier, record the new tier and award points
      if (nextTierIndex > previousTierIndex) {
        tierChanged = true;
        updatedAchievementProgresses[achievement.Identifier] = nextTierIndex;
        for (let i = Math.max(previousTierIndex, 0); i <= nextTierIndex; i++) {
          veriPointsAward += achievement.Tiers[i].VeriPointsAward ?? 0;
        }
      }
    }

    // Build the result object with the changes
    const result: UserProfileChanges = {};
    if (veriPointsAward != 0) {
      result.VeriPoints = (changes.VeriPoints ?? 0) + veriPointsAward;
    }
    if (tierChanged) {
      result.AchievementProgresses = updatedAchievementProgresses;
    }

    return result;
  }
}

