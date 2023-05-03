// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../geolocation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geolocationServiceHash() =>
    r'a66fefbc77f730c1090537e9b4848d7dfd4458ad';

/// See also [geolocationService].
@ProviderFor(geolocationService)
final geolocationServiceProvider =
    AutoDisposeProvider<GeolocationService>.internal(
  geolocationService,
  name: r'geolocationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geolocationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GeolocationServiceRef = AutoDisposeProviderRef<GeolocationService>;
String _$currentLocationHash() => r'c0d1bbd642a53478f75e50906a03df628c8230a0';

/// See also [currentLocation].
@ProviderFor(currentLocation)
final currentLocationProvider = AutoDisposeStreamProvider<LatLng>.internal(
  currentLocation,
  name: r'currentLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentLocationRef = AutoDisposeStreamProviderRef<LatLng>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
