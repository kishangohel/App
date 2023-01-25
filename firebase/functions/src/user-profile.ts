import { DocumentData, QueryDocumentSnapshot } from "firebase-admin/firestore";
import { AchievementProgresses } from "./achievement";

export type UserProfile = {
  VeriPoints: number;
  Statistics: Statistics;
  AchievementProgresses: AchievementProgresses;
}

export type Statistics = {
  AccessPointsCreated?: number;
  AccessPointsValidated?: number;
  TwitterVeriFied?: number;
}

export const userProfileConverter = {
  toFirestore(userProfile: UserProfile): DocumentData {
    return userProfile;
  },
  fromFirestore(
    snapshot: QueryDocumentSnapshot,
  ): UserProfile {
    const data = snapshot.data()!;
    return {
      VeriPoints: data.VeriPoints ?? 0,
      Statistics: data.Statistics ?? {},
      AchievementProgresses: data.AchievementProgresses ?? {},
    };
  }
};

