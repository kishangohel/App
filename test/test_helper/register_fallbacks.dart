import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';

/// Mocktail needs us to declare a fallback value for types which we want to
/// use with any(). The actual values are just used internally with Mocktail,
/// they are not returned in tests.
void registerFallbacks() {
  registerFallbackValue(LatLng(1.0, 1.1));
  registerFallbackValue(MapFilter.none);
  registerFallbackValue(CenterZoom(center: LatLng(0.1, 0.1), zoom: 0.1));
}
