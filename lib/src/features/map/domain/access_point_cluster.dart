import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';

// A cluster displayed on the map.
class AccessPointCluster extends ClusterDataBase {
  List<AccessPoint> accessPoints;
  final int verified;
  final int unverified;
  final int expired;
  final int total;

  AccessPointCluster({
    required this.accessPoints,
    this.verified = 0,
    this.unverified = 0,
    this.expired = 0,
  }) : total = verified + unverified + expired;

  factory AccessPointCluster.fromAccessPoint(AccessPoint accessPoint) {
    switch (accessPoint.verifiedStatus) {
      case VerifiedStatus.verified:
        return AccessPointCluster(
          accessPoints: [accessPoint],
          verified: 1,
        );
      case VerifiedStatus.unverified:
        return AccessPointCluster(
          accessPoints: [accessPoint],
          unverified: 1,
        );
      case VerifiedStatus.expired:
        return AccessPointCluster(
          accessPoints: [accessPoint],
          expired: 1,
        );
    }
  }

  // Combines two clusters, used when building the map clusters which begins
  // from the highest zoom level and moves down zoom levels. When
  // clusters/markers are close enough to be clustered in a lower zoom level
  // a new cluster is formed by combining them (AccessPoints are converted to a
  // cluster and then combined).
  @override
  AccessPointCluster combine(AccessPointCluster data) {
    return AccessPointCluster(
      accessPoints: List.from(accessPoints)..addAll(data.accessPoints),
      verified: verified + data.verified,
      unverified: unverified + data.unverified,
      expired: expired + data.expired,
    );
  }
}
