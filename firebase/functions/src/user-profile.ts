import { DocumentData, QueryDocumentSnapshot } from "firebase-admin/firestore";
import { AchievementProgresses } from "./achievement";

export type UserProfile = {
  VeriPoints?: number;
  Statistics?: Statistics;
  AchievementProgresses?: AchievementProgresses;
}

export type Statistics = {
  AccessPointsCreated?: number;
  AccessPointsValidated?: number;
  TwitterVeriFied?: number;
}

export const userProfileConverter = {
  toFirestore(userProfile: UserProfile): DocumentData {
    return {
      VeriPoints: userProfile.VeriPoints,
      AchievementProgresses: userProfile.AchievementProgresses,
    };
  },
  fromFirestore(
    snapshot: QueryDocumentSnapshot,
  ): UserProfile {
    const data = snapshot.data()!;
    return {
      VeriPoints: data.VeriPoints,
      AchievementProgresses: data.AchievementProgresses,
    };
  }
};

