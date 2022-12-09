import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/profile/profile_cubit.dart';
import 'package:verifi/models/pfp.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/repositories.dart';

import '../mocks/hydrated_storage.dart';

class MockWifiRepository extends Mock implements AccessPointRepository {}

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockUserLocationRepository extends Mock
    implements UserLocationRepository {}

class MockPosition extends Mock implements Position {}

class MockImageProvider extends Mock implements ImageProvider {}

class MockGeoPoint extends Mock implements GeoPoint {}

void main() {
  initHydratedStorage();

  group('Profile', () {
    late GeoPoint geoPoint;
    late Position position;
    late ProfileCubit profileCubit;
    late AccessPointRepository wifiRepository;
    late UserLocationRepository userLocationRepository;
    late UserProfileRepository userProfileRepository;
    late Profile testProfile;
    setUp(() {
      geoPoint = MockGeoPoint();
      position = MockPosition();
      wifiRepository = MockWifiRepository();
      userLocationRepository = MockUserLocationRepository();
      userProfileRepository = MockUserProfileRepository();
      profileCubit = ProfileCubit(
        userProfileRepository,
        userLocationRepository,
        wifiRepository,
      );
      testProfile = Profile(
        id: 'abcd',
        pfp: Pfp(
          id: 'id',
          name: 'name',
          image: const AssetImage('fake_image'),
          imageBitmap: Uint8List(0),
        ),
        displayName: 'name',
        ethAddress: '0x1234',
        veriPoints: 9001,
        validated: 9002,
        contributed: 9003,
      );
      registerFallbackValue(testProfile);
      registerFallbackValue(geoPoint);
      registerFallbackValue(position);
    });
    test('initial state', () {
      expect(profileCubit.state, const Profile(id: ''));
    });

    test('toJson/fromJson', () {
      expect(
        profileCubit.fromJson(
          profileCubit.toJson(profileCubit.state),
        ),
        profileCubit.state,
      );
    });

    test('getters', () {
      profileCubit.setProfile(testProfile);
      expect(profileCubit.userId, testProfile.id);
      expect(profileCubit.pfp, testProfile.pfp);
      expect(profileCubit.ethAddress, testProfile.ethAddress);
      expect(profileCubit.displayName, testProfile.displayName);
      expect(profileCubit.veriPoints, testProfile.veriPoints);
      expect(profileCubit.validatedCount, testProfile.validated);
      expect(profileCubit.contributedCount, testProfile.contributed);
    });

    test('setters', () {
      profileCubit.setEthAddress(testProfile.ethAddress!);
      expect(profileCubit.ethAddress, testProfile.ethAddress);
      profileCubit.setPfp(testProfile.pfp!);
      expect(profileCubit.pfp, testProfile.pfp);
      profileCubit.setDisplayName(testProfile.displayName!);
      expect(profileCubit.displayName, testProfile.displayName);
    });

    group('updates', () {
      // Pfp
      blocTest<ProfileCubit, Profile>(
        'update pfp',
        setUp: () {
          when(() => userProfileRepository.updatePfp(
                any(),
                testProfile.pfp!,
              )).thenAnswer((_) async => {});
        },
        build: () => profileCubit,
        act: (cubit) => cubit.updatePfp(testProfile.pfp!),
        expect: () => [
          isA<Profile>().having(
            (profile) => profile.pfp,
            'pfp',
            testProfile.pfp,
          ),
        ],
      );
      // Display name
      blocTest<ProfileCubit, Profile>(
        'update displayName',
        setUp: () {
          when(() => userProfileRepository.updateDisplayName(
                any(),
                testProfile.displayName!,
              )).thenAnswer((_) async => {});
        },
        build: () => profileCubit,
        act: (cubit) => cubit.updateDisplayName(testProfile.displayName!),
        expect: () => [
          isA<Profile>().having(
            (profile) => profile.displayName,
            'displayName',
            testProfile.displayName,
          ),
        ],
      );
      // Eth address
      blocTest<ProfileCubit, Profile>(
        'update ethAddress',
        setUp: () {
          when(() => userProfileRepository.updateEthAddress(
                any(),
                testProfile.ethAddress!,
              )).thenAnswer((_) async => {});
        },
        build: () => profileCubit,
        act: (cubit) => cubit.updateEthAddress(testProfile.ethAddress!),
        expect: () => [
          isA<Profile>().having(
            (profile) => profile.ethAddress,
            'ethAddress',
            testProfile.ethAddress,
          ),
        ],
      );
    });

    blocTest<ProfileCubit, Profile>(
      'getProfile',
      setUp: () {
        when(() => userProfileRepository.getProfileById('abcd'))
            .thenAnswer((_) => Stream.value(testProfile));
        when(() => wifiRepository.getNetworkValidatedCount('abcd'))
            .thenAnswer((_) async => 9002);
        when(() => wifiRepository.getNetworkContributionCount('abcd'))
            .thenAnswer((_) async => 9003);
      },
      build: () => profileCubit,
      act: (cubit) => cubit.getProfile('abcd'),
      expect: () => [testProfile],
    );

    test('create Profile', () {
      when(() => userProfileRepository.createProfile(any()))
          .thenAnswer((_) async => {});
      profileCubit.createProfile();
      verify(() => userProfileRepository.createProfile(any())).called(1);
    });

    test('delete profile', () {
      when(() => userProfileRepository.deleteProfile(any()))
          .thenAnswer((_) async => {});
      profileCubit.deleteProfile();
      verify(() => userProfileRepository.deleteProfile(any())).called(1);
    });

    test('createPalletteFromPfp multiavatar', () async {
      profileCubit.setPfp(testProfile.pfp!);
      profileCubit.setDisplayName(testProfile.displayName!);
      final palette = await profileCubit.createPaletteFromPfp();
      expect(palette, isA<PaletteGenerator>());
    });

    test('logout', () {
      profileCubit.setProfile(testProfile);
      profileCubit.logout();
      expect(profileCubit.state, const Profile(id: ''));
    });

    test('Update location', () {
      when(() => userLocationRepository.updateUserLocation(any(), any()))
          .thenAnswer((_) async => {});
      when(() => position.latitude).thenReturn(-1.0);
      when(() => position.longitude).thenReturn(-1.0);
      when(() => geoPoint.latitude).thenReturn(-1.0);
      when(() => geoPoint.longitude).thenReturn(-1.0);
      profileCubit.updateLocation(position);
      verify(() => userLocationRepository.updateUserLocation(
            any(),
            any(),
          )).called(1);
    });
  });
}
