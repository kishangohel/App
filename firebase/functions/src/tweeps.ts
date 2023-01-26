import * as admin from "firebase-admin";
// Recursively fetches all Firebase Auth users with a linked Twitter account.
export const getAllTweeps = async (
  nextPageToken: string | undefined,
  linkedUsers: Map<string, string>
) => {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    for (const userRecord of listUsersResult.users) {
      if (userRecord.providerData.length > 0) {
        for (const provider of userRecord.providerData) {
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
export const getTweepByTwitterUID = async (
  uid: string,
  nextPageToken: string | undefined
): Promise<string | undefined> => {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    for (const userRecord of listUsersResult.users) {
      if (userRecord.providerData.length > 0) {
        for (const provider of userRecord.providerData) {
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
};

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
