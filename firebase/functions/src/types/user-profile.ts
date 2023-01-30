import { CollectionReference, DocumentData, Firestore, QueryDocumentSnapshot, Timestamp } from "firebase-admin/firestore";
import { AchievementProgresses } from "./achievement";
import { CoordinateWithGeohash } from "./coordinate-with-geohash";

export type UserProfile = {
  DisplayName: string,
  CreatedOn: Timestamp,
  VeriPoints: number;
  Statistics: Statistics;
  AchievementProgresses: AchievementProgresses;
  LastLocation?: CoordinateWithGeohash;
  LastLocationUpdate?: Timestamp;
}

export type Statistics = {
  AccessPointsCreated?: number;
  AccessPointsValidated?: number;
  TwitterVeriFied?: number;
}

const converter = {
  toFirestore(userProfile: UserProfile): DocumentData {
    const result: DocumentData = { ...userProfile };

    if (userProfile.LastLocation === undefined) delete result.LastLocation;
    if (userProfile.LastLocationUpdate === undefined) delete result.LastLocationUpdate;

    return result;
  },
  fromFirestore(
    snapshot: QueryDocumentSnapshot,
  ): UserProfile {
    const data = snapshot.data();
    return {
      DisplayName: data.DisplayName,
      CreatedOn: data.CreatedOn,
      VeriPoints: data.VeriPoints ?? 0,
      Statistics: data.Statistics ?? {},
      AchievementProgresses: data.AchievementProgresses ?? {},
      LastLocation: data.LastLocation,
    };
  }
};

export const userProfileCollection = (
  db: Firestore
): CollectionReference<UserProfile> =>
  db.collection("UserProfile").withConverter(converter);
