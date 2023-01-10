// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_controller.dart';

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

String _$HomeScreenControllerHash() =>
    r'a7bf24c3ea23aabbb098ce534205c607c1f30c92';

/// We need to keep track of current page in order to ensure auth token
/// refreshes don't redirect user. By having `initialLocation` in
/// app_router.dart set to the state of this `Notifier`, auth token refreshes
/// won't interrupt the user.
///
/// Copied from [HomeScreenController].
final homeScreenControllerProvider =
    NotifierProvider<HomeScreenController, String>(
  HomeScreenController.new,
  name: r'homeScreenControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$HomeScreenControllerHash,
);
typedef HomeScreenControllerRef = NotifierProviderRef<String>;

abstract class _$HomeScreenController extends Notifier<String> {
  @override
  String build();
}
