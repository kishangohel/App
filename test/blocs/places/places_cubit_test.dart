import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/blocs/places/places_cubit.dart';
import 'package:verifi/models/place.dart';
import 'package:verifi/repositories/place_repository.dart';

class MockPlaceRepository extends Mock implements PlaceRepository {}

class MockPrediction extends Mock implements Prediction {}

class MockPosition extends Mock implements Position {}

class MockLocation extends Mock implements Location {}

void main() {
  group('PlacesCubit', () {
    late PlaceRepository placeRepository;
    late PlacesCubit placesCubit;
    late Prediction prediction;
    late Position position;

    setUp(() {
      registerFallbackValue(MockPosition());
      registerFallbackValue(MockLocation());
      placeRepository = MockPlaceRepository();
      prediction = MockPrediction();
      when(() => prediction.description).thenReturn('description');
      when(() => prediction.placeId).thenReturn('placeId');
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
            )).thenAnswer((_) async => [prediction]);
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
            name: prediction.description!,
            placeId: prediction.placeId!,
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
