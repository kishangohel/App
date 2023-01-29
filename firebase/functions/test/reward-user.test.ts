import "mocha";
import chai from "chai";
import { UserRewardCalculator } from "../src/reward-user";
import { Achievement, Statistics, UserProfile } from "verifi-types";
import {
  createAchievement,
  createTier,
  createUserProfile,
  createUserRewardCalculator,
} from "./helper";
import _ from "lodash";
const { expect } = chai;

describe("rewardUser", () => {
  let loggedMessages: Array<string>;

  const createCalculator = (
    achievements: Array<Achievement>
  ): UserRewardCalculator => {
    return createUserRewardCalculator(achievements, (message) =>
      loggedMessages.push(message)
    );
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
    await expectReward({
      calculator: createCalculator([]),
      input: createUserProfile(),
      veriPointsChange: 0,
      statisticsChange: {},
      expectedOutput: createUserProfile(),
    });

    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("only points awarded", async () => {
    await expectReward({
      calculator: createCalculator([]),
      input: createUserProfile(),
      veriPointsChange: 5,
      statisticsChange: {},
      expectedOutput: createUserProfile({ VeriPoints: 5 }),
    });
    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("no previous veripoints or statistics, no achievements", async () => {
    await expectReward({
      calculator: createCalculator([]),
      input: createUserProfile(),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 5,
        Statistics: { AccessPointsCreated: 1 },
      }),
    });

    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("previous veripoints and statistics, no matching achievement", async () => {
    await expectReward({
      calculator: createCalculator([]),
      input: createUserProfile({
        VeriPoints: 10,
        Statistics: { AccessPointsCreated: 1 },
      }),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsValidated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 15,
        Statistics: {
          AccessPointsCreated: 1,
          AccessPointsValidated: 1,
        },
      }),
    });

    expect(loggedMessages).deep.equals([
      "No change to achievements: no matching achievements exist",
    ]);
  });

  it("no previous veripoints or statistics, achievement awarded", async () => {
    const rewardCalculator = createCalculator([
      createAchievement({
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [
          {
            Identifier: "GoldTier",
            GoalTotal: 1,
            VeriPointsAward: 10,
          },
        ],
      }),
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: createUserProfile(),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: {
          AccessPointCreator: 0,
        },
      }),
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("matching achievement, not enough progress for next tier", async () => {
    const rewardCalculator = createCalculator([
      createAchievement({
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [
          createTier({ GoalTotal: 1, VeriPointsAward: 10 }),
          createTier({ GoalTotal: 10, VeriPointsAward: 20 }),
        ],
      }),
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: createUserProfile({
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: { AccessPointCreator: 0 },
      }),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 20,
        Statistics: { AccessPointsCreated: 2 },
        AchievementProgresses: { AccessPointCreator: 0 },
      }),
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("achievement is not downgraded if GoalTotal has been increased", async () => {
    const rewardCalculator = createCalculator([
      createAchievement({
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [createTier({ GoalTotal: 100, VeriPointsAward: 10 })],
      }),
    ]);
    await expectReward({
      calculator: rewardCalculator,
      input: createUserProfile({
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 1 },
        AchievementProgresses: { AccessPointCreator: 0 },
      }),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 20,
        Statistics: { AccessPointsCreated: 2 },
        AchievementProgresses: { AccessPointCreator: 0 },
      }),
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("achievement points are not rewarded if the tier has already been achieved", async () => {
    const rewardCalculator = createCalculator([
      createAchievement({
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [createTier({ GoalTotal: 100, VeriPointsAward: 10 })],
      }),
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: createUserProfile({
        VeriPoints: 0,
        Statistics: { AccessPointsCreated: 99 },
        AchievementProgresses: { AccessPointCreator: 0 },
      }),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 5,
        Statistics: { AccessPointsCreated: 100 },
        AchievementProgresses: { AccessPointCreator: 0 },
      }),
    });
    expect(loggedMessages).deep.equals([]);
  });

  it("multiple tiers achieved at once", async () => {
    const rewardCalculator = createCalculator([
      createAchievement({
        Identifier: "AccessPointCreator",
        StatisticsKey: "AccessPointsCreated",
        Tiers: [
          createTier({ GoalTotal: 1, VeriPointsAward: 10 }),
          createTier({ GoalTotal: 10, VeriPointsAward: 20 }),
        ],
      }),
    ]);

    await expectReward({
      calculator: rewardCalculator,
      input: createUserProfile({
        VeriPoints: 15,
        Statistics: { AccessPointsCreated: 9 },
        AchievementProgresses: {},
      }),
      veriPointsChange: 5,
      statisticsChange: { AccessPointsCreated: 1 },
      expectedOutput: createUserProfile({
        VeriPoints: 50,
        Statistics: { AccessPointsCreated: 10 },
        AchievementProgresses: { AccessPointCreator: 1 },
      }),
    });
    expect(loggedMessages).deep.equals([]);
  });
});
