import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Statistics, UserProfile, userProfileConverter } from "./user-profile";
import { UserRewardCalculator } from "./reward-user";
import { fetchAchievements } from "./achievement";
import { UserRecord } from "firebase-admin/auth";

import { Client } from "twitter-api-sdk";
const TWITTER_BEARER_TOKEN =
  "AAAAAAAAAAAAAAAAAAAAANM7lAEAAAAA5sDkmklFRMtc91NnTZgkQsONDXY%3DioTFQAqX7Ka2i2yy4iZZ6xmBvI8bXjIml4Q0LJXpfcwKPOqBm0";

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

export const checkForVeriFiedTweets = functions.pubsub
  .schedule("every 20 minutes")
  .onRun(async (context) => {
    const twitterClient = new Client(
      "AAAAAAAAAAAAAAAAAAAAANM7lAEAAAAA5sDkmklFRMtc91NnTZgkQsONDXY%3DioTFQAqX7Ka2i2yy4iZZ6xmBvI8bXjIml4Q0LJXpfcwKPOqBm0"
    );
    try {
      // Get list of users with connected Twitter accounts from Firebase Auth
      const tweeps: Map<string, string> = await getAllTweeps(
        undefined,
        new Map<string, string>()
      );
      // Filter out users who have already been rewarded for their tweet
      const unrewardedTweeps = MapUtils.filter(tweeps, async (userId, _) => {
        const userProfileCollection = db
          .collection("UserProfile")
          .withConverter(userProfileConverter);
        const userSnap = await userProfileCollection.doc(userId).get();
        const profileData = userSnap.data();
        if (!profileData) return false;
        // User has not already received second tier achievement
        return profileData.AchievementProgresses?.TwitterVeriFied != 2;
      });
    } catch (error) {
      if (error instanceof Error) {
        console.log("Error checking tweets: ", error);
        throw error;
      }
    }
  });

////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Private Functions ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Recursively fetches all the users with a linked Twitter account.
const getAllTweeps = async (
  nextPageToken: string | undefined,
  linkedUsers: Map<string, string>
) => {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    listUsersResult.users.forEach((userRecord) => {
      if (userRecord.providerData.length > 0) {
        userRecord.providerData.forEach((provider) => {
          if (provider.providerId === "twitter.com") {
            linkedUsers.set(userRecord.uid, provider.uid);
          }
        });
      }
    });
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

class MapUtils {
  static filter<TKey, TValue>(
    map: Map<TKey, TValue>,
    filterFunction: (key: TKey, value: TValue) => Promise<boolean>
  ): Map<TKey, TValue> {
    const filteredMap: Map<TKey, TValue> = new Map<TKey, TValue>();

    map.forEach(async (value, key) => {
      if (await filterFunction(key, value)) {
        filteredMap.set(key, value);
      }
    });

    return filteredMap;
  }
}
