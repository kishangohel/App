import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/models/models.dart';

void main() {
  group('Place', () {
    test('json serialization', () {
      final place = Place(
        id: 'testId',
        title: 'testTitle',
        address: 'testTitle, test Address',
        location: LatLng(1.0, 2.0),
      );
      final placeJson = place.toJson();
      expect(Place.fromJson(placeJson), equals(place));
    });
  });
}
