import "mocha";
import chai from "chai";
import { UserRewardCalculator } from "../src/reward-user";
import { Achievement } from "../src/achievement";
import { Statistics, UserProfile } from "../src/user-profile";
import _ from "lodash";
const { expect } = chai;

describe("rewardUser", () => {
  let loggedMessages: Array<string>;

  const createUserRewardCalculator = (
    achievements: Array<Achievement>
  ): UserRewardCalculator => {
    return new UserRewardCalculator({
      fetchAchievements: (statisticNames: (keyof Statistics)[]) => {
        return Promise.resolve(
          achievements.filter((achievement) =>
            statisticNames.includes(achievement.StatisticsKey)
          )
        );
      },
      log: (message) => {
        loggedMessages.push(message);
      },
    });
  };

  beforeEach(() => {
    loggedMessages = [];
  });

  interface ExpectArgs {
    calculator: UserRewardCalculator;
    input: UserProfile;
    veriPointsChange: number;
    statisticsChange: Statistics;
    expectedOutput: UserProfile;
  }

  const expectReward = async (expectArgs: ExpectArgs): Promise<void> => {
    const inputCopy = _.cloneDeep(expectArgs.input);
    const output = await expectArgs.calculator.withRewards({
      userProfile: expectArgs.input,
      veriPointsChange: expectArgs.veriPointsChange,
      statisticsChange: expectArgs.statisticsChange,
    });

    expect(output).deep.eq(expectArgs.expectedOutput);
    expect(expectArgs.input).deep.eq(inputCopy);
  };

  it("no reward", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 0,
      Statistics: {},
      AchievementProgresses: {},
    };
    await expectReward({
      calculator: createUserRewardCalculator([]),
      input: userProfile,
      veriPointsChange: 0,
      statisticsChange: {},
      expectedOutput: userProfile,
    });

    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("only points awarded", async () => {
    const userProfile = {
      VeriPoints: 0,
      Statistics: {},
      AchievementProgresses: {},
    };
    await expectReward({
      calculator: createUserRewardCalculator([]),
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: {},
      expectedOutput: {
        VeriPoints: 5,
        Statistics: {},
        AchievementProgresses: {},
      },
    });
    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("no previous veripoints or statistics, no achievements", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 0,
      Statistics: {},
      AchievementProgresses: {},
    };
    await expectReward({
      calculator: createUserRewardCalculator([]),
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: {
        VeriPoints: 5,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: {},
      },
    });

    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("previous veripoints and statistics, no matching achievement", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 10,
      Statistics: { AccessPointsCreated: 1 },
      AchievementProgresses: {},
    };

    await expectReward({
      calculator: createUserRewardCalculator([]),
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsValidated: 1 },
      expectedOutput: {
        VeriPoints: 15,
        Statistics: {
          AccessPointsCreated: 1,
          AccessPointsValidated: 1,
        },
        AchievementProgresses: {},
      },
    });

    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("no previous veripoints or statistics, achievement awarded", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 0,
      Statistics: {},
      AchievementProgresses: {},
    };
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [{ GoalTotal: 1, VeriPointsAward: 10 }],
      },
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: {
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: {
          AccessPointCreator: 0,
        },
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("matching achievement, not enough progress for next tier", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 15,
      Statistics: { AccessPointsCreated: 1 },
      AchievementProgresses: { AccessPointCreator: 0 },
    };
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [
          { GoalTotal: 1, VeriPointsAward: 10 },
          { GoalTotal: 10, VeriPointsAward: 20 },
        ],
      },
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: {
        VeriPoints: 20,
        Statistics: { AccessPointsCreated: 2 },
        AchievementProgresses: { AccessPointCreator: 0 },
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("achievement is not downgraded if GoalTotal has been increased", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 15,
      Statistics: { AccessPointsCreated: 1 },
      AchievementProgresses: { AccessPointCreator: 0 },
    };
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [{ GoalTotal: 100, VeriPointsAward: 10 }],
      },
    ]);
    await expectReward({
      calculator: rewardCalculator,
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: {
        VeriPoints: 20,
        Statistics: { AccessPointsCreated: 2 },
        AchievementProgresses: { AccessPointCreator: 0 },
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("achievement points are not rewarded if the tier has already been achieved", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 0,
      Statistics: { AccessPointsCreated: 99 },
      AchievementProgresses: { AccessPointCreator: 0 },
    };
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [{ GoalTotal: 100, VeriPointsAward: 10 }],
      },
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: {
        VeriPoints: 5,
        Statistics: { AccessPointsCreated: 100 },
        AchievementProgresses: { AccessPointCreator: 0 },
      },
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("multiple tiers achieved at once", async () => {
    const userProfile: UserProfile = {
      VeriPoints: 15,
      Statistics: { AccessPointsCreated: 9 },
      AchievementProgresses: {},
    };
    const rewardCalculator = createUserRewardCalculator([
      {
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [
          { GoalTotal: 1, VeriPointsAward: 10 },
          { GoalTotal: 10, VeriPointsAward: 20 },
        ],
      },
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: userProfile,
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: {
        VeriPoints: 50,
        Statistics: { AccessPointsCreated: 10 },
        AchievementProgresses: { AccessPointCreator: 1 },
      },
    });
    expect(loggedMessages).deep.equals([]);
  });
});
