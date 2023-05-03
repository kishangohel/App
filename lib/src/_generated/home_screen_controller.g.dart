// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../home_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeScreenControllerHash() =>
    r'ce8713017e3e69e5b14ae2c414116af503be061d';

/// We need to keep track of current page in order to ensure auth token
/// refreshes don't redirect user. By having `initialLocation` in
/// app_router.dart set to the state of this `Notifier`, auth token refreshes
/// won't interrupt the user.
///
/// Copied from [HomeScreenController].
@ProviderFor(HomeScreenController)
final homeScreenControllerProvider =
    NotifierProvider<HomeScreenController, String>.internal(
  HomeScreenController.new,
  name: r'homeScreenControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeScreenControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeScreenController = Notifier<String>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
