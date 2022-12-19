import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const apContributionToVeriPoints = functions.firestore
  .document("AccessPoint/{apId}")
  .onCreate(async (apSnap, _) => {
    const apData = apSnap.data();
    const submittedBy = apData.SubmittedBy;

    const userSnap = await db.collection("UserProfile").doc(submittedBy).get();
    const profileData = userSnap.data();
    if (profileData) {
      let veriPoints = profileData.VeriPoints;
      if (veriPoints) {
        veriPoints += 5;
      } else {
        veriPoints = 5;
      }
      return db
        .collection("UserProfile")
        .doc(submittedBy)
        .update({ VeriPoints: veriPoints });
    }
    return Promise.reject("User not found");
  });

export const apVerificationToVeriPoints = functions.firestore
  .document("AccessPoint/{apId}")
  .onWrite(async (change, context) => {
    const uid = context.auth?.uid;
    if (uid == undefined) {
      return Promise.reject("Unauthenticated");
    }
    if (change.before.get("LastValidated") != change.after.get("LastValidated")) {
      const userSnap = await db.collection("UserProfile").doc(uid).get();
      const profileData = userSnap.data();
      if (profileData) {
        let veriPoints = profileData.VeriPoints;
        if (veriPoints) {
          veriPoints += 1;
        } else {
          veriPoints = 1;
        }
        return db
          .collection("UserProfile")
          .doc(uid)
          .update({ VeriPoints: veriPoints });
      }
      return Promise.reject("User not found");
    }
    return Promise.resolve();
  })
