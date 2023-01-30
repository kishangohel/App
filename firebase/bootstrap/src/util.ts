import { Timestamp } from "firebase-admin/firestore";
import { LatLng } from "./types";

// Get a random LatLng within approx. maxDistanceInM of MY_LOCATION.
export const randomNearbyLatLng = (latLng: LatLng, maxDistanceInM: number): LatLng => {
  // Calculate random lat/lon offsets.
  const latDist = (Math.random() * 10) / (1000000 / maxDistanceInM);
  const lonDist = (Math.random() * 10) / (1000000 / maxDistanceInM);

  // Shift by the calculated distances in a random direction
  const result = { ...latLng };
  result.lat += (Math.random() < 0.5 ? latDist : -latDist);
  result.lon += (Math.random() < 0.5 ? lonDist : -lonDist);

  // Round to 4 decimal places
  result.lat = Number(result.lat.toFixed(4));
  result.lon = Number(result.lon.toFixed(4));

  return result
}

// Get a random element of an array except for the excluded element.
export const randomElementExcept = <T>(
  excluded: T,
  elements: Array<T>,
): T => {
  const remainingElements = [...elements];
  while (remainingElements.length > 0) {
    const randomIndex = Math.floor(Math.random() * remainingElements.length);
    const element = remainingElements.splice(randomIndex, 1)[0];
    if (element !== excluded) return element;
  }

  throw Error("No permitted elements");
}

// Generate a Timestamp n days ago
export const nDaysAgo = (daysAgo: number): Timestamp =>
  Timestamp.fromMillis(Date.now() - daysAgo * 24 * 60 * 60 * 1000);

