import * as geohash from "ngeohash";
import { Firestore, GeoPoint, Timestamp } from "firebase-admin/firestore";
import { UserRecord } from "firebase-admin/lib/auth/user-record";
import { userProfileCollection } from "verifi-types";
import { randomNearbyLatLng } from "./util";
import { LatLng } from "./types";


export const createUserProfiles = async (
  db: Firestore,
  users: Array<UserRecord>,
  centeredAround: LatLng,
  userSpreadInM: number,
): Promise<void> => {
  const collection = userProfileCollection(db);

  const batch = db.batch();
  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const latLng = randomNearbyLatLng(centeredAround, userSpreadInM);

    batch.set(
      collection.doc(user.uid),
      {
        DisplayName: user.displayName!,
        CreatedOn: Timestamp.now(),
        VeriPoints: 0,
        LastLocation: {
          geohash: geohash.encode(latLng.lat, latLng.lon),
          geopoint: new GeoPoint(latLng.lat, latLng.lon),
        },
        Statistics: {},
        AchievementProgresses: {},
        LastLocationUpdate: Timestamp.now(),
      }
    );
  }

  await batch.commit();
}
