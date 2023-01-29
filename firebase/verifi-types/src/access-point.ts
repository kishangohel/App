import { CollectionReference, DocumentData, Firestore, QueryDocumentSnapshot, Timestamp } from "firebase-admin/firestore";
import { CoordinateWithGeohash } from "./coordinate-with-geohash";

export type AccessPoint = {
  Name: string;
  Address: string;
  Location: CoordinateWithGeohash;
  SSID: string;
  Password?: string;
  SubmittedBy: string;
  SubmittedOn: Timestamp;
  ValidatedBy: Array<string>;
  LastValidated?: Timestamp;
}

const converter = {
  toFirestore(accessPoint: AccessPoint): DocumentData {
    const result: DocumentData = { ...accessPoint };

    if (accessPoint.Password === undefined) delete result.Password;
    if (accessPoint.LastValidated === undefined) delete result.LastValidated;
    if (accessPoint.ValidatedBy.length == 0) delete result.ValidatedBy;

    return result;
  },
  fromFirestore(
    snapshot: QueryDocumentSnapshot,
  ): AccessPoint {
    const data = snapshot.data()!;
    return {
      Name: data.Name,
      Address: data.Address,
      Location: data.Location,
      SSID: data.SSID,
      Password: data.Password,
      SubmittedBy: data.SubmittedBy,
      SubmittedOn: data.SubmittedOn,
      LastValidated: data.LastValidated,
      ValidatedBy: data.ValidatedBy ?? [],
    };
  }
};

export const accessPointCollection = (
  db: Firestore
): CollectionReference<AccessPoint> =>
  db.collection("AccessPoint").withConverter(converter);

