import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getTweepByTwitterUID } from "./tweeps";
import { UserRewardCalculator } from "./reward-user";
import {
  Achievement,
  achievementCollection,
  Statistics,
  userProfileCollection,
} from "./types";

admin.initializeApp();
const db = admin.firestore();

const fetchAchievements = async (
  db: admin.firestore.Firestore,
  statisticNames: Array<string>
): Promise<Achievement[]> => {
  const achievementSnapshot = await achievementCollection(db)
    .where("StatisticsKey", "in", statisticNames)
    .get();

  return achievementSnapshot.docs.map((achievementDoc) =>
    achievementDoc.data()
  );
};

const userRewardCalculator = new UserRewardCalculator({
  fetchAchievements: (statisticNames: Array<keyof Statistics>) =>
    fetchAchievements(db, statisticNames),
  log: functions.logger.log,
});

export const accessPointCreated = functions.firestore
  .document("AccessPoint/{apId}")
  .onCreate(async (apSnap) => {
    const submittedBy = apSnap.data().SubmittedBy;

    const profileRef = userProfileCollection(db).doc(submittedBy);
    return await db.runTransaction(async (t) => {
      // Find the user that created the AccessPoint
      const userSnap = await t.get(profileRef);
      const profileData = userSnap.data();
      if (!profileData) return Promise.reject(Error("User not found"));

      // Apply rewards
      const rewardedProfile = await userRewardCalculator.withRewards({
        userProfile: profileData,
        veriPointsChange: 5,
        statisticsChange: { AccessPointsCreated: 1 },
      });

      // Apply changes
      return t.update(profileRef, rewardedProfile);
    });
  });

export const accessPointVerified = functions.firestore
  .document("AccessPoint/{apId}")
  .onUpdate(async (change, context) => {
    const uid = context.auth?.uid;
    if (uid == undefined) return Promise.reject(Error("Unauthenticated"));

    // Only reward the user after a validation.
    if (
      change.before.get("LastValidated") == change.after.get("LastValidated")
    ) {
      return Promise.resolve();
    }

    const profileRef = userProfileCollection(db).doc(uid);
    return await db.runTransaction(async (t) => {
      // Find the user who made the change.
      const userSnap = await t.get(profileRef);
      const profileData = userSnap.data();
      if (!profileData) return Promise.reject(Error("User not found"));

      // Apply rewards
      const rewardedProfile = await userRewardCalculator.withRewards({
        userProfile: profileData,
        veriPointsChange: 1,
        statisticsChange: { AccessPointsValidated: 1 },
      });

      // Apply changes
      return t.update(profileRef, rewardedProfile);
    });
  });

import express from "express";
import basicAuth from "express-basic-auth";

const expressApp = express();
expressApp.use(
  basicAuth({
    users: { cloudrun: "EDWfDTM3PX95x6Le" },
  })
);

// Receive a POST request from Cloud Run containing Twitter UID. If UID is
// linked to a Firebase Auth user, and that user already has Silver tier of the
// Twitter achievement, grant that user the Gold tier for Twitter achievement.
export const listenForVeriFiedTweeps = functions.https.onRequest(
  async (req, resp) => {
    try {
      // Extract username from query
      const twitterUID = req.body["id"];
      if (typeof twitterUID !== "string") {
        const result = `Invalid request: ${req.body}`;
        console.log(result);
        resp.status(400).send(result);
        return;
      }

      // Get user from Firebase Auth lookup
      const tweepUID = await getTweepByTwitterUID(twitterUID, undefined);
      if (!tweepUID) {
        const result = `No user found with linked Twitter UID: ${twitterUID}`;
        console.log(result);
        resp.status(400).send(result);
        return;
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log("Error in listenForVeriFiedTweeps: ", error);
        throw error;
      }
    }
  }
);

export * from "./types";
