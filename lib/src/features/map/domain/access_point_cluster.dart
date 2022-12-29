import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';

// A cluster displayed on the map.
class AccessPointCluster extends ClusterDataBase {
  final int verified;
  final int unverified;
  final int expired;
  final int total;

  AccessPointCluster({
    this.verified = 0,
    this.unverified = 0,
    this.expired = 0,
  }) : total = verified + unverified + expired;

  factory AccessPointCluster.fromAccessPoint(AccessPoint accessPoint) {
    switch (accessPoint.verifiedStatus) {
      case VerifiedStatus.verified:
        return AccessPointCluster(verified: 1);
      case VerifiedStatus.unverified:
        return AccessPointCluster(unverified: 1);
      case VerifiedStatus.expired:
        return AccessPointCluster(expired: 1);
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
      verified: verified + data.verified,
      unverified: unverified + data.unverified,
      expired: expired + data.expired,
    );
  }
}
