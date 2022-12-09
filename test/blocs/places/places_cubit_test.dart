import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/blocs/places/places_cubit.dart';
import 'package:verifi/entities/feature_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/place_repository.dart';

class MockPlaceRepository extends Mock implements PlaceRepository {}

class MockFeatureEntity extends Mock implements FeatureEntity {}

class MockPosition extends Mock implements Position {}

class MockLatLng extends Mock implements LatLng {}

void main() {
  group('PlacesCubit', () {
    late PlaceRepository placeRepository;
    late PlacesCubit placesCubit;
    late FeatureEntity feature;
    late Position position;

    setUp(() {
      registerFallbackValue(MockPosition());
      registerFallbackValue(MockLatLng());
      placeRepository = MockPlaceRepository();
      feature = MockFeatureEntity();
      when(() => feature.placeName).thenReturn('placeName');
      when(() => feature.text).thenReturn('text');
      when(() => feature.id).thenReturn('placeId');
      when(() => feature.center).thenReturn(LatLng(1.0, 2.0));
      placesCubit = PlacesCubit(placeRepository);
      position = MockPosition();
      when(() => position.latitude).thenReturn(0.0);
      when(() => position.longitude).thenReturn(0.0);
    });

    test('emits [] when nothing is called', () {
      expect(placesCubit.state, []);
    });

    blocTest<PlacesCubit, List<Place>>(
      'valid query',
      setUp: () {
        when(() => placeRepository.searchNearbyPlaces(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => [feature]);
      },
      build: () => placesCubit,
      act: (placesCubit) => placesCubit.searchNearbyPlaces(
        'valid query',
        position,
        100,
      ),
      expect: () => [
        [
          Place(
            id: feature.id,
            title: feature.text,
            address: feature.placeName,
            location: feature.center,
          ),
        ],
      ],
    );
    blocTest<PlacesCubit, List<Place>>(
      'invalid query',
      setUp: () {
        when(() => placeRepository.searchNearbyPlaces(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => []);
      },
      build: () => placesCubit,
      act: (placesCubit) => placesCubit.searchNearbyPlaces(
        'invalid query',
        position,
        100,
      ),
      expect: () => [
        <Place>[],
      ],
    );
  });
}
