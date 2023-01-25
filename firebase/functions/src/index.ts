import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Statistics, userProfileConverter } from "./user-profile";
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

    const profileRef = db.
      collection("UserProfile").
      withConverter(userProfileConverter).
      doc(submittedBy);
    return await db.runTransaction(async (t) => {
      // Find the user that created the AccessPoint
      const userSnap = await t.get(profileRef);
      const profileData = userSnap.data();
      if (!profileData) return Promise.reject("User not found");

      // Apply rewards
      const rewardedProfile = await userRewardCalculator.withRewards(
        {
          userProfile: profileData,
          veriPointsChange: 5,
          statisticsChange: { "AccessPointsCreated": 1 },
        },
      );

      // Apply changes
      return t.update(profileRef, rewardedProfile);
    });
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

    const profileRef = db.
      collection("UserProfile").
      withConverter(userProfileConverter).
      doc(uid);
    return await db.runTransaction(async (t) => {
      // Find the user who made the change.
      const userSnap = await t.get(profileRef);
      const profileData = userSnap.data();
      if (!profileData) return Promise.reject("User not found");

      // Apply rewards
      const rewardedProfile = await userRewardCalculator.withRewards(
        {
          userProfile: profileData,
          veriPointsChange: 1,
          statisticsChange: { "AccessPointsValidated": 1 },
        },
      );

      // Apply changes
      return t.update(profileRef, rewardedProfile);
    });
  });

