import 'package:auto_connect/auto_connect.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/map/map_utils.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/wifi_repository.dart';

Future<bool> addNearbyAccessPoints(double lat, double lng) async {
  final permissionGranted = await Permission.location.isGranted;
  if (permissionGranted == false) {
    return false;
  }
  List<AccessPoint> accessPoints = await MapUtils.getNearbyAccessPoints(
    WifiRepository(),
    GeoFirePoint(lat, lng),
    3.0, // get everything within 3km
  );
  if (accessPoints.length > 100) {
    accessPoints = accessPoints.sublist(0, 100);
  }
  for (AccessPoint ap in accessPoints) {
    assert(ap.wifiDetails != null);
    AutoConnect.addAccessPointWithGeofence(
      id: ap.placeDetails!.placeId!,
      geofence: Geofence(
        lat: ap.wifiDetails!.location.latitude,
        lng: ap.wifiDetails!.location.longitude,
      ),
      wifi: WiFi(
        ssid: ap.wifiDetails!.ssid,
        password: ap.wifiDetails!.password ?? "",
      ),
    );
  }
  return true;
}
