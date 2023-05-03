import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/map/application/map_service.dart';

import 'access_point_marker.dart';

part '_generated/access_point_layer_controller.g.dart';

@Riverpod(keepAlive: true)
class AccessPointLayerController extends _$AccessPointLayerController {
  @override
  FutureOr<List<AccessPointMarker>> build() async => [];

  MapService get mapService => ref.read(mapServiceProvider);

  Future<void> updateAccessPoints() async {
    state = await AsyncValue.guard(() async {
      final accessPoints = await mapService.getNearbyAccessPoints();
      // Sort AccessPoints stably otherwise clusters may move around slightly.
      accessPoints.sort((ap1, ap2) => ap1.id.compareTo(ap2.id));

      final accessPointMarkers =
          accessPoints.map(AccessPointMarker.fromAccessPoint).toList();
      return accessPointMarkers;
    });
  }
}
