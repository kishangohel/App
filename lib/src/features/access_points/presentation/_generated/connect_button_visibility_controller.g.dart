// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../connect_button_visibility_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectButtonVisibilityControllerHash() =>
    r'f72133b1e01958463beacd9d0540966ba4d3093b';

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

abstract class _$ConnectButtonVisibilityController
    extends BuildlessAutoDisposeAsyncNotifier<bool> {
  late final AccessPoint accessPoint;

  Future<bool> build(
    AccessPoint accessPoint,
  );
}

/// See also [ConnectButtonVisibilityController].
@ProviderFor(ConnectButtonVisibilityController)
const connectButtonVisibilityControllerProvider =
    ConnectButtonVisibilityControllerFamily();

/// See also [ConnectButtonVisibilityController].
class ConnectButtonVisibilityControllerFamily extends Family<AsyncValue<bool>> {
  /// See also [ConnectButtonVisibilityController].
  const ConnectButtonVisibilityControllerFamily();

  /// See also [ConnectButtonVisibilityController].
  ConnectButtonVisibilityControllerProvider call(
    AccessPoint accessPoint,
  ) {
    return ConnectButtonVisibilityControllerProvider(
      accessPoint,
    );
  }

  @override
  ConnectButtonVisibilityControllerProvider getProviderOverride(
    covariant ConnectButtonVisibilityControllerProvider provider,
  ) {
    return call(
      provider.accessPoint,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'connectButtonVisibilityControllerProvider';
}

/// See also [ConnectButtonVisibilityController].
class ConnectButtonVisibilityControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<
        ConnectButtonVisibilityController, bool> {
  /// See also [ConnectButtonVisibilityController].
  ConnectButtonVisibilityControllerProvider(
    this.accessPoint,
  ) : super.internal(
          () => ConnectButtonVisibilityController()..accessPoint = accessPoint,
          from: connectButtonVisibilityControllerProvider,
          name: r'connectButtonVisibilityControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$connectButtonVisibilityControllerHash,
          dependencies: ConnectButtonVisibilityControllerFamily._dependencies,
          allTransitiveDependencies: ConnectButtonVisibilityControllerFamily
              ._allTransitiveDependencies,
        );

  final AccessPoint accessPoint;

  @override
  bool operator ==(Object other) {
    return other is ConnectButtonVisibilityControllerProvider &&
        other.accessPoint == accessPoint;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accessPoint.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  Future<bool> runNotifierBuild(
    covariant ConnectButtonVisibilityController notifier,
  ) {
    return notifier.build(
      accessPoint,
    );
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
