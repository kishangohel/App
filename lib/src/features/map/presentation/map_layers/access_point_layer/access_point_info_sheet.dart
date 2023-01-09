import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

class AccessPointInfoSheet extends StatefulWidget {
  final AccessPoint accessPoint;

  const AccessPointInfoSheet(this.accessPoint);

  @override
  State<StatefulWidget> createState() => _AccessPointInfoSheetState();
}

class _AccessPointInfoSheetState extends State<AccessPointInfoSheet> {
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
                  widget.accessPoint.place?.title ?? "Unknown place",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  widget.accessPoint.place?.address ?? "Unknown address",
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
                      widget.accessPoint.ssid,
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
                        (widget.accessPoint.password == null ||
                                widget.accessPoint.password!.isEmpty)
                            ? Icons.lock_open
                            : Icons.lock_outlined,
                      ),
                    ),
                    Text(
                      (widget.accessPoint.password == null ||
                              widget.accessPoint.password == "")
                          ? "Open"
                          : "\u2022" * widget.accessPoint.password!.length,
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
                      child: widget.accessPoint.isVerified
                          ? const Icon(Icons.check)
                          : const Icon(Icons.question_mark),
                    ),
                    Text(widget.accessPoint.verifiedStatusLabel),
                  ],
                ),
              ),
            ],
          ),
          // Connect button
          Visibility(
            visible: isWithinProximityOfAP(
              context,
              widget.accessPoint.location,
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
                          // TODO: Uncomment when plugin is published
                          // final result = await AutoConnect.verifyAccessPoint(
                          //   wifi: WiFi(
                          //     ssid: widget.accessPoint.ssid,
                          //     password: widget.accessPoint.password ?? "",
                          //   ),
                          // );
                          setState(() => _connecting = false);
                          // TODO: Uncomment when plugin is published
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   _connectSnackbar(result),
                          // );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.accessPoint.isVerified
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

  // TODO: Uncomment when plugin is published
  // SnackBar _connectSnackbar(String result) {
  //   return SnackBar(
  //     backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
  //     content: Text(
  //       result,
  //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //             color: Theme.of(context).colorScheme.onSurfaceVariant,
  //           ),
  //       textAlign: TextAlign.center,
  //     ),
  //   );
  // }

  bool isWithinProximityOfAP(BuildContext context, LatLng apPosition) {
    // Get current location
    final currentLocation = ProviderScope.containerOf(context)
        .read(locationRepositoryProvider)
        .currentLocation;
    if (currentLocation == null) {
      return false;
    }
    // Convert current position to LatLng
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
}
