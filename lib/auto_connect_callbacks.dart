import 'dart:io';

import 'package:auto_connect/auto_connect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';
import 'package:verifi/blocs/map/map_utils.dart';
import 'package:verifi/blocs/profile/profile_cubit.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';

Future<bool> updateNearbyAccessPoints(double lat, double lng) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize storage for hydrated cubits
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  // Initialize repositories and cubits
  final userProfileRepository = UserProfileRepository();
  final userLocationRepository = UserLocationRepository();
  final profile = ProfileCubit(userProfileRepository);
  // Assumes user id is cached via hydrated cubit
  final uid = profile.userId;
  // Don't continue if not logged in
  if (uid == '') {
    return false;
  }
  // Update user location
  if (uid != '') {
    userLocationRepository.updateUserLocation(uid, GeoPoint(lat, lng));
  }
  // Make sure we still have location permissions
  final permissionGranted = await Permission.location.isGranted;
  if (permissionGranted == false) {
    return false;
  }
  // Get geofences already registered on app
  final registeredGeofences = await AutoConnect.getGeofences();
  debugPrint("Registerd geofences: ${registeredGeofences.toString()}");
  // Get nearby access points from Firestore DB
  List<AccessPoint> newAccessPoints =
      await MapUtils.getNearbyAccessPointsWithPlaceDetails(
    WifiRepository(),
    PlaceRepository(),
    GeoFirePoint(lat, lng),
    5.0, // get everything within 5km
  );
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
      newAccessPoints.map((ap) => ap.placeDetails?.placeId).toList();
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
    if (ap.wifiDetails == null ||
        ap.placeDetails == null ||
        ap.placeDetails!.placeId == null) {
      debugPrint("Access point wifi or place details is null");
      return false;
    }
    // If geofence is already registered, skip
    if (registeredGeofences.contains(ap.placeDetails!.placeId!)) {
      continue;
    }
    debugPrint("Adding access point ${ap.id}");
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
  debugPrint("Finished updating geofences!");
  return true;
}
