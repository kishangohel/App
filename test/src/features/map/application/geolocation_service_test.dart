import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/map/application/geolocation_service.dart';
import 'package:verifi/src/features/map/data/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../../../test_helper/register_fallbacks.dart';
import '../../../mocks.dart';

void main() {
  GeolocationService makeGeolocationService({
    required AuthenticationRepository authRepository,
    required LocationRepository locationRepository,
    required ProfileRepository profileRepository,
  }) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        locationRepositoryProvider.overrideWithValue(locationRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);
    return container.read(geolocationServiceProvider);
  }

  group(GeolocationService, () {
    setUpAll(() => registerFallbacks());
    late AuthenticationRepository authRepository;
    late LocationRepository locationRepository;
    late ProfileRepository profileRepository;
    setUp(() {
      authRepository = MockAuthRepository();
      locationRepository = MockLocationRepository();
      profileRepository = MockProfileRepository();
    });

    test(
      '''
      When GeolocationService is initialized,
      Then it should listen to
        locationRepositoryProvider.locationServicesStatusUpdates.
      ''',
      () {
        when(() => locationRepository.locationServicesStatusUpdates())
            .thenAnswer((_) => Stream.value(true));
        when(() => locationRepository.isLocationPermitted())
            .thenAnswer((_) => Future.value(false));
        makeGeolocationService(
          authRepository: authRepository,
          locationRepository: locationRepository,
          profileRepository: profileRepository,
        );
        verify(
          () => locationRepository.locationServicesStatusUpdates(),
        ).called(1);
      },
    );

    test(
      '''
      Given the user is signed in, location services are enabled, and user 
         location access is permitted,
      When GeolocationService.startPositionStream is called,
      Then it should update the user's location to the profile repo.
      ''',
      () async {
        when(() => locationRepository.locationServicesStatusUpdates())
            .thenAnswer((_) => Stream.value(true));
        when(() => locationRepository.isLocationPermitted())
            .thenAnswer((_) => Future.value(true));
        when(() => locationRepository.userLocationUpdates())
            .thenAnswer((_) => Stream.value(LatLng(1.0, 1.0)));
        when(() => authRepository.currentUser).thenReturn(MockUser());
        when(() => profileRepository.updateUserLocation(any()))
            .thenAnswer((_) => Future.value());
        makeGeolocationService(
          authRepository: authRepository,
          locationRepository: locationRepository,
          profileRepository: profileRepository,
        );
        await Future.delayed(const Duration(milliseconds: 100));
        verify(
          () => profileRepository.updateUserLocation(any()),
        ).called(1);
      },
    );
  });
}
