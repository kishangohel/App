import _ from "lodash";
import { Achievement, Statistics, UserProfile } from "./types";

interface WithRewardProps {
  userProfile: UserProfile;
  veriPointsChange: number;
  statisticsChange: Statistics;
}

export class UserRewardCalculator {
  _fetchAchievements: (
    statisticNames: (keyof Statistics)[]
  ) => Promise<Array<Achievement>>;
  _log: (message: string) => void;

  constructor({
    fetchAchievements,
    log,
  }: {
    fetchAchievements: (
      statisticNames: (keyof Statistics)[]
    ) => Promise<Array<Achievement>>;
    log: (message: string) => void;
  }) {
    this._fetchAchievements = fetchAchievements;
    this._log = log;
  }

  withRewards = async (
    withRewardProps: WithRewardProps
  ): Promise<UserProfile> => {
    const { userProfile, veriPointsChange, statisticsChange } = withRewardProps;
    const result: UserProfile = _.cloneDeep(userProfile);

    // Apply the VeriPoints change
    result.VeriPoints += veriPointsChange;

    // Apply the Statistics change
    this.updateStatistics(result, statisticsChange);

    // Apply the AchievementProgresses change as a result of Statistics change.
    await this.updateAchievementProgresses(this._fetchAchievements, result);

    return result;
  };

  private updateStatistics(
    userProfile: UserProfile,
    statisticsChange: Statistics
  ) {
    for (const statisticName of Object.keys(statisticsChange) as Array<
      keyof Statistics
    >) {
      userProfile.Statistics[statisticName] ??= 0;
      userProfile.Statistics[statisticName] =
        (userProfile.Statistics[statisticName] ?? 0) +
        (statisticsChange[statisticName] ?? 0);
    }
  }

  private async updateAchievementProgresses(
    fetchAchievements: (
      statisticNames: (keyof Statistics)[]
    ) => Promise<Array<Achievement>>,
    userProfile: UserProfile
  ): Promise<void> {
    // Fetch achievements
    const matchingAchievements = await fetchAchievements(
      Object.keys(userProfile.Statistics) as Array<keyof Statistics>
    );
    if (matchingAchievements.length == 0) {
      this._log("No change to achievements: no matching achievements exist");
      return;
    }

    for (const achievement of matchingAchievements) {
      this.updateAchievementProgress(userProfile, achievement);
    }
  }

  private updateAchievementProgress = (
    userProfile: UserProfile,
    achievement: Achievement
  ) => {
    // Find the relevant statistic value
    const statisticsKey: keyof Statistics = achievement.StatisticsKey;
    const statisticValue: number = userProfile.Statistics[statisticsKey] ?? 0;

    // Calculate the achievement tier with the new statistics
    const previousTierIndex: number =
      userProfile.AchievementProgresses[achievement.Identifier] ?? -1;
    let newTierIndex = -1;
    for (let i = achievement.Tiers.length - 1; i >= 0; i--) {
      if (statisticValue >= achievement.Tiers[i].GoalTotal) {
        newTierIndex = i;
        break;
      }
    }

    // If we are in a higher tier, record the new tier and award points
    if (newTierIndex > previousTierIndex) {
      userProfile.AchievementProgresses[achievement.Identifier] = newTierIndex;
      for (let i = Math.max(previousTierIndex, 0); i <= newTierIndex; i++) {
        userProfile.VeriPoints += achievement.Tiers[i].VeriPointsAward ?? 0;
      }
    }
  };
}
