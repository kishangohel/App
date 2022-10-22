import json
import random

# CHANGE THIS TO YOUR LOCATION
# Recommend at least 4 digits after the decimal (10 meter precision)
MY_LOCATION = [33.5049, -82.0529]

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


coordinates = []
for i in range(5):
    coordinate = get_random_nearby_coordinate()
    coordinates.append(
        {
            "lat": coordinate[0],
            "lng": coordinate[1],
            "geohash": create_geohash(coordinate[0], coordinate[1]),
            "ssid": f"test-network-{i}",
            "name": f"Test Location {i}",
        }
    )
o = json.dumps({"access_points": coordinates}, indent=2)

with open("test_data.json", "w") as outfile:
    outfile.write(o)
