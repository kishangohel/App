// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../nearby_users_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbyUsersRepositoryHash() =>
    r'dd02eb1b37d4799895e818e2f530935de0a492f8';

/// See also [nearbyUsersRepository].
@ProviderFor(nearbyUsersRepository)
final nearbyUsersRepositoryProvider = Provider<NearbyUsersRepository>.internal(
  nearbyUsersRepository,
  name: r'nearbyUsersRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyUsersRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NearbyUsersRepositoryRef = ProviderRef<NearbyUsersRepository>;
String _$nearbyUsersWithinRadiusHash() =>
    r'0f78cdf9ddf2b7ddde282389fb8e71d9df2c60be';

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

typedef NearbyUsersWithinRadiusRef
    = AutoDisposeStreamProviderRef<List<UserProfile>>;

/// See also [nearbyUsersWithinRadius].
@ProviderFor(nearbyUsersWithinRadius)
const nearbyUsersWithinRadiusProvider = NearbyUsersWithinRadiusFamily();

/// See also [nearbyUsersWithinRadius].
class NearbyUsersWithinRadiusFamily
    extends Family<AsyncValue<List<UserProfile>>> {
  /// See also [nearbyUsersWithinRadius].
  const NearbyUsersWithinRadiusFamily();

  /// See also [nearbyUsersWithinRadius].
  NearbyUsersWithinRadiusProvider call({
    required LatLng center,
    required double radius,
  }) {
    return NearbyUsersWithinRadiusProvider(
      center: center,
      radius: radius,
    );
  }

  @override
  NearbyUsersWithinRadiusProvider getProviderOverride(
    covariant NearbyUsersWithinRadiusProvider provider,
  ) {
    return call(
      center: provider.center,
      radius: provider.radius,
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
  String? get name => r'nearbyUsersWithinRadiusProvider';
}

/// See also [nearbyUsersWithinRadius].
class NearbyUsersWithinRadiusProvider
    extends AutoDisposeStreamProvider<List<UserProfile>> {
  /// See also [nearbyUsersWithinRadius].
  NearbyUsersWithinRadiusProvider({
    required this.center,
    required this.radius,
  }) : super.internal(
          (ref) => nearbyUsersWithinRadius(
            ref,
            center: center,
            radius: radius,
          ),
          from: nearbyUsersWithinRadiusProvider,
          name: r'nearbyUsersWithinRadiusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nearbyUsersWithinRadiusHash,
          dependencies: NearbyUsersWithinRadiusFamily._dependencies,
          allTransitiveDependencies:
              NearbyUsersWithinRadiusFamily._allTransitiveDependencies,
        );

  final LatLng center;
  final double radius;

  @override
  bool operator ==(Object other) {
    return other is NearbyUsersWithinRadiusProvider &&
        other.center == center &&
        other.radius == radius;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, center.hashCode);
    hash = _SystemHash.combine(hash, radius.hashCode);

    return _SystemHash.finish(hash);
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
