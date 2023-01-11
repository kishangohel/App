import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/access_points/domain/place_model.dart';

void main() {
  group('Place', () {
    test('json serialization', () {
      final place = Place(
        id: 'testId',
        name: 'testName',
        address: 'testTitle, test Address',
        location: LatLng(1.0, 2.0),
      );
      final placeJson = place.toJson();
      expect(Place.fromJson(placeJson), equals(place));
    });
  });
}
