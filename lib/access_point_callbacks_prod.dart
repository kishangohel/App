import 'dart:io';

import 'package:auto_connect/auto_connect.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/firebase_options_prod.dart';
import 'package:verifi/main_prod.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

/// Pulls down nearby access points from Firestore to register geofences.
///
Future<void> updateNearbyAccessPoints(double lat, double lng) async {
  debugPrint("Updating nearby access points");
  await initialize();
  final permissionGranted = await Permission.location.isGranted;
  if (permissionGranted == false) {
    return;
  }
  // Get geofences already registered on app
  final registeredGeofences = await AutoConnect.getGeofences();
  // Get nearby access points from Firestore DB
  List<AccessPoint> newAccessPoints = await MapUtils.getNearbyAccessPoints(
    accessPointRepo: AccessPointRepository(),
    location: GeoFirePoint(lat, lng),
    radiusInKm: 5.0,
  );
  // Don't auto connect to UnVeriFied APs
  newAccessPoints.removeWhere((ap) => ap.verifiedStatus == "UnVeriFied");
  // Get pinned access points
  List<String> pinnedAccessPoints = await AutoConnect.getPinnedGeofences();
  // Shrink down geofence list to max amount allowed, minus pinned geofences
  if (Platform.isAndroid) {
    if (newAccessPoints.length > 100) {
      newAccessPoints = newAccessPoints.sublist(
        0,
        100 - pinnedAccessPoints.length,
      );
    }
  } else if (Platform.isIOS) {
    if (newAccessPoints.length > 20) {
      newAccessPoints = newAccessPoints.sublist(
        0,
        20 - pinnedAccessPoints.length,
      );
    }
  }
  // Extract IDs from access points for filtering / searching
  List<String?> newAccessPointIds =
      newAccessPoints.map((ap) => ap.place?.id).toList();
  // Get registered geofences that aren't in new access points
  List<String> geofencesToDelete = registeredGeofences
      .where((id) => !newAccessPointIds.contains(id))
      .toList();
  // Delete geofences not in new access points and not pinned
  for (String deleteId in geofencesToDelete) {
    if (false == await AutoConnect.isAccessPointPinned(deleteId)) {
      debugPrint("Removing access point $deleteId");
      await AutoConnect.removeAccessPointWithGeofence(deleteId);
    }
  }
  // Register the new geofences
  for (AccessPoint ap in newAccessPoints) {
    if (ap.place == null) {
      debugPrint("Place details is null");
      return;
    }
    // If geofence is already registered, skip
    if (registeredGeofences.contains(ap.place!.id)) {
      continue;
    }
    AutoConnect.addAccessPointWithGeofence(
      id: ap.place!.id,
      geofence: Geofence(
        lat: ap.location.latitude,
        lng: ap.location.longitude,
      ),
      wifi: WiFi(
        ssid: ap.ssid,
        password: ap.password ?? "",
      ),
    );
  }
  return;
}

Future<void> notifyAccessPointConnectionResult(
  String accessPointId,
  String ssid,
  String result,
) async {
  debugPrint("Notifying user of access point connection result");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final user = FirebaseAuth.instance.currentUser;
  final accessPointRepo = AccessPointRepository();
  if (user != null) {
    debugPrint("$ssid validated by $user");
    await accessPointRepo.networkValidatedByUser(accessPointId, user.uid);
  } else {
    debugPrint("Unable to get user for validation event");
  }
  final notifications = FlutterLocalNotificationsPlugin();
  final isInitialized = await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  if (isInitialized == null || !isInitialized) {
    debugPrint("Notifications intialization failed");
  }
  await notifications.show(
    0,
    (result == 'Success') ? 'VeriFied' : 'VeriFication failed',
    (result == 'Success') ? "You're now connected to $ssid" : result,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'verifi-auto-connect-updates',
        'Auto Connect Updates',
        channelDescription: 'Notifies user that VeriFi automatically connected '
            'to a nearby access point',
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
  return;
}
