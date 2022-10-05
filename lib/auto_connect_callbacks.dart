import 'package:auto_connect/auto_connect.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/wifi_utils.dart';
import 'package:verifi/models/wifi.dart';
import 'package:verifi/repositories/wifi_repository.dart';

Future<bool> addNearbyAccessPoints(double lat, double lng) async {
  final permissionGranted = await Permission.location.isGranted;
  if (permissionGranted == false) {
    return false;
  }
  List<Wifi> wifis = await WifiUtils.getNearbyWifi(
    WifiRepository(),
    GeoFirePoint(lat, lng),
    3.0, // get everything within 3km
  );
  if (wifis.length > 100) {
    wifis = wifis.sublist(0, 100);
  }
  for (Wifi wifi in wifis) {
    assert(wifi.wifiDetails != null && wifi.placeDetails != null);
    AutoConnect.addAccessPoint(
      Geofence(
        id: wifi.placeDetails!.placeId!,
        lat: wifi.placeDetails!.geometry!.location!.lat!,
        lng: wifi.placeDetails!.geometry!.location!.lng!,
        radius: 100.0,
      ),
      AccessPoint(
        ssid: wifi.wifiDetails!.ssid,
        password: wifi.wifiDetails!.password ?? "",
      ),
      addNearbyAccessPoints,
    );
  }
  return true;
}
