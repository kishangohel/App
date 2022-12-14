// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String $mapServiceHash() => r'f6f8a95e9e008b95c283c8aac51ccfbc6fc93e98';

/// See also [mapService].
final mapServiceProvider = Provider<MapService>(
  mapService,
  name: r'mapServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : $mapServiceHash,
);
typedef MapServiceRef = ProviderRef<MapService>;
String $mapControllerHash() => r'64b16e3e841f648f85f0b6c74f010204dca088dc';

/// See also [mapController].
final mapControllerProvider = Provider<MapController>(
  mapController,
  name: r'mapControllerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : $mapControllerHash,
);
typedef MapControllerRef = ProviderRef<MapController>;
