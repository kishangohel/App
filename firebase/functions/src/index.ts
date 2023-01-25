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
    const userProfileCollection = db
      .collection("UserProfile")
      .withConverter(userProfileConverter);
    const userSnap = await userProfileCollection.doc(submittedBy).get();
    const profileData = userSnap.data();
    if (!profileData) return Promise.reject("User not found");

    // Calculate changes to the profile
    const changes = userRewardCalculator.calculateUserReward({
      userProfile: profileData,
      veriPoints: 5,
      statistics: { AccessPointsCreated: 1 },
    });
    const updatedUser: UserProfile = { ...profileData, ...changes };

    // Apply changes
    return userProfileCollection.doc(submittedBy).update(updatedUser);
  });

export const accessPointVerified = functions.firestore
  .document("AccessPoint/{apId}")
  .onUpdate(async (change, context) => {
    const uid = context.auth?.uid;
    if (uid == undefined) return Promise.reject("Unauthenticated");

    // Only reward the user after a validation.
    if (
      change.before.get("LastValidated") == change.after.get("LastValidated")
    ) {
      return Promise.resolve();
    }

    // Find the user who made the change.
    const userProfileCollection = db
      .collection("UserProfile")
      .withConverter(userProfileConverter);
    const userSnap = await userProfileCollection.doc(uid).get();
    const profileData = userSnap.data();
    if (!profileData) return Promise.reject("User not found");

    // Calculate changes to the profile
    const changes = userRewardCalculator.calculateUserReward({
      userProfile: profileData,
      veriPoints: 1,
      statistics: { AccessPointsValidated: 1 },
    });
    const updatedUser: UserProfile = { ...profileData, ...changes };

    // Apply changes
    return userProfileCollection.doc(uid).update(updatedUser);
  });

import express from "express";
import basicAuth from "express-basic-auth";

const expressApp = express();
expressApp.use(
  basicAuth({
    users: { "cloudrun": "EDWfDTM3PX95x6Le" }
  }),
);

// Receive a POST request from Cloud Run containing Twitter UID. If UID is 
// linked to a Firebase Auth user, and that user already has Silver tier of the 
// Twitter achievement, grant that user the Gold tier for Twitter achievement.
export const listenForVeriFiedTweeps = functions.https.onRequest(async (req, resp) => {
  try {

    // Extract username from query
    const twitterUID = req.query.uid;
    if (typeof twitterUID !== "string") {
      const result = `Invalid query parameter value for uid: ${twitterUID}`;
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
});

////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Private Functions ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Recursively fetches all Firebase Auth users with a linked Twitter account.
const getAllTweeps = async (
  nextPageToken: string | undefined,
  linkedUsers: Map<string, string>
) => {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    for (let userRecord of listUsersResult.users) {
      if (userRecord.providerData.length > 0) {
        for (let provider of userRecord.providerData) {
          if (provider.providerId === "twitter.com") {
            linkedUsers.set(userRecord.uid, provider.uid);
          }
        }
      }
    }
    if (listUsersResult.pageToken) {
      // List next batch of users.
      // Recursively call getAllTweeps() until no more pages are left
      await getAllTweeps(listUsersResult.pageToken, linkedUsers);
    }
    return linkedUsers;
  } catch (error) {
    console.log("Error listing users:", error);
    return linkedUsers;
  }
};

// Recursively searches for a Firebase Auth user with a linked Twitter account
// matching the given Twitter UID.
async function getTweepByTwitterUID(
  uid: string,
  nextPageToken: string | undefined,
): Promise<string | undefined> {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    for (let userRecord of listUsersResult.users) {
      if (userRecord.providerData.length > 0) {
        for (let provider of userRecord.providerData) {
          if (provider.providerId === "twitter.com") {
            if (provider.uid === uid) {
              return userRecord.uid;
            }
          }
        }
      }
    }
    if (listUsersResult.pageToken) {
      // List next batch of users.
      // Recursively call getAllTweeps() until no more pages are left
      return getTweepByTwitterUID(uid, listUsersResult.pageToken);
    }
    return undefined;
  } catch (error) {
    console.log("Unable to get user:", error);
    return undefined;
  }

}

/* class MapUtils { */
/*   static filter<TKey, TValue>( */
/*     map: Map<TKey, TValue>, */
/*     filterFunction: (key: TKey, value: TValue) => Promise<boolean> */
/*   ): Map<TKey, TValue> { */
/*     const filteredMap: Map<TKey, TValue> = new Map<TKey, TValue>(); */
/**/
/*     map.forEach(async (value, key) => { */
/*       if (await filterFunction(key, value)) { */
/*         filteredMap.set(key, value); */
/*       } */
/*     }); */
/**/
/*     return filteredMap; */
/*   } */
/* } */
