import * as geohash from "ngeohash";
import { Firestore, GeoPoint, Timestamp } from "firebase-admin/firestore";
import { nDaysAgo, randomElementExcept, randomNearbyLatLng } from "./util";
import { LatLng } from "./types";
import { accessPointCollection } from "verifi-types";

type AccessPointValidationState = {
  submittedBy: string,
  submittedOn: Timestamp;
  validatedBy: Array<string>;
  lastValidated?: Timestamp;
}

const generateValidationState = (
  accessPointIndex: number,
  userProfileUids: Array<string>,
): AccessPointValidationState => {
  // 5 APs created by first user, the rest by randomly selected users.
  const submittedBy = accessPointIndex < 5 ?
    userProfileUids[0] :
    randomElementExcept(userProfileUids[0], userProfileUids);

  if (accessPointIndex % 3 == 0) {
    // Unverified
    return {
      submittedBy,
      submittedOn: Timestamp.now(),
      validatedBy: [],
      lastValidated: Timestamp.now(),
    }
  }
  else if (accessPointIndex % 3 == 1) {
    // Verified
    return {
      submittedBy,
      submittedOn: nDaysAgo(2),
      validatedBy: [randomElementExcept(submittedBy, userProfileUids)],
      lastValidated: nDaysAgo(1),
    }
  } else {
    // Expired
    return {
      submittedBy,
      submittedOn: nDaysAgo(40),
      validatedBy: [randomElementExcept(submittedBy, userProfileUids)],
      lastValidated: nDaysAgo(35),
    }
  }
}

export const createAccessPoints = async (
  db: Firestore,
  userProfileUids: Array<string>,
  accessPointCount: number,
  centeredAround: LatLng,
  accessPointSpreadInM: number,
): Promise<void> => {
  const collection = accessPointCollection(db);

  const batch = db.batch();
  for (let i = 0; i < accessPointCount; i++) {
    const latLng = randomNearbyLatLng(centeredAround, accessPointSpreadInM);
    const validationState = generateValidationState(i, userProfileUids);

    batch.create(
      collection.doc(),
      {
        Name: `Test Place ${i}`,
        Address: `Test Address ${i}`,
        Location: {
          geohash: geohash.encode(latLng.lat, latLng.lon),
          geopoint: new GeoPoint(latLng.lat, latLng.lon),
        },
        SSID: "Test SSID",
        Password: "random.password",
        SubmittedBy: validationState.submittedBy,
        SubmittedOn: validationState.submittedOn,
        ValidatedBy: validationState.validatedBy,
        LastValidated: validationState.lastValidated,
      }
    );
  }

  await batch.commit();
}
