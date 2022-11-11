#!/usr/bin/env python3
import datetime
import os
import random
import sys

from firebase_admin import auth, credentials, firestore
import firebase_admin
from firebase_admin.auth import UserRecord
from google.cloud.firestore import GeoPoint
from google.api_core.retry import Retry

MY_LOCATION = [-1.0, -1.0]
PLACE_ID = ""

BASE32_CODES = "0123456789bcdefghjkmnpqrstuvwxyz"


def create_geohash(lat, lng):
    """Creates a 9 char geohash from coordinates."""
    chars = []
    bits = 0
    bitsTotal = 0
    hashValue = 0
    maxLat = 90.0
    minLat = -90.0
    maxLon = 180.0
    minLon = -180.0
    mid = 0

    while len(chars) < 9:
        if bitsTotal % 2 == 0:
            mid = (maxLon + minLon) / 2.0
            if lng > mid:
                hashValue = (hashValue << 1) + 1
                minLon = mid
            else:
                hashValue = (hashValue << 1) + 0
                maxLon = mid
        else:
            mid = (maxLat + minLat) / 2
            if lat > mid:
                hashValue = (hashValue << 1) + 1
                minLat = mid
            else:
                hashValue = (hashValue << 1) + 0
                maxLat = mid
        bits += 1
        bitsTotal += 1
        if bits == 5:
            code = BASE32_CODES[hashValue]
            chars.append(code)
            bits = 0
            hashValue = 0
    return "".join(chars)


def get_random_nearby_coordinate():
    """Gets a random coordinate within approx. 100 meters of MY_LOCATION."""
    lat_dist = random.randint(1, 10) / 10000.0
    lng_dist = random.randint(1, 10) / 10000.0
    lat_direction = random.randint(0, 1)
    lng_direction = random.randint(0, 1)

    result = [MY_LOCATION[0], MY_LOCATION[1]]
    if lat_direction == 0:
        result[0] += lat_dist
    else:
        result[0] -= lat_dist
    if lng_direction == 0:
        result[1] += lng_dist
    else:
        result[1] -= lng_dist
    result[0] = round(result[0], 4)
    result[1] = round(result[1], 4)
    return result


def main():
    cred = credentials.Certificate("mock_service_account.json")
    firebase_admin.initialize_app(credential=cred)
    db = firestore.client()

    # Create user
    try:
        user: UserRecord = auth.create_user(phone_number="+1 6505553434")
    except:  # noqa: E722
        print(
            "Unable to create user. Are you sure Firebase emulator is running?"
        )
        sys.exit(1)

    # Create access points
    access_points = []
    for i in range(5):
        coordinate = get_random_nearby_coordinate()
        access_points.append(
            {
                "lat": coordinate[0],
                "lng": coordinate[1],
                "geohash": create_geohash(coordinate[0], coordinate[1]),
                "ssid": "Another Pixel",
                "password": "random.password",
                "name": f"Test Location {i}",
            }
        )

    # Add access points
    for ap in access_points:
        try:
            time = datetime.datetime.now(tz=datetime.timezone.utc)
            db.collection("AccessPoint").add(
                {
                    "Location": {
                        "geohash": ap["geohash"],
                        "geopoint": GeoPoint(ap["lat"], ap["lng"]),
                    },
                    "PlaceId": PLACE_ID,
                    "Name": ap["name"],
                    "SSID": ap["ssid"],
                    "Password": ap["password"],
                    "LastValidated": time,
                    "SubmittedBy": user.uid,
                    "SubmittedOn": time,
                    "ValidatedBy": [],
                },
                retry=Retry(deadline=5.0),
            )
        except:  # noqa: E722
            print(
                "Failed to connect to Firestore. Are you sure the emulator is "
                "running?"
            )
            sys.exit(1)

    # Create profile
    db.collection("UserProfile").document(user.uid).set(
        {
            "CreatedOn": datetime.datetime.now(tz=datetime.timezone.utc),
            "DisplayName": "test-user",
            "EthAddress": "0x0123456789abcdef0123456789abcdef01234567",
            "PFP": None,
            "VeriPoints": 50,
        }
    )


if __name__ == "__main__":
    authEmulator = os.getenv("FIREBASE_AUTH_EMULATOR_HOST")
    if authEmulator is None:
        print("FIREBASE_AUTH_EMULATOR_HOST environment variable is not set")
        print("It should most likely be set to 'localhost:9099'")
        sys.exit(1)

    firestoreEmulator = os.getenv("FIRESTORE_EMULATOR_HOST")
    if firestoreEmulator is None:
        print("FIRESTORE_EMULATOR_HOST environment varaible is not set")
        print("It should most likely be set to 'localhost:8080'")
        sys.exit(1)

    if len(sys.argv) != 4:
        print("Invalid arguments")
        print(
            "Please pass the GPS coordinates and place ID, all seperated by "
            "spaces (e.g. 12.3456 -7.8901 ChIJcVTyZY_S-YgMBGplVHWkw0c) of the "
            "location to create fake WiFi access points and users."
        )
        sys.exit(1)

    MY_LOCATION = [float(sys.argv[1]), float(sys.argv[2])]
    PLACE_ID = sys.argv[3]
    main()
