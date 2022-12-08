import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/models/models.dart';

class PfpCluster extends ClusterDataBase {
  static const maxPfpsInSample = 5;
  final List<Pfp> pfpSample;

  PfpCluster({required this.pfpSample});

  PfpCluster.fromPfp(Pfp pfp) : pfpSample = [pfp];

  @override
  PfpCluster combine(covariant PfpCluster data) {
    if (pfpSample.length < maxPfpsInSample) {
      return PfpCluster(
        pfpSample: List.from(pfpSample)
          ..addAll(
            data.pfpSample.take(maxPfpsInSample - pfpSample.length),
          ),
      );
    } else {
      return PfpCluster(pfpSample: pfpSample);
    }
  }
}
