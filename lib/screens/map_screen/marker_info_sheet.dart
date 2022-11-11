import 'package:auto_connect/auto_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/blocs/map/map_utils.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

class MarkerInfoSheet extends StatefulWidget {
  final AccessPoint accessPoint;
  const MarkerInfoSheet(this.accessPoint);
  @override
  State<StatefulWidget> createState() => _MarkerInfoSheetState();
}

class _MarkerInfoSheetState extends State<MarkerInfoSheet> {
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Place name and address
              ListTile(
                title: Text(
                  widget.accessPoint.placeDetails?.name ?? "Unknown place",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  widget.accessPoint.placeDetails?.formattedAddress ??
                      "Unknown address",
                ),
              ),
              // Network name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.wifi),
                    ),
                    Text(
                      widget.accessPoint.wifiDetails?.ssid ?? "Unknown network",
                    ),
                  ],
                ),
              ),
              // Network password
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        (widget.accessPoint.wifiDetails?.password == null ||
                                widget.accessPoint.wifiDetails?.password == "")
                            ? Icons.lock_open
                            : Icons.lock_outlined,
                      ),
                    ),
                    Text(
                      (widget.accessPoint.wifiDetails?.password == null ||
                              widget.accessPoint.wifiDetails?.password == "")
                          ? "Open"
                          : "\u2022" *
                              widget.accessPoint.wifiDetails!.password!.length,
                    ),
                  ],
                ),
              ),
              // VeriFied status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: (widget.accessPoint.wifiDetails!.verifiedStatus ==
                              "VeriFied")
                          ? const Icon(Icons.check)
                          : const Icon(Icons.question_mark),
                    ),
                    Text(widget.accessPoint.wifiDetails!.verifiedStatus!),
                  ],
                ),
              ),
            ],
          ),
          // // Save button
          // Container(
          //   padding: const EdgeInsets.symmetric(
          //     vertical: 8.0,
          //     horizontal: 8.0,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Expanded(child: Container()),
          //       Expanded(
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //           child: ElevatedButton(
          //             onPressed: () async => _onSaveButtonPressed(),
          //             child: const Text(
          //               "Save",
          //             ),
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Container(),
          //       ),
          //     ],
          //   ),
          // ),
          // Connect button
          Visibility(
            visible: isWithinProximityOfAP(
              context,
              widget.accessPoint.wifiDetails!.location,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Container()),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_connecting) {
                            return;
                          }
                          setState(() => _connecting = true);
                          final result = await AutoConnect.verifyAccessPoint(
                            wifi: WiFi(
                              ssid: widget.accessPoint.wifiDetails!.ssid,
                              password:
                                  widget.accessPoint.wifiDetails!.password ??
                                      "",
                            ),
                          );
                          setState(() => _connecting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            _connectSnackbar(result),
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          (widget.accessPoint.wifiDetails!.verifiedStatus! ==
                                  "VeriFied")
                              ? "Connect"
                              : "Validate",
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: _connecting == true,
                          child: const CircularProgressIndicator(),
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

  SnackBar _connectSnackbar(String result) {
    return SnackBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      content: Text(
        result,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool isWithinProximityOfAP(BuildContext context, LatLng apPosition) {
    // Get current location
    final currentPosition = context.read<LocationCubit>().state;
    // If location is not enabled or not found, return false
    if (currentPosition == null) {
      return false;
    }
    // Convert current position to LatLng
    final currentLocation = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    // Convert AP location to GeoPoint so we can use haversineDistance func
    final apGeoPoint = GeoFirePoint(apPosition.latitude, apPosition.longitude);
    // Calculate distance via haversineDistance in km
    final distanceFromAP = apGeoPoint.haversineDistance(
      lat: currentLocation.latitude,
      lng: currentLocation.longitude,
    );
    // Return true if within 100m, false otherwise
    return distanceFromAP < 0.1;
  }

  Future<void> _onSaveButtonPressed() async {
    await AutoConnect.addAccessPointWithGeofence(
      id: widget.accessPoint.placeDetails!.placeId,
      geofence: Geofence(
        lat: widget.accessPoint.wifiDetails!.location.latitude,
        lng: widget.accessPoint.wifiDetails!.location.longitude,
      ),
      wifi: WiFi(
        ssid: widget.accessPoint.wifiDetails!.ssid,
        password: widget.accessPoint.wifiDetails?.password ?? "",
      ),
    );
    final isPinned = await AutoConnect.isAccessPointPinned(
      widget.accessPoint.placeDetails!.placeId,
    );
    if (isPinned) {
      ScaffoldMessenger.of(context).showSnackBar(
        _alreadySavedSnackbar(),
      );
    } else {
      await AutoConnect.addPinAccessPoint(
        widget.accessPoint.placeDetails!.placeId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        _saveSnackbar(),
      );
    }
    Navigator.of(context).pop();
    return;
  }

  SnackBar _saveSnackbar() {
    return SnackBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      content: Text(
        "Saved succeesfully",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  SnackBar _alreadySavedSnackbar() {
    return SnackBar(
      content: Text(
        "Already saved",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}
