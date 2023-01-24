import { firestore } from "firebase-admin";
import { DocumentData, QueryDocumentSnapshot } from "firebase-admin/firestore";
import { Statistics } from "./user-profile";

export type Achievement = {
  Identifier: AchievementIdentifier,
  StatisticsKey: keyof Statistics,
  Tiers: AchievementTier[],
}

export type AchievementTier = {
  GoalTotal: number;
  VeriPointsAward?: number;
}

const achievementIdentifiers = [
  'AccessPointCreator',
  'AccessPointValidator',
  'TwitterVeriFied',
] as const;
type AchievementIdentifier = typeof achievementIdentifiers[number];

export type AchievementProgresses = {
  [key in AchievementIdentifier]?: number;
}

const achievementConverter = {
  toFirestore(achievement: Achievement): DocumentData {
    return {
      Identifier: achievement.Identifier,
      StatisticsKey: achievement.StatisticsKey,
      Tiers: achievement.Tiers,
    };
  },
  fromFirestore(
    snapshot: QueryDocumentSnapshot,
  ): Achievement {
    const data = snapshot.data()!;
    return {
      Identifier: data.Identifier,
      StatisticsKey: data.StatisticsKey,
      Tiers: data.Tiers,
    };
  }
};

export const fetchAchievements = async (db: firestore.Firestore, statisticNames: Array<string>): Promise<Achievement[]> => {
  const achievementSnapshot = await db.
    collection("Achievement").
    withConverter(achievementConverter).
    where("StatisticsKey", "in", statisticNames).
    get();

  return achievementSnapshot.docs.map((achievementDoc) => achievementDoc.data());
}

