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

ACCESS_POINT_COUNT = 10
ACCESS_POINT_SPREAD_IN_M = 200
USER_COUNT = 10
USER_SPREAD_IN_M = 1000
MY_LOCATION = [-1.0, -1.0]

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


def get_random_nearby_coordinate(maxDistanceInM):
    """
    Gets a random coordinate within approx. maxDistanceInM of MY_LOCATION.
    """
    lat_dist = random.randint(1, 10) / (1000000.0 / maxDistanceInM)
    lng_dist = random.randint(1, 10) / (1000000.0 / maxDistanceInM)
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


def get_random_user_index_except(excluded_user_index):
    """Gets a random user, excluding the user at the specified index"""
    random_user_index = random.randint(0, USER_COUNT - 1)
    while random_user_index == excluded_user_index:
        random_user_index = random.randint(0, USER_COUNT - 1)

    return random_user_index


def main():
    cred = credentials.Certificate("mock_service_account.json")
    firebase_admin.initialize_app(credential=cred)
    db = firestore.client()

    phone_number_start = 6505553434
    users = []
    for i in range(USER_COUNT):
        user_phone_number = phone_number_start + i
        display_name_suffix = "" if i == 0 else f"_{i}"

        # Create user
        try:
            user: UserRecord = auth.create_user(
                phone_number=f"+1 {user_phone_number}",
                display_name=f"test_user{display_name_suffix}",
            )
            users.append(user)
        except Exception as e:
            print("Unable to create user. Is Firebase emulator running?")
            print(str(e))
            sys.exit(1)

    # Create access points
    access_points = []
    for i in range(ACCESS_POINT_COUNT):
        if i < 5:
            submitted_by_index = 0
        else:
            submitted_by_index = get_random_user_index_except(0)

        submitted_by = users[submitted_by_index].uid

        time = datetime.datetime.now(tz=datetime.timezone.utc)
        if i % 3 == 0:  # Unverified
            submitted_on = time
            last_validated = None
            validated_by = []
        elif i % 3 == 1:  # Verified
            submitted_on = time - datetime.timedelta(days=2)
            last_validated = time - datetime.timedelta(days=1)
            validated_by = [
                users[get_random_user_index_except(submitted_by_index)].uid,
            ]
        else:  # Expired
            submitted_on = time - datetime.timedelta(days=40)
            last_validated = time - datetime.timedelta(days=35)
            validated_by = [
                users[get_random_user_index_except(submitted_by_index)].uid,
            ]

        coordinate = get_random_nearby_coordinate(ACCESS_POINT_SPREAD_IN_M)
        access_points.append(
            {
                "lat": coordinate[0],
                "lng": coordinate[1],
                "geohash": create_geohash(coordinate[0], coordinate[1]),
                "ssid": "Test SSID",
                "password": "random.password",
                "name": f"Test Place {i}",
                "address": f"Test Address {i}",
                "submittedOn": submitted_on,
                "submittedBy": submitted_by,
                "validatedBy": validated_by,
                "lastValidated": last_validated,
            }
        )

    # Add access points
    for ap in access_points:
        try:
            db.collection("AccessPoint").add(
                {
                    "Location": {
                        "geohash": ap["geohash"],
                        "geopoint": GeoPoint(ap["lat"], ap["lng"]),
                    },
                    "Address": ap["address"],
                    "Name": ap["name"],
                    "SSID": ap["ssid"],
                    "Password": ap["password"],
                    "LastValidated": ap["lastValidated"],
                    "SubmittedBy": ap["submittedBy"],
                    "SubmittedOn": ap["submittedOn"],
                    "ValidatedBy": ap["validatedBy"],
                },
                retry=Retry(deadline=5.0),
            )
        except:  # noqa: E722
            print(
                "Failed to connect to Firestore. Are you sure the emulator is "
                "running?"
            )
            sys.exit(1)

    for i in range(USER_COUNT):
        # Create profile
        display_name_suffix = "" if i == 0 else f"_{i}"
        coordinate = get_random_nearby_coordinate(USER_SPREAD_IN_M)

        db.collection("UserProfile").document(users[i].uid).set(
            {
                "CreatedOn": datetime.datetime.now(tz=datetime.timezone.utc),
                "DisplayName": f"test_user{display_name_suffix}",
                "LastLocation": {
                    "geohash": create_geohash(coordinate[0], coordinate[1]),
                    "geopoint": GeoPoint(coordinate[0], coordinate[1]),
                },
                "LastLocationUpdate": datetime.datetime.now(
                    tz=datetime.timezone.utc
                ),
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

    if len(sys.argv) != 3:
        print("Invalid arguments")
        print(
            "Please pass the latitude and longitude close to which the "
            "access_points points and users should be placed, seperated by "
            "spaces (e.g. 12.3456 -7.8901)"
        )
        sys.exit(1)

    MY_LOCATION = [float(sys.argv[1]), float(sys.argv[2])]
    main()
