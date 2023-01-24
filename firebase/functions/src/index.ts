import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Statistics, UserProfile, userProfileConverter } from "./user-profile";
import { UserRewardCalculator } from "./reward-user";
import { fetchAchievements } from "./achievement";

admin.initializeApp();
const db = admin.firestore();

const userRewardCalculator = new UserRewardCalculator({
  fetchAchievements: (statisticNames: Array<keyof Statistics>) =>
    fetchAchievements(db, statisticNames),
  log: functions.logger.log,
});

export const accessPointCreated = functions.firestore
  .document("AccessPoint/{apId}")
  .onCreate(async (apSnap) => {
    const submittedBy = apSnap.data().SubmittedBy;

    // Find the user that created the AccessPoint
    const userProfileCollection = db.
      collection("UserProfile").
      withConverter(userProfileConverter);
    const userSnap = await userProfileCollection.doc(submittedBy).get();
    const profileData = userSnap.data();
    if (!profileData) return Promise.reject("User not found");

    // Calculate changes to the profile
    const changes = userRewardCalculator.calculateUserReward(
      {
        userProfile: profileData,
        veriPoints: 5,
        statistics: { "AccessPointsCreated": 1 },
      },
    );
    const updatedUser: UserProfile = { ...profileData, ...changes, };

    // Apply changes
    return userProfileCollection
      .doc(submittedBy)
      .update(updatedUser);
  });

export const accessPointVerified = functions.firestore
  .document("AccessPoint/{apId}")
  .onUpdate(async (change, context) => {
    const uid = context.auth?.uid;
    if (uid == undefined) return Promise.reject("Unauthenticated");

    // Only reward the user after a validation.
    if (change.before.get("LastValidated") == change.after.get("LastValidated")) {
      return Promise.resolve();
    }

    // Find the user who made the change.
    const userProfileCollection = db.
      collection("UserProfile").
      withConverter(userProfileConverter);
    const userSnap = await userProfileCollection.doc(uid).get();
    const profileData = userSnap.data();
    if (!profileData) return Promise.reject("User not found");

    // Calculate changes to the profile
    const changes = userRewardCalculator.calculateUserReward(
      {
        userProfile: profileData,
        veriPoints: 1,
        statistics: { "AccessPointsValidated": 1 },
      },
    );
    const updatedUser: UserProfile = { ...profileData, ...changes, };

    // Apply changes
    return userProfileCollection
      .doc(uid)
      .update(updatedUser);
  });

