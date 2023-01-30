import * as admin from "firebase-admin";
import { Achievement, achievementCollection } from "functions";

const achievements: Array<Achievement> = [
  {
    Identifier: "AccessPointCreator",
    StatisticsKey: "AccessPointsCreated",
    Name: "Access Point Creator",
    Description: "Create access points",
    ListPriority: 100,
    Tiers: [
      {
        Identifier: "BronzeTier",
        GoalTotal: 3,
        VeriPointsAward: 20,
      },
      {
        Identifier: "SilverTier",
        GoalTotal: 10,
        VeriPointsAward: 40,
      },
      {
        Identifier: "GoldTier",
        GoalTotal: 25,
        VeriPointsAward: 60,
      },
    ],
  },
  {
    Identifier: "AccessPointValidator",
    StatisticsKey: "AccessPointsValidated",
    Name: "Access Point Validator",
    Description: "Validate access points",
    ListPriority: 200,
    Tiers: [
      {
        Identifier: "BronzeTier",
        GoalTotal: 3,
        VeriPointsAward: 20,
      },
      {
        Identifier: "SilverTier",
        GoalTotal: 10,
        VeriPointsAward: 40,
      },
      {
        Identifier: "GoldTier",
        GoalTotal: 25,
        VeriPointsAward: 60,
      },
    ],
  },
  // {
  //     Identifier: "TwitterVeriFied",
  //     StatisticsKey: "TwitterVeriFied",
  //     Name: "Twitter VeriFied",
  //     ListPriority: 300,
  //     Tiers: [
  //         {
  //             Identifier: "SilverTier",
  //             Description: "Connect your Twitter account",
  //             GoalTotal: 1,
  //             VeriPointsAward: 40,
  //         },
  //         {
  //             Identifier: "GoldTier",
  //             Description: "Post VeriFied tweet",
  //             GoalTotal: 2,
  //             VeriPointsAward: 60,
  //         },
  //     ],
  // },
]

export const createAchievements = async (
  db: admin.firestore.Firestore,
): Promise<void> => {
  const collection = achievementCollection(db);

  const batch = db.batch();
  for (const achievement of achievements) {
    batch.create(collection.doc(), achievement);
  }

  await batch.commit();
}
