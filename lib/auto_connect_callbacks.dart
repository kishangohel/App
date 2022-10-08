import 'package:auto_connect/auto_connect.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/map_utils.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/wifi_repository.dart';

Future<bool> addNearbyAccessPoints(double lat, double lng) async {
  final permissionGranted = await Permission.location.isGranted;
  if (permissionGranted == false) {
    return false;
  }
  List<AccessPoint> accessPoints = await MapUtils.getNearbyWifi(
    WifiRepository(),
    GeoFirePoint(lat, lng),
    3.0, // get everything within 3km
  );
  if (accessPoints.length > 100) {
    accessPoints = accessPoints.sublist(0, 100);
  }
  for (AccessPoint ap in accessPoints) {
    assert(ap.wifiDetails != null);
    AutoConnect.addAccessPoint(
      Geofence(
        id: ap.placeDetails!.placeId!,
        latitude: ap.wifiDetails!.location.latitude,
        longitude: ap.wifiDetails!.location.longitude,
        radius: 100.0,
      ),
      WiFi(
        ssid: ap.wifiDetails!.ssid,
        password: ap.wifiDetails!.password ?? "",
      ),
      addNearbyAccessPoints,
    );
  }
  return true;
}
