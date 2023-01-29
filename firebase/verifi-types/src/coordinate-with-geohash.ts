import { GeoPoint } from "firebase-admin/firestore";

export type CoordinateWithGeohash = {
  geohash: string;
  geopoint: GeoPoint;
}

