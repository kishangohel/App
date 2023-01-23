"""
Does the following:

1. Iterate over Firestore collection AccessPoint and only get access point
where the Name field is Starbucks.

2. For each access point, get the geohash and the geopoint from the
Location field.

3. Query Radar Autocomplete API at the geopoint for a nearby Starbucks.
If none exists, print that none exists and skip.
Otherwise, if one exists, write the Radar data into a new Feature field and
delete the PlaceId field.
"""

import concurrent.futures
import json
import os
import requests
import sys

from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from fuzzywuzzy import fuzz, process
import geohash
import geopy.distance
from google.cloud.firestore import GeoPoint
import googlemaps
from radar import RadarClient


i = 0


def upload_new_ap(k, v):
    # Progress tracker
    global i
    i += 1
    if i % 100 == 0:
        print(i)
    # Dict for output data of specific AP
    output_data_k = {}

    input_geopoint = v["Location"]["geopoint"]
    input_lat = input_geopoint["__lat__"]
    input_lng = input_geopoint["__lon__"]

    radar_results = radarClient.search.autocomplete(
        query="Starbucks",
        near=[input_lat, input_lng],
    )
    # Get closest place
    new_place = radar_results[0]

    distance = geopy.distance.distance(
        (input_lat, input_lng),
        (new_place.latitude, new_place.longitude),  # type: ignore
    ).m

    if distance > 100:
        return
    if new_place.placeLabel != "Starbucks":  # type: ignore
        return

    # Create Location field
    output_data_k["Location"] = {
        "geohash": geohash.encode(
            new_place.latitude,  # type: ignore
            new_place.longitude,  # type: ignore
            precision=9,
        ),
        "geopoint": GeoPoint(
            new_place.latitude,  # type: ignore
            new_place.longitude,  # type: ignore
        ),
    }
    # Copy over the rest of the data
    output_data_k["Address"] = new_place.formattedAddress  # type: ignore
    output_data_k["Name"] = "Starbucks"
    output_data_k["SSID"] = v["SSID"]
    output_data_k["Password"] = v["Password"]
    output_data_k["LastValidated"] = datetime.now()
    output_data_k["SubmittedBy"] = v["SubmittedBy"]
    output_data[k] = output_data_k

    ap_collection.document(k).create(output_data_k)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(
            "Usage: python3 get_starbucks_locations.py <PLACES_KEY> "
            "<RADAR_SECRET> <SERVICE_KEY_JSON_FILE>"
        )
        sys.exit(0)

    # Initialize Google Maps and Radar clients
    gmaps = googlemaps.Client(key=sys.argv[1])
    radarClient = RadarClient(secret_key=sys.argv[2])

    """
    NOTE: Uncomment below if using emulator
    """
    # authEmulator = os.getenv("FIREBASE_AUTH_EMULATOR_HOST")
    # if authEmulator is None:
    #     print("FIREBASE_AUTH_EMULATOR_HOST environment variable is not set")
    #     print("It should most likely be set to 'localhost:9099'")
    #     sys.exit(1)
    #
    # firestoreEmulator = os.getenv("FIRESTORE_EMULATOR_HOST")
    # if firestoreEmulator is None:
    #     print("FIRESTORE_EMULATOR_HOST environment varaible is not set")
    #     print("It should most likely be set to 'localhost:8080'")
    #     sys.exit(1)

    # Initialize Firestore client

    cred = credentials.Certificate(
        cert=sys.argv[3],
    )
    firebase_admin.initialize_app(credential=cred)
    db = firestore.client()

    ap_collection = db.collection("AccessPoint")

    # Initialize dictionaries to store input and output data
    input_data = {}
    output_data = {}

    # Read data from json representing existing Firestore data
    with open("../../Starbucks_prod_export.json", "r") as input_file:
        input_data = json.load(input_file)
        input_data = input_data["data"]

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        for k, v in input_data.items():
            executor.submit(upload_new_ap, k, v)
