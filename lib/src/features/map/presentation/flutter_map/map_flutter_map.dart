import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/location_permission_dialog.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/map_initial_location_controller.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/map_location_permissions_controller.dart';
import 'package:verifi/src/features/map/presentation/map_layers/attribution_layer.dart';

import '../map_layers/access_point_layer/access_point_cluster_layer.dart';
import '../map_layers/mapbox_layer/mapbox_tile_layer.dart';
import '../map_layers/user_layer/user_cluster_layer.dart';

class MapFlutterMap extends ConsumerStatefulWidget {
  static const maxZoom = 19.0;
  static const initialLocationMove = "initialLocationMove";

  @override
  ConsumerState<MapFlutterMap> createState() => _MapFlutterMapState();
}

class _MapFlutterMapState extends ConsumerState<MapFlutterMap>
    with TickerProviderStateMixin<MapFlutterMap> {
  static const _initialZoom = 16.0;

  @override
  Widget build(BuildContext context) {
    _listenToLocationPermissions();
    _listenToLocation();

    return FlutterMap(
      mapController: ref.watch(mapControllerProvider),
      options: MapOptions(
        maxZoom: MapFlutterMap.maxZoom,
        interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
        center: ref.watch(mapInitialLocationControllerProvider),
        zoom: _initialZoom,
        keepAlive: true,
        onMapReady: () {
          ref.read(mapServiceProvider).associateMap(this);
          ref.read(mapServiceProvider).updateMap();
        },
      ),
      children: ref.watch(mapFilterControllerProvider).when<List<Widget>>(
            data: (filter) {
              final layers = <Widget>[
                MapboxTileLayer(),
                AttributionLayer(),
              ];
              if (filter.showAccessPoints) {
                layers.add(AccessPointClusterLayer());
              }
              if (filter.showProfiles) {
                layers.add(UserClusterLayer());
              }
              return layers;
            },
            loading: () => [
              MapboxTileLayer(),
              AttributionLayer(),
            ],
            error: (error, stacktrace) {
              debugPrint(error.toString());
              debugPrintStack(stackTrace: stacktrace);
              return [
                MapboxTileLayer(),
                AttributionLayer(),
              ];
            },
          ),
    );
  }

  void _listenToLocationPermissions() {
    // Handle location permission prompt for first use
    ref.listen<AsyncValue<LocationPermission>>(
      mapLocationPermissionsControllerProvider,
      (previousState, currentState) {
        // Request permission if initial state is denied
        if (previousState?.value == null &&
            currentState.value == LocationPermission.denied) {
          LocationPermissionDialog.show(context);
        } else if (previousState?.value?.isAllowed != true &&
            currentState.value?.isAllowed == true) {
          // Start location stream if location permission granted
          ref.read(locationRepositoryProvider).initLocationStream();
        }
      },
    );
  }

  void _listenToLocation() {
    // When first location value is emitted, move to current location.
    ref.listen<AsyncValue<LatLng?>>(
      locationStreamProvider,
      (previousState, currentState) {
        if (previousState?.value == null && currentState.value != null) {
          ref
              .read(mapInitialLocationControllerProvider.notifier)
              .update(currentState.value!);
          ref.read(mapControllerProvider).move(
                currentState.value!,
                18,
                id: MapFlutterMap.initialLocationMove,
              );
        }
      },
    );
  }
}
