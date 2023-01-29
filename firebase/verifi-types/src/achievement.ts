import { CollectionReference, DocumentData, Firestore, QueryDocumentSnapshot } from "firebase-admin/firestore";
import { Statistics } from "./user-profile";

const achievementIdentifiers = [
  'AccessPointCreator',
  'AccessPointValidator',
  'TwitterVeriFied',
] as const;
export type AchievementIdentifier = typeof achievementIdentifiers[number];

export type Achievement = {
  Identifier: AchievementIdentifier;
  Name: string;
  ListPriority: number;
  StatisticsKey: keyof Statistics;
  Description?: string;
  Tiers: AchievementTier[];
}

const tierIdentifiers = [
  'BronzeTier',
  'SilverTier',
  'GoldTier',
] as const;
export type TierIdentifier = typeof tierIdentifiers[number];
export type AchievementTier = {
  Identifier: TierIdentifier;
  GoalTotal: number;
  VeriPointsAward?: number;
  Description?: string;
}


export type AchievementProgresses = {
  [key in AchievementIdentifier]?: number;
}

const converter = {
  toFirestore(achievement: Achievement): DocumentData {
    const result: DocumentData = { ...achievement };

    if (achievement.Description === undefined) delete result.Description;

    return result;
  },
  fromFirestore(
    snapshot: QueryDocumentSnapshot,
  ): Achievement {
    const data = snapshot.data()!;
    return {
      Identifier: data.Identifier,
      Name: data.Name,
      ListPriority: data.ListPriority,
      StatisticsKey: data.StatisticsKey,
      Description: data.Description,
      Tiers: data.Tiers,
    };
  }
};

export const achievementCollection = (
  db: Firestore
): CollectionReference<Achievement> =>
  db.collection("Achievement").withConverter(converter);
