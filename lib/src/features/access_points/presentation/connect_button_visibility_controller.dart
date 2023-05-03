import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/data/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

part '_generated/connect_button_visibility_controller.g.dart';

@Riverpod()
class ConnectButtonVisibilityController
    extends _$ConnectButtonVisibilityController {
  @override
  Future<bool> build(AccessPoint accessPoint) async {
    final isNotContributor =
        ref.read(currentUserProvider).value?.id != accessPoint.submittedBy;
    return await isWithinProximity(accessPoint) && isNotContributor;
  }

  Future<bool> isWithinProximity(AccessPoint accessPoint) async {
    final currentLocation =
        await ref.read(locationRepositoryProvider).currentLocation;
    if (currentLocation == null) return false;

    final apGeoPoint = GeoFirePoint(
      accessPoint.location.latitude,
      accessPoint.location.longitude,
    );
    // Calculate distance via haversineDistance in km
    final distanceFromAP = apGeoPoint.haversineDistance(
      lat: currentLocation.latitude,
      lng: currentLocation.longitude,
    );
    // Return true if within 100m, false otherwise
    return distanceFromAP < 0.1;
  }
}
