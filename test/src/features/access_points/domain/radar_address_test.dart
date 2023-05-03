import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/access_points/domain/radar_address_model.dart';

void main() {
  group('RadarAddress', () {
    test('json serialization', () {
      final place = RadarAddress(
        name: 'testName',
        address: 'testTitle, test Address',
        location: LatLng(1.0, 2.0),
      );
      final placeJson = place.toJson();
      expect(RadarAddress.fromJson(placeJson), equals(place));
    });
  });
}
