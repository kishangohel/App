import "mocha";
import chai from "chai";
import { UserRewardCalculator } from '../src/reward-user';
import { Achievement } from "../src/achievement";
import { Statistics } from "../src/user-profile";
const { expect } = chai;


describe("rewardUser", () => {
  let loggedMessages: Array<string>;

  const createUserRewardCalculator =
    (achievements: Array<Achievement>): UserRewardCalculator => {
      return new UserRewardCalculator({
        fetchAchievements: (statisticNames: (keyof Statistics)[]) => {
          return Promise.resolve(
            achievements.filter((achievement) =>
              statisticNames.includes(achievement.StatisticsKey,
              )
            ),
          );
        },
        log: (message) => { loggedMessages.push(message); },
      });
    }

  beforeEach(() => {
    loggedMessages = [];
  });


  it("no reward", async () => {
    const rewardCalculator = createUserRewardCalculator([]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {},
    });

    expect(userProfileChange).deep.equals({});
    expect(loggedMessages).deep.equals(
      ["No change to achievements: no statistics changed"],
    );
  });

  it("only points awarded", async () => {
    const rewardCalculator = createUserRewardCalculator([]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {},
      veriPoints: 5,
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 5,
    });
    expect(loggedMessages).deep.equals(
      ["No change to achievements: no statistics changed"],
    );
  });

  it("no previous veripoints or statistics, no achievements", async () => {
    const rewardCalculator = createUserRewardCalculator([]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {},
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 5,
      Statistics: { AccessPointsCreated: 1 }
    });
    expect(loggedMessages).deep.equals(
      ["No change to achievements: no matching achievements exist"],
    );
  });

  it("no previous veripoints or statistics, achievement awarded", async () => {
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: 'AccessPointCreator',
        StatisticsKey: 'AccessPointsCreated',
        Tiers: [
          { GoalTotal: 1, VeriPointsAward: 10 },
        ],
      },
    ]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {},
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 15,
      Statistics: { AccessPointsCreated: 1 },
      AchievementProgresses: {
        AccessPointCreator: 0,
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("previous veripoints and statistics, no matching achievement", async () => {
    const rewardCalculator = createUserRewardCalculator([]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {
        Statistics: { AccessPointsCreated: 1 },
      },
      veriPoints: 5,
      statistics: { AccessPointsValidated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 5,
      Statistics: {
        AccessPointsValidated: 1,
        AccessPointsCreated: 1,
      },
    });
    expect(loggedMessages).deep.equals(
      ["No change to achievements: no matching achievements exist"],
    );
  });

  it("matching achievement, not enough progress for next tier", async () => {
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: 'AccessPointCreator',
        StatisticsKey: 'AccessPointsCreated',
        Tiers: [
          { GoalTotal: 1, VeriPointsAward: 10 },
          { GoalTotal: 10, VeriPointsAward: 20 },
        ],
      },
    ]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: { AccessPointCreator: 0 },
      },
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 20,
      Statistics: {
        AccessPointsCreated: 2,
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("achievement is not downgraded if GoalTotal has been increased", async () => {
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: 'AccessPointCreator',
        StatisticsKey: 'AccessPointsCreated',
        Tiers: [
          { GoalTotal: 100, VeriPointsAward: 10 },
        ],
      },
    ]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: { AccessPointCreator: 0 },
      },
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 20,
      Statistics: {
        AccessPointsCreated: 2,
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("achievement points are not rewarded if the tier has already been achieved", async () => {
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: 'AccessPointCreator',
        StatisticsKey: 'AccessPointsCreated',
        Tiers: [
          { GoalTotal: 100, VeriPointsAward: 10 },
        ],
      },
    ]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {
        VeriPoints: 0,
        Statistics: { AccessPointsCreated: 99 },
        AchievementProgresses: { AccessPointCreator: 0 },
      },
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 5,
      Statistics: {
        AccessPointsCreated: 100,
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("multiple tiers achieved at once", async () => {
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: 'AccessPointCreator',
        StatisticsKey: 'AccessPointsCreated',
        Tiers: [
          { GoalTotal: 1, VeriPointsAward: 10 },
          { GoalTotal: 10, VeriPointsAward: 20 },
        ],
      },
    ]);
    const userProfileChange = await rewardCalculator.calculateUserReward({
      userProfile: {
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 9 },
      },
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });

    expect(userProfileChange).deep.equals({
      VeriPoints: 50,
      Statistics: {
        AccessPointsCreated: 10,
      },
      AchievementProgresses: {
        AccessPointCreator: 1,
      }
    });
    expect(loggedMessages).deep.equals([]);
  });
});
