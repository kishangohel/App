/* eslint-disable spaced-comment */
import * as admin from "firebase-admin";
import { createAccessPoints } from "./create-access-points";
import { createAchievements } from "./create-achievements";
import { createUserProfiles } from "./create-user-profiles";
import { createUsers } from "./create-users";
import { LatLng } from "./types";

const userCount = 10;
const userSpreadInM = 1000;
const accessPointCount = 20;
const accessPointSpreadInM = 200;

const bootstrap = async (centeredAround: LatLng): Promise<void> => {
  const auth = admin.initializeApp({ projectId: "verifi-dev" });
  const db = admin.firestore();

  await createAchievements(db);
  const users = await createUsers(auth, userCount);
  await createUserProfiles(db, users, centeredAround, userSpreadInM);
  const profileUids = users.map((e) => e.uid);
  await createAccessPoints(
    db,
    profileUids,
    accessPointCount,
    centeredAround,
    accessPointSpreadInM,
  );
}


//////////////////////////////////////////////////////////////////////////////
/// Entrypoint
///////////////////////////////////////////////////////////////////////////////

/// Read/set firebase environment variables
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "127.0.0.1:9099";
process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";

// Read the center point around which users and access points will be spread.
if (process.argv.length != 4) {
  console.log("Invalid arguments")
  console.log(
    "Please pass the latitude and longitude close to which the " +
    "access_points points and users should be placed, seperated by " +
    "spaces (e.g. 12.3456 -7.8901)"
  );

  process.exit(1);
}
const centeredAround: LatLng = {
  lat: parseFloat(process.argv[2]),
  lon: parseFloat(process.argv[3]),
};

(async () => await bootstrap(centeredAround))();
