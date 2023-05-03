import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_generated/map_initial_location_controller.g.dart';

@Riverpod(keepAlive: true)
class MapInitialLocationController extends _$MapInitialLocationController {
  @override
  LatLng build() => LatLng(40.7794, -73.9632);

  void update(LatLng location) => state = location;
}
