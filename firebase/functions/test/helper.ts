import { Timestamp } from "firebase-admin/firestore";
import { UserRewardCalculator } from "../src/reward-user";
import { Achievement, AchievementIdentifier, AchievementProgresses, AchievementTier, Statistics, UserProfile } from "../src/types";
import { TierIdentifier } from "../src/types/achievement";

type CreateUserProfileProps = {
  VeriPoints?: number;
  Statistics?: Statistics;
  AchievementProgresses?: AchievementProgresses;
};
export const createUserProfile = (
  props?: CreateUserProfileProps
): UserProfile => {
  return {
    DisplayName: "TestUser",
    CreatedOn: Timestamp.now(),
    VeriPoints: props?.VeriPoints ?? 0,
    Statistics: props?.Statistics ?? {},
    AchievementProgresses: props?.AchievementProgresses ?? {},
  };
};

type CreateAchievementProps = {
  Identifier: AchievementIdentifier;
  StatisticsKey: keyof Statistics;
  Tiers: Array<AchievementTier>;
};

export const createAchievement = (
  props: CreateAchievementProps
): Achievement => {
  return {
    Name: "TestAchievement",
    Identifier: props.Identifier,
    StatisticsKey: props.StatisticsKey,
    ListPriority: 100,
    Tiers: props.Tiers,
  };
};

type CreateAchievementTierProps = {
  Identifier?: TierIdentifier;
  GoalTotal: number;
  VeriPointsAward: number;
  Description?: string;
};

export const createTier = (
  props: CreateAchievementTierProps
): AchievementTier => {
  return {
    Identifier: props.Identifier ?? "GoldTier",
    GoalTotal: props.GoalTotal,
    VeriPointsAward: props.VeriPointsAward,
    Description: props.Description,
  };
};

export const createUserRewardCalculator = (
  achievements: Array<Achievement>,
  log: (message: string) => void
): UserRewardCalculator => {
  return new UserRewardCalculator({
    fetchAchievements: (statisticNames: (keyof Statistics)[]) => {
      return Promise.resolve(
        achievements.filter((achievement) =>
          statisticNames.includes(achievement.StatisticsKey)
        )
      );
    },
    log: log,
  });
};
