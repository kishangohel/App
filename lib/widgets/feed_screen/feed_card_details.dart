import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FeedCardDetails extends StatelessWidget {
  final String name;
  final String ssid;
  final num? distance;
  final LatLng myLocation;
  final LatLng wifiLocation;

  const FeedCardDetails({
    required this.name,
    required this.ssid,
    this.distance,
    required this.myLocation,
    required this.wifiLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.network_wifi,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    "  $ssid",
                                    style: GoogleFonts.rubik(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              _distanceText(distance, myLocation, wifiLocation),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _distanceText(
  num? distance,
  LatLng myLocation,
  LatLng wifiLocation,
) {
  double actualDistance;
  if (distance != null) {
    actualDistance = distance.toDouble();
  } else {
    final myGeo = GeoFirePoint(myLocation.latitude, myLocation.longitude);
    actualDistance = myGeo.haversineDistance(
      lat: wifiLocation.latitude,
      lng: wifiLocation.longitude,
    );
  }
  actualDistance = double.parse(actualDistance.toStringAsFixed(1));
  return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Text(
      (actualDistance < 0.1) ? "Nearby" : "$actualDistance mi",
      style: GoogleFonts.rubik(
        color: Colors.grey,
        fontSize: 12,
      ),
    ),
  );
}
