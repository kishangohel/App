import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/map/domain/access_point_connection_state.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_connection_controller.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

class AccessPointInfoSheet extends ConsumerWidget {
  final AccessPoint accessPoint;

  const AccessPointInfoSheet(this.accessPoint);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AccessPointConnectionState>>(
        accessPointConnectionControllerProvider, (previous, next) {
      if (previous?.value?.connectionResult == null &&
          next.valueOrNull?.connectionResult != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          _connectSnackBar(context, next.value!.connectionResult!),
        );
        context.pop();
      }
    });

    final connectionState = ref.watch(accessPointConnectionControllerProvider);
    final contributorProfile =
        ref.watch(userProfileFamily(accessPoint.submittedBy));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _nameAndAddress(context),
          _networkName(),
          _networkPassword(),
          _verifiedStatus(),
          _contributor(contributorProfile),
          if (_isWithinProximityOfAP(ref, accessPoint.location))
            _connectButton(
              context,
              ref,
              connectionState: connectionState,
            ),
        ],
      ),
    );
  }

  Widget _nameAndAddress(BuildContext context) {
    return ListTile(
      title: Text(
        accessPoint.place?.title ?? "Unknown place",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      subtitle: Text(
        accessPoint.place?.address ?? "Unknown address",
      ),
    );
  }

  Widget _networkName() {
    return _detailsRow(
      leading: const Icon(Icons.wifi),
      label: Text(accessPoint.ssid),
    );
  }

  Widget _networkPassword() {
    return _detailsRow(
      leading: accessPoint.password == null || accessPoint.password!.isEmpty
          ? const Icon(Icons.lock_open)
          : const Icon(Icons.lock_outlined),
      label: Text(
        (accessPoint.password == null || accessPoint.password == "")
            ? "Open"
            : "\u2022" * accessPoint.password!.length,
      ),
    );
  }

  Widget _verifiedStatus() {
    return _detailsRow(
      leading: accessPoint.isVerified
          ? const Icon(Icons.check)
          : const Icon(Icons.question_mark),
      label: Text(accessPoint.verifiedStatusLabel),
    );
  }

  Widget _contributor(AsyncValue<UserProfile?> profile) {
    const padding = EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0);

    if (profile.isLoading) {
      return _detailsRow(
        leading: const VShimmerWidget(
          width: 24,
          height: 24,
          margin: EdgeInsets.zero,
        ),
        label: const VShimmerWidget(
          width: 120,
          height: 24,
          margin: EdgeInsets.zero,
        ),
        padding: padding,
      );
    }
    final displayName = profile.valueOrNull?.displayName ?? "Unknown";

    return _detailsRow(
      leading: randomAvatar(
        displayName,
        trBackground: true,
        width: 24,
        height: 24,
      ),
      label: Text(displayName),
      padding: padding,
    );
  }

  Widget _detailsRow({
    required Widget leading,
    required Widget label,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
  }) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 8.0),
            child: leading,
          ),
          label,
        ],
      ),
    );
  }

  Widget _connectButton(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<AccessPointConnectionState> connectionState,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
        onPressed: connectionState.valueOrNull?.connecting != false
            ? null
            : () {
                ref
                    .read(accessPointConnectionControllerProvider.notifier)
                    .connect();
              },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (connectionState.valueOrNull?.connecting == true)
            Container(
              padding: const EdgeInsets.only(right: 8),
              width: 29,
              height: 22,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
          Text(accessPoint.isVerified ? "Connect" : "Validate"),
          if (connectionState.valueOrNull?.connecting == true)
            const SizedBox(width: 29),
        ]),
      ),
    );
  }

  SnackBar _connectSnackBar(BuildContext context, String result) {
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

  bool _isWithinProximityOfAP(WidgetRef ref, LatLng apPosition) {
    // Get current location
    final currentLocation =
        ref.read(locationRepositoryProvider).currentLocation;
    if (currentLocation == null) return false;

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
