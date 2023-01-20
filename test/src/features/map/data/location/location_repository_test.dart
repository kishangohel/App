import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/map/data/location/geolocator_service.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../../../../test_helper/register_fallbacks.dart';
import '../../../../../test_helper/riverpod_test_helper.dart';
import 'geolocator_service_mock.dart';

class ProfileRepositoryMock extends Mock implements ProfileRepository {}

void main() {
  late GeolocatorServiceMock geolocatorServiceMock;
  late ProfileRepositoryMock profileRepositoryMock;

  void mockGeolocatorService() {
    geolocatorServiceMock = GeolocatorServiceMock();
    addTearDown(geolocatorServiceMock.dispose);
  }

  void mockProfileRepository() {
    profileRepositoryMock = ProfileRepositoryMock();
    when(() => profileRepositoryMock.updateUserLocation(any()))
        .thenAnswer((_) async {});
  }

  setUpAll(() {
    registerFallbacks();
  });

  group('LocationRepository', () {
    riverpodTest<AsyncValue<LatLng>>(
      'does not emit a location if the stream is not initialized',
      providerListenable: locationStreamProvider,
      setUp: () {
        mockGeolocatorService();
        mockProfileRepository();
      },
      overrides: () => [
        geolocatorServiceProvider.overrideWithValue(geolocatorServiceMock),
        profileRepositoryProvider.overrideWithValue(profileRepositoryMock),
      ],
      act: (ProviderContainer container) async {
        await geolocatorServiceMock.dispose();
      },
      expect: [
        const AsyncLoading<LatLng>(),
      ],
    );

    riverpodTest<AsyncValue<LatLng>>(
      'updates the location when it changes and sets the user location to it',
      providerListenable: locationStreamProvider,
      setUp: () {
        mockGeolocatorService();
        mockProfileRepository();
      },
      overrides: () => [
        geolocatorServiceProvider.overrideWithValue(geolocatorServiceMock),
        profileRepositoryProvider.overrideWithValue(profileRepositoryMock),
      ],
      act: (ProviderContainer container) async {
        // Start the location stream
        container.read(locationRepositoryProvider).initLocationStream();
        geolocatorServiceMock.changePosition(lat: 42.1, lon: 10.3);

        // Make sure the stream finishes sending events.
        await geolocatorServiceMock.dispose();
      },
      expect: [
        const AsyncLoading<LatLng>(),
        AsyncData(LatLng(42.1, 10.3)),
      ],
      verify: () {
        verifyInOrder([
          () => profileRepositoryMock.updateUserLocation(LatLng(42.1, 10.3)),
        ]);
        verifyNoMoreInteractions(profileRepositoryMock);
      },
    );
  });
}
